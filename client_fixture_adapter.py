"""Explicit TEMP-only mock-input adapter for disconnected body-admission tests.

Production/native compiles must run before this adapter. Five substitutions
adapt six preference/history/account-age reads, never the native algorithm, final connected-client
admission, constructor argument, client consumer, UI authorization or menu.
Passing those tests does not establish a real connected BYOND spawn.
"""
from __future__ import annotations

from hashlib import sha256
from pathlib import Path


SPECS = (
    {
        "path": "code/modules/mob/dead/new_player/new_player.dm",
        "source_sha256_lf": "7fcd95754081ee18eddd9be132c237baea879859b7d0135cabf1cf7f8349cfe4",
        "start": "/mob/dead/new_player/proc/create_character(atom/destination, forced_slot, datum/job_character_creation/creation) // BANDASTATION EDIT - Per-call ownership supplied by the module.\n",
        "end": "/mob/dead/new_player/proc/transfer_character()\n",
        "replacements": (
            (
                "var/spawned_slot = isnum(forced_slot) ? forced_slot : LAZYACCESS(client.prefs.job_assigned_profiles, mind.assigned_role.title)",
                "var/client/fixture_client = GET_CLIENT(src)\n\tvar/spawned_slot = isnum(forced_slot) ? forced_slot : LAZYACCESS(fixture_client.prefs.job_assigned_profiles, mind.assigned_role.title)",
            ),
            (
                "if(isnum(spawned_slot) && client.prefs.default_slot != spawned_slot)",
                "if(isnum(spawned_slot) && fixture_client.prefs.default_slot != spawned_slot)",
            ),
            (
                "client.prefs.load_character(spawned_slot) // if this fails, we will simply load their current slot anyways",
                "fixture_client.prefs.load_character(spawned_slot) // if this fails, we will simply load their current slot anyways",
            ),
        ),
        "additional_scopes": (
            {
                "start": "/mob/dead/new_player/proc/IsJobUnavailable(rank, latejoin = FALSE)\n",
                "end": "/mob/dead/new_player/proc/AttemptLateSpawn(rank)\n",
                "replacements": (
                    (
                        "if(isnum(client.player_age) && client.player_age <= 14)",
                        "var/client/fixture_client = GET_CLIENT(src)\n\t\t\tif(isnum(fixture_client.player_age) && fixture_client.player_age <= 14)",
                    ),
                ),
            },
        ),
    },
    {
        "path": "modular_bandastation/jobs/code/player/character_creation.dm",
        "source_sha256_lf": "955314661687f328dbfe7c7aabb6df0b8e9ea41fefef098099f5923a0b37a4fd",
        "start": "/mob/dead/new_player/create_character(atom/destination, forced_slot)\n",
        "end": "/mob/dead/new_player/proc/prepare_character_profile(atom/destination, forced_slot)\n",
        "replacements": (
            (
                "var/datum/persistent_client/connection = client.persistent_client",
                "var/client/fixture_client = GET_CLIENT(src)\n\tvar/datum/persistent_client/connection = fixture_client.persistent_client",
            ),
        ),
    },
)


def apply(worktree: Path | str) -> list[dict]:
    """Apply once to a detached TEMP Git worktree; fail before writes on drift.

    Full LF-normalized input hashes allow Git checkout newline conversion only.
    Original file EOL bytes are preserved, and raw before/after hashes are
    returned together with all literal replacements for runner provenance.
    """
    root = Path(worktree).resolve(strict=True)
    if not (root / ".git").is_file():
        raise RuntimeError("Client fixture adapter requires an isolated Git worktree, never the primary checkout")
    plans = []
    for spec in SPECS:
        path = (root / spec["path"]).resolve(strict=True)
        if not path.is_relative_to(root):
            raise RuntimeError("Unsafe client fixture adapter destination")
        original = path.read_bytes()
        normalized = original.replace(b"\r\n", b"\n")
        if sha256(normalized).hexdigest() != spec["source_sha256_lf"]:
            raise RuntimeError(f"Client fixture input hash changed: {spec['path']}")
        if b"\r" in normalized:
            raise RuntimeError(f"Unsupported newline bytes: {spec['path']}")
        eol = b"\r\n" if b"\r\n" in original else b"\n"
        if normalized.replace(b"\n", eol) != original:
            raise RuntimeError(f"Mixed newlines require review: {spec['path']}")
        text = normalized.decode("utf-8")
        replacements = []
        scopes = (spec, *spec.get("additional_scopes", ()))
        for scope_spec in scopes:
            if text.count(scope_spec["start"]) != 1 or text.count(scope_spec["end"]) != 1:
                raise RuntimeError(f"Native input scope changed: {spec['path']}")
            prefix, scope = text.split(scope_spec["start"])
            scope, suffix = scope.split(scope_spec["end"])
            for old, new in scope_spec["replacements"]:
                if text.count(old) != 1 or scope.count(old) != 1 or new in text:
                    raise RuntimeError(f"Client-read replacement count changed: {spec['path']}: {old}")
                scope = scope.replace(old, new, 1)
                replacements.append({"scope": scope_spec["start"].rstrip(), "old": old, "new": new, "count": 1})
            text = prefix + scope_spec["start"] + scope + scope_spec["end"] + suffix
        adapted = text.encode("utf-8").replace(b"\n", eol)
        plans.append((path, original, adapted, {
            "path": spec["path"],
            "before_sha256": sha256(original).hexdigest(),
            "before_sha256_lf": sha256(normalized).hexdigest(),
            "after_sha256": sha256(adapted).hexdigest(),
            "scopes": [scope_spec["start"].rstrip() for scope_spec in scopes],
            "replacements": replacements,
            "reason": "Headless fixture supplies preference/history/account-age inputs through existing mock_client; final connected-client/body admission remains unadapted",
        }))
    # Check every original a second time before any mutation, including other files.
    if any(path.read_bytes() != original for path, original, _, _ in plans):
        raise RuntimeError("TEMP source changed during client adapter preparation")
    for path, _, adapted, _ in plans:
        path.write_bytes(adapted)
    return [inventory for _, _, _, inventory in plans]
