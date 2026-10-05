---
name: jacky-rust-daemon
description: Standards and patterns for the Jacky Rust workspace daemon, Windows process supervisor, error handling, Job Objects, priority classes, and tokio runtime architecture.
---

# Jacky Rust Daemon Skill

Use this skill when designing, authoring, or refactoring code in `jacky-daemon`, `jacky-brain`, or the root workspace configuration.

## Core Rules

1. **Workspace Layout**:
   - Keep crate boundaries sharp. `jacky-daemon` is the orchestrator and entry point.
   - Modules/crates: `jacky-daemon`, `jacky-brain`, `jacky-memory`, `jacky-persona`, `jacky-tools`, `jacky-web`, `jacky-janitor`, `jacky-eval`, `jacky-ui`.
2. **Error Handling**:
   - Every crate defines its own explicit error enum using `thiserror`.
   - The top-level binary in `jacky-daemon` uses `anyhow::Result` for application lifecycle.
   - **Zero unwrap/expect**: `.unwrap()` and `.expect()` are strictly forbidden in production code. Use `?` or map errors explicitly. Allowed only in `#[cfg(test)]`.
3. **Windows Process Management**:
   - Always spawn child processes (`llama-server`) inside a Windows Job Object configured with `JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE`. This guarantees that if the daemon exits, crashes, or is killed, no zombie `llama-server` remains running.
   - Process creation flags must include:
     - `CREATE_NO_WINDOW (0x08000000)`
     - `BELOW_NORMAL_PRIORITY_CLASS (0x00004000)`
   - Never spawn processes with default normal priority; keep host system (browser, editor) responsive.
4. **Tokio Runtime & Concurrency**:
   - Keep daemon footprint minimal. Avoid spinning dozens of runtime worker threads.
   - Pin worker threads to 2 or use `current_thread` runtime where appropriate.
   - Idle policy: terminate background inference processes after idle duration (default 5 minutes).
5. **Quality Gates & Dependency Justification**:
   - Every added dependency must be recorded and justified in `DECISIONS.md`.
   - Code must pass `cargo fmt --check` and `cargo clippy --workspace -- -D warnings`.

## Checklist

- [ ] All errors use `thiserror` (crates) or `anyhow` (daemon bin).
- [ ] No `.unwrap()` or `.expect()` in non-test code.
- [ ] Windows Job Object kill-on-close verified for child processes.
- [ ] `CREATE_NO_WINDOW` and `BELOW_NORMAL_PRIORITY_CLASS` set on child spawns.
- [ ] New crates recorded in `DECISIONS.md`.
- [ ] Passes `cargo fmt` and `cargo clippy -- -D warnings`.

## How to Verify

Run:
```powershell
cargo fmt --check
cargo clippy --workspace -- -D warnings
cargo test --workspace
```
Inspect process lifecycle in tests to ensure child processes are terminated when parent drops the Job Object handle.
