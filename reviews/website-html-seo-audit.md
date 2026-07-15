# Website HTML, SEO, and static-output audit

Date: 2026-07-14

Production: `https://condensed-phase-spectrum.vercel.app`

Verified target: the production alias above, in `READY` state at audit time.

## Release verdict

PASS. The local export, production crawl, metadata, asset delivery, security headers, redirects, and post-fix Lighthouse runs satisfy the release gates. No executable client JavaScript is shipped.

## Local build and export verification

The final release commands passed:

```sh
cd website
npm run check
npm audit --omit=dev --audit-level=high
npm run build:vercel
```

The verified export contains:

- 6 complete paper pages and 14 diagram assets;
- 9 indexable routes and 12 HTML files;
- 1,089 checked local links;
- complete MathML and no KaTeX errors;
- 16 synchronized Haskell files and 10 synchronized Lean files;
- 0 executable script tags, JavaScript preloads, or retained JavaScript files.

The finalizer removed 1,964 script tags and 12 JavaScript preloads. It reduced HTML from 10,109,660 to 3,277,110 bytes and pruned 88 unused runtime files totaling 17,129,864 bytes. Total static-delivery savings were 23,962,414 bytes. Eight JSON-LD blocks remain on the routes that declare structured data.

## Production acceptance

A fresh crawl of the production alias established:

- all 9 sitemap routes return `200`;
- all 8 non-root route variants without a trailing slash return `308` to the canonical slash form;
- HTTP redirects to HTTPS;
- every route has its exact self-canonical URL, matching `og:url`, route-specific social metadata, and `index, follow` directives;
- `robots.txt` and `sitemap.xml` use the production origin consistently;
- the five configured security headers are live on every route: HSTS, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, and `Permissions-Policy`;
- deployed HTML contains 0 executable scripts, JavaScript references, raw cross-reference labels, comma-fragment references, broken fragments, literal LaTeX labels, or KaTeX errors;
- an unknown route returns `404`.

Representative PDF, Haskell, Lean, review Markdown, icon, WebP cover, Open Graph PNG, and SVG diagram assets all return `200`, pass content-type checks, and match their local SHA-256 values. The live homepage also matches `website/out/index.html` byte for byte:

```text
528015443eaa78ebea44c6e6ae87e8a9e8317eb2780f239f1b3352fb40d8572a
```

## Lighthouse 13.4.0 mobile results

All measurements were rerun against the final production deployment with Chrome 150 and simulated mobile throttling.

| Route | Performance | Accessibility | Best Practices | SEO | Binary failures |
|---|---:|---:|---:|---:|---:|
| `/` | 98 | 100 | 100 | 100 | 0 |
| `/papers/` | 99 | 100 | 100 | 100 | 0 |
| `/papers/microscopic-effective-theories/` | 94 | 100 | 100 | 100 | 0 |

| Route | FCP | LCP | TBT | CLS | Speed Index |
|---|---:|---:|---:|---:|---:|
| `/` | 1.357 s | 1.957 s | 0 ms | 0 | 3.527 s |
| `/papers/` | 1.161 s | 2.061 s | 0 ms | 0 | 2.320 s |
| `/papers/microscopic-effective-theories/` | 1.893 s | 2.493 s | 0 ms | 0 | 3.932 s |

The runs produced no Lighthouse warnings or runtime errors. The corrected display-math role passes `aria-prohibited-attr`, and the wordmark now uses its visible content as its accessible name. `label-content-name-mismatch` is not applicable on the final homepage.

These are controlled lab measurements, not field Core Web Vitals. A new site has no meaningful 75th-percentile CrUX history yet.

## Resolved release findings

- The production alias is deployed and healthy; the earlier `DEPLOYMENT_NOT_FOUND` state is closed.
- PDF-faithful cross-references now cover all 111 calls and 115 targets, including 71 labeled equations with visible numbering.
- Regression gates reject raw reference labels, missing reference metadata, dead Next.js runtime files, invalid labeled-math roles, and wordmark name overrides.
- Mobile browser checks pass at 320, 375, 768, and 1,440 pixels without overflow or interaction errors.
- Static routing, canonical URLs, metadata, JSON-LD, the icon, security headers, and the trailing-slash policy are verified both locally and live.

## Optional post-launch work

- Evaluate a Content Security Policy after deciding how strictly to constrain inline JSON-LD and styles.
- Submit the sitemap through search-engine webmaster tools; IndexNow support is optional.
- Monitor field performance for the longest paper once real-user data becomes available.

## Reproduction commands

```sh
vercel inspect https://condensed-phase-spectrum.vercel.app
curl -sSIL https://condensed-phase-spectrum.vercel.app/
curl -fsSL https://condensed-phase-spectrum.vercel.app/sitemap.xml
npx --yes lighthouse@13.4.0 https://condensed-phase-spectrum.vercel.app/ \
  --form-factor=mobile \
  --throttling-method=simulate \
  --only-categories=performance,accessibility,best-practices,seo \
  --output=json \
  --chrome-flags='--headless=new --no-sandbox'
```

AUDIT VERDICT: PASS
