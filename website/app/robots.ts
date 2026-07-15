import type { MetadataRoute } from "next";

const origin = "https://condensed-phase-spectrum.vercel.app";

export const dynamic = "force-static";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: { userAgent: "*", allow: "/" },
    sitemap: `${origin}/sitemap.xml`,
  };
}
