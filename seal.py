"""Explicitly seal reviewed replay sources and product inputs; no tests or builds run."""
import argparse
import ast
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import subprocess

BUNDLE = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def git_bytes(repository, *args):
    return subprocess.check_output(['git', '-C', str(repository), *args])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', required=True, type=Path)
    parser.add_argument('--upstream-base', default='820de7f6ef9235d8417250cb01eec15da6735b18')
    args = parser.parse_args()
    repo = args.repo.resolve()
    names = set(filter(None, git_bytes(repo, 'diff', '--name-only', '--no-renames', '-z', args.upstream_base, '--').decode('utf-8').split('\0')))
    names.update(filter(None, git_bytes(repo, 'ls-files', '--others', '--exclude-standard', '-z').decode('utf-8').split('\0')))
    names.update(filter(None, git_bytes(repo, 'ls-files', '-z', '--', 'dependencies.sh', 'tgstation.dme', 'modular_bandastation/modular_bandastation.dme', 'tools/build', 'tools/bootstrap', 'tools/migrate_job_slots', 'tgui/package.json', 'tgui/bun.lock', 'tgui/bun.lockb', 'tgui/tsconfig.json', 'tgui/packages/*/package.json', '.github/workflows/run_linters.yml').decode('utf-8').split('\0')))
    files = []
    for name in sorted(names):
        path = (repo / name).resolve()
        if not path.is_relative_to(repo):
            raise RuntimeError(f'Unsafe product input: {name}')
        files.append({'path': name, 'sha256': digest(path) if path.is_file() else None})
    patch = git_bytes(repo, 'diff', '--binary', 'HEAD', '--')
    write_json(BUNDLE / 'SOURCE_INPUTS.json', {
        'schema': 1, 'sealed_utc': datetime.now(timezone.utc).isoformat(),
        'upstream_base': args.upstream_base,
        'source_head_at_seal': git_bytes(repo, 'rev-parse', 'HEAD').decode().strip(),
        'source_patch_sha256_at_seal': hashlib.sha256(patch).hexdigest(),
        'files': files,
        'scope': 'All PR paths changed/deleted against upstream base, nonignored untracked files and explicit build/bootstrap/migration/lock inputs. Full HEAD/patch/untracked bytes are captured separately at replay.',
    })
    provenance_path = BUNDLE / 'provenance.json'
    provenance = json.loads(provenance_path.read_text(encoding='utf-8'))
    provenance['support_adaptations'] = [
        {'path': 'client_fixture_adapter.py', 'source': 'preserve-native external input adapter', 'changes': ['Five exact TEMP substitutions/six reads bridge only mock prefs/history/account age input; full source hashes/counts/scopes checked before writes. Constructor, real-client admission and consumers unchanged; never used by production/native compile.']},
        {'path': 'native_preservation.py', 'source': 'preserve-native reviewed native contract', 'changes': ['All native definitions and multiline blocks retained; every current native insertion/single-line replacement reviewed with owner and reason in NATIVE_CONTRACTS.json. Read-only BASE comparison before TEMP overlays.']},
        {'path': 'source_invariants.py', 'source': 'task_state/20261016-pr11-contract-cleanup/source_invariants.py',
         'changes': ['Portable default checkout is cwd; explicit --repo, --migration and --old-ref remain supported. No invariant changed.']},
        {'path': 'run.py', 'source': 'baseline/run.py', 'changes': [
            'Portable settings-relative dependency paths; explicit isolated artifacts; no local.json or machine paths.',
            'Reviewed tracked/untracked source bytes captured exactly; source integrity checked in finally.',
            'Four independent flag modes 00/01/10/11 and expected startup markers; baseline policy assertions retained.',
            'Late module-constant helpers and all unique tests focused only in TEMP; removed private continuation fixtures replaced by real public operations.',
            'Static bundle/source binding verification, manifest hashes and support inventory; no runtime execution on import.',
            'Before any TEMP overlay, native_preservation checks every code/ hunk against NATIVE_CONTRACTS.json; canonical mode never stages external tests.',
            'Only after unadapted canonical compile, stage_tests applies the exact hash/scope/count guarded client_fixture_adapter; its inventory is recorded.',
            'Final cleanup: Bun timeout is explicitly bounded at 30000ms after the unchanged subprocess-output regression exceeded the default 5000ms on Windows. Assertions and product build helper remain unchanged.']},
    ]
    test_files = []
    dm_names, python_count, bun_count = [], 0, 0
    for record in provenance['test_files']:
        path = BUNDLE / 'overlay' / record['destination']
        text = path.read_text(encoding='utf-8')
        dm = re.findall(r'^/datum/unit_test/(.+)/Run\(', text, re.MULTILINE) if path.suffix == '.dm' else []
        python_methods = []
        if path.suffix == '.py':
            python_methods = [node.name for node in ast.walk(ast.parse(text)) if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)) and node.name.startswith('test_')]
            python_count += len(python_methods)
        if path.name.endswith('.test.js'):
            bun_count += len(re.findall(r'^test\(', text, re.MULTILINE))
        record['adapted_sha256'] = digest(path)
        test_files.append({'path': record['destination'], 'sha256': digest(path), 'lines': len(text.splitlines()), 'dm_names': dm, 'python_methods': python_methods})
        dm_names += dm
    if len(dm_names) != len(set(dm_names)):
        raise RuntimeError('Duplicate DM tests')
    write_json(provenance_path, provenance)
    excluded = {'manifest.json', 'settings.json'}
    support = {}
    for path in sorted(BUNDLE.rglob('*')):
        if not path.is_file():
            continue
        relative = path.relative_to(BUNDLE).as_posix()
        if relative in excluded or relative.startswith(('overlay/', 'browser/dist/', 'browser/runtime/', '__pycache__/')):
            continue
        if relative.startswith('browser/') and path.name.startswith(('source-binding', 'RESULT', 'SUMMARY')):
            continue
        support[relative] = digest(path)
    manifest = {
        'schema': 2, 'head': provenance['baseline_head'],
        'upstream_base': args.upstream_base,
        'reviewed_source_head': git_bytes(repo, 'rev-parse', 'HEAD').decode().strip(),
        'test_files': test_files, 'dm_names': sorted(dm_names), 'dm_count': len(dm_names),
        'python_count': python_count, 'bun_count': bun_count,
        'flag_modes': ['00', '01', '10', '11'],
        'adaptations': provenance['test_files'], 'bundle_files': support,
        'execution_status_at_seal': 'PREPARED_NOT_RUN',
    }
    write_json(BUNDLE / 'manifest.json', manifest)
    print(json.dumps({'status': 'SEALED', 'manifest_sha256': digest(BUNDLE / 'manifest.json'),
                      'test_files': len(test_files), 'dm_count': len(dm_names),
                      'python_count': python_count, 'bun_count': bun_count,
                      'source_inputs': len(files), 'support_files': len(support)}, indent=2))


if __name__ == '__main__':
    main()
