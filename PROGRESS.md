# PROGRESS.md - Project Tracking & Measured Benchmarks

## Current State: Phase 0 (Environment & Benchmarking) & Phase 0b (Skills Setup)
- **Active Phase**: Phase 0 & Phase 0b
- **Gate Status**: Gate 0 in progress (Model download running in background; benchmark execution next)

---

## 1. Environment Verification Metrics (Real measurements from `scripts/check-env.ps1`)

| Parameter | Measured Value | Target / Constraint | Status | Notes |
|---|---|---|---|---|
| OS | Windows 11 Build 26100 | Windows 64-bit | PASS | Windows 11 Build 26100 |
| CPU | AMD Ryzen 5 5500U with Radeon Graphics | AMD Ryzen 5 5500U | PASS | 6 Cores / 12 Threads (Zen 2, AVX2 support) |
| Total Visible RAM | 7.33 GB | 8 GB nominal (~7.3 GB usable) | PASS | Exactly matches expected hardware |
| Idle Free RAM | **0.67 GB** (measured) | Real free RAM baseline | **FLAGGED / CRITICAL** | Tight RAM headroom. Must design strictly to ~1.0-1.5 GB peak working set during generation. |
| Storage Type | NVMe SSD (WD PC SN740 512GB) | SSD preferred | PASS | NVMe SSD ensures fast model cold-load |
| Disk Free (D: Project) | 306.77 GB | >= 10 GB free | PASS | Abundant workspace capacity |
| Disk Free (C: APPDATA) | 16.51 GB | >= 10 GB free | PASS | Sufficient for models and SQLite db |
| Power Scheme | Balanced (381b4222-f694...) | High Performance for bench | ATTENTION | Recommend switching to Best Performance during benchmark runs |
| MSVC C++ Tools | Visual Studio Build Tools 2022 (17.14) | VS 2022+ Desktop C++ | PASS | Present at `C:\Program Files (x86)\...\BuildTools` |
| Git | 2.53.0.windows.2 | Git present | PASS | Available in PATH |
| WebView2 Runtime | Detected in Program Files (x86) | Pre-installed | PASS | Available for Phase 7 if needed |
| Rust Toolchain | rustc 1.99.0 / cargo 1.99.0 | Rust stable (msvc) | **PASS** | Installed via rustup (stable `x86_64-pc-windows-msvc`) |
| llama.cpp Release | Build b11146 (2026-09-23) | Prebuilt Windows CPU AVX2 | **PASS** | Installed at `%APPDATA%\Jacky\bin\`. Zen 2 auto-loads `ggml-cpu-haswell.dll`. |
| Vulkan Experiment | Devices found: `(none)` | Experimental GPU test | **RESOLVED** | Vulkan APU compute unavailable; CPU-only confirmed (ADR 0002). |

---

## 2. Phase 0b Status: COMPLETE

- [x] Skill library inventory performed across all 32 directories.
- [x] `SKILLS_INDEX.md` created with verified frontmatter, assigned phase, and conflict analysis.
- [x] Superpowers plugin check completed (not installed; manual discipline active).
- [x] Outlines of the six Jacky-specific skills approved by user.
- [x] Six Jacky-specific skills created in `<repo>/.claude/skills/`:
  - [jacky-rust-daemon](file:///d:/projects/Jacky/.claude/skills/jacky-rust-daemon/SKILL.md)
  - [jacky-local-llm-ops](file:///d:/projects/Jacky/.claude/skills/jacky-local-llm-ops/SKILL.md)
  - [jacky-memory-and-janitor](file:///d:/projects/Jacky/.claude/skills/jacky-memory-and-janitor/SKILL.md)
  - [jacky-tool-safety](file:///d:/projects/Jacky/.claude/skills/jacky-tool-safety/SKILL.md)
  - [jacky-eval-and-perf](file:///d:/projects/Jacky/.claude/skills/jacky-eval-and-perf/SKILL.md)
  - [jacky-persona-emotion](file:///d:/projects/Jacky/.claude/skills/jacky-persona-emotion/SKILL.md)
- [x] Active skills copied into `<repo>/.claude/skills/`: `doc-coauthoring`, `output-skill`, `skill-creator`, `discernment-nudge`.

---

## 3. Phase 0 Benchmark Execution (In Progress)

- [x] `scripts/setup-llama.ps1` executed: binaries verified.
- [x] `scripts/download-models.ps1` running: FAST (Qwen2.5-1.5B Q4_K_M) and DEEP (Phi-4-mini Q4_K_M).
- [x] `scripts/run-benchmark.ps1` prepared for automated benchmark capture.
- [ ] Record Gate 0 performance numbers (tok/s, peak RAM, cold-load).
