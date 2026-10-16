"""Run PR11 regressions in a new TEMP worktree from HEAD or an explicit tracked/untracked worktree snapshot."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

import native_preservation
from client_fixture_adapter import apply as apply_client_fixture_adapter

BUNDLE = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def git(repository, *args):
    return subprocess.check_output(['git', '-C', str(repository), *args], text=True).strip()


def git_bytes(repository, *args):
    return subprocess.check_output(['git', '-C', str(repository), *args])


def execute(command, cwd, log, env):
    print(f'Running {command[0]} {" ".join(command[1:])}', flush=True)
    with log.open('w', encoding='utf-8') as output:
        result = subprocess.run(command, cwd=cwd, env=env, stdout=output,
                                stderr=subprocess.STDOUT, creationflags=subprocess.CREATE_NO_WINDOW)
    print(f'Exit {result.returncode}; log: {log}', flush=True)
    if result.returncode:
        raise RuntimeError(f'Command failed ({result.returncode}); see {log}')


def stage_tests(worktree, manifest):
    for item in manifest['test_files']:
        destination = (worktree / item['path']).resolve()
        if not destination.is_relative_to(worktree) or destination.exists():
            raise RuntimeError(f'Test overlay would overwrite a product file: {item["path"]}')
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(BUNDLE / 'overlay' / item['path'], destination)
    fixture_adaptations = list(manifest["adaptations"])
    fixture_adaptations.append({"TEMP_mock_input_adapter": apply_client_fixture_adapter(worktree)})
    unit_file = worktree / 'code/modules/unit_tests/_unit_tests.dm'
    contents = unit_file.read_text(encoding='utf-8')
    anchor = '#undef TEST_ASSERT\n'
    if contents.count(anchor) != 1 or 'BANDASTATION EDIT - Donor jobs tests' in contents:
        raise RuntimeError('Native assertion/include anchor changed; review the external adapter')
    unit_file.write_text(contents.replace(anchor, (BUNDLE / 'includes.dm').read_text(encoding='utf-8') + anchor),
                         encoding='utf-8', newline='\n')
    dme = worktree / 'tgstation.dme'
    focus = '\n#ifdef UNIT_TESTS\n' + (BUNDLE / 'late_includes.dm').read_text(encoding='utf-8') + ''.join(
        f'TEST_FOCUS(/datum/unit_test/{name})\n' for name in manifest['dm_names']) + '#endif\n'
    with dme.open('ab') as output:
        output.write(focus.encode('utf-8'))
    return fixture_adaptations


def isolate_bootstrap_log(worktree):
    # Upstream starts two Python generators concurrently, but both open the same
    # Windows log with an exclusive writer. Keep this environment adjustment
    # exclusively in our TEMP checkout; no build/product logic is replaced.
    bootstrap = worktree / 'tools/bootstrap/python_.ps1'
    contents = bootstrap.read_text(encoding='utf-8')
    original = '$Log = "$Cache/last-command.log"'
    if contents.count(original) != 1:
        raise RuntimeError('Bootstrap logging changed; review the external environment adapter')
    bootstrap.write_text(contents.replace(original, '$Log = "$Cache/last-command-$PID.log"'),
                         encoding='utf-8', newline='\n')


def seed_cutter(worktree, settings):
    source = Path(settings['cutter'])
    if digest(source).lower() != settings['cutter_sha256'].lower():
        raise RuntimeError('Pinned Cutter hash changed')
    version = re.search(r'^export CUTTER_VERSION=(\S+)$',
                        (worktree / 'dependencies.sh').read_text(), re.MULTILINE).group(1)
    name = 'hypnagogic' + version.replace('.', '-') + '.exe'
    if source.name != name:
        raise RuntimeError('Checkout requires another Cutter; update the external dependency')
    target = worktree / 'tools/icon_cutter/cache' / name
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, target)


def native_runtime(worktree, run_root, artifacts, mode, settings, manifest, env):
    runtime = run_root / ('runtime-' + mode)
    runtime.mkdir()
    for folder in ('_maps', 'build', 'code', 'icons', 'modular_bandastation', 'sound', 'strings', 'tgui'):
        # Use Windows directory junctions so an administrator symlink privilege is not required.
        # Only newly created destinations inside our TEMP directory are used.
        link, target = str(runtime / folder), str(worktree / folder)
        quote = lambda value: "'" + value.replace("'", "''") + "'"
        command = f'New-Item -ItemType Junction -Path {quote(link)} -Target {quote(target)} | Out-Null'
        subprocess.run(['powershell.exe', '-NoProfile', '-Command', command], check=True,
                       creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL)
    (runtime / 'config').mkdir()
    (runtime / 'data').mkdir()
    jobs_enabled, prisoner_gate = int(mode[0]), int(mode[1])
    flags = '\n' + ('DONOR_JOBS_ENABLED\n' if jobs_enabled else '') + ('DONOR_PRISONER_GATE\n' if prisoner_gate else '')
    (runtime / 'config/config.txt').write_text('# Isolated external regressions' + flags, encoding='utf-8')
    map_root = worktree / '_maps/map_jsons'
    maps = []
    for map_file in sorted(map_root.glob('*.json'), key=lambda path: str(path)):
        if not json.loads(map_file.read_text(encoding='utf-8-sig')).get('exclude_from_ci', False):
            maps.extend(['map ' + map_file.stem, 'endmap'])
    (runtime / 'config/maps.txt').write_text('\n'.join(maps) + '\n', encoding='utf-8')
    shutil.copyfile(map_root / 'runtimestation_minimal.json', runtime / 'data/next_map.json')
    for name in ('tgstation.dmb', 'tgstation.rsc'):
        shutil.copyfile(artifacts / name, runtime / name)
    dll_hashes = {}
    for name in ('rust_g.dll', 'librust_utils.dll'):
        source = Path(settings['runtime_dlls']) / name
        actual = digest(source)
        if actual.lower() != settings['dll_sha256'][name].lower():
            raise RuntimeError(f'Configured runtime library changed: {name}')
        shutil.copyfile(source, runtime / name)
        dll_hashes[name] = actual
    execute([str(Path(settings['byond_bin']) / 'dd.exe'), 'tgstation.dmb', '-close', '-trusted', '-verbose',
             '-params', f'log-directory=external-tests&pr11-jobs-flag={jobs_enabled}&pr11-prisoner-flag={prisoner_gate}'], runtime, runtime / 'DreamDaemon.log', env)
    results = json.loads((runtime / 'data/unit_tests.json').read_text(encoding='utf-8-sig'))
    wanted = {'/datum/unit_test/' + name for name in manifest['dm_names']}
    if set(results) != wanted or any(result['status'] != 0 for result in results.values()):
        raise RuntimeError(f'Native test names/status differ; see {runtime / "data/unit_tests.json"}')
    clean = (runtime / 'data/logs/external-tests/clean_run.lk').is_file()
    if not clean:
        raise RuntimeError(f'Native runtime did not finish cleanly: {runtime}')
    print(f'DM {mode}: {len(results)}/{len(wanted)} PASS; clean_run', flush=True)
    return {'passed': len(results), 'clean_run': clean, 'map': 'runtimestation_minimal',
            'startup_flags': {'donor_jobs_enabled': jobs_enabled, 'donor_prisoner_gate': prisoner_gate}, 'dll_sha256': dll_hashes, 'runtime': str(runtime)}


def capture_untracked(repository):
    names = git_bytes(repository, 'ls-files', '--others', '--exclude-standard', '-z').decode('utf-8').split('\0')
    result = {}
    for name in sorted(filter(None, names)):
        path = (repository / name).resolve()
        if not path.is_relative_to(repository) or not path.is_file():
            raise RuntimeError(f'Unsafe/unreadable untracked input: {name}')
        result[name] = path.read_bytes()
    return result


def verify_bundle():
    manifest = json.loads((BUNDLE / 'manifest.json').read_text(encoding='utf-8-sig'))
    expected = {item['path'] for item in manifest['test_files']}
    actual = {p.relative_to(BUNDLE / 'overlay').as_posix() for p in (BUNDLE / 'overlay').rglob('*') if p.is_file()}
    if expected != actual:
        raise RuntimeError(f'Overlay inventory mismatch: missing={expected-actual}; extra={actual-expected}')
    names = []
    for item in manifest['test_files']:
        path = (BUNDLE / 'overlay' / item['path']).resolve()
        if not path.is_relative_to(BUNDLE / 'overlay') or digest(path) != item['sha256']:
            raise RuntimeError(f'External fixture bytes changed: {item["path"]}')
        if path.suffix == '.dm':
            found = re.findall(r'^/datum/unit_test/(.+)/Run\(', path.read_text(encoding='utf-8'), re.MULTILINE)
            if found != item['dm_names']:
                raise RuntimeError(f'DM test inventory changed: {item["path"]}')
            names += found
    if len(names) != len(set(names)) or sorted(names) != manifest['dm_names'] or len(names) != manifest['dm_count']:
        raise RuntimeError('Duplicate/missing DM test names')
    for relative, expected_hash in manifest['bundle_files'].items():
        path = (BUNDLE / relative).resolve()
        if not path.is_relative_to(BUNDLE) or digest(path) != expected_hash:
            raise RuntimeError(f'Bundle support input changed: {relative}')
    return manifest


def verify_source_inputs(repository):
    binding = json.loads((BUNDLE / 'SOURCE_INPUTS.json').read_text(encoding='utf-8'))
    for item in binding['files']:
        target = (repository / item['path']).resolve()
        if not target.is_relative_to(repository):
            raise RuntimeError(f'Unsafe source binding path: {item["path"]}')
        actual = digest(target) if target.is_file() else None
        if actual != item['sha256']:
            raise RuntimeError(f'Source differs from reviewed bundle inputs: {item["path"]}')


def main():
    default_settings = BUNDLE / 'settings.json'
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--settings', type=Path, default=default_settings)
    parser.add_argument('--repository', type=Path)
    parser.add_argument('--suite', choices=('all', 'canonical', 'production', 'native', 'dm', 'python', 'bun'), default='all')
    parser.add_argument('--artifacts', type=Path, help='Parent directory for a new isolated run; defaults to the OS TEMP directory')
    parser.add_argument('--include-worktree', action='store_true',
                        help='Capture tracked and untracked product bytes on HEAD in the isolated TEMP worktree')
    parser.add_argument('--verify-bundle', action='store_true', help='Verify portable artifact hashes and test inventory without dependencies, checkout or execution')
    args = parser.parse_args()
    manifest = verify_bundle()
    if args.verify_bundle:
        print(json.dumps({'status': 'PASS', 'bundle_only': True, 'dm_count': manifest['dm_count'], 'python_count': manifest['python_count'], 'bun_count': manifest['bun_count']}, indent=2))
        return 0
    if os.name != 'nt':
        parser.error('Build/runtime replay requires Windows; artifact verification is portable')
    if not args.settings.is_file():
        parser.error('Provide --settings; copy settings.example.json and configure local dependencies first')
    settings_file = args.settings.resolve()
    settings = json.loads(settings_file.read_text(encoding='utf-8-sig'))
    for key in ('repository', 'byond_bin', 'bootstrap_cache', 'runtime_dlls', 'cutter'):
        value = Path(settings[key]).expanduser()
        settings[key] = str((settings_file.parent / value).resolve() if not value.is_absolute() else value.resolve())
    repository = (args.repository or Path(settings['repository'])).resolve()
    verify_source_inputs(repository)
    source_head = git(repository, 'rev-parse', 'HEAD')
    source_status = git_bytes(repository, 'status', '--porcelain=v1', '--untracked-files=all')
    source_patch = git_bytes(repository, 'diff', '--binary', 'HEAD', '--')
    untracked = capture_untracked(repository)
    if source_status and not args.include_worktree:
        parser.error('Use --include-worktree to test the current tracked changes without a commit')
    if args.artifacts:
        args.artifacts.mkdir(parents=True, exist_ok=True)
    run_root = Path(tempfile.mkdtemp(prefix='bandastation-external-tests-', dir=args.artifacts)).resolve()
    worktree = run_root / 'source'
    patch_file = run_root / 'source-worktree.patch'
    patch_file.write_bytes(source_patch)
    env = dict(os.environ, DM_EXE=str(Path(settings['byond_bin']) / 'dm.exe'),
               TG_BOOTSTRAP_CACHE=settings['bootstrap_cache'], PYTHONDONTWRITEBYTECODE='1')
    report = {'source_head': source_head, 'source_status': source_status.decode('utf-8', errors='replace'),
              'include_worktree': args.include_worktree,
              'source_status_sha256': hashlib.sha256(source_status).hexdigest(),
              'source_patch_sha256': hashlib.sha256(source_patch).hexdigest(),
              'source_patch_bytes': len(source_patch), 'source_patch_file': str(patch_file),
              'snapshot_applied_exactly': False,
              'original_tests_head': manifest['head'],
              'bundle_manifest_sha256': digest(BUNDLE / 'manifest.json'),
              'source_untracked_sha256': {name: hashlib.sha256(data).hexdigest() for name, data in untracked.items()},
              'run_root': str(run_root), 'suite': args.suite, 'results': {},
              'started_utc': datetime.now(timezone.utc).isoformat(), 'status': 'RUNNING'}
    print(f'Source HEAD: {source_head}\nIsolated artifacts: {run_root}', flush=True)
    try:
        if (git(repository, 'rev-parse', 'HEAD') != source_head or
                git_bytes(repository, 'status', '--porcelain=v1', '--untracked-files=all') != source_status or
                git_bytes(repository, 'diff', '--binary', 'HEAD', '--') != source_patch or
                capture_untracked(repository) != untracked):
            raise RuntimeError('Source checkout changed while its snapshot was being captured')
        execute(['git', '-C', str(repository), 'worktree', 'add', '--detach', str(worktree), source_head],
                repository, run_root / 'checkout.log', env)
        if source_patch:
            execute(['git', '-C', str(worktree), 'apply', '--index', str(patch_file)],
                    worktree, run_root / 'worktree-patch.log', env)
        for relative, data in untracked.items():
            target = (worktree / relative).resolve()
            if not target.is_relative_to(worktree) or target.exists():
                raise RuntimeError(f'Untracked snapshot destination is unsafe: {relative}')
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
        # Untracked fixture/product inputs are captured explicitly, never staged in the source checkout.
        report['source_patch_applied'] = bool(source_patch)
        staged_patch = git_bytes(worktree, 'diff', '--cached', '--binary', 'HEAD', '--')
        working_patch = git_bytes(worktree, 'diff', '--binary', '--')
        report['snapshot_applied_exactly'] = staged_patch == source_patch and not working_patch and capture_untracked(worktree) == untracked
        report['snapshot_staged_patch_sha256'] = hashlib.sha256(staged_patch).hexdigest()
        if not report['snapshot_applied_exactly']:
            raise RuntimeError('TEMP index or tracked working tree differs from the captured source snapshot')
        report['results']['native_preservation'] = native_preservation.run(worktree)
        if args.suite in ('all', 'canonical', 'production', 'native', 'dm'):
            isolate_bootstrap_log(worktree)
            seed_cutter(worktree, settings)
            report['temp_environment_adjustment'] = 'python bootstrap: per-process log name to avoid Windows writer collision'
            report['cutter_sha256'] = settings['cutter_sha256']
        build = str(worktree / 'tools/build/build.bat')
        if args.suite in ('all', 'canonical', 'production'):
            execute([build, 'build', '-Werror'], worktree, run_root / 'production.log', env)
            artifacts = run_root / 'production-artifacts'
            artifacts.mkdir()
            for name in ('tgstation.dmb', 'tgstation.rsc'):
                shutil.copyfile(worktree / name, artifacts / name)
            report['results']['production'] = {'command': 'tools/build/build.bat build -Werror',
                'dmb_sha256': digest(artifacts / 'tgstation.dmb'), 'dme_sha256': digest(worktree / 'tgstation.dme'),
                'external_tests_injected': False}
        if args.suite in ('all', 'canonical', 'native'):
            execute([build, 'dm', '-DCIBUILDING', '-Werror', '-ITG0001', '-Iloop_checks'],
                     worktree, run_root / 'native-harness-compile.log', env)
            report['results']['native_harness_compile'] = {
                'external_tests_injected': False, 'dmb_sha256': digest(worktree / 'tgstation.dmb')}
        if args.suite not in ('canonical', 'production', 'native'):
            report['test_fixture_adaptations'] = stage_tests(worktree, manifest)
        if args.suite in ('all', 'python'):
            execute([sys.executable, '-B', '-m', 'unittest', 'discover', '-s',
                     'tools/migrate_job_slots/tests', '-v'], worktree, run_root / 'python.log', env)
            output = (run_root / 'python.log').read_text(encoding='utf-8', errors='replace')
            if not re.search(rf'Ran {manifest["python_count"]} tests', output):
                raise RuntimeError('Unexpected Python test count')
            report['results']['python'] = {'passed': manifest['python_count']}
        if args.suite in ('all', 'bun'):
            execute([str(worktree / 'tools/bootstrap/javascript.bat'), 'test', '--timeout', '30000', 'tools/build/juke/exec.test.js'],
                     worktree, run_root / 'bun.log', env)
            report['results']['bun'] = {'passed': manifest['bun_count']}
        if args.suite in ('all', 'dm'):
            execute([build, 'dm', '-DCIBUILDING', '-Werror', '-ITG0001', '-Iloop_checks'],
                     worktree, run_root / 'dm-compile.log', env)
            artifacts = run_root / 'dm-artifacts'
            artifacts.mkdir()
            for name in ('tgstation.dmb', 'tgstation.rsc'):
                shutil.copyfile(worktree / name, artifacts / name)
            report['results']['dm_compile'] = {'dmb_sha256': digest(artifacts / 'tgstation.dmb')}
            for mode in ('00', '01', '10', '11'):
                report['results']['dm_' + mode] = native_runtime(
                    worktree, run_root, artifacts, mode, settings, manifest, env)
        report['status'] = 'PASS'
    except Exception as error:
        report['status'] = 'FAIL'
        report['error'] = str(error)
        raise
    finally:
        final_head = git(repository, 'rev-parse', 'HEAD')
        final_status = git_bytes(repository, 'status', '--porcelain=v1', '--untracked-files=all')
        final_patch = git_bytes(repository, 'diff', '--binary', 'HEAD', '--')
        report['source_integrity'] = {
            'head_unchanged': final_head == source_head,
            'status_unchanged': final_status == source_status,
            'patch_bytes_unchanged': final_patch == source_patch,
            'untracked_bytes_unchanged': capture_untracked(repository) == untracked,
            'final_patch_sha256': hashlib.sha256(final_patch).hexdigest(),
        }
        report['source_checkout_unchanged'] = all(
            report['source_integrity'][key] for key in ('head_unchanged', 'status_unchanged', 'patch_bytes_unchanged', 'untracked_bytes_unchanged'))
        if not report['source_checkout_unchanged']:
            report['status'] = 'FAIL'
        report['finished_utc'] = datetime.now(timezone.utc).isoformat()
        (run_root / 'RESULT.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
        print(f'{report["status"]}; source unchanged: {report["source_checkout_unchanged"]}; {run_root / "RESULT.json"}', flush=True)
    return 0 if report['status'] == 'PASS' else 1


if __name__ == '__main__':
    sys.exit(main())
