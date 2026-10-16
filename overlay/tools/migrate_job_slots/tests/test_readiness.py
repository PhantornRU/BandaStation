"""Deployment readiness checks use isolated temporary saves only."""

from contextlib import redirect_stderr, redirect_stdout
import io
import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import migrate


class ReadinessTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="job-slot-readiness-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name) / "player_saves"
        self.source = self.root / "a" / "alice" / "preferences.json"
        self.source.parent.mkdir(parents=True)
        self.document = {
            "version": migrate.SAVEFILE_VERSION_MAX,
            "default_slot": 1,
            "job_assigned_profiles": {"Cargo Technician": 2},
            "character1": {"real_name": "Fixture"},
        }
        self.save(self.document)

    def save(self, document):
        self.source.write_text(json.dumps(document), encoding="utf-8")

    def run_gate(self, *extra):
        output = io.StringIO()
        with redirect_stdout(output), redirect_stderr(output):
            result = migrate.main([str(self.root), "--check-ready", *extra])
        return result, output.getvalue()

    def test_legacy_files_block_deployment_without_any_write(self):
        before = self.source.read_bytes()
        before_mtime = self.source.stat().st_mtime_ns
        result, output = self.run_gate()
        self.assertEqual(result, 1)
        self.assertIn("READY_CHECK examined=1 changed=1 unchanged=0 errors=0", output)
        self.assertEqual(self.source.read_bytes(), before)
        self.assertEqual(self.source.stat().st_mtime_ns, before_mtime)
        self.assertEqual(list(self.source.parent.iterdir()), [self.source])

    def test_plain_dry_run_keeps_its_original_exit_code(self):
        before = self.source.read_bytes()
        with redirect_stdout(io.StringIO()):
            self.assertEqual(migrate.main([str(self.root)]), 0)
        self.assertEqual(self.source.read_bytes(), before)

    def test_converted_files_allow_deployment(self):
        self.save(migrate.migrate_job_slots(self.document))
        before = self.source.read_bytes()
        self.assertEqual(self.run_gate()[0], 0)
        self.assertEqual(self.source.read_bytes(), before)

    def test_malformed_data_blocks_deployment(self):
        self.source.write_bytes(b"{not-json")
        self.assertEqual(self.run_gate()[0], 1)
        self.assertEqual(self.source.read_bytes(), b"{not-json")

    def test_gate_cannot_be_combined_with_apply(self):
        before = self.source.read_bytes()
        with self.assertRaises(SystemExit) as error:
            self.run_gate("--apply")
        self.assertEqual(error.exception.code, 2)
        self.assertEqual(self.source.read_bytes(), before)

    def test_empty_root_is_not_mistaken_for_completed_migration(self):
        self.source.unlink()
        self.assertEqual(self.run_gate()[0], 2)

    def test_current_and_random_assignments_remain_ready(self):
        document = migrate.migrate_job_slots(self.document)
        document["pref_job_slots"] = {"Cargo Technician": 0, "Assistant": -1}
        self.save(document)
        self.assertEqual(self.run_gate()[0], 0)
        self.assertEqual(json.loads(self.source.read_bytes()), document)
