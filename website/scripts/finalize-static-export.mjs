import { readFileSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import path from "node:path";

const outputRoot = path.join(process.cwd(), "out");

function filesBelow(directory) {
  return readdirSync(directory, { withFileTypes: true })
    .flatMap((entry) => {
      const target = path.join(directory, entry.name);
      return entry.isDirectory() ? filesBelow(target) : [target];
    });
}

function attributeValue(attributes, name) {
  const match = attributes.match(new RegExp(
    `(?:^|\\s)${name}\\s*=\\s*(?:"([^"]*)"|'([^']*)'|([^\\s"'=<>]+))`,
    "i",
  ));
  return match?.slice(1).find((value) => value !== undefined) ?? "";
}

function stripClientRuntime(html) {
  let removedScripts = 0;
  let removedScriptPreloads = 0;

  const withoutScripts = html.replace(
    /<script\b([^>]*)>[\s\S]*?<\/script\s*>/gi,
    (element, attributes) => {
      if (attributeValue(attributes, "type").toLowerCase() === "application/ld+json") {
        return element;
      }
      removedScripts += 1;
      return "";
    },
  );

  const finalized = withoutScripts.replace(/<link\b([^>]*)>/gi, (element, attributes) => {
    const rel = attributeValue(attributes, "rel").toLowerCase().split(/\s+/);
    const as = attributeValue(attributes, "as").toLowerCase();
    const href = attributeValue(attributes, "href");
    const isScriptPreload = (rel.includes("preload") || rel.includes("modulepreload"))
      && (as === "script" || /\.m?js(?:[?#]|$)/i.test(href));
    if (!isScriptPreload) return element;
    removedScriptPreloads += 1;
    return "";
  });

  return { html: finalized, removedScripts, removedScriptPreloads };
}

const htmlFiles = filesBelow(outputRoot)
  .filter((file) => file.endsWith(".html"))
  .sort((left, right) => left.localeCompare(right));

const files = htmlFiles.map((file) => {
  const before = readFileSync(file, "utf8");
  const result = stripClientRuntime(before);
  writeFileSync(file, result.html, "utf8");
  return {
    file: path.relative(outputRoot, file).split(path.sep).join("/"),
    beforeBytes: Buffer.byteLength(before),
    afterBytes: Buffer.byteLength(result.html),
    removedScripts: result.removedScripts,
    removedScriptPreloads: result.removedScriptPreloads,
  };
});

const runtimeFiles = filesBelow(outputRoot)
  .filter((file) => (
    path.relative(outputRoot, file).startsWith(`_next${path.sep}`) && file.endsWith(".js")
    || path.basename(file) === "index.txt"
    || path.basename(file).startsWith("__next") && file.endsWith(".txt")
  ));
const prunedRuntimeBytes = runtimeFiles.reduce((total, file) => total + statSync(file).size, 0);
for (const file of runtimeFiles) rmSync(file);

const report = {
  version: 2,
  policy: "Static HTML retains JSON-LD, stylesheets, fonts, and content while removing the unused Next client runtime.",
  prunedRuntimeFiles: runtimeFiles.length,
  prunedRuntimeBytes,
  files,
  totals: files.reduce((totals, file) => ({
    beforeBytes: totals.beforeBytes + file.beforeBytes,
    afterBytes: totals.afterBytes + file.afterBytes,
    removedScripts: totals.removedScripts + file.removedScripts,
    removedScriptPreloads: totals.removedScriptPreloads + file.removedScriptPreloads,
  }), {
    beforeBytes: 0,
    afterBytes: 0,
    removedScripts: 0,
    removedScriptPreloads: 0,
  }),
};

writeFileSync(
  path.join(outputRoot, "static-delivery-report.json"),
  `${JSON.stringify(report, null, 2)}\n`,
  "utf8",
);

const savedBytes = report.totals.beforeBytes - report.totals.afterBytes;
console.log(
  `Finalized ${files.length} HTML files: removed ${report.totals.removedScripts} scripts, `
  + `${report.totals.removedScriptPreloads} JavaScript preloads, pruned ${runtimeFiles.length} runtime files, `
  + `and saved ${savedBytes + prunedRuntimeBytes} bytes.`,
);
