import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import path from "node:path";
import { load } from "cheerio";

const root = process.cwd();
const outputRoot = path.join(root, "out");
const origin = "https://condensed-phase-spectrum.vercel.app";
const papers = [
  {
    slug: "locality-condensed-families",
    title: "Uniform Locality for Condensed Families of Quantum Lattice Interactions",
  },
  {
    slug: "condensed-observables",
    title: "Condensed Families of Quantum Observables",
  },
  {
    slug: "thermodynamic-gaps",
    title: "Thermodynamic Spectral Gaps in Parameterized Quantum Lattice Systems",
  },
  {
    slug: "microscopic-effective-theories",
    title: "From Microscopic Lattice Hamiltonians to Effective Theories",
  },
  {
    slug: "physical-realizability",
    title: "Physical Realizability of Invertible Phase Classes",
  },
  {
    slug: "invertible-condensed-phase-spectrum",
    title: "The Invertible Condensed Phase Spectrum Program",
  },
];
const routes = [
  { path: "", socialTitle: "Topological Phases of Matter in Condensed Mathematics", schemaTypes: ["WebSite", "Person"] },
  { path: "papers", socialTitle: "Research Papers | Spectral Ledger", schemaTypes: ["CollectionPage", "ItemList"] },
  { path: "artifacts", socialTitle: "Code, Proofs, and Reviews | Spectral Ledger", schemaTypes: [] },
  { path: "pipeline", socialTitle: "Pipeline Metrics | Spectral Ledger", schemaTypes: ["WebPage", "Dataset"] },
  ...papers.map((paper) => ({
    path: `papers/${paper.slug}`,
    socialTitle: paper.title,
    schemaTypes: ["ScholarlyArticle"],
    paper,
  })),
];
const failures = [];
const fragmentCache = new Map();
let checkedLinks = 0;

function fail(message) {
  failures.push(message);
}

function htmlPath(route) {
  return path.join(outputRoot, route, "index.html");
}

function expectedUrl(route) {
  return route === "" ? `${origin}/` : `${origin}/${route}/`;
}

function collectSchemaNodes(value) {
  if (Array.isArray(value)) return value.flatMap(collectSchemaNodes);
  if (!value || typeof value !== "object") return [];
  const graph = Array.isArray(value["@graph"])
    ? value["@graph"].flatMap(collectSchemaNodes)
    : [];
  return [value, ...graph];
}

function readJsonLd($, route) {
  const nodes = [];
  $('script[type="application/ld+json"]').each((_, element) => {
    try {
      nodes.push(...collectSchemaNodes(JSON.parse($(element).text())));
    } catch (error) {
      fail(`invalid JSON-LD on /${route}: ${error.message}`);
    }
  });
  return nodes;
}

function hasSchemaType(nodes, expectedType) {
  return nodes.some((node) => {
    const value = node["@type"];
    return Array.isArray(value) ? value.includes(expectedType) : value === expectedType;
  });
}

function headingOutline($) {
  return $("h1,h2,h3,h4,h5,h6")
    .map((_, element) => Number(element.tagName.slice(1)))
    .get();
}

function outputTarget(pathname) {
  let decoded;
  try {
    decoded = decodeURIComponent(pathname);
  } catch {
    return null;
  }
  const relative = decoded.replace(/^\/+/, "");
  const exact = path.join(outputRoot, relative);
  const candidates = decoded.endsWith("/")
    ? [path.join(exact, "index.html")]
    : [exact, `${exact}.html`, path.join(exact, "index.html")];
  return candidates.find((candidate) => existsSync(candidate) && statSync(candidate).isFile()) ?? null;
}

function targetIds(file) {
  if (!fragmentCache.has(file)) {
    const $ = load(readFileSync(file, "utf8"));
    fragmentCache.set(file, new Set($("[id]").map((_, element) => $(element).attr("id")).get()));
  }
  return fragmentCache.get(file);
}

for (const route of routes) {
  const file = htmlPath(route.path);
  if (!existsSync(file) || statSync(file).size === 0) {
    fail(`missing route output: /${route.path}`);
    continue;
  }

  const html = readFileSync(file, "utf8");
  const $ = load(html);
  const url = expectedUrl(route.path);
  const label = route.path ? `/${route.path}/` : "/";

  if ($("main").length !== 1) fail(`${label} must contain exactly one main element`);
  if ($('link[rel="stylesheet"]').length === 0) fail(`${label} lost its stylesheet`);
  if ($('link[rel="preload"][as="font"]').length === 0) fail(`${label} lost its font preloads`);
  if ($("h1").length !== 1) fail(`${label} must contain exactly one h1; found ${$("h1").length}`);
  $(".math-display[aria-label]").each((_, element) => {
    if ($(element).attr("role") !== "math") {
      fail(`${label} labeled display math must use role=math`);
    }
  });
  if ($('a.wordmark[aria-label]').length > 0) {
    fail(`${label} visible wordmark must use its content-derived accessible name`);
  }
  const headings = headingOutline($);
  for (let index = 1; index < headings.length; index += 1) {
    if (headings[index] > headings[index - 1] + 1) {
      fail(`${label} heading outline jumps from h${headings[index - 1]} to h${headings[index]}`);
      break;
    }
  }

  if ($('link[rel="canonical"]').attr("href") !== url) fail(`${label} canonical must be ${url}`);
  if ($('meta[property="og:url"]').attr("content") !== url) fail(`${label} og:url must be ${url}`);
  if ($('meta[property="og:title"]').attr("content") !== route.socialTitle) {
    fail(`${label} Open Graph title is not route-specific`);
  }
  if ($('meta[name="twitter:title"]').attr("content") !== route.socialTitle) {
    fail(`${label} Twitter title is not route-specific`);
  }
  if (!$('meta[property="og:description"]').attr("content")) fail(`${label} is missing an Open Graph description`);
  if (!$('meta[name="twitter:description"]').attr("content")) fail(`${label} is missing a Twitter description`);
  if (!$('meta[property="og:image"]').attr("content")) fail(`${label} is missing an Open Graph image`);
  if (!$('meta[name="twitter:image"]').attr("content")) fail(`${label} is missing a Twitter image`);
  if (!$('meta[name="robots"]').attr("content")?.includes("index")) fail(`${label} must be indexable`);

  const schemaNodes = readJsonLd($, route.path);
  for (const schemaType of route.schemaTypes) {
    if (!hasSchemaType(schemaNodes, schemaType)) fail(`${label} JSON-LD is missing ${schemaType}`);
  }

  if (route.path === "papers") {
    const itemList = schemaNodes.find((node) => node["@type"] === "ItemList");
    if (!Array.isArray(itemList?.itemListElement) || itemList.itemListElement.length !== papers.length) {
      fail("/papers/ ItemList must enumerate all six papers");
    }
  }

  if (route.path === "pipeline") {
    const metricContract = {
      "codex-sessions": "34",
      "model-invocations": "78",
      "approved-runtime": "3 h 31 m 12 s",
      "codex-tokens": "1,813,129,602",
    };
    for (const [metric, expectedValue] of Object.entries(metricContract)) {
      const rendered = $(`[data-pipeline-metric="${metric}"]`).text().replace(/\s+/g, " ").trim();
      if (rendered !== expectedValue) {
        fail(`/pipeline/ ${metric} metric must be ${expectedValue}; found ${rendered || "nothing"}`);
      }
    }
    const invocationCounts = $("[data-pipeline-invocations]")
      .map((_, element) => Number($(element).attr("data-pipeline-invocations")))
      .get();
    if (invocationCounts.length !== 4 || invocationCounts.some((value) => !Number.isInteger(value))) {
      fail("/pipeline/ must expose four numeric invocation groups");
    } else if (invocationCounts.reduce((total, value) => total + value, 0) !== 78) {
      fail("/pipeline/ invocation groups must sum to 78");
    }

    const tokenValues = $("[data-pipeline-token]")
      .map((_, element) => Number($(element).attr("data-pipeline-token")))
      .get();
    const [gross, input, cached, uncached, output, reasoning, native, isolated] = tokenValues;
    if (tokenValues.length !== 8 || tokenValues.some((value) => !Number.isInteger(value))) {
      fail("/pipeline/ must expose eight numeric token ledger entries");
    } else {
      if (cached + uncached !== input) fail("/pipeline/ cached and uncached input must sum to input");
      if (input + output !== gross) fail("/pipeline/ input and output must sum to the gross token total");
      if (native + isolated !== gross) fail("/pipeline/ Codex session subtotals must sum to the gross token total");
      if (reasoning > output) fail("/pipeline/ reasoning output must remain a subset of output");
    }
    if ($('[data-pipeline-spend="not-recorded"]').length !== 1) {
      fail("/pipeline/ must explicitly mark monetary spend as not recorded");
    }
    const cacheComposition = $('.cache-composition[role="img"]').attr("aria-label") ?? "";
    if (!cacheComposition.includes("97.75 percent cached")
      || !cacheComposition.includes("2.25 percent uncached")) {
      fail("/pipeline/ cache composition must expose its computed percentages accessibly");
    }
    for (const stage of ["code", "review", "fix", "verify", "deploy"]) {
      if ($(`[data-pipeline-stage="${stage}"]`).length !== 1) {
        fail(`/pipeline/ is missing the ${stage} stage`);
      }
    }
  }

  if (route.paper) {
    const renderedTitle = $("title").text();
    if (renderedTitle.length > 60) fail(`${label} title exceeds 60 characters: ${renderedTitle.length}`);
    if ($("h1").text().trim() !== route.paper.title) fail(`${label} visible scholarly title changed`);
    const article = schemaNodes.find((node) => node["@type"] === "ScholarlyArticle");
    if (article?.headline !== route.paper.title) fail(`${label} ScholarlyArticle headline must match the visible title`);
    if (article?.author?.name !== "Matthew Long") fail(`${label} ScholarlyArticle author is missing or unsupported`);
    if ("doi" in (article ?? {})) fail(`${label} must not invent a DOI`);
    if ($("article.paper-prose").text().trim().length < 5_000) fail(`${label} lost substantive paper content`);
    if ($("details.paper-toc-mobile").length !== 1) fail(`${label} lost its native mobile disclosure`);
  }

  $("a[href]").each((_, element) => {
    const href = $(element).attr("href");
    if (!href) {
      fail(`${label} contains an empty link`);
      return;
    }
    if (href.startsWith("#")) {
      const target = href.slice(1);
      const text = $(element).text().trim();
      if (target && (text === target || text === `[${target}]`)) {
        fail(`${label} exposes a raw cross-reference label: ${text}`);
      }
    }
    let targetUrl;
    try {
      targetUrl = new URL(href, url);
    } catch {
      fail(`${label} contains an invalid link: ${href}`);
      return;
    }
    if (!['http:', 'https:'].includes(targetUrl.protocol) || targetUrl.origin !== origin) return;
    checkedLinks += 1;
    const target = outputTarget(targetUrl.pathname);
    if (!target) {
      fail(`${label} contains a broken local link: ${href}`);
      return;
    }
    if (targetUrl.hash && target.endsWith(".html")) {
      let fragment;
      try {
        fragment = decodeURIComponent(targetUrl.hash.slice(1));
      } catch {
        fail(`${label} contains an invalid fragment: ${href}`);
        return;
      }
      if (fragment && !targetIds(target).has(fragment)) fail(`${label} contains a broken fragment: ${href}`);
    }
  });
}

for (const file of ["robots.txt", "sitemap.xml", "static-delivery-report.json"]) {
  const target = path.join(outputRoot, file);
  if (!existsSync(target) || statSync(target).size === 0) fail(`missing export: ${file}`);
}

const htmlFiles = readdirSync(outputRoot, { recursive: true })
  .map(String)
  .filter((file) => file.endsWith(".html"))
  .sort();
const deadRuntimeFiles = readdirSync(outputRoot, { recursive: true })
  .map(String)
  .filter((file) => (
    file.startsWith(`_next${path.sep}`) && file.endsWith(".js")
    || path.basename(file) === "index.txt"
    || path.basename(file).startsWith("__next") && file.endsWith(".txt")
  ));
if (deadRuntimeFiles.length > 0) {
  fail(`static export retains ${deadRuntimeFiles.length} unreferenced Next runtime files`);
}
for (const relativeFile of htmlFiles) {
  const $ = load(readFileSync(path.join(outputRoot, relativeFile), "utf8"));
  const executableScripts = $("script").filter((_, element) => (
    ($(element).attr("type") ?? "").toLowerCase() !== "application/ld+json"
  ));
  if (executableScripts.length > 0) fail(`${relativeFile} retains ${executableScripts.length} executable script tags`);

  const scriptPreloads = $("link").filter((_, element) => {
    const rel = ($(element).attr("rel") ?? "").toLowerCase().split(/\s+/);
    const as = ($(element).attr("as") ?? "").toLowerCase();
    const href = $(element).attr("href") ?? "";
    return (rel.includes("preload") || rel.includes("modulepreload"))
      && (as === "script" || /\.m?js(?:[?#]|$)/i.test(href));
  });
  if (scriptPreloads.length > 0) fail(`${relativeFile} retains ${scriptPreloads.length} JavaScript preloads`);
}

const sitemapPath = path.join(outputRoot, "sitemap.xml");
if (existsSync(sitemapPath)) {
  const sitemap = readFileSync(sitemapPath, "utf8");
  for (const route of routes) {
    const url = expectedUrl(route.path);
    if (!sitemap.includes(`<loc>${url}</loc>`)) fail(`sitemap missing canonical URL: ${url}`);
  }
}

const robotsPath = path.join(outputRoot, "robots.txt");
if (existsSync(robotsPath)) {
  const robots = readFileSync(robotsPath, "utf8");
  if (!robots.includes(`Sitemap: ${origin}/sitemap.xml`)) fail("robots.txt has the wrong sitemap URL");
}

const vercelConfigPath = path.join(root, "..", "vercel.json");
try {
  const vercelConfig = JSON.parse(readFileSync(vercelConfigPath, "utf8"));
  if (vercelConfig.trailingSlash !== true) fail("vercel.json must enforce trailingSlash: true");
  const headers = vercelConfig.headers?.flatMap((rule) => rule.headers ?? []) ?? [];
  for (const requiredHeader of [
    "Strict-Transport-Security",
    "X-Content-Type-Options",
    "X-Frame-Options",
    "Referrer-Policy",
    "Permissions-Policy",
  ]) {
    if (!headers.some((header) => header.key?.toLowerCase() === requiredHeader.toLowerCase())) {
      fail(`vercel.json is missing ${requiredHeader}`);
    }
  }
} catch (error) {
  fail(`invalid vercel.json: ${error.message}`);
}

const deliveryReportPath = path.join(outputRoot, "static-delivery-report.json");
if (existsSync(deliveryReportPath)) {
  try {
    const report = JSON.parse(readFileSync(deliveryReportPath, "utf8"));
    if (!Array.isArray(report.files) || report.files.length !== htmlFiles.length) {
      fail("static delivery report must cover every exported HTML file");
    } else {
      let removedScripts = 0;
      let beforeBytes = 0;
      let afterBytes = 0;
      let removedScriptPreloads = 0;
      for (const entry of report.files) {
        const outputFile = path.join(outputRoot, entry.file);
        if (!existsSync(outputFile)) {
          fail(`static delivery report names missing file: ${entry.file}`);
          continue;
        }
        if (entry.afterBytes !== statSync(outputFile).size) fail(`stale size in static delivery report: ${entry.file}`);
        if (entry.beforeBytes < entry.afterBytes) fail(`static finalizer enlarged ${entry.file}`);
        removedScripts += entry.removedScripts ?? 0;
        beforeBytes += entry.beforeBytes ?? 0;
        afterBytes += entry.afterBytes ?? 0;
        removedScriptPreloads += entry.removedScriptPreloads ?? 0;
      }
      if (removedScripts === 0) fail("static finalizer did not record any removed scripts");
      if (!Number.isInteger(report.prunedRuntimeFiles) || report.prunedRuntimeFiles <= 0) {
        fail("static finalizer did not record pruned runtime files");
      }
      if (!Number.isInteger(report.prunedRuntimeBytes) || report.prunedRuntimeBytes <= 0) {
        fail("static finalizer did not record pruned runtime bytes");
      }
      if (beforeBytes <= afterBytes) fail("static finalizer did not reduce total HTML bytes");
      if (report.totals?.beforeBytes !== beforeBytes || report.totals?.afterBytes !== afterBytes) {
        fail("static delivery report byte totals are inconsistent");
      }
      if (report.totals?.removedScripts !== removedScripts
        || report.totals?.removedScriptPreloads !== removedScriptPreloads) {
        fail("static delivery report removal totals are inconsistent");
      }
    }
  } catch (error) {
    fail(`invalid static delivery report: ${error.message}`);
  }
}

if (failures.length > 0) {
  console.error(failures.join("\n"));
  process.exit(1);
}

console.log(
  `Static export verification passed: ${routes.length} routes, ${htmlFiles.length} HTML files, `
  + `${checkedLinks} local links, grounded metadata, and zero client scripts.`,
);
