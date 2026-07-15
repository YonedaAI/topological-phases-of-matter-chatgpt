import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import path from "node:path";
import * as cheerio from "cheerio";

const root = process.cwd();
const slugs = [
  "locality-condensed-families",
  "condensed-observables",
  "thermodynamic-gaps",
  "microscopic-effective-theories",
  "physical-realizability",
  "invertible-condensed-phase-spectrum",
];
const failures = [];
let renderedDiagrams = 0;
let mencloseNodes = 0;
let mphantomNodes = 0;
let combinedPaperHtml = "";
let tableRegions = 0;
let labeledTableRegions = 0;
let resolvedReferenceOccurrences = 0;
let resolvedReferenceTargets = 0;
let numberedEquationAnchors = 0;
let visibleEquationNumbers = 0;
const diagramAltTexts = new Set();
const diagramCaptions = new Set();
const expectedReferenceStats = {
  "locality-condensed-families": [26, 26],
  "condensed-observables": [18, 20],
  "thermodynamic-gaps": [11, 11],
  "microscopic-effective-theories": [9, 9],
  "physical-realizability": [33, 35],
  "invertible-condensed-phase-spectrum": [14, 14],
};
const referenceExpectations = {
  "locality-condensed-families": [
    ["eq:F-norm", "equation (11)"],
  ],
  "physical-realizability": [
    ["thm:fh", "theorem 2.3"],
  ],
};

function requireFile(file) {
  if (!existsSync(file) || statSync(file).size === 0) failures.push(`missing or empty: ${file}`);
}

function walk(directory) {
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const item = path.join(directory, entry.name);
    return entry.isDirectory() ? walk(item) : [item];
  });
}

function svgIntrinsicPixels(file) {
  const svg = readFileSync(file, "utf8");
  const openingTag = svg.match(/<svg\b[^>]*>/i)?.[0] ?? "";
  const readLength = (attribute) => {
    const value = openingTag.match(new RegExp(`${attribute}="([0-9.]+)([a-z]*)"`, "i"));
    if (!value) return Number.NaN;
    const amount = Number(value[1]);
    const factors = { "": 1, px: 1, pt: 96 / 72, pc: 16, in: 96, cm: 96 / 2.54, mm: 96 / 25.4 };
    return Math.round(amount * (factors[value[2].toLowerCase()] ?? Number.NaN));
  };
  return { width: readLength("width"), height: readLength("height") };
}

for (const slug of slugs) {
  const contentFile = path.join(root, "content", "papers", `${slug}.json`);
  const pdfFile = path.join(root, "public", "papers", `${slug}.pdf`);
  const coverFile = path.join(root, "public", "covers", `${slug}.webp`);
  const ogFile = path.join(root, "public", "og", `${slug}.png`);
  [contentFile, pdfFile, coverFile, ogFile].forEach(requireFile);
  if (!existsSync(contentFile)) continue;

  const content = JSON.parse(readFileSync(contentFile, "utf8"));
  const [expectedOccurrences, expectedTargets] = expectedReferenceStats[slug];
  if (content.references?.occurrences !== expectedOccurrences) {
    failures.push(`${slug}: expected ${expectedOccurrences} resolved reference occurrences`);
  }
  if (content.references?.targets !== expectedTargets) {
    failures.push(`${slug}: expected ${expectedTargets} resolved reference targets`);
  }
  resolvedReferenceOccurrences += content.references?.occurrences ?? 0;
  resolvedReferenceTargets += content.references?.targets ?? 0;
  combinedPaperHtml += content.html;
  const $ = cheerio.load(content.html);
  if ($("h1").length > 0) failures.push(`${slug}: imported article contains an h1`);
  for (const item of content.toc ?? []) {
    const heading = $("[id]").filter((_, element) => $(element).attr("id") === item.id);
    const expectedTag = `h${Math.min(Number(item.level) + 1, 6)}`;
    if (heading.length !== 1 || heading.prop("tagName")?.toLowerCase() !== expectedTag) {
      failures.push(`${slug}: TOC item ${item.id} did not retain level ${item.level} as ${expectedTag}`);
    }
  }
  tableRegions += $(".table-scroll").length;
  const paperTableRegions = $(".table-scroll[role='region'][tabindex='0']");
  labeledTableRegions += paperTableRegions.filter((_, element) => {
    return $(element).attr("aria-label")?.trim().length > 0;
  }).length;
  const tableRegionLabels = paperTableRegions
    .map((_, element) => $(element).attr("aria-label")?.trim() ?? "")
    .get();
  if (tableRegionLabels.some((label) => label.length === 0)) {
    failures.push(`${slug}: focusable table region has an empty accessible name`);
  }
  if (new Set(tableRegionLabels).size !== tableRegionLabels.length) {
    failures.push(`${slug}: focusable table region accessible names are not unique within the paper`);
  }
  if ($(".katex-error").length > 0) failures.push(`${slug}: KaTeX errors remain`);
  if (content.html.includes("\\label")) failures.push(`${slug}: literal LaTeX label remains in rendered HTML`);
  if (content.html.includes("#cc0000")) failures.push(`${slug}: red KaTeX fallback remains in rendered HTML`);
  $("span.citation").each((_, element) => {
    if ($(element).text().trim().length === 0) failures.push(`${slug}: empty citation span`);
  });
  const ids = new Set();
  $("[id]").each((_, element) => {
    const id = $(element).attr("id");
    if (!id) return;
    if (ids.has(id)) failures.push(`${slug}: duplicate id: ${id}`);
    ids.add(id);
  });
  $("a[href^='#']").each((_, element) => {
    const target = $(element).attr("href")?.slice(1);
    if (target && !ids.has(target)) failures.push(`${slug}: missing internal target: ${target}`);
    const text = $(element).text().trim();
    if (target && (text === target || text === `[${target}]`)) {
      failures.push(`${slug}: raw cross-reference label is visible: ${text}`);
    }
    if (target?.includes(",")) failures.push(`${slug}: unresolved multi-reference href remains: ${target}`);
  });
  $(".equation-anchor[id^='eq:']").each((_, element) => {
    numberedEquationAnchors += 1;
    const anchor = $(element);
    const tag = anchor
      .next(".katex-display")
      .find(".tag")
      .text()
      .replace(/[\u2000-\u200b]/g, "")
      .trim();
    const diagramCaption = anchor
      .parent()
      .nextAll("figure.math-diagram-rendered")
      .first()
      .find("figcaption")
      .text()
      .trim();
    if (/^\(\d+(?:\.\d+)*\)$/.test(tag) || /equation \(\d+(?:\.\d+)*\)$/.test(diagramCaption)) {
      visibleEquationNumbers += 1;
    } else {
      failures.push(`${slug}: labeled equation ${anchor.attr("id")} has no visible number`);
    }
  });
  for (const [target, expectedText] of referenceExpectations[slug] ?? []) {
    const link = $(`a[href='#${target}']`).first();
    if (link.text().trim() !== expectedText) {
      failures.push(`${slug}: ${target} must render as ${expectedText}`);
    }
  }
  if (slug === "condensed-observables") {
    const texts = $(".multi-reference").map((_, element) => (
      $(element).text().replace(/\s+/g, " ").trim()
    )).get();
    if (!texts.includes("theorems 3.3 and 3.5")) {
      failures.push(`${slug}: theorem group must render as theorems 3.3 and 3.5`);
    }
    if (!texts.includes("Theorems 5.1 and 6.2")) {
      failures.push(`${slug}: capitalized theorem group must render as Theorems 5.1 and 6.2`);
    }
  }
  if (slug === "physical-realizability") {
    const text = $(".multi-reference").first().text().replace(/\s+/g, " ").trim();
    if (text !== "sections 4 to 6") {
      failures.push(`${slug}: section group must render as sections 4 to 6`);
    }
    const caption = $("#eq\\:comparison-diagram")
      .parent()
      .next("figure")
      .find("figcaption")
      .text()
      .trim();
    if (!caption.endsWith("equation (5)")) {
      failures.push(`${slug}: numbered comparison diagram must expose equation (5)`);
    }
  }
  if (slug === "locality-condensed-families") {
    const tag = $("#eq\\:F-norm")
      .next(".katex-display")
      .find(".tag")
      .text()
      .replace(/[\u2000-\u200b]/g, "")
      .trim();
    if (tag !== "(11)") failures.push(`${slug}: F-norm display must carry equation tag (11)`);
  }
  if (slug === "microscopic-effective-theories") {
    const texts = $("a[href='#thm:flattening']").map((_, element) => $(element).text().trim()).get();
    if (JSON.stringify(texts) !== JSON.stringify(["3.3", "theorem 3.3", "3.3"])) {
      failures.push(`${slug}: ref and cref forms for thm:flattening are not faithful`);
    }
  }
  mencloseNodes += $("menclose").length;
  mphantomNodes += $("mphantom").length;
  if (!Array.isArray(content.toc) || content.toc.length === 0) failures.push(`${slug}: empty table of contents`);

  $("figure.math-diagram-rendered").each((_, figure) => {
    renderedDiagrams += 1;
    const images = $(figure).find("img");
    if (images.length !== 1) {
      failures.push(`${slug}: rendered diagram does not contain exactly one image`);
      return;
    }
    const source = images.attr("src");
    const diagramFile = source && path.join(root, "public", source.replace(/^\//, ""));
    if (!diagramFile || !existsSync(diagramFile)) {
      failures.push(`${slug}: diagram source does not exist: ${source ?? "missing src"}`);
    }
    const width = Number(images.attr("width"));
    const height = Number(images.attr("height"));
    if (!Number.isInteger(width) || width <= 0 || !Number.isInteger(height) || height <= 0) {
      failures.push(`${slug}: diagram lacks positive integer intrinsic dimensions: ${source ?? "missing src"}`);
    }
    if (diagramFile && existsSync(diagramFile)) {
      const expected = svgIntrinsicPixels(diagramFile);
      if (width !== expected.width || height !== expected.height) {
        failures.push(`${slug}: diagram dimensions ${width}x${height} do not match SVG intrinsic size ${expected.width}x${expected.height}: ${source}`);
      }
    }
    const alt = images.attr("alt")?.trim() ?? "";
    const caption = $(figure).find("figcaption").text().trim();
    if (!alt || alt === "Commutative diagram. The surrounding text states the mathematical content.") {
      failures.push(`${slug}: diagram has an empty or generic alt description: ${source ?? "missing src"}`);
    }
    if (!caption || caption === "Commutative diagram") {
      failures.push(`${slug}: diagram has an empty or generic caption: ${source ?? "missing src"}`);
    }
    if (alt) diagramAltTexts.add(alt);
    if (caption) diagramCaptions.add(caption);
  });
}

if (renderedDiagrams !== 14) failures.push(`expected 14 rendered diagrams, found ${renderedDiagrams}`);
if (tableRegions !== 25) failures.push(`expected 25 focusable table regions, found ${tableRegions}`);
if (labeledTableRegions !== 25) failures.push(`expected 25 named focusable table regions, found ${labeledTableRegions}`);
if (diagramAltTexts.size !== 14) failures.push(`expected 14 distinct diagram alt descriptions, found ${diagramAltTexts.size}`);
if (diagramCaptions.size !== 14) failures.push(`expected 14 distinct diagram captions, found ${diagramCaptions.size}`);
if (mencloseNodes !== 2) failures.push(`expected 2 menclose nodes, found ${mencloseNodes}`);
if (mphantomNodes !== 1) failures.push(`expected 1 mphantom node, found ${mphantomNodes}`);
if (resolvedReferenceOccurrences !== 111) {
  failures.push(`expected 111 resolved reference occurrences, found ${resolvedReferenceOccurrences}`);
}
if (resolvedReferenceTargets !== 115) {
  failures.push(`expected 115 resolved reference targets, found ${resolvedReferenceTargets}`);
}
if (numberedEquationAnchors !== 71) {
  failures.push(`expected 71 labeled equation anchors, found ${numberedEquationAnchors}`);
}
if (visibleEquationNumbers !== 71) {
  failures.push(`expected 71 visible equation numbers, found ${visibleEquationNumbers}`);
}

const mathMlAttributeSelectors = [
  "mi[mathvariant]",
  "mn[mathvariant]",
  "mo[fence]",
  "mo[lspace]",
  "mo[mathvariant]",
  "mo[maxsize]",
  "mo[minsize]",
  "mo[rspace]",
  "mo[separator]",
  "mo[stretchy]",
  "mover[accent]",
  "munder[accentunder]",
  "mpadded[lspace]",
  "mpadded[width]",
  "mspace[width]",
  "mstyle[displaystyle]",
  "mstyle[scriptlevel]",
  "mtable[columnalign]",
  "mtable[columnspacing]",
  "mtable[rowspacing]",
  "mtext[mathvariant]",
  "menclose[notation]",
];
const mathMl = cheerio.load(combinedPaperHtml);
for (const selector of mathMlAttributeSelectors) {
  if (mathMl(selector).length === 0) failures.push(`MathML attribute was stripped: ${selector}`);
}

const locality = readFileSync(
  path.join(root, "content", "papers", "locality-condensed-families.json"),
  "utf8",
);
if (!/\\\\mathcal\s*\\?\{?A\\?\}?_\\?\{?\\\\Lambda\\?\}?/.test(locality)) {
  failures.push("known subscript formula lost its TeX structure");
}

const haskellCount = walk(path.join(root, "public", "code")).filter((file) => file.endsWith(".hs")).length;
const leanCount = walk(path.join(root, "public", "lean")).filter((file) => file.endsWith(".lean")).length;
if (haskellCount !== 16) failures.push(`expected 16 Haskell files, found ${haskellCount}`);
if (leanCount !== 10) failures.push(`expected 10 Lean files, found ${leanCount}`);

[
  "final-cross-paper-mathematical-audit.md",
  "final-lean-haskell-audit.md",
].forEach((review) => requireFile(path.join(root, "public", "reviews", review)));

if (failures.length > 0) {
  console.error(failures.join("\n"));
  process.exit(1);
}

console.log("Content verification passed: 6 papers, 14 diagrams, complete MathML, 16 Haskell files, and 10 Lean files.");
