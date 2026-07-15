# Website responsive, accessibility, browser, and performance audit

Date: 2026-07-14
Artifact: exact static export in `website/out`, rebuilt at 20:45:25 local time
Browser: Chromium through Playwright, served from `http://127.0.0.1:4175/`

## Final result

The final exported website passes the release-relevant responsive and accessibility checks in this audit. The first rendered pass exposed four real narrow-screen overflow defects. Those defects were fixed, both production build paths passed, and the complete matrix was rerun against the rebuilt export before this verdict was assigned.

The temporary audit server was stopped after capture. No website source was edited during this final verification pass.

## Viewport and route matrix

The following routes were rendered at 320, 375, 768, and 1440 CSS pixels, for 20 route/viewport combinations:

- `/`
- `/papers/`
- `/artifacts/`
- `/papers/microscopic-effective-theories/`
- `/papers/invertible-condensed-phase-spectrum/`

| Route | 320 px | 375 px | 768 px | 1440 px |
| --- | --- | --- | --- | --- |
| `/` | 320/320, pass | 375/375, pass | 768/768, pass | 1440/1440, pass |
| `/papers/` | 320/320, pass | 375/375, pass | 768/768, pass | 1440/1440, pass |
| `/artifacts/` | 320/320, pass | 375/375, pass | 768/768, pass | 1440/1440, pass |
| Microscopic-to-EFT paper | 320/320, pass | 375/375, pass | 768/768, pass | 1440/1440, pass |
| Synthesis paper | 320/320, pass | 375/375, pass | 768/768, pass | 1440/1440, pass |

Each cell reports `documentElement.scrollWidth/clientWidth`. All 20 combinations had zero page-level horizontal overflow. The persistent navigation fit inside every viewport with zero overlapping links. At both phone widths, its three target boxes measured 59.4x44, 52.7x44, and 99.3x44 CSS pixels.

The initial failed render was useful diagnostic evidence:

- Home: `.hero-copy` and `.hero-ledger` resolved to 442 pixels with automatic grid-item minimums, producing a 458-pixel page.
- Artifacts: `.artifact-entry` resolved to 342.7 pixels inside a 288-pixel ledger, producing a 358-pixel page.
- Microscopic-to-EFT paper: no-wrap multi-citations expanded `.paper-prose` from 288 to 336 scroll pixels.
- Synthesis: unbroken DOI links expanded `.paper-prose` from 288 to 344 scroll pixels.

The final matrix confirms those four failure modes no longer enlarge the page.

## Keyboard and focus behavior

- The skip link is the first focus target at 320 and 1440 pixels. At 320 it rendered at 146.7x47.2 pixels, at `(12, 12)`, with a 3-pixel solid focus outline.
- Activating the skip link changed the hash to `#main-content`. The main region landed at the sticky-header boundary: 114 pixels on phone and 71 pixels on desktop.
- At 375 pixels, the mobile table of contents opened with Space while focus remained on its summary and retained a 3-pixel focus outline. Enter also toggled it.
- The largest paper has eight focusable table regions. All eight names are contextual and unique, from `Scrollable table 1: Status vocabulary` through `Scrollable table 8: Comparison checklist for later work`.
- Across all six papers, all 25 table regions have nonempty, contextual names unique within their paper.
- Every table on the 375-pixel test page was horizontally scrollable. With the first table focused, ArrowRight changed `scrollLeft` from 0 to 40 while preserving focus and its visible outline.

## Anchors and JavaScript-free navigation

The exported pages contain zero executable scripts and zero JavaScript/module preloads. Ordinary fragment navigation therefore exercises native browser behavior rather than a client router.

At 375 and 1440 pixels, clicked links to `#eq:five-stage-symbolic` and `#ref-Scholze2026` changed the URL hash, scrolled to an on-screen target, and cleared the sticky header:

| Target | 375 px target/header | 1440 px target/header |
| --- | ---: | ---: |
| Equation display | 267 / 114 px | 243 / 71 px |
| Citation entry | 216 / 114 px | 192 / 71 px |

The equation, citation, section, skip-link, and ordinary route anchors remain usable in the script-free export.

## Reduced motion

With `prefers-reduced-motion: reduce` emulated:

- the media query matched;
- root and button `scroll-behavior` computed to `auto`;
- transition and animation durations computed to `0.00001s`.

Without the preference, root scrolling returned to `smooth` and normal button transitions to `0.16s`. The reduced-motion branch therefore materially disables smooth and animated behavior.

## Images, diagrams, icon, and math

- All 14 diagram images across all six paper routes decoded with nonzero intrinsic dimensions.
- All 14 retained distinct source-specific alternatives; no generic diagram description remains.
- All six paper-cover WebP images decoded at 840x1087.
- The declared `/icon.svg` returned HTTP 200 as `image/svg+xml` and decoded at 150x150.
- No broken image, diagram, cover, or icon request was observed.

The separate math audit verifies 1,706 KaTeX/MathML expressions and exact formula fidelity. This pass confirmed that narrow equations and diagrams remain in local scroll containers without expanding the page.

## Static delivery and structured data

All representative pages had:

- zero executable scripts;
- zero JavaScript preloads;
- zero console errors;
- zero page errors;
- zero failed requests;
- zero HTTP responses at 400 or above.

Valid JSON-LD remains on home, the papers index, and both representative paper pages. The artifacts route intentionally has no JSON-LD block. Five non-blocking Chromium warnings on `/papers/` reported preloaded font files not used within the warning window; they do not indicate a failed resource or executable-script regression.

## Accessibility-tree equivalent

Chromium's full accessibility tree was captured through the DevTools Accessibility domain for the 375-pixel microscopic-to-EFT page. This is the available native equivalent to an axe tree inspection in the current harness.

- 14,406 total accessibility nodes; 13,752 exposed nodes.
- 94 focusable nodes.
- All links, headings, navigation landmarks, and named regions had accessible names.
- The sole unnamed `main` landmark is unique on the page and does not require a distinguishing label.
- Eight table regions appeared with eight distinct contextual names.
- Heading levels were one H1, 18 H2, and 56 H3.
- `/papers/` independently rendered one H1 followed by six H2 paper titles; the prior H1-to-H3 jump is resolved.

This was not a full third-party axe ruleset, so the audit does not claim an axe score. It does provide computed browser accessibility-tree evidence for the requested landmarks, names, controls, and headings.

## Local load and DOM measurements

These are local Playwright navigation measurements, not field Core Web Vitals. Three cache-busted runs were sampled at a 375x844 viewport:

| Route | Decoded HTML | DOM elements | Median response end | Median DOMContentLoaded | Median load |
| --- | ---: | ---: | ---: | ---: | ---: |
| Home | 32,966 bytes | 537 | 1.0 ms | 28.6 ms | 30.1 ms |
| Microscopic-to-EFT paper | 640,112 bytes | 16,544 | 2.1 ms | 54.7 ms | 69.1 ms |

The largest paper remains a large document and accessibility tree. That is a real maintenance/performance risk on slower devices, but the script-free export materially reduces runtime work. These localhost timings must not be interpreted as network, LCP, INP, or field-CWV measurements.

## Screenshot evidence

The following temporary viewport screenshots were captured and inspected during the audit:

- `home-320.png`
- `home-1440.png`
- `papers-375.png`
- `artifacts-768.png`
- `microscopic-320.png`
- `synthesis-1440.png`

The two key 320-pixel captures were also visually inspected after the quantitative matrix passed. All temporary screenshots were removed after the audit and are not shipped in the repository.

## Disposition of initial findings

| Initial finding | Final disposition |
| --- | --- |
| Anonymous table regions | Resolved: 25/25 contextual, per-paper unique names |
| Papers index H1-to-H3 jump | Resolved: one H1 followed by six H2 titles |
| Generic diagram alternatives | Resolved: 14/14 distinct source-specific descriptions |
| Small mobile navigation targets | Resolved and measured at 44 pixels high |
| Large paper DOM | Documented residual performance risk; no release failure in local rendered tests |
| Missing browser icon | Resolved: declared SVG icon returns 200 and decodes |
| Narrow-screen page overflow | Resolved across the full 20-case matrix |

## Exact cross-reference rerun

After the export gained exact LaTeX cross-reference text and visible equation numbers, the full five-route by four-viewport browser matrix was rerun at 320, 375, 768, and 1440 CSS pixels. All 20 cases again had `scrollWidth === clientWidth`, with zero console errors, page errors, failed requests, or HTTP error responses.

At 320 pixels, the locality, physical-realizability, and synthesis papers had zero visible raw label tokens. All 68 nonempty KaTeX equation tags were numeric (16 locality, 19 realizability, 33 synthesis) and stayed within horizontally scrollable display containers. The seven diagram captions across the latter two papers, including four captions carrying visible equation references, remained within their 254-pixel caption boxes and the viewport.

FINAL VERDICT: PASS
