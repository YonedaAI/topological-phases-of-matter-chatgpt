import "server-only";

import { readFile } from "node:fs/promises";
import path from "node:path";

export type PaperContent = {
  html: string;
  references: {
    occurrences: number;
    targets: number;
  };
  toc: Array<{
    id: string;
    label: string;
    level: number;
  }>;
};

export async function getPaperContent(slug: string): Promise<PaperContent> {
  const file = path.join(process.cwd(), "content", "papers", `${slug}.json`);
  return JSON.parse(await readFile(file, "utf8")) as PaperContent;
}
