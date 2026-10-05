# SKILLS_INDEX.md - Jacky Skills Inventory & Routing

This document inventories the skills library at `d:\projects\Jacky\skills` (read-only source).
Each skill's true purpose was verified directly from its `SKILL.md` frontmatter and contents.
Per Section 2 & 3A, hard project constraints override any skill guidance (no cloud APIs, 100% local, offline assets, lightweight idle RAM).

---

## 1. Inventory & Phase Mapping

| Skill Folder | True Name in Frontmatter | Verified Purpose (from SKILL.md) | Assigned Phase | Conflicts with Section 2 / Adaptations | Status in v1 |
|---|---|---|---|---|---|
| `academy-guide` | `academy-guide` | Recommends matching courses and tutorials from Claude Academy (academy.claude.com). | None | Relies on Claude Academy cloud resources. | **Skipped** |
| `algorithmic-art` | `algorithmic-art` | Generative canvas art using p5.js with seeded randomness. | None | Non-goal for desktop assistant; p5.js web runtime. | **Skipped** |
| `brand-guidelines` | `brand-guidelines` | Applies Anthropic's official brand colors and typography. | None | Anthropic brand specific; Jacky has its own identity. | **Skipped** |
| `brandkit` | `brandkit` | Image generation for brand identity, logo systems, and visual decks. | Phase 7 (optional) | Design exploration only if requested; never runtime code. | **Optional** |
| `brutalist-skill` | `industrial-brutalist-ui` | Raw mechanical interfaces, Swiss print, utilitarian terminal styling. | Phase 7 (alternative) | Conflicts with chosen `minimalist-ui` direction (Rule 3A.5: one aesthetic). | **Skipped** |
| `canvas-design` | `canvas-design` | Visual art in .png/.pdf using design philosophy. | Phase 7 (optional) | Usable to design tray icon / logo (.ico/.png). Assets must be pre-rendered. | **Optional** |
| `claude-api` | `claude-api` | Reference for Anthropic SDK / Claude API (models, pricing, caching). | Never | **HARD CONFLICT**: Section 2 bans all cloud LLM APIs. | **BANNED** |
| `discernment-nudge` | `discernment-nudge` | Appends follow-up verification questions to substantive plans and drafts. | Process / Planning | Build-time planning aid; runtime uses `jacky-persona` honesty rules. | **Active (Process)** |
| `doc-coauthoring` | `doc-coauthoring` | Structured workflow for co-authoring documentation, specs, README, and decisions. | All Phases | None. Guides `README.md`, `DECISIONS.md`, and architecture docs. | **Active** |
| `docx` | `docx` | Word document creation, extraction, and editing (.docx/.dotx). | On request | Non-goal unless printable manual export requested. | **Skipped** |
| `frontend-design` | `frontend-design` | Baseline visual craft: intentional typography, spacing, states, anti-template. | Phase 7 | Web guidance adapted to egui or offline WebView2; zero external CDN calls. | **Active (Phase 7)** |
| `gpt-tasteskill` | `gpt-taste` | Elite GSAP motion engineering and web landing page design. | None | Heavy web animation / GSAP incompatible with lightweight desktop popup. | **Skipped** |
| `image-to-code-skill` | `image-to-code` | Generate UI reference images and implement matching code. | Phase 7 (optional) | Design exploration only; no runtime dependencies. | **Optional** |
| `imagegen-frontend-mobile`| `imagegen-frontend-mobile` | Mobile app concept image generation (iOS/Android). | None | Irrelevant platform (Jacky is Windows desktop only). | **Skipped** |
| `imagegen-frontend-web` | `imagegen-frontend-web` | Section-by-section horizontal image generation for web landing pages. | Phase 7 (optional) | Exploration only if requested. | **Optional** |
| `internal-comms` | `internal-comms` | Corporate internal communications formats (status reports, newsletters). | None | Corporate comms irrelevant to personal companion daemon. | **Skipped** |
| `mcp-builder` | `mcp-builder` | Building MCP servers (Python/FastMCP, Node SDK). | Future | Non-goal for v1; Jacky uses internal native Rust tool system. | **Deferred** |
| `minimalist-skill` | `minimalist-ui` | Clean editorial interfaces, warm monochrome palette, flat bento, no heavy shadows. | Phase 7 | **DEFAULT aesthetic direction**. All assets must be bundled offline. | **Active (Phase 7)** |
| `output-skill` | `full-output-enforcement` | Prevents code truncation, bans placeholder comments (`// TODO`), enforces complete files. | All Phases | None. Essential for full Rust implementations and SQL schemas. | **Active** |
| `pdf` | `pdf` | PDF manipulation (text extraction, merging, OCR, generation). | On request | Non-goal unless export requested. | **Skipped** |
| `pptx` | `pptx` | PowerPoint deck creation and editing (.pptx). | None | Irrelevant to desktop assistant daemon. | **Skipped** |
| `redesign-skill` | `redesign-existing-projects` | Audits existing UI, removes generic AI patterns, polishes layout. | Phase 7 (iterations)| Iterative polish for popup UI. | **Active (Phase 7)** |
| `skill-creator` | `skill-creator` | Tooling and methodology to author, test, and refine new skills. | Phase 0b | Used to structure and author the six Jacky-specific skills. | **Active (Phase 0b)** |
| `slack-gif-creator` | `slack-gif-creator` | Animated GIF creation optimized for Slack. | None | Irrelevant. | **Skipped** |
| `soft-skill` | `high-end-visual-design` | Agency soft UI, gradients, cards, and animations. | None | Conflicts with chosen `minimalist-ui` direction. | **Skipped** |
| `stitch-skill` | `stitch-design-taste` | Semantic design system generation for Google Stitch. | None | Google Stitch specific; not applicable to desktop popup. | **Skipped** |
| `taste-skill` | `design-taste-frontend` | Anti-slop frontend design (v2 experimental): brief inference, design system, pre-flight. | Phase 7 | Quality bar and self-review for popup UI. Supersedes v1. | **Active (Phase 7)** |
| `taste-skill-v1` | `design-taste-frontend-v1` | Legacy v1 of taste-skill. | None | Superseded by `taste-skill` (v2). | **Skipped** |
| `theme-factory` | `theme-factory` | Font and color palette toolkit for artifacts. | Phase 7 (optional) | Design tokens for light/dark mode; must stay within monochrome constraint. | **Optional** |
| `web-artifacts-builder` | `web-artifacts-builder` | Multi-component React/Vite/Parcel artifact generator. | None | Heavy Node build stack unsuitable for lightweight local desktop popup. | **Skipped** |
| `webapp-testing` | `webapp-testing` | Playwright testing of local web applications. | Phase 7 (conditional)| Only used if popup UI is implemented with WebView2. | **Conditional** |
| `xlsx` | `xlsx` | Spreadsheet (.xlsx, .csv) data creation, editing, formula verification. | None | Irrelevant to core assistant daemon. | **Skipped** |

---

## 2. Engineering-Process Skills Status (obra/superpowers)

- **Status**: Checked `~/.claude/skills` and `~/.claude/plugins`. The `obra/superpowers` suite is **not installed** locally.
- **Workflow discipline adopted manually** (per Section 3A, Part A):
  1. *Brainstorming*: Clarify and align on edge cases prior to implementation.
  2. *Writing-plans*: Detailed step-by-step plan per phase before coding.
  3. *Test-driven-development*: Formulate test cases and mocks first.
  4. *Systematic-debugging*: Root-cause analysis with logs, avoiding guesswork.
  5. *Verification-before-completion*: Execute commands, measure real metrics, provide verbatim proof at every GATE.
