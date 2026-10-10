"""Conversion safety checks use only isolated temporary player save fixtures."""

from copy import deepcopy
from contextlib import redirect_stderr, redirect_stdout
import io
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import migrate


class ConversionTests(unittest.TestCase):
    def test_explicit_new_values_win_including_current_and_random(self):
        source = {
            "job_assigned_profiles": {"Cargo Technician": 2, "Assistant": 3, "Engineer": 4, "Doctor": 5},
            "pref_job_slots": {"Cargo Technician": 0, "Assistant": -1, "Doctor": 2.0},
            "character1": {"job_assigned_profiles": {"Nested field": 8}, "real_name": "Fixture Name"},
            "unrelated": {"value": [1, 2, 3]},
        }
        original = deepcopy(source)
        converted = migrate.migrate_job_slots(source)
        self.assertEqual(converted["pref_job_slots"], {"Cargo Technician": 0, "Assistant": -1, "Engineer": 4, "Doctor": 2})
        self.assertNotIn("job_assigned_profiles", converted)
        self.assertEqual(converted["character1"], original["character1"])
        self.assertEqual(converted["unrelated"], original["unrelated"])
        self.assertEqual(source, original)
        converted["character1"]["real_name"] = "Changed fixture"
        self.assertEqual(source, original)

    def test_missing_and_empty_maps(self):
        for old in (None, [], {}):
            for new in (None, [], {}):
                with self.subTest(old=old, new=new):
                    self.assertEqual(migrate.migrate_job_slots({"job_assigned_profiles": old, "pref_job_slots": new}), {"pref_job_slots": {}})
        self.assertEqual(migrate.migrate_job_slots({}), {"pref_job_slots": {}})
        self.assertEqual(migrate.migrate_job_slots({"job_assigned_profiles": {"Doctor": 2}}), {"pref_job_slots": {"Doctor": 2}})
        self.assertEqual(migrate.migrate_job_slots({"pref_job_slots": {"Doctor": -1}}), {"pref_job_slots": {"Doctor": -1}})

    def test_bad_maps_and_slots_are_rejected_without_reset(self):
        for key, minimum in (("job_assigned_profiles", 1), ("pref_job_slots", -1)):
            for invalid in (["Doctor"], "map", 1000, True, {"": 2}, {1: 2}, {"Doctor": True}, {"Doctor": "2"}, {"Doctor": 1.5}, {"Doctor": minimum - 1}, {"Doctor": float("nan")}, {"Doctor": float("inf")}):
                with self.subTest(key=key, invalid=invalid):
                    with self.assertRaises(ValueError):
                        migrate.migrate_job_slots({key: invalid})

    def test_conversion_is_idempotent(self):
        for source in (
            {},
            {"job_assigned_profiles": {"Doctor": 3}, "pref_job_slots": {"Doctor": 0, "Assistant": -1}},
            {"job_assigned_profiles": [], "pref_job_slots": None},
            {"pref_job_slots": {"Doctor": 2.0, "Unavailable job": 999}},
        ):
            with self.subTest(source=source):
                once = migrate.migrate_job_slots(source)
                self.assertEqual(migrate.migrate_job_slots(once), once)


class FileConversionTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="banda-job-slots-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name) / "player_saves"
        self.root.mkdir()
        self.source = self.root / "a" / "alice" / "preferences.json"
        self.source.parent.mkdir(parents=True)
        self.backups = Path(self.temporary.name) / "backups"
        self.backup = self.backups / "a" / "alice" / "preferences.json"
        self.document = {
            "version": 52,
            "default_slot": 1,
            "job_assigned_profiles": {"Cargo Technician": 2, "Assistant": 3},
            "pref_job_slots": {"Assistant": -1},
            "character1": {"version": 52, "real_name": "Тестовый персонаж", "job_assigned_profiles": {"Nested value": 7}},
            "other_setting": {"value": [1, 2, 3]},
        }
        self.original = (json.dumps(self.document, ensure_ascii=False, indent=4) + "\n").encode("utf-8")
        self.source.write_bytes(self.original)

    def run_cli(self, *arguments):
        output = io.StringIO()
        with redirect_stdout(output), redirect_stderr(output):
            result = migrate.main([str(self.root), *arguments])
        return result, output.getvalue()

    def test_default_dry_run_leaves_all_files_untouched(self):
        before = self.source.stat().st_mtime_ns
        result, output = self.run_cli()
        self.assertEqual(result, 0)
        self.assertIn("DRY_RUN examined=1 changed=1 unchanged=0 errors=0", output)
        self.assertEqual(self.source.read_bytes(), self.original)
        self.assertEqual(self.source.stat().st_mtime_ns, before)
        self.assertFalse(self.backups.exists())
        self.assertEqual(list(self.source.parent.glob("*.tmp")), [])
        self.assertNotIn("Тестовый персонаж", output)

    def test_apply_requires_stopped_server_and_separate_backup(self):
        for arguments in (
            ("--apply",),
            ("--apply", "--server-stopped"),
            ("--apply", "--backup-dir", str(self.backups)),
            ("--apply", "--server-stopped", "--backup-dir", str(self.root / "backups")),
        ):
            with self.subTest(arguments=arguments):
                with self.assertRaises(SystemExit) as error:
                    self.run_cli(*arguments)
                self.assertEqual(error.exception.code, 2)
                self.assertEqual(self.source.read_bytes(), self.original)
                self.assertFalse(self.backups.exists())

    def test_apply_backs_up_exact_bytes_and_second_run_does_not_write(self):
        args = ("--apply", "--server-stopped", "--backup-dir", str(self.backups))
        result, output = self.run_cli(*args)
        self.assertEqual(result, 0)
        self.assertIn("APPLY examined=1 changed=1 unchanged=0 errors=0", output)
        self.assertEqual(self.backup.read_bytes(), self.original)
        expected = migrate.migrate_job_slots(self.document)
        self.assertEqual(json.loads(self.source.read_text(encoding="utf-8")), expected)
        self.assertEqual(expected["character1"], self.document["character1"])
        self.assertEqual(expected["other_setting"], self.document["other_setting"])
        once = self.source.read_bytes()
        written_at = self.source.stat().st_mtime_ns
        result, output = self.run_cli(*args)
        self.assertEqual(result, 0)
        self.assertIn("changed=0 unchanged=1 errors=0", output)
        self.assertEqual(self.source.read_bytes(), once)
        self.assertEqual(self.source.stat().st_mtime_ns, written_at)
        self.assertEqual(self.backup.read_bytes(), self.original)
        self.assertEqual(list(self.source.parent.glob("*.tmp")), [])
        result, output = self.run_cli()
        self.assertEqual(result, 0)
        self.assertIn("DRY_RUN examined=1 changed=0 unchanged=1 errors=0", output)

    def test_bad_structure_json_and_assignments_are_not_overwritten(self):
        bad_documents = [
            [],
            {"preferences": self.document},
            {**self.document, "version": 53},
            {**self.document, "version": 31},
            {**self.document, "version": True},
            {**self.document, "version": 51.5},
            {**self.document, "default_slot": 0},
            {**self.document, "default_slot": True},
            {**self.document, "character1": "corrupted character"},
            {**self.document, "character0": {}},
            {**self.document, "pref_job_slots": {"Doctor": 1.5}},
            {**self.document, "job_assigned_profiles": {"Doctor": 0}},
        ]
        bad_bytes = [json.dumps(document).encode("utf-8") for document in bad_documents]
        bad_bytes.extend((b"{broken JSON", b'\xff', b'{"version":52,"version":52,"default_slot":1}', b'{"version":52,"default_slot":1,"pref_job_slots":{"Doctor":NaN}}'))
        for source_bytes in bad_bytes:
            with self.subTest(source_bytes=source_bytes):
                self.source.write_bytes(source_bytes)
                result, output = self.run_cli("--apply", "--server-stopped", "--backup-dir", str(self.backups))
                self.assertEqual(result, 1)
                self.assertIn("errors=1", output)
                self.assertEqual(self.source.read_bytes(), source_bytes)
                self.assertFalse(self.backups.exists())

    def test_unexpected_player_path_is_rejected_and_other_json_is_ignored(self):
        unrelated = self.root / "other.json"
        unrelated.write_bytes(self.original)
        character_file = self.source.with_name("character1.json")
        character_file.write_bytes(self.original)
        wrong = self.root / "b" / "alice" / "preferences.json"
        wrong.parent.mkdir(parents=True)
        wrong.write_bytes(self.original)
        result, output = self.run_cli()
        self.assertEqual(result, 1)
        self.assertIn("examined=2 changed=1 unchanged=0 errors=1", output)
        self.assertEqual(unrelated.read_bytes(), self.original)
        self.assertEqual(character_file.read_bytes(), self.original)
        self.assertEqual(wrong.read_bytes(), self.original)

    def test_backup_collision_does_not_overwrite_either_file(self):
        self.backup.parent.mkdir(parents=True)
        self.backup.write_bytes(b"existing independent backup")
        result, output = self.run_cli("--apply", "--server-stopped", "--backup-dir", str(self.backups))
        self.assertEqual(result, 1)
        self.assertIn("errors=1", output)
        self.assertEqual(self.source.read_bytes(), self.original)
        self.assertEqual(self.backup.read_bytes(), b"existing independent backup")
        self.assertEqual(list(self.source.parent.glob("*.tmp")), [])

    def test_failed_atomic_replace_preserves_original_and_backup(self):
        with patch.object(migrate.os, "replace", side_effect=OSError("simulated replace failure")):
            result, output = self.run_cli("--apply", "--server-stopped", "--backup-dir", str(self.backups))
        self.assertEqual(result, 1)
        self.assertIn("errors=1", output)
        self.assertEqual(self.source.read_bytes(), self.original)
        self.assertEqual(self.backup.read_bytes(), self.original)
        self.assertEqual(list(self.source.parent.glob("*.tmp")), [])

    def test_concurrent_writer_is_detected_before_replace(self):
        make_temporary = migrate.tempfile.mkstemp
        concurrent_data = b"concurrently written fixture data"

        def change_source(*args, **kwargs):
            temporary = make_temporary(*args, **kwargs)
            self.source.write_bytes(concurrent_data)
            return temporary

        with patch.object(migrate.tempfile, "mkstemp", side_effect=change_source):
            result, output = self.run_cli("--apply", "--server-stopped", "--backup-dir", str(self.backups))
        self.assertEqual(result, 1)
        self.assertIn("changed during conversion", output)
        self.assertEqual(self.source.read_bytes(), concurrent_data)
        self.assertEqual(self.backup.read_bytes(), self.original)
        self.assertEqual(list(self.source.parent.glob("*.tmp")), [])

    def test_empty_root_is_reported_as_wrong_input(self):
        self.source.unlink()
        result, output = self.run_cli()
        self.assertEqual(result, 2)
        self.assertIn("no player preference files", output)


if __name__ == "__main__":
    unittest.main()
