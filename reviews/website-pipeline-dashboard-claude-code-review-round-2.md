# Claude code review — pipeline dashboard, round 2

Reviewer: Claude Opus, high effort, focused read-only review

## Verdict

**PASS**

Every accepted round-one finding was resolved or explicitly deferred, the
exact release metrics and `Not recorded` coverage remained correct, the
generated page remained a zero-client-JavaScript static export, and no new
release-blocking defect was introduced.

## Confirmed fixes

| Check | Result |
|---|---|
| Headline values render from the typed snapshot | Confirmed |
| Invocation and token totals are derived or guarded | Confirmed |
| Export verifier checks sub-ledger arithmetic | Confirmed |
| Native and isolated Codex token subtotals are visible | Confirmed |
| Snapshot status has an effective semantic role | Confirmed |
| Corpus wording is consistent | Confirmed |
| Exact release metrics and missing-data boundaries remain correct | Confirmed |
| Page remains static and accessible | Confirmed |

The reviewer independently recomputed:

- `recordedInvocations = 10 + 24 + 20 + 24 = 78`;
- `input = 1,767,338,496 + 40,665,511 = 1,808,004,007`;
- `grossTotal = 1,808,004,007 + 5,125,595 = 1,813,129,602`;
- `nativeCodex + isolatedCodex = 1,813,129,602`;
- the approval window rounds to `3 h 31 m 12 s`;
- the cache split remains `97.75 + 2.25 = 100`.

## Remaining findings

### 1. Low — cache bar label needs a semantic role

The cache-composition `div` has an `aria-label`, but no role, so assistive
technology may ignore the label. The adjacent legend is hidden from assistive
technology. Visible prose preserves the same information, so this is not a
release blocker. Add `role="img"` so the label describes the visualization.

### 2. Low — cache percentages still duplicate computed values

The typed snapshot drives the bar widths, while `97.75%` and `2.25%` remain
hardcoded in the introduction, accessible label, and legend. Render those
strings from the computed snapshot percentages to preserve the single-source
contract established for the headline metrics.

### 3. Informational — narrative copy repeats summary counts

Supporting prose repeats counts such as 34, 78, 10, and 24. Those values are
currently correct and are readable prose rather than independent data fields.

### 4. Informational — generated `colSpan` casing

The generated HTML retains `colSpan="2"`. HTML attribute names are
case-insensitive, so rendering and accessibility are unaffected.

### 5. Informational — deferred social artwork and retrospective commit

Generic social artwork remains intentionally deferred. The frozen commit
continues to identify the historical research release, not this later
dashboard implementation.

## Round-one disposition

| Round-one item | Result |
|---|---|
| Headline duplication | Resolved |
| Unguarded arithmetic | Resolved |
| Generic social artwork | Deferred by scope |
| Snapshot-status semantics | Resolved |
| UTC/local date boundary | Confirmed non-defect |
| Corpus wording | Resolved |
| Hidden token subtotals | Resolved |

The round-two verdict is PASS. Findings 1 and 2 are accepted for a final
hardening delta before release.
