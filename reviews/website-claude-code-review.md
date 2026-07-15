I now have comprehensive direct evidence. All three round-1 findings and every numeric gate check out. Here is the round-2 review.

---

# Release Review - Round 2 (Spectral Ledger static export)

## Summary table

| Item | Round‑1 | Round‑2 result | Key evidence |
|---|---|---|---|
| **F1** visible raw label slugs | High blocker | **RESOLVED** | 0 `[eq:*]`/`[thm:*]`... in `website/content/papers/*.json` and `website/out/**/*.html`; all `\ref`-family links rewritten to numbers |
| **F2** verifier gap | Low | **RESOLVED** | `verify-content.mjs:127‑130`, `verify-export.mjs:189‑191` now fail on raw label text + comma hrefs; build throws on unconsumed/missing ref metadata |
| **F3** orphaned Next runtime | Low | **RESOLVED** | 0 `.js` under `out/`; only `robots.txt` among `.txt`; no `index.txt`/`__next*.txt` |
| 111 reference call occurrences | gate | **PASS** | source `papers/latex/*.tex` = 111 calls; JSON `references.occurrences` sums 26+18+11+9+33+14 = 111 |
| 115 reference targets | gate | **PASS** | JSON `references.targets` sums 26+20+11+9+35+14 = 115; matches multi-target calls |
| 71 labeled equations numbered | gate | **PASS** | 71 `equation-anchor id="eq:..."` (16+20+35); 68 numeric `\tag{}` + 3 diagram captions "equation (N)" |
| 14 diagram SVGs / 14 image regions | gate | **PASS** | 14 files `out/diagrams/*.svg`; 14 distinct `src="/diagrams/*.svg"`, each once |
| 25 uniquely named table regions | gate | **PASS** | 25 `table-scroll[role=region][tabindex=0]`; uniqueness asserted per paper |
| exactly one H1 / indexable route | gate | **PASS** | `<h1>`=1 in all 12 HTML files |
| 0 broken internal route/asset/fragment | gate | **PASS** | `verify-export.mjs:180‑217` resolves every same-origin link + fragment |
| 0 KaTeX errors / visible raw TeX | gate | **PASS** | 0 `katex-error`, 0 leaked `\ref`/`\label`/`tikzcd` in HTML |
| 0 executable scripts / JSON-LD kept | gate | **PASS** | all 8 `<script>` are `type="application/ld+json"` on the 8 schema routes |
| app icon linked | gate | **PASS** | `<link rel="icon" href="/icon.svg...">` in 12/12 files; `out/icon.svg` present |
| metadata/robots/sitemap/headers/trailing slash | gate | **PASS** | origin consistent across canonical/OG/robots/sitemap; `vercel.json` has all 5 security headers, `trailingSlash:true`, `outputDirectory: website/out` |

## Evidence that the fixes are real, not string masking

**Numbering is PDF-faithful (not an HTML counter).** `build-content.mjs:198‑253` (`latexReferenceMap`) runs `lualatex -draftmode` and parses `\newlabel{...}` and `...@cref` entries from the compiled `.aux` for the number and cleveref type - the same compilation that produces the PDF. Unsupported types or non-numeric displays throw (`:237‑248`), so the build itself gates faithfulness. Display equations then get `\tag{<aux number>}` injected (`:410‑413`).

**F-norm = (11), from the aux.** `out/papers/locality-condensed-families/index.html` contains exactly one `\tag{11}` (the x-tex annotation) on the `id="eq:F-norm"` display; verifier asserts `.tag` text `=== "(11)"` (`verify-content.mjs:186‑194`).

**Cross-reference semantics render correctly** (all from real HTML, not the verifier's PASS):
- `\cref{thm:objectwise,thm:descent}` → `theorems 3.3 and 3.5` (lowercase, plural, "and"). `condensed-observables/index.html:118`.
- `\Cref{ce:norms,ce:states}` → `Theorems 5.1 and 6.2` (capitalized). `:422`.
- `\cref{sec:kitaev,sec:bdi,sec:aklt}` → `sections 4 to 6` (consecutive range collapsed, endpoints linked). `physical-realizability/index.html:32`.
- `\ref/\cref/\ref` for `thm:flattening` → `3.3 / theorem 3.3 / 3.3` in source order - validates the call-queue ordering (`microscopic-effective-theories/index.html:153,189,537`).
- equation-labeled tikzcd `eq:comparison-diagram` → figcaption `...comparisons, equation (5)` (`physical-realizability/index.html:100`).
- `thm:fh` → `theorem 2.3` present. Parentheses only on equations (`referenceNumberText` `build-content.mjs:260‑263`); typed names/plurals via `referenceTypeName` (`:255‑258`).

**Bidirectional completeness.** `renderReferenceLinks` throws if any `#`-anchor lacks call metadata (`:287`) and if any LaTeX call is left unconsumed (`:321‑324`). Reference links are rewritten *before* citations are linkified (`:473` vs `:483`), so only `\ref`-family anchors are processed - no spurious throws, no citation false-positives. Source count (111/115) equals emitted count exactly, so nothing was silently dropped.

**F3 pruning is real and surgical.** `finalize-static-export.mjs:68‑75` deletes `_next/**.js`, `index.txt`, `__next*.txt`; `verify-export.mjs:229‑238` fails if any survive. Confirmed retained: `out/_next/static/chunks/1numukwmx36v7.css`, Next + KaTeX fonts, `out/icon.svg`, diagrams, PDFs, covers, OG images, JSON-LD.

## Concrete findings

None at release-blocking or lower severity.

Two non-blocking observations (no action required):
- The verifier's raw-label assertion is form-specific (`text === target || text === '[target]'`), catching exactly the round-1 shape. This is adequate here only because the *primary* defense is `build-content.mjs` throwing on any unresolved/unconsumed reference, which makes a raw label unreachable in output regardless of shape. The narrow verifier is a secondary net, not the guarantee.
- Round‑1 F4 (origin `condensed-phase-spectrum.vercel.app` reachability) is out of scope this round. Artifact-level URL usage is internally consistent (robots.txt, sitemap.xml, canonical/OG all agree) - no inconsistency to flag.

Round‑1 findings F1, F2, and F3 are resolved, and no new release blocker was found.

## Late type-only delta check

The final check inspected `website/lib/content.ts` at mtime `2026-07-14 21:06:11`, after the main round-2 review started.

- **Declaration matches all generated JSON.** `website/lib/content.ts:6-17` declares `references: { occurrences: number; targets: number }`; all six `website/content/papers/*.json` provide exactly that shape with integer values.
- **Source of truth confirms numbers, not optional.** `website/scripts/build-content.mjs:325` returns `{ occurrences, targets: targetCount }` and `:588` emits `{ html, toc, references: referenceStats }`, so the field is always populated and correctly required.
- **No unsafe runtime/React assumption was introduced.** `references` is not rendered by React; the paper route reads only `content.toc` and `content.html`. The existing `as PaperContent` JSON-parse cast is unchanged.
- **No duplicate or conflicting type exists.** `PaperContent` is defined only in `website/lib/content.ts`.
- **The type declaration cannot change generated output.** The generator is plain `.mjs`; the TypeScript declaration does not participate in JSON emission.

DELTA VERDICT: PASS

## Post-release-gate delta review

An external Claude Opus/high read-only review checked the four changes made after the canonical PASS.

| Delta | Result | Evidence |
|---|---|---|
| Labeled display math uses `role="math"` | **PASS** | `website/components/math.tsx:19-23` applies the role only when an accessible label exists. The current labeled export retains KaTeX HTML and MathML with one authoritative accessible name. |
| Redundant wordmark `aria-label` removed | **PASS** | `website/components/site-header.tsx:7-14` leaves the sigma mark hidden and derives the link name from visible text. The primary navigation keeps `aria-label="Primary navigation"`. |
| Export regression gates added | **PASS** | `website/scripts/verify-export.mjs:134-141` rejects labeled `.math-display` elements without `role="math"` and rejects a restored wordmark `aria-label`. The current export satisfies both checks across the canonical routes. |
| Root Vercel framework detection disabled | **PASS** | `vercel.json:3-6` uses `framework: null` with explicit nested install, build, and output commands. This is consistent with the repo-root project and `website/` Next.js package, while retaining static export, trailing-slash behavior, and response headers. |

The locally recorded Chromium accessibility audit remains supporting local-export evidence, not live field or Core Web Vitals evidence. The reviewer found no new accessibility, semantic HTML, static-export, verification, or deployment blocker.

DELTA VERDICT: PASS

VERDICT: PASS
