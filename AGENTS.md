# AGENTS.md — AI Assistant Guide for abap-util

> This file follows the cross-tool AGENTS.md convention and is the single
> agent instruction file of this repository — there is no separate
> `CLAUDE.md`; Claude Code reads `AGENTS.md` natively.

## Project Overview

abap-util provides utility functions for ABAP as class-based methods — strings, JSON/XML/CSV/XLSX, RTTI, messages, logging, locks, calendar, transports, persistence and more. It hides language-version differences between ABAP Cloud and Standard ABAP behind one façade and supports all releases from NW 7.02 to ABAP Cloud.

**License:** MIT
**Language:** English — all code, comments, commit messages, PRs, issues, documentation, and communication must be in English.
**Documentation:** https://abap-util.github.io/docs/

## The Master-Catalog Principle (Superset of All Methods)

This is the most important concept in this repository. Read it before changing anything.

**abap-util is the master catalog for platform-abstraction utilities: it contains all available utility classes with all available methods. Downstream projects do not install it as a dependency — each project decides which classes it needs and embeds a renamed copy of exactly those classes.**

```
abap-util (master catalog, this repo)             Downstream projects (vendored copies)
┌──────────────────────────────┐
│ zabaputil_cl_util_context    │  copy + rename   ┌────────────────────────────────────┐
│  (ALL utility methods,       │ ───────────────→ │ abap2UI5 (src/00/03/):             │
│   full unit test coverage,   │  context class:  │  z2ui5_cl_ui5_util_context (subset)│
│   linted for 7.02/Standard/  │  trim to used    │  z2ui5_cl_ui5_util_http            │
│   Cloud)                     │  methods         │  z2ui5_cx_ui5_util_error           │
│ zabaputil_cl_util_http       │ ───────────────→ ├────────────────────────────────────┤
│ zabaputil_cx_error           │  other classes:  │ popups:                            │
│ ...                          │  copy as-is      │  z2ui5_cl_popup_context            │
│                              │                  │  (src/00/, popup subset)           │
└──────────────────────────────┘                  └────────────────────────────────────┘
        ↑                                                          │
        └── periodic AI sync-back: what was added or fixed in ─────┘
            ANY vendored class downstream is merged into abap-util,
            so the master stays the superset of all methods
```

**Why copies instead of a dependency:**
- abapGit has no dependency management — a hard dependency would force installation order and version pinning on every user. Copies keep every consumer "clone and go".
- Namespace isolation: multiple projects (even on different versions of the utils) can coexist in one system without conflicts.
- The context-class copy only carries the methods the project actually uses instead of the full class.

**How the cycle works:**
1. **Class-level selection:** every project decides which utility classes it needs and vendors a renamed copy of exactly those classes.
2. **Method-level trimming — context class only:** the copy of `zabaputil_cl_util_context` is additionally reduced at method level to the methods the project actually uses. Trimming must keep the closure: every private/protected helper a kept method calls (transitively) stays in the copy. All other vendored classes are copied as-is.
3. **New methods are developed locally.** When a project needs a utility method during development that its context-class copy does not have, it is simply written directly into the project's local context class — no upstream round-trip is required. (If the method already exists in this catalog, copy it from here with its helper closure instead of re-implementing it.)
4. **Periodic AI sync-back:** every few weeks an AI compares abap-util with all consumers and merges what was added or fixed downstream into this repository — so abap-util always converges back to the superset of all methods, unit-tested and linted for all targets, and every other consumer can pick them up from here.

   **The sync covers every vendored class, not only the context class.** The context class is where most of the movement is, but a consumer fixes whatever it has a copy of: abap2UI5's `z2ui5_cx_ui5_util_error` and `z2ui5_cl_ui5_util_http` are copies of `zabaputil_cx_error` and `zabaputil_cl_util_http` and drift exactly the same way. Diff each consumer's full set of vendored classes against its master here.

   The class names above are abap2UI5's current ones. They carry an `ui5` segment since that repository's rename (`z2ui5_cl_a2ui5_context` → `z2ui5_cl_ui5_util_context`, `z2ui5_cl_a2ui5_http` → `z2ui5_cl_ui5_util_http`, `z2ui5_cx_a2ui5_error` → `z2ui5_cx_ui5_util_error`) — the same three objects under new names, so an older note written under the pre-rename names is describing the same code. A consumer renaming its copy is expected and costs nothing here; read the consumer's own AGENTS.md for the list that is current at sync time.

   **Two things next to a vendored copy are not sync sources.** A consumer may own classes in the same package that have no master here — abap2UI5's `z2ui5_cl_ui5_util_json_fl` is framework-owned and stays downstream. And abap2UI5's `src/99/01/` (`z2ui5_cl_util`, `z2ui5_cl_util_http`, `z2ui5_cx_util_error`, …) holds frozen pre-vendoring copies that receive no fixes; syncing from them would drag dead code back into the master. Both are excluded — check the consumer's own AGENTS.md for its current list.

   **The sync compares method *bodies*, not just method names.** A consumer that fixes a bug in a method it already has produces no missing method at all, so a name-level diff reports "in sync" while the master keeps shipping the broken implementation to every other consumer. Diff each shared method's body (normalizing the renamed class/exception prefixes), and treat a behavioral difference as a sync item exactly like a missing method. Pure formatting and comment-wording differences are expected — each consumer runs its own formatter config — and are not sync items.

   **Extract methods with their pragmas.** A naive `METHOD <name>.` extractor silently skips `METHOD constructor ##ADT_SUPPRESS_GENERATION.` and every other declaration carrying a pragma or a pseudo-comment — the method then appears in neither the missing list nor the changed list, and a defect in it survives every sync run that has ever been made. The 2026-09 sync found two real changes hiding in exactly that method. Match the pragmas, and sanity-check the extracted method count against `grep -c '^  METHOD'` on both sides.
5. **Multi-environment compatibility is non-negotiable:** every method must work on NW 7.02, Standard ABAP, and ABAP Cloud, because any consumer may run on any of these targets. Environment-specific behavior is branched via `check_abap_cloud( )` and dynamic calls so the code compiles everywhere.

**Why the consumers need this at all:** in every consumer, *all* system- and environment-specific functionality is reached through a method of its context class — never by calling `cl_abap_*`, a function module, or an environment-specific API directly. That is what confines the dependency on SAP standard objects to one class per project and makes those projects portable across all three targets and transpilable to JS. This catalog exists to keep that one class from having to be written from scratch in every project.

## Repository Structure

```
src/
├── zabaputil_cl_util_context.clas.abap   # THE master utility façade (strings, JSON, XML, RTTI,
│                                         #   UUID, calendar, locks, BAL, transports, ...)
├── zabaputil_cl_util_http.clas.abap      # Unified HTTP abstraction (on-premise + cloud)
├── zabaputil_cl_util_db.clas.abap        # Key/value persistence (table zabaputil_t_91)
├── zabaputil_cl_util_log.clas.abap       # Logging
├── zabaputil_cl_util_msg.clas.abap       # Message handling
├── zabaputil_cl_util_range.clas.abap     # Select-option range builders
├── zabaputil_cl_util_xml.clas.abap       # Fluent XML builder
├── zabaputil_cl_http.clas.abap           # HTTP helper
├── zabaputil_cx_error.clas.abap          # No-check exception
├── zabaputil_cx_util_error.clas.abap     # Exception (compatibility)
└── 00/
    ├── 01/                               # ajson mirror — DO NOT MODIFY (synced from upstream)
    └── 02/                               # S-RTTI mirror — DO NOT MODIFY (synced from upstream)
```

Every class has a `.testclasses.abap` file. The master carries the **full** test suite — every method, all three targets — and is the only place where a vendored method is guaranteed to be covered. Consumers may additionally test their own copy (abap2UI5 does, for the subset it vendors); that does not replace the coverage here, and a method synced back from a consumer needs its tests written in this repository.

## Build & Validation

```bash
npm install
npx abaplint                  # Lint (v750 syntax, downport rule for 7.02 compatibility)
npm run auto_transpile        # Transpile ABAP → JS
npm run unit                  # Run unit tests in Node.js
```

CI lints against all three targets (`ABAP_702.yaml`, `ABAP_STANDARD.yaml`, `ABAP_CLOUD.yaml`) and runs the transpiled unit tests (`test_unit.yaml`). All must stay green — they guarantee that any subset of methods can be vendored into any consumer on any release.

## Rules for AI Assistants

1. **Do not modify `src/00/01/` (ajson) and `src/00/02/` (S-RTTI)** — mirrored from external projects.
2. **Never break the master-catalog contract** (see above): this repository must remain the superset of all utility methods across all consumers — for *every* vendored class, not only the context class. Methods added downstream are merged back here by the periodic AI sync, and unit tests live here.
3. **Always run `npx abaplint`** before considering changes complete.
4. **Multi-environment compatibility** — code must work on NW 7.02, Standard ABAP, and ABAP Cloud. No direct use of on-premise-only or cloud-only APIs without a dynamic-call branch.
5. **String literals use backticks** (`` ` ``), not single quotes; `xsdbool()` for booleans; `NEW #()` instead of `CREATE OBJECT`.
6. **Public API stability:** downstream copies mirror method signatures, so default to additive changes — new methods and new optional parameters, not edits to what exists.

   A rename is possible, because nobody installs this repository as a dependency (every consumer runs its own renamed copy, so a rename here breaks no running system). But it only pays off if it lands everywhere at once: rename in this catalog **and** in every consumer's context class in the same coordinated change, or the next sync reports the signature as drift and reverts it. Before renaming, check each consumer for callers that pass the parameter **by name** — a consumer that cannot be edited blocks the rename outright. Concrete case: `rtti_create_sel_tab_type`'s `ir_tab` keeps its Hungarian name because abap2UI5's frozen `src/99` passes it as a named argument; the parameter is documented as such at the declaration in both repositories.
