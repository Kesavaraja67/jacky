---
name: jacky-local-llm-ops
description: Operations guide for local llama.cpp processes, CLI flag verification, GGUF model handling, benchmark procedures, supervisor lifecycle, thinking-mode toggles, and schema-constrained tool calls.
---

# Jacky Local LLM Operations Skill

Use this skill during Phase 0 benchmarking, Phase 1 `jacky-brain` implementation, and whenever tuning model parameters or server flags.

## Core Rules

1. **Verify Before Use Protocol**:
   - Never guess `llama-server` CLI flags or Hugging Face model repository IDs.
   - Always run `llama-server.exe --help` and consult docs before introducing flags.
   - Check model repos on Hugging Face to confirm exact file names, quantization tags (e.g. `Q4_K_M`), and SHA256/sizes.
2. **Server Execution Flags**:
   - Host: `--host 127.0.0.1` (never expose to 0.0.0.0).
   - Port: Bind to a random available TCP port per launch.
   - API Key: Generate a cryptographically random token per launch and pass via `--api-key`.
   - Context: Pin `--ctx-size 2048` (to conserve RAM on 8GB host).
   - Threads: Pin `--threads 3` (avoids starving Ryzen 5 5500U cores).
3. **Disabling Thinking / Reasoning Mode**:
   - Qwen3 models feature dual-mode reasoning. To disable thinking tokens for fast assistant responses, use `--reasoning off` (or on older builds `--chat-template-kwargs "{\"enable_thinking\": false}"`).
   - Validate that prompt output does not contain `<think>...</think>` tokens.
4. **Structured Generation**:
   - Use `response_format` with JSON schemas or GBNF grammars when tool calling is required.
   - Prevent model hallucination of free-form shell commands.
5. **Benchmark Hygiene**:
   - Ensure AC adapter is connected and Windows Power Plan is set to Best Performance.
   - Measure real numbers: cold-load time (s), prompt processing speed (tok/s), generation speed (tok/s), peak RAM working set (MB).
   - Log all metrics in `PROGRESS.md`.

## Checklist

- [ ] All `llama-server` flags verified with `--help`.
- [ ] Context size pinned to 2048 and threads to 3.
- [ ] Reasoning mode disabled for Qwen3 (`--reasoning off`).
- [ ] Server supervisor verifies `/health` endpoint before forwarding requests.
- [ ] Idle timer triggers child process termination after configured timeout (default 5 min).
- [ ] Benchmark conditions (RAM, power plan, CPU) noted alongside all metrics in `PROGRESS.md`.

## How to Verify

Run a standalone benchmark:
```powershell
.\llama-bench.exe -m <model.gguf> -t 3 -n 128 -p 512
```
And check process working set:
```powershell
Get-Process llama-server | Select-Object Id, WorkingSet64, CPU
```
