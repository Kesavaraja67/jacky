---
name: jacky-memory-and-janitor
description: Protocol for SQLite database schema, FTS5 full-text indexing, strict fact write-policy with verified source spans, and janitor curation lifecycle.
---

# Jacky Memory and Janitor Skill

Use this skill when designing, authoring, or maintaining `jacky-memory`, SQLite tables, migrations, write verification, or `jacky-janitor` curation rules.

## Core Rules

1. **Storage Architecture**:
   - Single SQLite file located at `%APPDATA%\Jacky\jacky.db`.
   - Embedded via `rusqlite` with `bundled` feature and FTS5 enabled.
   - Connection PRAGMAs required on open: `PRAGMA journal_mode=WAL;`, `PRAGMA synchronous=NORMAL;`, `PRAGMA foreign_keys=ON;`, `PRAGMA busy_timeout=5000;`.
   - Single-writer pattern: All write queries must go through a single worker task receiving commands over an MPSC channel. Readers can read concurrently via WAL mode.
2. **Memory Write Policy (Zero Hallucination Grounding)**:
   - A fact is eligible to be recorded ONLY if:
     a) Explicitly stated by the user in conversation, or
     b) Extracted from an explicitly fetched web page with a verified URL.
   - The LLM extracts proposed facts as structured JSON containing `source_span` (the exact quote from the source text).
   - **Rust verification is mandatory**: The Rust code MUST perform an exact substring match of `source_span` inside the raw user episode or raw fetched web text before inserting into `facts`. If the span does not match verbatim, the fact insertion is rejected.
   - The model's own answers, reasoning, or unverified claims are NEVER stored as facts.
3. **Database Migrations & Maintenance**:
   - Versioned migrations tracked via `PRAGMA user_version`.
   - Always run an automated database backup (`VACUUM INTO` or online backup API) before executing any migration. Keep last 7 daily backups.
   - Execute `PRAGMA quick_check;` on startup and full `PRAGMA integrity_check;` weekly.
4. **Janitor Lifecycle**:
   - Janitor runs strictly during idle conditions: user idle >= 10 min, host on AC power, and CPU usage low.
   - Operations: deduplication, scoring $f(\text{age}, \text{use\_count}, \text{confidence})$, and soft-deleting low-scoring facts to `status = 'archived'`.
   - Purge permanently only after 30 days in archived status.
   - First 7 days operate in **DRY-RUN** mode (log proposed changes to `janitor_log` without executing).
   - Support `jacky janitor --undo <run_id>` to restore archived records.

## Checklist

- [ ] WAL mode and busy timeout configured on connection open.
- [ ] Writes routed through single-writer channel.
- [ ] Strict source-span exact matching implemented and tested.
- [ ] Model free-form output prevented from entering facts table.
- [ ] Backup taken before schema migrations.
- [ ] Janitor requires idle >= 10m, AC power, low CPU.
- [ ] Undo command implemented for janitor runs.

## How to Verify

Unit test fact insertion:
1. Provide an input episode text and a matching proposed `source_span` -> assert accepted.
2. Provide an input episode text and a hallucinated `source_span` -> assert rejected with `UngroundedSpanError`.
3. Test restart persistence: write fact, drop connection, open new connection, query via FTS5 -> assert identical fact retrieved.
