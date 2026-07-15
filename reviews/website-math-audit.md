# Independent website math and corpus-fidelity audit

Date: 2026-07-14
Scope: frozen static export in `website/out`, all six generated paper JSON files, the six LaTeX sources, and the generated diagram SVGs.
Mode: read-only audit of website source and generated artifacts; this report is the only file created.

## Release finding

No release-blocking math-rendering or corpus-fidelity defect remains in the frozen export. The source-to-site story is internally consistent:

```text
six LaTeX papers
  -> Pandoc HTML with TeX-preserving math spans
  -> server-side KaTeX or tikz-cd SVG conversion
  -> six generated paper JSON documents
  -> six statically exported paper routes
  -> browser-visible HTML, MathML, and SVG
```

## Commands and results

The repository validators and TypeScript check were rerun against the frozen artifacts:

```sh
cd website
npm run verify:content
npm run verify:export
npx tsc --noEmit --incremental false
```

All exited 0. `verify:content` reported six papers, 14 diagrams, complete MathML, 16 Haskell files, and 10 Lean files. `verify:export` reported nine HTML routes plus `robots.txt` and `sitemap.xml`.

Source math inventory was independently derived with Pandoc rather than trusted from the generated manifest:

```sh
pandoc -f latex -t html5 --mathjax papers/latex/<paper>.tex
```

The resulting `span.math` elements were parsed with Cheerio and classified as KaTeX expressions or `tikzcd` environments. Generated JSON and exported HTML were then independently parsed to count KaTeX, MathML, TeX annotations, images, duplicate IDs, unresolved fragment links, empty citations, and raw TeX outside `.katex`, `code`, and `pre`.

| Paper | Source math spans | Diagram spans | `tikzcd` environments | Expected/found KaTeX | SVGs |
|---|---:|---:|---:|---:|---:|
| Condensed observables | 321 | 1 | 1 | 320 / 320 | 1 |
| Synthesis spectrum | 229 | 3 | 3 | 226 / 226 | 3 |
| Locality | 379 | 0 | 0 | 379 / 379 | 0 |
| Microscopic to EFT | 315 | 4 | 5 | 311 / 311 | 5 |
| Physical realizability | 261 | 3 | 4 | 258 / 258 | 4 |
| Thermodynamic gaps | 213 | 1 | 1 | 212 / 212 | 1 |
| **Total** | **1,718** | **12** | **14** | **1,706 / 1,706** | **14** |

The requested “12 tikz-cd conversions” is a count of Pandoc math spans, not diagrams. Two spans each contain two independent `tikzcd` environments. The authoritative source count is therefore 14, and the export correctly contains 14 SVGs rather than silently dropping the second diagram in either span.

SVG integrity was checked with:

```sh
find website/public/diagrams -name '*.svg' -type f -print0 \
  | xargs -0 -n1 xmllint --noout
find website/public/diagrams -name '*.svg' -type f -size 0 -print
```

All 14 SVGs are well-formed and nonempty. Every generated `<img>` resolves to an existing SVG and has a nonempty `alt` attribute.

## Static math and document checks

The six JSON documents and six exported paper pages agree exactly:

- 1,706 KaTeX roots, 1,706 `<math>` trees, and 1,706 `application/x-tex` annotations.
- Zero `.katex-error`, `<merror>`, remaining `span.math`, raw TeX delimiters/environments, or red KaTeX fallback nodes.
- Zero dropped formulas relative to the independently derived Pandoc inventory.
- Macro-sensitive structures survive sanitization, including two `menclose` nodes and one `mphantom` node.
- Each expression has a `.katex-mathml` representation; each duplicate visual `.katex-html` tree is `aria-hidden="true"`.
- Zero duplicate IDs, zero unresolved internal fragment targets, zero empty citation spans, and 64 visible citation spans containing 80 resolved links after multi-reference expansion.
- The five allowed claim-status labels are exactly `established`, `proposed`, `conjectural`, `open`, and `obstructed` in `website/data/papers.ts:1-6`; no sixth label is accepted by the type.

Accessibility was adequate at the initial audit: formulas retained semantic MathML and TeX annotations, and all 14 diagrams had alternative text. That first pass noted that the diagram descriptions were generic and depended on surrounding prose. The post-fix pass below resolved the finding with a distinct source-specific description and caption for every diagram.

## Browser rendering

The frozen export was served locally and all six paper routes were exercised with Playwright at 1440x900 and 390x844. Lazy diagram images were scrolled into view before their intrinsic dimensions were checked.

Across the 12 page/viewport combinations:

- 0 KaTeX errors, 0 MathML errors, 0 raw math spans, and 0 JavaScript page errors.
- All 14 diagrams completed with nonzero intrinsic width and height; every diagram response was HTTP 200 or a valid cache response.
- 0 page-level horizontal overflows and 0 elements escaping the viewport without an `overflow-x: auto` or `scroll` ancestor.
- Long display equations overflow only inside their designated scroll containers: 0 unsafe equation overflows at either viewport.
- The local static server made one harmless `/favicon.ico` 404 request. It does not affect any paper, formula, diagram, or navigation target.

## Corpus-fidelity checks

The rendered TeX annotations were checked against the source, not only visually sampled.

- **Five-stage sequence:** the boxed sequence appears in the required order with four down-arrows and the `\infty`-groupoid stage intact (`papers/latex/invertible-condensed-phase-spectrum.tex:109-121` and `:1561-1573`).
- **Witness versus image:** the quantitative `\mathfrak{Gap}^{\mathrm{wit}}`/`\Gap_F^{\mathrm{wit}}` object remains distinct from the propositional image `\mathfrak{Gap}^{\mathrm{prop}}`/`\Gap_F^{\mathrm{prop}}` (`invertible-condensed-phase-spectrum.tex:543-590`; `thermodynamic-gaps.tex:843-874`).
- **Target/reference orientation:** both the paper-specific and synthesis formulas render target minus reference, `[p_h]-[p_{h_{\mathrm{ref}}}]`, and the prose explicitly fixes the first argument as target (`microscopic-effective-theories.tex:549-558`; `invertible-condensed-phase-spectrum.tex:1030-1040`).
- **`c_E` versus `\kappa`:** the physical comparison map `c_E:\nu_{\mathrm{mic}}(H)\mapsto\nu_E(H)` is preserved as a natural comparison, while `\kappa(h,h_{\mathrm{ref}})` remains the relative operator K-class; the export does not conflate them (`invertible-condensed-phase-spectrum.tex:949-958` and `:1019-1040`).
- **Tail requirement:** the rendered paper includes the uniform tail `T_F(R)` and the separate limit requirement `\lim_{R\to\infty}T_F(R)=0`; the synthesis also warns that finite-region continuity does not imply it (`thermodynamic-gaps.tex:267-280`; `invertible-condensed-phase-spectrum.tex:367-368`).
- **Comparison arrows:** the controlled free flattening arrow is the only established microscopic operator-K arrow. In the general chain, `L` and `R` remain dashed/open and `I` is scoped to its declared EFT domain; no `K_{\mathrm{op}}\to\mathrm{EFT}^{\mathrm{invertible}}` arrow or commutative comparison square is introduced (`microscopic-effective-theories.tex:1533-1565`). The synthesis likewise states that the comparison maps are not automatic inverses and renders unproved comparison-web arrows as dotted (`invertible-condensed-phase-spectrum.tex:995-1015` and `:1120-1138`).

## Findings by severity

- Release blockers: none.
- Major findings: none.
- Minor findings: none affecting mathematics, accessibility, navigation, or responsive layout.
- Optional improvement identified in the initial audit: replace the generic diagram `alt` sentence with diagram-specific summaries. This is resolved in the post-fix pass below.

## Post-fix verification

The optional diagram-accessibility improvement and the related structural fixes were implemented on 2026-07-14 and promoted into release gates:

- `sanitize-html` now preserves `aria-label`. The builder assigns all 25 horizontally scrollable, focusable table regions a concise indexed name derived from the nearest table caption or section heading, and the verifier requires names to be nonempty and unique within each paper.
- Pandoc's original H1/H2 levels remain unchanged in the JSON TOC, while imported article markup is shifted to H2/H3. An independent export scan found exactly one H1 per paper page, the React hero title, and zero H1 elements inside all six `.paper-prose` articles.
- All 14 diagram images now carry integer `width` and `height` attributes derived from the generated SVG's physical dimensions at 96 CSS pixels per inch. The content verifier recomputes the SVG intrinsic dimensions and requires an exact match.
- Each of the 14 diagrams now has a distinct source-specific `alt` description and caption. The verifier rejects empty descriptions, the former generic description/caption, missing dimensions, and duplicate descriptions.
- The new content gates were observed failing against the prior artifacts before the builder was changed. After regeneration, `npm run verify:content`, `npm run build`, and `npm run build:vercel` all exited 0; both build paths also passed `verify:export` for nine HTML routes plus robots and sitemap.
- A final exported-DOM scan found six paper pages, six total H1 elements, zero article H1 elements, 25/25 named table regions, 14/14 dimensioned diagrams, and zero generic diagram descriptions. All 14 regenerated SVGs also passed `xmllint --noout`.

## Final rendered-browser retest

After the coordinated production rebuild, Chromium/Playwright reran five representative routes at 320, 375, 768, and 1440 CSS pixels. All 20 combinations had `scrollWidth === clientWidth`, including long equations, diagrams, citations, and DOI links at 320 pixels. All 14 diagrams decoded with nonzero intrinsic dimensions and their source-specific alternatives. Equation and citation fragment links landed below the sticky header at phone and desktop widths. The static pages retained valid MathML and JSON-LD while containing zero executable scripts, console errors, page errors, failed requests, or HTTP error responses. Temporary screenshots were inspected during the audit and removed afterward. The audit server was stopped after capture.

## Exact cross-reference and numbering rerun

The rebuilt export was rerun after exact `.aux`-derived cross-reference text and visible equation tags were added. At 320 pixels, the locality, physical-realizability, and synthesis papers contained zero visible raw label tokens and displayed user-facing references such as `equation (1)` and `theorem 4.1`. After removing KaTeX's zero-width placeholder characters, every nonempty display tag was numeric: 16 of 16 in locality, 19 of 19 in realizability, and 33 of 33 in synthesis. Unnumbered displays retained empty tag slots, not false or raw labels.

All equation tags remained inside their `overflow-x: auto` display containers without page-level overflow. The four physical-realizability and three synthesis diagram captions also fit at 320 pixels; four of those captions carry the appropriate visible equation reference. A fresh 20-case route/viewport matrix again recorded no page overflow, console or page errors, failed requests, executable scripts, or HTTP error responses.

AUDIT VERDICT: PASS
