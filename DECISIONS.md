# DECISIONS.md - Architectural & Design Decision Record

## ADR 0001: Initial Architecture and Tooling Setup
- **Date**: 2026-10-03
- **Status**: Accepted
- **Context**: Jacky requires a lightweight, 100% offline personal assistant daemon running on Windows with an AMD Ryzen 5 5500U and 8 GB RAM.
- **Decisions**:
  1. **Inference Engine**: Prebuilt `llama-server` (AVX2 build) executed as an on-demand child process. Process lifecycle managed by a Windows Job Object (`JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE`) to ensure no orphan processes survive daemon crashes.
  2. **Priority and Threading**: Child process spawned with `CREATE_NO_WINDOW | BELOW_NORMAL_PRIORITY_CLASS` with thread limit pinned to 3 to maintain host responsiveness.
  3. **Storage Engine**: SQLite via `rusqlite` (`bundled` feature with FTS5 enabled). WAL journal mode with single-writer channel pattern. No external database servers or heavy vector database runtimes.
  4. **Skill System Adaptation**: Hard constraints in Section 2 strictly override any build-time skills. Skills library in `d:\projects\Jacky\skills` is treated as read-only. Skills providing cloud APIs (e.g. `claude-api`), heavy web animation frameworks, or external CDNs are banned or skipped.
  5. **UI Aesthetic**: Selected `minimalist-ui` as the single visual direction for Phase 7 (calm, warm monochrome, flat bento, zero CDN dependencies).

## ADR 0002: Backend Inference Hardware Policy (CPU-Only Confirmation)
- **Date**: 2026-10-03
- **Status**: Accepted
- **Context**: Evaluated the experimental llama.cpp Vulkan backend against the laptop's integrated AMD Radeon Graphics.
- **Evidence**: `llama-b11146-bin-win-vulkan-x64` was downloaded and executed with `--list-devices`. Output returned `Available devices: (none)`. The integrated Radeon APU on standard OEM drivers does not expose a functional Vulkan compute device to the generic loader without heavy driver modifications.
- **Decision**: Commit strictly to CPU-only AVX2 inference (`ggml-cpu-haswell.dll` auto-selected by llama.cpp for Zen 2 architecture). The CPU backend is completely self-contained, stable, and requires zero third-party GPU runtime dependencies.
