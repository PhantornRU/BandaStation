from pathlib import Path
import sys,json,hashlib,datetime
if len(sys.argv)<3:
    raise SystemExit('Usage: bind_sources.py PRODUCTION_SOURCE CHECKOUT_ROOT [before|final]')
prod=Path(sys.argv[1]).resolve()
root=Path(sys.argv[2]).resolve()
temp=Path(__file__).resolve().parent
stage=sys.argv[3] if len(sys.argv)>3 else 'before'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
paths=set()
for folder in ['tgui/packages/tgui/bandastation/donor_jobs','tgui/packages/tgui/bandastation/jobs','tgui/packages/tgui/bandastation/job_slots_preferences']:
    for path in (prod/folder).rglob('*'):
        if path.is_file() and path.suffix in ('.ts','.tsx'):
            paths.add(path.relative_to(prod).as_posix())
paths.update(['tgui/packages/tgui/interfaces/JobSelection.tsx','tgui/packages/tgui/interfaces/PreferencesMenu/types.ts','tgui/packages/tgui/interfaces/PreferencesMenu/useServerPrefs.ts','tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/JobsPage.tsx','tgui/packages/tgui/interfaces/PreferencesMenu/CharacterPreferences/JobSlotDropdown.tsx','tgui/packages/tgui/styles/interfaces/PreferencesMenu.scss','tgui/packages/tgui/styles/bandastation/donor_jobs.scss','tgui/packages/tgui/styles/bandastation/job_variants.scss','tgui/packages/tgui/styles/bandastation/job_hud_icon.scss','tgui/packages/tgui/styles/main.scss','tgui/rspack.config.ts'])
hashes={path:sha(prod/path) for path in sorted(paths)}
for path,value in hashes.items():
    assert sha(root/path)==value,('production source mismatch',path)
deleted=['tgui/packages/tgui/bandastation/donor_jobs/JobList.tsx','tgui/packages/tgui/bandastation/donor_jobs/JobLabel.tsx','tgui/packages/tgui/bandastation/donor_jobs/JobHudIcon.tsx']
for path in deleted:
    assert not (prod/path).exists() and not (root/path).exists(),('old source remains',path)
css=prod/'tgui/public/tgui.bundle.css'
assert css.is_file()
data={'kind':'source/CSS binding; synthetic backend','verified_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'root':root.as_posix(),'production_source':prod.as_posix(),'component_sources':hashes,'removed_sources_absent':deleted,'css':{'path':css.as_posix(),'bytes':css.stat().st_size,'sha256':sha(css)},'harness':{name:sha(temp/name) for name in ['browser.tsx','browser-checks.js','serve.ts','data.json','dist/browser.js']}}
if stage!='before':
    before=json.loads((temp/'source-binding-before.json').read_text(encoding='utf-8'))
    for key in ['production_source','component_sources','removed_sources_absent','css','harness']:
        assert data[key]==before[key],('changed during browser',key)
(temp/f'source-binding-{stage}.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'binding':stage,'component_count':len(hashes),'css':data['css'],'source_unchanged':True}))
