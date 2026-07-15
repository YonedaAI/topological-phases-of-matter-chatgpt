import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import parse from "html-react-parser";
import { ArrowLeft, ArrowRight, Download, FileCode2, FileText } from "lucide-react";
import { JsonLd } from "@/components/json-ld";
import { StatusBadge } from "@/components/status-badge";
import { paperBySlug, papers } from "@/data/papers";
import { getPaperContent } from "@/lib/content";

const siteUrl = "https://condensed-phase-spectrum.vercel.app";

type PaperPageProps = {
  params: Promise<{ slug: string }>;
};

export function generateStaticParams() {
  return papers.map((paper) => ({ slug: paper.slug }));
}

export async function generateMetadata({ params }: PaperPageProps): Promise<Metadata> {
  const { slug } = await params;
  const paper = paperBySlug(slug);
  if (!paper) return {};
  return {
    title: paper.metadataTitle,
    description: paper.description,
    alternates: { canonical: `/papers/${paper.slug}/` },
    openGraph: {
      type: "article",
      url: `/papers/${paper.slug}/`,
      title: paper.title,
      description: paper.description,
      images: [{
        url: `/og/${paper.slug}.png`,
        width: 1200,
        height: 630,
        alt: paper.title,
      }],
    },
    twitter: {
      card: "summary_large_image",
      title: paper.title,
      description: paper.description,
      images: [`/og/${paper.slug}.png`],
    },
  };
}

export default async function PaperPage({ params }: PaperPageProps) {
  const { slug } = await params;
  const paper = paperBySlug(slug);
  if (!paper) notFound();
  const content = await getPaperContent(paper.slug);
  const paperIndex = papers.findIndex((entry) => entry.slug === paper.slug);
  const previous = paperIndex > 0 ? papers[paperIndex - 1] : undefined;
  const next = paperIndex < papers.length - 1 ? papers[paperIndex + 1] : undefined;
  const paperUrl = `${siteUrl}/papers/${paper.slug}/`;
  const paperJsonLd = {
    "@context": "https://schema.org",
    "@type": "ScholarlyArticle",
    "@id": `${paperUrl}#article`,
    url: paperUrl,
    mainEntityOfPage: paperUrl,
    headline: paper.title,
    alternativeHeadline: paper.subtitle,
    description: paper.description,
    articleSection: paper.stage,
    inLanguage: "en",
    datePublished: "2026-07-14",
    dateModified: "2026-07-14",
    isAccessibleForFree: true,
    author: {
      "@type": "Person",
      "@id": `${siteUrl}/#matthew-long`,
      name: "Matthew Long",
    },
    isPartOf: {
      "@type": "CollectionPage",
      "@id": `${siteUrl}/papers/#collection`,
      name: "Research Papers",
    },
    image: `${siteUrl}/og/${paper.slug}.png`,
    encoding: {
      "@type": "MediaObject",
      contentUrl: `${siteUrl}/papers/${paper.slug}.pdf`,
      encodingFormat: "application/pdf",
    },
  };

  return (
    <>
      <JsonLd id={`${paper.slug}-structured-data`} data={paperJsonLd} />
      <main id="main-content" className="paper-main">
      <header className={`paper-hero accent-${paper.accent}`}>
        <div className="page-shell paper-hero-grid">
          <div>
            <Link className="back-link" href="/papers/">
              <ArrowLeft aria-hidden="true" size={16} /> All papers
            </Link>
            <p className="eyebrow">Paper {paper.sequence} / Stage {paper.stageIndex}</p>
            <StatusBadge status={paper.status} />
            <h1>{paper.title}</h1>
            <p className="paper-deck">{paper.description}</p>
            <p className="paper-status-note">{paper.statusNote}</p>
          </div>
          <aside className="paper-access" aria-label="Paper resources">
            <span className="paper-access-label">Canonical record</span>
            <strong>{paper.pages} pages</strong>
            <a className="button button-primary" href={`/papers/${paper.slug}.pdf`}>
              <Download aria-hidden="true" size={17} /> Download PDF
            </a>
            <a className="button button-secondary" href={`/reviews/${paper.reviewFiles[0]}`}>
              <FileText aria-hidden="true" size={17} /> Paper review
            </a>
            <Link className="text-link" href={`/artifacts/#${paper.slug}`}>
              <FileCode2 aria-hidden="true" size={16} /> Code and proof files
            </Link>
          </aside>
        </div>
      </header>

      <div className="page-shell paper-layout">
        <aside className="paper-toc" aria-label="Table of contents">
          <span className="paper-toc-label">On this page</span>
          <ol>
            {content.toc.filter((item) => item.level <= 2).map((item) => (
              <li key={item.id}><a href={`#${item.id}`}>{item.label}</a></li>
            ))}
          </ol>
        </aside>
        <details className="paper-toc-mobile">
          <summary>On this page</summary>
          <ol>
            {content.toc.filter((item) => item.level <= 2).map((item) => (
              <li key={item.id}><a href={`#${item.id}`}>{item.label}</a></li>
            ))}
          </ol>
        </details>
        <article className="paper-prose">
          {parse(content.html)}
        </article>
      </div>

      <nav className="page-shell paper-pagination" aria-label="Adjacent papers">
        {previous ? (
          <Link href={`/papers/${previous.slug}/`}>
            <ArrowLeft aria-hidden="true" size={18} />
            <span><small>Previous</small>{previous.shortTitle}</span>
          </Link>
        ) : <span />}
        {next ? (
          <Link href={`/papers/${next.slug}/`}>
            <span><small>Next</small>{next.shortTitle}</span>
            <ArrowRight aria-hidden="true" size={18} />
          </Link>
        ) : <span />}
      </nav>
      </main>
    </>
  );
}
