import type { Metadata } from "next";
import { JsonLd } from "@/components/json-ld";
import { PaperCard } from "@/components/paper-card";
import { papers } from "@/data/papers";

const siteUrl = "https://condensed-phase-spectrum.vercel.app";
const description = "Five papers and a synthesis on the condensed phase spectrum program.";

export const metadata: Metadata = {
  title: "Research Papers",
  description,
  alternates: { canonical: "/papers/" },
  openGraph: {
    type: "website",
    url: "/papers/",
    title: "Research Papers | Spectral Ledger",
    description,
    images: [{
      url: "/og/home.png",
      width: 1200,
      height: 630,
      alt: "The Spectral Ledger research corpus",
    }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Research Papers | Spectral Ledger",
    description,
    images: ["/og/home.png"],
  },
};

const papersJsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "CollectionPage",
      "@id": `${siteUrl}/papers/#collection`,
      url: `${siteUrl}/papers/`,
      name: "Research Papers",
      description,
      isPartOf: { "@id": `${siteUrl}/#website` },
      mainEntity: { "@id": `${siteUrl}/papers/#item-list` },
    },
    {
      "@type": "ItemList",
      "@id": `${siteUrl}/papers/#item-list`,
      name: "Topological phases research corpus",
      numberOfItems: papers.length,
      itemListOrder: "https://schema.org/ItemListOrderAscending",
      itemListElement: papers.map((paper, index) => ({
        "@type": "ListItem",
        position: index + 1,
        url: `${siteUrl}/papers/${paper.slug}/`,
        name: paper.title,
      })),
    },
  ],
};

export default function PapersPage() {
  return (
    <>
      <JsonLd id="papers-structured-data" data={papersJsonLd} />
      <main id="main-content" className="interior-main">
      <header className="interior-hero page-shell">
        <p className="eyebrow">Research corpus / six documents</p>
        <h1>One program, six exact interfaces</h1>
        <p>
          Each paper isolates one obligation in the passage from local interaction data
          to a proposed invertible condensed phase spectrum.
        </p>
      </header>
      <section className="page-shell papers-index" aria-label="Research papers">
        <div className="paper-grid">
          {papers.map((paper) => (
            <PaperCard key={paper.slug} paper={paper} headingLevel={2} />
          ))}
        </div>
      </section>
      </main>
    </>
  );
}
