import { cp, mkdir, rm } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const websiteRoot = path.resolve(here, "..");
const repoRoot = path.resolve(websiteRoot, "..");
const publicRoot = path.join(websiteRoot, "public");

const copies = [
  [path.join(repoRoot, "papers", "pdf"), path.join(publicRoot, "papers")],
  [path.join(repoRoot, "src"), path.join(publicRoot, "code")],
  [path.join(repoRoot, "lean"), path.join(publicRoot, "lean")],
  [path.join(repoRoot, "reviews"), path.join(publicRoot, "reviews")],
];

await mkdir(publicRoot, { recursive: true });
for (const [, destination] of copies) {
  await rm(destination, { recursive: true, force: true });
}
for (const [source, destination] of copies) {
  await cp(source, destination, { recursive: true });
}

console.log("Synchronized canonical PDFs, executable packages, Lean files, and reviews.");
