I have gathered sufficient direct evidence. Here is the release review.

---

# Release Review - Spectral Ledger static export (`website/out/`)

## Release-gate confirmations

| Gate | Result | Evidence |
|---|---|---|
| 14 diagram SVG assets + 14 rendered diagram image regions | **CONFIRMED** | 14 files in `website/out/diagrams/*.svg`; 14 unique `<img src="/diagrams/*.svg">` inside `<figure class="math-diagram math-diagram-rendered">` (e.g. `papers/microscopic-effective-theories/index.html:5,10,558`; `physical-realizability/index.html:100,499,501`). Each SVG referenced exactly once - none lost or duplicated. |
| 25 table regions, each with a unique accessible name | **CONFIRMED** | 25 × `class="table-scroll" tabindex="0" role="region" aria-label="Scrollable table N: ..."` (6+5+1+8+2+3 across the six papers). Names are caption/heading-derived and index-prefixed, so unique within each page - e.g. `microscopic-effective-theories/index.html:40-730`. |
| Exactly one H1 on every indexable route | **CONFIRMED** | `<h1>` count = 1 in all 12 generated HTML files (9 indexable + `404.html`, `404/index.html`, `_not-found/index.html`). |
| Zero broken internal route/asset targets | **CONFIRMED** | `verify-export.mjs` resolves every same-origin link + fragment on all 9 routes; I independently confirmed all referenced assets exist (`out/diagrams/*`, `out/og/*.png`, `out/covers/*.webp`, `out/icon.svg`). |
| Zero KaTeX error nodes | **CONFIRMED** | 0 matches for `katex-error`/`<merror>` in any HTML file. |
| Zero raw LaTeX labels / unsupported math left visible | **REFUTED** | ~57 visible `[eq:label]` cross-references rendered as reader-facing link text across 3 papers (see F1). |
| Zero executable scripts; JSON-LD present & preserved as non-executable | **CONFIRMED** | Every `<script>` in `out/` is `type="application/ld+json"` (8 tags, 8 files); 0 executable scripts. JSON-LD present on all routes that declare schema (`/`, `/papers/`, 6 papers); `/artifacts/` intentionally declares none. |
| App icon exists and is linked | **CONFIRMED** | `out/icon.svg` exists; `<link rel="icon" href="/icon.svg?...">` present in all 12 HTML files. |

One explicitly required gate (**no raw LaTeX labels visible**) fails.

## Findings

### F1 - Visible raw LaTeX cross-reference labels in body prose (Severity: High, release-blocking)
- **Path / cause:** `website/scripts/build-content.mjs:297-306`. Pandoc is invoked (`build-content.mjs:529-536`) without a cross-reference filter or `--number-sections`, so `\eqref{...}`/`\ref{...}` become links whose visible text is the raw label key. The builder creates anchor IDs from `\label{}` (so the `href` resolves) and rewrites *multi-target comma* references, but never rewrites *single-reference* link text.
- **Direct evidence:** `website/out/papers/locality-condensed-families/index.html:128` - `...obtained by multiplying <a href="#eq:F-norm">[eq:F-norm]</a> by ...`. Total ≈57 occurrences: `locality-condensed-families` (16), `physical-realizability` (27), `invertible-condensed-phase-spectrum` (14). Readers see internal slugs such as `[eq:F-norm]`, `[eq:comparison-diagram]`, `[eq:relative-charge]` instead of a number/label. The other three papers are clean.
- **Specific fix:** add a numbering + reference-resolution pass in `renderPaperHtml` (assign display numbers to labelled equations/diagrams and rewrite the text of any `a[href^="#"]` whose text matches `[\w:-]+`), or run Pandoc with `pandoc-crossref`. Then extend `verify-content.mjs`/`verify-export.mjs` to fail on any anchor text matching `^\[[a-z]+:.*\]$`.

### F2 - Verification scripts do not enforce the "no visible raw labels" gate (Severity: Low)
- **Path:** `website/scripts/verify-export.mjs:180-210`, `verify-content.mjs`. Link checking asserts the fragment target exists but never inspects the visible link text; the math audit only checked for `\label{}` tokens and raw math delimiters, not Pandoc `[key]` output. The self-reported PASS on this gate is therefore bypassable - F1 slipped through both build gates and both prior audits.
- **Fix:** add the assertion described in F1 so this class is caught at build time.

### F3 - Orphaned Next runtime artifacts remain in the export (Severity: Low)
- **Path:** `website/scripts/finalize-static-export.mjs:51-53` operates only on `.html`. It strips `<script>`/JS-preload references from HTML but leaves the actual runtime files on disk: `website/out/_next/static/chunks/*.js` (10 JS chunks) and ~70 RSC/Flight payloads (`**/__next*.txt`, `**/index.txt`). The finalizer's report claims it removed "the unused Next client runtime," but only the HTML references were removed; the chunks and serialized RSC trees still ship. With `cleanUrls: true` the `.txt` payloads are reachable (e.g. `/index.txt`), though none are linked or in the sitemap.
- **Not a safety violation:** needed content, CSS (`_next/static/chunks/*.css` still linked), fonts, JSON-LD, and corpus links are all retained.
- **Fix:** after export, prune `out/_next/static/chunks/*.js` and `out/**/__next*.txt` + `out/**/index.txt`, or accept as harmless dead weight (they are unreferenced by the finalized HTML).

### F4 - Production origin reachability (Severity: operational; not independently verified here)
- The origin `https://condensed-phase-spectrum.vercel.app` is hard-coded in `website/app/layout.tsx:27`, `website/app/robots.ts:3`, and `website/app/sitemap.ts:4`, and is internally consistent across canonical/OG/Twitter/robots/sitemap in the generated output. `reviews/website-html-seo-audit.md:41-53` reports this alias returns `DEPLOYMENT_NOT_FOUND`. I have no network access and did not re-verify this; if that audit is still current it is a deploy-time blocker (canonical/sitemap point at an unreachable host), but it is not a defect in the generated artifact itself.

Config, semantics, and metadata are otherwise sound: `next.config.ts` correctly sets `output: "export"`, `trailingSlash: true`, `images.unoptimized`; root `vercel.json` matches (`outputDirectory: website/out`, `trailingSlash`, `cleanUrls`, and all five security headers); the finalizer's JSON-LD preservation is regex-safe and double-checked by `verify-export.mjs:224-227`; 404 documents carry `noindex` and one `h1`; diagram `alt`/captions are figure-specific.

The core deliverable - the research papers - ships ~57 reader-visible raw label slugs across half the corpus, and this violates an explicit release gate that no build check enforces.

VERDICT: NEEDS_FIX
