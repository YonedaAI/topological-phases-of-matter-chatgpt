import type { MetadataRoute } from "next";
import { papers } from "@/data/papers";

const origin = "https://condensed-phase-spectrum.vercel.app";

export const dynamic = "force-static";

export default function sitemap(): MetadataRoute.Sitemap {
  const paperPages = papers.map((paper) => ({
    url: `${origin}/papers/${paper.slug}/`,
    lastModified: new Date("2026-07-14"),
    changeFrequency: "monthly" as const,
    priority: 0.8,
  }));
  return [
    {
      url: `${origin}/`,
      lastModified: new Date("2026-07-14"),
      changeFrequency: "monthly",
      priority: 1,
    },
    {
      url: `${origin}/papers/`,
      lastModified: new Date("2026-07-14"),
      changeFrequency: "monthly",
      priority: 0.9,
    },
    {
      url: `${origin}/artifacts/`,
      lastModified: new Date("2026-07-14"),
      changeFrequency: "monthly",
      priority: 0.8,
    },
    {
      url: `${origin}/pipeline/`,
      lastModified: new Date("2026-07-15"),
      changeFrequency: "monthly",
      priority: 0.7,
    },
    ...paperPages,
  ];
}
