# Release code review — Spectral Ledger `/pipeline/`

Reviewer: Claude Opus, high effort, read-only (`Read`, `Glob`, `Grep`)

**VERDICT: PASS**

No release-blocking defects were found. All contract metrics are
arithmetically consistent and correctly rendered; the page is a genuine
zero-client-JavaScript static export; accounting is honest; accessibility,
semantics, metadata, JSON-LD, sitemap, and navigation are sound; and tables
and long values are contained with no page-level overflow. The findings below
are non-blocking hardening items.

## Arithmetic verification

- Codex sessions `34` = `10` native + `24` isolated.
- Model invocations `78` = `10 + 24 + 20 + 24`. The 34-to-78 distinction is
  explicit: 34 is the Codex session record, while 44 is the AGY and Claude
  external-review record.
- Runtime: `03:36:21.520Z - 00:05:09.813Z = 3 h 31 m 11.707 s`, correctly
  rounded to `3 h 31 m 12 s`.
- Cached input `1,767,338,496` + uncached input `40,665,511` = input
  `1,808,004,007`; input + output `5,125,595` = gross `1,813,129,602`.
  Reasoning output `1,954,724` is less than output, is identified as a subset,
  and is not added again. Native and isolated Codex totals sum to the gross
  total. The cache split sums to 100%.
- External reviewer tokens and monetary spend render `Not recorded`, matching
  the reporting contract.

## Findings

### 1. Medium — headline metrics duplicate the snapshot

`website/app/pipeline/page.tsx` renders the four headline metrics as string
literals instead of reading `pipelineSnapshot`. The same values are also
pinned in `website/scripts/verify-export.mjs`. They currently agree and the
export verifier protects the rendered page, but the data file and cards could
diverge after a future data edit. Render the cards from the typed snapshot so
the data module remains the single source of truth.

### 2. Low — totals are not derived or checked against sub-figures

Nothing asserts that the four invocation-group counts sum to 78, that cached
plus uncached input equals input, or that input plus output equals the gross
total. The export verifier checks the headline metrics but not the token
sub-ledger or invocation table. Derive or explicitly assert the totals and
extend the export contract to protect the component figures.

### 3. Low — generic social artwork

The route uses `/og/home.png` with pipeline-specific alt text. This is valid
but does not provide page-specific artwork.

### 4. Low — snapshot-status label has no semantic role

The `aria-label` on `div.pipeline-freeze` is generally ignored because the
element has no semantic or landmark role. Visible text preserves all
information. Adding `role="region"` would make the label effective.

### 5. Informational — timestamp date boundary

The snapshot and structured-data dates are 15 July UTC while the local
environment date was still 14 July. This is internally consistent with the
UTC release timestamps and the design contract.

### 6. Informational — corpus wording

“Five papers and synthesis” and “Six papers” refer to the same corpus, but the
second phrase could be clarified as “five papers plus synthesis.”

### 7. Informational — unused breakdown and retrospective commit

The native/isolated Codex token subtotals are defined but not rendered. The
frozen commit is intentionally the earlier release-completion record rather
than the dashboard implementation.

## Requirements coverage

| Requirement | Result |
|---|---|
| Static, zero-client-JavaScript `/pipeline/` | Pass |
| 34 sessions / 10 native / 24 isolated / 78 invocations distinguished | Pass |
| 20 AGY + 24 Claude rounds | Pass |
| Runtime and token arithmetic | Pass |
| Missing external tokens and spend reported honestly | Pass |
| Privacy: no local paths or private session IDs | Pass |
| Semantic HTML and keyboard-accessible table regions | Pass |
| Narrow-screen containment and long-value wrapping | Pass |
| Canonical metadata, JSON-LD, sitemap, header, and footer links | Pass |
| React and Next.js static-server-component design | Pass |
| Export regression protection | Pass, with hardening findings 1 and 2 |

## Review disposition

The initial verdict is PASS. Findings 1, 2, 4, and 6 are valid and inexpensive
to resolve in the dashboard implementation. Finding 3 is deferred because a
new generated social image is outside this reporting-page scope. Finding 5 is
confirmed as a UTC date boundary, not a defect. Finding 7 is resolved by
rendering the native/isolated token subtotals and retaining the explicitly
retrospective release commit.
