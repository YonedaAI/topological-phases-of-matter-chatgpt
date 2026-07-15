# Pipeline dashboard implementation checklist

Approved scope: publish one static, source-backed `/pipeline/` snapshot for the
research release completed on 15 July 2026. This is a reporting page, not a new
orchestration system.

## Metric contract

- Distinguish **34 Codex sessions** from **78 recorded model invocations**.
- Break the 34 sessions into 10 native Codex agent threads and 24 isolated
  `codex exec` reviewer attempts; label the latter as superseded by the final
  Claude review record.
- Break the other 44 invocations into 20 AGY paper-review rounds and 24 Claude
  code-review rounds.
- Report 3 h 31 m 12 s from approval to release completion, with the snapshot
  timestamps and cutoff visible.
- Report 1,813,129,602 gross logged Codex tokens, including cached context;
  separately show input, cached input, uncached input, output, and reasoning
  output. Do not add reasoning output to the total because it is a subset of
  output.
- State that external-review token usage and monetary spend were not retained.
  Never display missing cost as zero or estimate API-equivalent spend.
- Describe provenance without exposing local absolute log paths or private
  session identifiers.

## Build and release checklist

- [x] Add a failing export contract for `/pipeline/`.
- [x] Add typed snapshot data, page metadata/JSON-LD, accessible tables, and the
      code -> review -> fix -> verify -> deploy trace.
- [x] Add Pipeline to primary/footer navigation and the sitemap.
- [x] Build the zero-client-JavaScript static export and test narrow and wide
      layouts for overflow.
- [x] Obtain an independent read-only Claude code review, fix valid findings,
      and rerun the complete verification suite.
Commit, push, deployment, and production-route verification are recorded in
the release handoff rather than pre-checked in this implementation file.
