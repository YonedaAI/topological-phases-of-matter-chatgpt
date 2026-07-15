import { spawnSync } from "node:child_process";
import { existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { cp, mkdir, readFile, rm, writeFile } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import * as cheerio from "cheerio";
import katex from "katex";
import sanitizeHtml from "sanitize-html";
import sharp from "sharp";

const here = path.dirname(fileURLToPath(import.meta.url));
const websiteRoot = path.resolve(here, "..");
const repoRoot = path.resolve(websiteRoot, "..");
const publicRoot = path.join(websiteRoot, "public");
const contentRoot = path.join(websiteRoot, "content", "papers");

const papers = [
  ["locality-condensed-families", "Uniform Locality for Condensed Families", "THE ANALYTIC FIRST ARROW", "01"],
  ["condensed-observables", "Condensed Families of Quantum Observables", "POSITIVITY, NORMS, DESCENT", "02"],
  ["thermodynamic-gaps", "Thermodynamic Spectral Gaps", "WITNESSES, IMAGES, STABILITY", "03"],
  ["microscopic-effective-theories", "Microscopic Hamiltonians to Effective Theories", "THREE MAPS, NOT ONE EQUIVALENCE", "04"],
  ["physical-realizability", "Physical Realizability of Invertible Classes", "FROM CLASS TO LATTICE WITNESS", "05"],
  ["invertible-condensed-phase-spectrum", "The Invertible Condensed Phase Spectrum", "CONDITIONAL ASSEMBLY", "S"],
];

const katexMacros = {
  "\\C": "\\mathbb{C}",
  "\\R": "\\mathbb{R}",
  "\\Z": "\\mathbb{Z}",
  "\\N": "\\mathbb{N}",
  "\\T": "\\mathbb{T}",
  "\\A": "\\mathcal{A}",
  "\\H": "\\mathcal{H}",
  "\\State": "\\operatorname{State}",
  "\\Spec": "\\operatorname{Spec}",
  "\\Hom": "\\operatorname{Hom}",
  "\\Gap": "\\operatorname{Gap}",
};

const diagramDescriptions = {
  "condensed-observables": [
    {
      alt: "Dependency chain from local matrix algebras through the C*-inductive limit and the condensed observable algebra C(S, A Gamma) to topological K-theory.",
      caption: "Observable-algebra and K-theory dependency chain",
    },
  ],
  "invertible-condensed-phase-spectrum": [
    {
      alt: "Three separate comparisons: dashed low-energy L from gapped microscopic Hamiltonians to invertible effective field theories, scoped invariant I to stable classes, dashed realization R to lattice witnesses, and a map that forgets witnesses.",
      caption: "Low-energy, invariant, and realization comparisons",
    },
    {
      alt: "Dotted comparison web among Kubota's microscopic phase spectrum, the proposed condensed phase spectrum, the Freed-Hopkins mapping spectrum, and operator K-theory; no global equivalence is asserted.",
      caption: "Open comparison web among phase classifiers",
    },
    {
      alt: "Segment of the relative cohomology exact sequence from E to the q of B, through E to the q of U and E to the q plus 1 of the pair B comma U, to E to the q plus 1 of B.",
      caption: "Relative cohomology exact sequence",
    },
  ],
  "microscopic-effective-theories": [
    {
      alt: "Five-stage research program from local quantum interactions through condensed Hamiltonian moduli, the uniformly gapped substack, and the stabilized phase infinity-groupoid to the invertible condensed phase spectrum.",
      caption: "Five-stage condensed phase program",
    },
    {
      alt: "Factorization from microscopic Hamiltonians to low-energy effective theories by L and then to stable classes by I.",
      caption: "Microscopic, low-energy, and stable-class factorization",
    },
    {
      alt: "Dashed realization problem R from stable classes to explicit lattice realizations; it is not an inverse of L or I.",
      caption: "Realization as a separate open problem",
    },
    {
      alt: "Established spectral flattening map from uniformly gapped free Hamiltonians to operator K-theory.",
      caption: "Controlled free flattening to operator K-theory",
    },
    {
      alt: "General comparison chain with open dashed L from gapped microscopic Hamiltonians to invertible effective field theories, scoped established I to bordism classes, and open dashed R to lattice realizations.",
      caption: "Scoped microscopic-to-bordism comparison program",
    },
  ],
  "physical-realizability": [
    {
      alt: "Dashed partial packaging and dotted low-energy comparisons from invertible microscopic phases to Kubota's phase spectrum and Freed-Hopkins classes, with the remaining comparison marked open.",
      caption: "Partial microscopic and low-energy comparisons",
    },
    {
      alt: "Dotted proposed comparison from Kubota's phase spectrum to the condensed phase spectrum, explicitly labeled no theorem.",
      caption: "Unproved comparison to the condensed spectrum",
    },
    {
      alt: "Relative cohomology exact sequence from E to the q of B through restriction to E to the q of U, the connecting map to E to the q plus 1 of the pair B comma U, and the map to E to the q plus 1 of B.",
      caption: "Exact sequence for a transition locus",
    },
    {
      alt: "Excision and inverse Thom isomorphisms from relative E-cohomology on the pair B comma U, through the normal disk-sphere pair, to E to the q plus 1 minus c of the transition locus Sigma.",
      caption: "Excision and oriented Thom localization",
    },
  ],
  "thermodynamic-gaps": [
    {
      alt: "Five-stage program from local interactions through parameterized Hamiltonians, the uniformly gapped subobject, and the stable phase groupoid to the invertible phase spectrum.",
      caption: "Five-stage program centered on the gapped subobject",
    },
  ],
};

function run(command, args, cwd = repoRoot) {
  const result = spawnSync(command, args, { cwd, encoding: "utf8" });
  if (result.status !== 0) {
    throw new Error(`${command} failed:\n${result.stderr || result.stdout}`);
  }
  return result.stdout;
}

function slugify(value) {
  return value
    .toLowerCase()
    .normalize("NFKD")
    .replace(/[^a-z0-9\s-]/g, "")
    .trim()
    .replace(/[\s-]+/g, "-")
    .slice(0, 72);
}

function bibliographyKeys(latex) {
  return [...latex.matchAll(/\\bibitem(?:\s*\[[^\]]*\])?\s*\{([^}]+)\}/g)]
    .map((match) => match[1]);
}

function stripMathDelimiters(value) {
  const trimmed = value
    .replace(/[\u2000-\u200b]/g, " ")
    .replaceAll("⌀", "\\varnothing")
    .trim();
  if (
    (trimmed.startsWith("\\(") && trimmed.endsWith("\\)")) ||
    (trimmed.startsWith("\\[") && trimmed.endsWith("\\]")) ||
    (trimmed.startsWith("$$") && trimmed.endsWith("$$"))
  ) {
    return trimmed.slice(2, -2).trim();
  }
  if (trimmed.startsWith("$") && trimmed.endsWith("$")) {
    return trimmed.slice(1, -1).trim();
  }
  return trimmed;
}

function escapeHtml(value) {
  return value.replace(/[<>&'"]/g, (character) => ({
    "<": "&lt;",
    ">": "&gt;",
    "&": "&amp;",
    "'": "&#39;",
    '"': "&quot;",
  })[character]);
}

function latexReferenceCalls(latex) {
  const calls = new Map();
  for (const match of latex.matchAll(/\\(Cref|cref|eqref|ref)\{([^}]+)\}/g)) {
    const targets = match[2].split(",").map((target) => target.trim()).filter(Boolean);
    const key = targets.join(",");
    const queue = calls.get(key) ?? [];
    queue.push(match[1]);
    calls.set(key, queue);
  }
  return calls;
}

function parseBalancedGroups(value) {
  const groups = [];
  let index = 0;
  while (index < value.length) {
    while (/\s/.test(value[index] ?? "")) index += 1;
    if (index >= value.length) break;
    if (value[index] !== "{") throw new Error(`Malformed LaTeX auxiliary groups: ${value}`);
    const start = index + 1;
    let depth = 1;
    index += 1;
    while (index < value.length && depth > 0) {
      if (value[index] === "\\") {
        index += 2;
        continue;
      }
      if (value[index] === "{") depth += 1;
      if (value[index] === "}") depth -= 1;
      index += 1;
    }
    if (depth !== 0) throw new Error(`Unbalanced LaTeX auxiliary groups: ${value}`);
    groups.push(value.slice(start, index - 1));
  }
  return groups;
}

function latexReferenceMap(source) {
  const temporary = mkdtempSync(path.join(os.tmpdir(), "spectral-references-"));
  const basename = path.basename(source, path.extname(source));
  try {
    run(
      "lualatex",
      [
        "-interaction=nonstopmode",
        "-halt-on-error",
        "-draftmode",
        `-output-directory=${temporary}`,
        source,
      ],
      repoRoot,
    );
    const auxiliary = readFileSync(path.join(temporary, `${basename}.aux`), "utf8");
    const numbers = new Map();
    const types = new Map();
    for (const line of auxiliary.split("\n")) {
      const match = line.match(/^\\newlabel\{([^}]+)\}\{(.*)\}$/);
      if (!match) continue;
      const groups = parseBalancedGroups(match[2]);
      if (groups.length === 0) throw new Error(`Empty LaTeX label metadata: ${line}`);
      if (match[1].endsWith("@cref")) {
        const label = match[1].slice(0, -"@cref".length);
        const type = groups[0].match(/^\[([^\]]+)\]/)?.[1];
        if (!type) throw new Error(`Missing cleveref type for ${label}`);
        if (types.has(label)) throw new Error(`Duplicate cleveref type for ${label}`);
        types.set(label, type);
      } else {
        if (numbers.has(match[1])) throw new Error(`Duplicate LaTeX label ${match[1]}`);
        numbers.set(match[1], groups[0]);
      }
    }

    const references = new Map();
    for (const [label, number] of numbers) {
      const type = types.get(label);
      if (!type) throw new Error(`Missing cleveref type for ${label}`);
      if (!["equation", "section", "theorem"].includes(type)) {
        throw new Error(`Unsupported cleveref type ${type} for ${label}`);
      }
      if (!/^\d+(?:\.\d+)*$/.test(number)) {
        throw new Error(`Unsupported display number ${number} for ${label}`);
      }
      references.set(label, { type, number });
    }
    if (references.size !== numbers.size || references.size !== types.size) {
      throw new Error(`Incomplete cross-reference metadata for ${source}`);
    }
    if (references.size === 0) throw new Error(`No cross-reference metadata was generated for ${source}`);
    return references;
  } finally {
    rmSync(temporary, { recursive: true, force: true });
  }
}

function referenceTypeName(type, plural, capitalize) {
  const base = plural ? `${type}s` : type;
  return capitalize ? `${base[0].toUpperCase()}${base.slice(1)}` : base;
}

function referenceNumberText(reference, macro) {
  if (reference.type === "equation" && macro !== "ref") return `(${reference.number})`;
  return reference.number;
}

function joinReferenceLinks(links, references, typed) {
  if (links.length === 1) return links[0];
  if (links.length === 2) return `${links[0]} and ${links[1]}`;
  const integerNumbers = references.map((reference) => Number(reference.number));
  const consecutiveRange = typed
    && integerNumbers.every(Number.isInteger)
    && integerNumbers.every((number, index) => index === 0 || number === integerNumbers[index - 1] + 1);
  if (consecutiveRange) return `${links[0]} to ${links.at(-1)}`;
  return `${links.slice(0, -1).join(", ")}, and ${links.at(-1)}`;
}

function renderReferenceLinks($, referenceMap, callQueues) {
  let occurrences = 0;
  let targetCount = 0;
  $("a[href^='#']").each((_, element) => {
    const link = $(element);
    const href = link.attr("href");
    if (!href) return;
    const targets = href.slice(1).split(",").map((target) => target.trim()).filter(Boolean);
    const key = targets.join(",");
    const queue = callQueues.get(key);
    const macro = queue?.shift();
    if (!macro) throw new Error(`Missing LaTeX reference call metadata for ${key}`);
    occurrences += 1;
    targetCount += targets.length;

    const references = targets.map((target) => {
      const reference = referenceMap.get(target);
      if (!reference) throw new Error(`Missing LaTeX cross-reference metadata for ${target}`);
      return { target, ...reference };
    });
    const typed = macro === "cref" || macro === "Cref";

    if (references.length === 1) {
      const [reference] = references;
      const number = referenceNumberText(reference, macro);
      const text = typed
        ? `${referenceTypeName(reference.type, false, macro === "Cref")} ${number}`
        : number;
      link.attr("href", `#${reference.target}`);
      link.text(text);
      return;
    }

    const commonType = references.every((reference) => reference.type === references[0].type)
      ? references[0].type
      : null;
    const links = references.map((reference) => (
      `<a href="#${escapeHtml(reference.target)}">${escapeHtml(referenceNumberText(reference, macro))}</a>`
    ));
    const prefix = typed && commonType
      ? `${referenceTypeName(commonType, true, macro === "Cref")} `
      : "";
    link.replaceWith(`<span class="multi-reference">${prefix}${joinReferenceLinks(links, references, typed)}</span>`);
  });

  const unconsumed = [...callQueues.entries()].filter(([, queue]) => queue.length > 0);
  if (unconsumed.length > 0) {
    throw new Error(`Pandoc omitted LaTeX references: ${unconsumed.map(([key]) => key).join(", ")}`);
  }
  return { occurrences, targets: targetCount };
}

function svgIntrinsicPixels(file) {
  const svg = readFileSync(file, "utf8");
  const openingTag = svg.match(/<svg\b[^>]*>/i)?.[0] ?? "";
  const readLength = (attribute) => {
    const value = openingTag.match(new RegExp(`${attribute}="([0-9.]+)([a-z]*)"`, "i"));
    if (!value) throw new Error(`Generated SVG is missing ${attribute}: ${file}`);
    const amount = Number(value[1]);
    const factors = { "": 1, px: 1, pt: 96 / 72, pc: 16, in: 96, cm: 96 / 2.54, mm: 96 / 25.4 };
    const factor = factors[value[2].toLowerCase()];
    if (!Number.isFinite(amount) || factor === undefined) {
      throw new Error(`Unsupported SVG ${attribute} value ${value[0]}: ${file}`);
    }
    return Math.max(1, Math.round(amount * factor));
  };
  return { width: readLength("width"), height: readLength("height") };
}

function renderDiagram(source, slug, index, equationReference) {
  const filename = `${slug}-${String(index).padStart(2, "0")}.svg`;
  const output = path.join(publicRoot, "diagrams", filename);
  const description = diagramDescriptions[slug]?.[index - 1];
  if (!description) throw new Error(`Missing description for diagram ${slug}-${index}`);
  const temporary = mkdtempSync(path.join(os.tmpdir(), "spectral-diagram-"));
  const diagramSource = source
    .replaceAll("\\begin{equation}", "")
    .replaceAll("\\end{equation}", "")
    .replace(/\\label\{[^}]+\}/g, "");
  const document = String.raw`\documentclass[border=10pt]{standalone}
\usepackage{amsmath,amssymb,mathtools}
\usepackage{tikz-cd}
\usepackage{xcolor}
\definecolor{ledgerink}{HTML}{F3EFE6}
\color{ledgerink}
\begin{document}
${diagramSource}
\end{document}
`;
  try {
    writeFileSync(path.join(temporary, "diagram.tex"), document, "utf8");
    run(
      "lualatex",
      ["-interaction=nonstopmode", "-halt-on-error", "diagram.tex"],
      temporary,
    );
    run(
      "pdftocairo",
      ["-svg", path.join(temporary, "diagram.pdf"), output],
      temporary,
    );
    const { width, height } = svgIntrinsicPixels(output);
    const caption = equationReference
      ? `${description.caption}, equation (${equationReference.number})`
      : description.caption;
    return `<figure class="math-diagram math-diagram-rendered"><img src="/diagrams/${filename}" alt="${escapeHtml(description.alt)}" width="${width}" height="${height}" loading="lazy"><figcaption>${escapeHtml(caption)}</figcaption></figure>`;
  } catch (error) {
    const reason = error instanceof Error
      ? error.message.replace(/\s+/g, " ").slice(-360)
      : "unknown renderer error";
    console.warn(`Diagram ${filename} could not be rendered; preserving its source. ${reason}`);
    return `<figure class="math-diagram"><figcaption>Commutative diagram source</figcaption><pre><code>${escapeHtml(source)}</code></pre></figure>`;
  } finally {
    rmSync(temporary, { recursive: true, force: true });
  }
}

function renderPaperHtml(rawHtml, slug, citationKeys, referenceMap, referenceCalls) {
  const $ = cheerio.load(rawHtml, null, false);
  $("#title-block-header").remove();
  $("script, style, iframe, object, embed").remove();

  let diagramIndex = 0;
  $("span.math").each((_, element) => {
    const node = $(element);
    const display = node.hasClass("display");
    const rawSource = stripMathDelimiters(node.text());
    const labels = [...rawSource.matchAll(/\\label\{([^}]+)\}/g)].map((match) => match[1]);
    const equationReference = labels
      .map((label) => referenceMap.get(label))
      .find((reference) => reference?.type === "equation");
    const anchors = labels
      .map((label) => `<span class="equation-anchor" id="${escapeHtml(label)}" aria-hidden="true"></span>`)
      .join("");
    const source = rawSource.replace(/\\label\{([^}]+)\}/g, (_, label) => {
      const reference = referenceMap.get(label);
      return display && reference?.type === "equation" ? `\\tag{${reference.number}}` : "";
    });
    if (source.includes("\\begin{tikzcd}")) {
      const diagramSources = source.match(/\\begin\{tikzcd\}[\s\S]*?\\end\{tikzcd\}/g) ?? [source];
      const figures = diagramSources.map((diagramSource) => {
        diagramIndex += 1;
        return renderDiagram(diagramSource, slug, diagramIndex, equationReference);
      });
      node.replaceWith(anchors + figures.join(""));
      return;
    }
    const rendered = katex.renderToString(source, {
      displayMode: display,
      throwOnError: false,
      strict: "ignore",
      trust: false,
      output: "htmlAndMathml",
      macros: katexMacros,
    });
    node.replaceWith(anchors + rendered);
  });

  $("section[id]").each((_, element) => {
    const section = $(element);
    const heading = section.children("h1, h2, h3").first();
    const id = section.attr("id");
    if (heading.length > 0 && id) {
      heading.attr("id", id);
      section.removeAttr("id");
    }
  });

  const usedIds = new Set();
  $("[id]").each((_, element) => {
    const node = $(element);
    const original = node.attr("id");
    if (!original) return;
    let id = original;
    let suffix = 2;
    while (usedIds.has(id)) {
      id = `${original}-${suffix}`;
      suffix += 1;
    }
    node.attr("id", id);
    usedIds.add(id);
  });

  $("h1, h2, h3").each((_, element) => {
    const heading = $(element);
    if (heading.attr("id")) return;
    const base = slugify(heading.text()) || "section";
    let id = base;
    let suffix = 2;
    while (usedIds.has(id)) {
      id = `${base}-${suffix}`;
      suffix += 1;
    }
    heading.attr("id", id);
    usedIds.add(id);
  });

  const referenceStats = renderReferenceLinks($, referenceMap, referenceCalls);

  const bibliographyParagraphs = $(".thebibliography > p").filter((_, element) => {
    return $(element).text().trim() !== "99";
  });
  bibliographyParagraphs.each((index, element) => {
    const key = citationKeys[index];
    if (key) $(element).attr("id", `ref-${key}`);
  });

  $("span.citation[data-cites]").each((_, element) => {
    const citation = $(element);
    const keys = citation.attr("data-cites")?.split(/\s+/).filter(Boolean) ?? [];
    const links = keys
      .map((key) => `<a href="#ref-${escapeHtml(key)}">${escapeHtml(key)}</a>`)
      .join(", ");
    citation.html(`[${links}]`);
  });

  const toc = [];
  $("h1, h2, h3").each((_, element) => {
    const heading = $(element);
    const label = heading.text().trim();
    const id = heading.attr("id");
    if (!label || !id) return;
    toc.push({ id, label, level: Number(element.tagName.slice(1)) });
  });

  $("h1, h2, h3").each((_, element) => {
    const originalLevel = Number(element.tagName.slice(1));
    element.tagName = `h${originalLevel + 1}`;
  });

  $("table").each((index, element) => {
    const table = $(element);
    const caption = table.children("caption").first().text().replace(/\s+/g, " ").trim();
    const sectionHeading = table
      .closest("section")
      .children("h2, h3, h4")
      .first()
      .text()
      .replace(/\s+/g, " ")
      .trim();
    const context = caption || sectionHeading || "Paper data";
    const conciseContext = context.length > 72 ? `${context.slice(0, 69).trimEnd()}...` : context;
    const label = `Scrollable table ${index + 1}: ${conciseContext}`;
    table.wrap(`<div class="table-scroll" tabindex="0" role="region" aria-label="${escapeHtml(label)}"></div>`);
  });

  $("a").each((_, element) => {
    const href = $(element).attr("href");
    if (href?.startsWith("http")) {
      $(element).attr("rel", "noreferrer");
    }
  });

  const cleaned = sanitizeHtml($.html(), {
    allowedTags: [
      ...sanitizeHtml.defaults.allowedTags,
      "article",
      "section",
      "figure",
      "figcaption",
      "img",
      "details",
      "summary",
      "math",
      "semantics",
      "annotation",
      "mrow",
      "mi",
      "mo",
      "mn",
      "ms",
      "mtext",
      "mspace",
      "mstyle",
      "menclose",
      "mphantom",
      "mfrac",
      "msqrt",
      "mroot",
      "msup",
      "msub",
      "msubsup",
      "mover",
      "munder",
      "munderover",
      "mtable",
      "mtr",
      "mtd",
      "mpadded",
    ],
    allowedAttributes: {
      "*": ["class", "id", "aria-hidden", "aria-label", "role", "tabindex", "style"],
      a: ["href", "title", "rel"],
      img: ["src", "alt", "width", "height", "loading"],
      math: ["xmlns", "display"],
      annotation: ["encoding"],
      mi: ["mathvariant"],
      mn: ["mathvariant"],
      mo: ["fence", "lspace", "mathvariant", "maxsize", "minsize", "rspace", "separator", "stretchy"],
      mover: ["accent"],
      munder: ["accentunder"],
      mpadded: ["lspace", "width"],
      mspace: ["width"],
      mstyle: ["displaystyle", "mathcolor", "scriptlevel"],
      mtable: ["columnalign", "columnspacing", "rowspacing"],
      mtext: ["mathvariant"],
      menclose: ["notation"],
    },
    allowedSchemes: ["http", "https", "mailto"],
    allowProtocolRelative: false,
  });

  return { html: cleaned, toc, references: referenceStats };
}

function splitTitle(title, max = 31) {
  const words = title.split(" ");
  const lines = [""];
  for (const word of words) {
    const current = lines.at(-1);
    if (current && `${current} ${word}`.length > max && lines.length < 3) {
      lines.push(word);
    } else {
      lines[lines.length - 1] = current ? `${current} ${word}` : word;
    }
  }
  return lines;
}

function escapeXml(value) {
  return value.replace(/[<>&'"]/g, (character) => ({
    "<": "&lt;",
    ">": "&gt;",
    "&": "&amp;",
    "'": "&apos;",
    '"': "&quot;",
  })[character]);
}

function ogSvg(title, eyebrow, number) {
  const lines = splitTitle(title);
  const text = lines
    .map((line, index) => `<text x="84" y="${238 + index * 76}" class="title">${escapeXml(line)}</text>`)
    .join("");
  return Buffer.from(`
    <svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630">
      <style>
        .eyebrow{font:600 20px Arial,sans-serif;letter-spacing:4px;fill:#58d4c2}
        .title{font:600 58px Georgia,serif;fill:#f3efe6}
        .meta{font:500 19px 'Courier New',monospace;letter-spacing:2px;fill:#a9b4c7}
      </style>
      <rect width="1200" height="630" fill="#060a12"/>
      <rect x="40" y="40" width="1120" height="550" rx="2" fill="#0b1322" stroke="#27344b"/>
      <path d="M84 128 H742 M840 128 H1114" stroke="#58d4c2" stroke-width="3"/>
      <path d="M742 128 L791 166 L840 128" fill="none" stroke="#ff7b6b" stroke-width="5"/>
      <text x="84" y="102" class="eyebrow">SPECTRAL LEDGER / ${escapeXml(number)}</text>
      ${text}
      <text x="84" y="538" class="meta">${escapeXml(eyebrow)}</text>
      <circle cx="1090" cy="516" r="24" fill="#101b2b" stroke="#9a8cff" stroke-width="2"/>
      <text x="1090" y="523" text-anchor="middle" font-family="Georgia" font-size="24" fill="#f3efe6">Σ</text>
    </svg>
  `);
}

async function copyCorpusAssets() {
  await Promise.all([
    rm(path.join(publicRoot, "papers"), { recursive: true, force: true }),
    rm(path.join(publicRoot, "code"), { recursive: true, force: true }),
    rm(path.join(publicRoot, "lean"), { recursive: true, force: true }),
    rm(path.join(publicRoot, "reviews"), { recursive: true, force: true }),
    rm(path.join(publicRoot, "covers"), { recursive: true, force: true }),
    rm(path.join(publicRoot, "diagrams"), { recursive: true, force: true }),
    rm(path.join(publicRoot, "og"), { recursive: true, force: true }),
  ]);
  await Promise.all([
    mkdir(path.join(publicRoot, "papers"), { recursive: true }),
    mkdir(path.join(publicRoot, "code"), { recursive: true }),
    mkdir(path.join(publicRoot, "lean"), { recursive: true }),
    mkdir(path.join(publicRoot, "reviews"), { recursive: true }),
    mkdir(path.join(publicRoot, "covers"), { recursive: true }),
    mkdir(path.join(publicRoot, "diagrams"), { recursive: true }),
    mkdir(path.join(publicRoot, "og"), { recursive: true }),
  ]);
  await Promise.all([
    cp(path.join(repoRoot, "papers", "pdf"), path.join(publicRoot, "papers"), { recursive: true }),
    cp(path.join(repoRoot, "src"), path.join(publicRoot, "code"), { recursive: true }),
    cp(path.join(repoRoot, "lean"), path.join(publicRoot, "lean"), { recursive: true }),
    cp(path.join(repoRoot, "reviews"), path.join(publicRoot, "reviews"), { recursive: true }),
  ]);
}

async function buildVisualAssets() {
  for (const [slug, title, eyebrow, number] of papers) {
    const source = path.join(repoRoot, "images", `${slug}.png`);
    if (existsSync(source)) {
      await sharp(source)
        .resize({ width: 840, withoutEnlargement: true })
        .webp({ quality: 82 })
        .toFile(path.join(publicRoot, "covers", `${slug}.webp`));
    }
    await sharp(ogSvg(title, eyebrow, number))
      .png()
      .toFile(path.join(publicRoot, "og", `${slug}.png`));
  }
  await sharp(
    ogSvg(
      "Topological Phases of Matter",
      "FIVE PAPERS + SYNTHESIS / CONDENSED MATHEMATICS",
      "Σ",
    ),
  )
    .png()
    .toFile(path.join(publicRoot, "og", "home.png"));
}

async function buildPaperContent() {
  await mkdir(contentRoot, { recursive: true });
  for (const [slug] of papers) {
    const source = path.join(repoRoot, "papers", "latex", `${slug}.tex`);
    const latex = await readFile(source, "utf8");
    const referenceMap = latexReferenceMap(source);
    const referenceCalls = latexReferenceCalls(latex);
    const rawHtml = run("pandoc", [
      source,
      "--from=latex",
      "--to=html5",
      "--mathjax",
      "--section-divs",
      "--wrap=none",
    ]);
    const rendered = renderPaperHtml(
      rawHtml,
      slug,
      bibliographyKeys(latex),
      referenceMap,
      referenceCalls,
    );
    await writeFile(
      path.join(contentRoot, `${slug}.json`),
      `${JSON.stringify(rendered)}\n`,
      "utf8",
    );
  }
}

await mkdir(publicRoot, { recursive: true });
await copyCorpusAssets();
await Promise.all([buildPaperContent(), buildVisualAssets()]);
console.log(`Built ${papers.length} paper pages and refreshed static corpus assets.`);
