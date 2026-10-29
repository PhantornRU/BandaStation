SAN FRANCISCO IMPORT AND CHECKS

Python 3.12+, Git and the repository's tools/requirements.txt are required for
import tools. BYOND 516.1685 is required for the Windows launcher and focused
integration tests. Run these commands from the target repository root:

  python -m pip install -r tools/requirements.txt
  git clone https://github.com/Monkestation/crimson-grid <donor-directory>
  git -C <donor-directory> checkout 483ef4772fe4957027c8e2f290cd1503b2b237f5

Pass the absolute or relative path to that donor checkout with --source.
Import tools reject a different HEAD before writing files. Use a clean donor
checkout with the source map, DM sources and required DMI available; a sparse
checkout must include those files. The target is always the repository
containing these scripts, regardless of its directory name or current working
directory. Python dependencies come from tools/requirements.txt. Type inventory
is read directly from the donor DMM; no external research or audit files exist.

Read-only checks (the resource checker prints JSON to standard output):

  python tools/san_francisco/port_city.py coverage --source <donor-directory>
  python tools/san_francisco/check_decor_resources.py
  python tools/san_francisco/check_decor_resources.py --source <donor-directory>

The resource checker verifies every imported DMI against the checked-in
provenance manifest, PNG structure and static architecture/decor states.
--source additionally compares the exact bytes against the pinned donor.
Runtime overlays, worn sprites and map initialization are covered by:

  powershell -NoProfile -File tools/san_francisco/test-city.ps1

# AI EDIT START - Document the extended native compatibility checks
Fifteen test groups cover city initialization, movement-grid compatibility,
real passage travel, native creation/deletion and equipment icons. Native
emissive validation is also enabled. The map is excluded from the generic
station CI matrix until station shuttle routes are integrated. Test logs and
isolated runtime files are written under tmp/ and must not be committed.
# AI EDIT END

Maintainer generation commands overwrite the named generated outputs. Run them
on a branch and review the diff; no generation is needed to play the checked-in
map. Technical bindings and manually maintained adapters remain under review.

  python tools/san_francisco/build_decor.py --source <donor-directory>
  python tools/san_francisco/port_city.py equipment --source <donor-directory>
  python tools/san_francisco/port_city.py convert --source <donor-directory>

build_decor writes decor adapters and bindings, required mannequin clothing,
copied assets/attribution and donor wording in walls/turfs. equipment writes
clothing adapters and bindings. convert writes the city DMM, its map JSON,
core bindings, native spawn report and UpdatePaths rules. It does not change
config/maps.txt or data/next_map.json; selecting the city for a local run is
the launcher's responsibility. Imported icons should retain their recorded
bytes; reconcile provenance.json when intentionally changing the imported set.

Local play on Windows:

  powershell -NoProfile -File tools/san_francisco/start-local.ps1
  powershell -NoProfile -File tools/san_francisco/start-local.ps1 -AdminKey YourCkey
  powershell -NoProfile -File tools/san_francisco/stop-local.ps1

The default creates no personal admin entry. The native localhost rank remains
enabled. -ByondBin can select a nonstandard BYOND installation. The launcher
keeps configuration, saves and logs under its own tmp/ deployment.
