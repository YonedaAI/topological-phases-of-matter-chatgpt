import type { Metadata } from "next";
import { ExternalLink, FileCheck2, FileCode2, Sigma } from "lucide-react";
import { StatusBadge } from "@/components/status-badge";
import { papers } from "@/data/papers";

const description = "Haskell checks, Lean interfaces, and independent reviews for the condensed phase spectrum research corpus.";

export const metadata: Metadata = {
  title: "Code, Proofs, and Reviews",
  description,
  alternates: { canonical: "/artifacts/" },
  openGraph: {
    type: "website",
    url: "/artifacts/",
    title: "Code, Proofs, and Reviews | Spectral Ledger",
    description,
    images: [{
      url: "/og/home.png",
      width: 1200,
      height: 630,
      alt: "Code, proof, and review artifacts in Spectral Ledger",
    }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Code, Proofs, and Reviews | Spectral Ledger",
    description,
    images: ["/og/home.png"],
  },
};

function fileLabel(file: string) {
  return file.split("/").at(-1) ?? file;
}

export default function ArtifactsPage() {
  return (
    <main id="main-content" className="interior-main artifacts-page">
      <header className="interior-hero page-shell">
        <p className="eyebrow">Executable research record</p>
        <h1>Code makes each theorem contract inspectable.</h1>
        <p>
          Haskell files test finite witnesses and reject invalid implications. Lean modules
          encode theorem interfaces and status boundaries. Reviews remain visible beside both.
        </p>
      </header>

      <section className="page-shell artifact-notes" aria-label="Artifact interpretation">
        <article>
          <FileCode2 aria-hidden="true" />
          <h2>Haskell</h2>
          <p>Executable finite checks and counterexample contracts. They are not numerical simulations of the thermodynamic limit.</p>
        </article>
        <article>
          <Sigma aria-hidden="true" />
          <h2>Lean</h2>
          <p>Formal library representations and interfaces. Their status modules keep proved statements separate from open obligations.</p>
        </article>
        <article>
          <FileCheck2 aria-hidden="true" />
          <h2>Reviews</h2>
          <p>AGY reviews the papers. Claude independently reviews code and the formal artifacts.</p>
        </article>
      </section>

      <section className="page-shell artifact-ledger" aria-label="Artifacts by paper">
        {papers.map((paper) => (
          <article className={`artifact-entry accent-${paper.accent}`} id={paper.slug} key={paper.slug}>
            <header>
              <div>
                <p className="eyebrow">Paper {paper.sequence}</p>
                <h2>{paper.shortTitle}</h2>
                <p>{paper.statusNote}</p>
              </div>
              <StatusBadge status={paper.status} />
            </header>
            <div className="artifact-columns">
              <div>
                <h3>Executable package</h3>
                <ul className="file-list">
                  {paper.codeFiles.map((file) => (
                    <li key={file}>
                      <a href={`/code/${paper.slug}/${file}`}>
                        <FileCode2 aria-hidden="true" size={15} /> {fileLabel(file)}
                        <ExternalLink aria-hidden="true" size={13} />
                      </a>
                    </li>
                  ))}
                </ul>
              </div>
              <div>
                <h3>Lean</h3>
                <ul className="file-list">
                  {paper.leanFiles.map((file) => (
                    <li key={file}>
                      <a href={`/lean/${file}`}>
                        <Sigma aria-hidden="true" size={15} /> {fileLabel(file)}
                        <ExternalLink aria-hidden="true" size={13} />
                      </a>
                    </li>
                  ))}
                </ul>
              </div>
              <div>
                <h3>Canonical reviews</h3>
                <ul className="file-list">
                  {paper.reviewFiles.map((file) => (
                    <li key={file}>
                      <a href={`/reviews/${file}`}>
                        <FileCheck2 aria-hidden="true" size={15} />
                        {file.includes("agy") ? "AGY paper review" : "Claude code review"}
                        <ExternalLink aria-hidden="true" size={13} />
                      </a>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </article>
        ))}
      </section>

      <section className="page-shell corpus-audits">
        <p className="eyebrow">Corpus-level audits</p>
        <div>
          <a href="/reviews/five-paper-consistency-preaudit.md">Five-paper consistency preaudit</a>
          <a href="/reviews/final-cross-paper-mathematical-audit.md">Final cross-paper mathematical audit</a>
          <a href="/reviews/final-lean-haskell-audit.md">Final Lean and Haskell audit</a>
        </div>
      </section>
    </main>
  );
}
