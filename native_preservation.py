"""Check all reviewed native insertions/replacements against the PR base, read-only."""
import argparse
from collections import Counter
import difflib
import json
from pathlib import Path
import re
import subprocess

BUNDLE = Path(__file__).resolve().parent

def run(repo):
    contract = json.loads((BUNDLE / 'NATIVE_CONTRACTS.json').read_text(encoding='utf-8'))
    def git(*args):
        return subprocess.check_output(['git', '-C', str(repo), *args]).decode('utf-8')
    expected = {item['path']: item for item in contract['files']}
    actual = set(git('diff', '--name-only', contract['base'], '--', 'code/').splitlines())
    assert actual == set(expected), ('Changed native paths differ', actual ^ set(expected))
    symbols = re.compile(r'^(/[^\n(]+)(?:\([^\n]*\))?[^\n]*$', re.M)
    def definitions(text):
        return Counter(m[1].strip() for m in symbols.finditer(text))
    hunks = replacements = 0
    for name, entry in expected.items():
        old = git('show', contract['base'] + ':' + name)
        new = (repo / name).read_text(encoding='utf-8')
        assert definitions(old) == definitions(new), ('Native definitions changed', name)
        observed = []
        before, after = old.splitlines(keepends=True), new.splitlines(keepends=True)
        for tag, a, b, c, d in difflib.SequenceMatcher(None, before, after, autojunk=False).get_opcodes():
            if tag == 'equal':
                continue
            assert tag != 'delete' and b-a <= 1, ('Native block deletion/refactor', name, tag, a, b)
            observed.append((''.join(before[a:b]), ''.join(after[c:d])))
            replacements += b-a
        approved = [(h['before'], h['after']) for h in entry['hunks']]
        assert observed == approved, ('Unreviewed native hook or input replacement', name)
        assert all(h['owner'] and h['reason'] for h in entry['hunks'])
        hunks += len(observed)
    middleware = 'code/modules/client/preferences/middleware/jobs.dm'
    assert git('show', contract['base'] + ':' + middleware) == (repo / middleware).read_text(encoding='utf-8')
    return {'status': 'PASS', 'native_files': len(expected), 'hunks': hunks,
            'single_line_replacements': replacements, 'removed_definitions': 0,
            'removed_multiline_blocks': 0, 'native_jobs_middleware': 'exact BASE'}

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', required=True, type=Path)
    args = parser.parse_args()
    print(json.dumps(run(args.repo.resolve()), indent=2))
