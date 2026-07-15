import Link from "next/link";
import { ArrowRight, Braces, FileCheck2, Layers3 } from "lucide-react";
import { JsonLd } from "@/components/json-ld";
import { Math } from "@/components/math";
import { PaperCard } from "@/components/paper-card";
import { SpectralRail } from "@/components/spectral-rail";
import { StatusBadge } from "@/components/status-badge";
import { ledgerClaims, papers } from "@/data/papers";

const siteUrl = "https://condensed-phase-spectrum.vercel.app";
const homeJsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "WebSite",
      "@id": `${siteUrl}/#website`,
      url: `${siteUrl}/`,
      name: "Spectral Ledger",
      description:
        "Five papers and a synthesis on topological phases of matter in condensed mathematics.",
      inLanguage: "en",
      author: { "@id": `${siteUrl}/#matthew-long` },
    },
    {
      "@type": "Person",
      "@id": `${siteUrl}/#matthew-long`,
      name: "Matthew Long",
    },
  ],
};

export default function Home() {
  return (
    <>
      <JsonLd id="home-structured-data" data={homeJsonLd} />
      <main id="main-content">
      <section className="hero page-shell">
        <div className="hero-copy">
          <p className="eyebrow">Condensed mathematics × quantum matter</p>
          <h1>Where does a topological phase become a theorem?</h1>
          <p className="hero-lede">
            A six-paper research program tracks the exact obligations between local
            Hamiltonians, uniform gaps, stabilized phases, and an invertible condensed
            phase spectrum.
          </p>
          <div className="hero-actions">
            <Link className="button button-primary" href="#program">
              Trace the program <ArrowRight aria-hidden="true" size={18} />
            </Link>
            <a className="button button-secondary" href="/papers/invertible-condensed-phase-spectrum.pdf">
              Read the synthesis PDF
            </a>
          </div>
        </div>
        <aside className="hero-ledger" aria-label="Research program summary">
          <div className="ledger-topline">
            <span>PROGRAM / 2026</span>
            <span>5 + 1 PAPERS</span>
          </div>
          <Math display label="The five-stage program">
            {String.raw`\mathcal I_{\mathrm{loc}} \longrightarrow \mathrm{Ham}_{\mathrm{cond}} \supset \mathrm{Gap}_{\mathrm{unif}} \longrightarrow \mathrm{Ph}_{\infty}^{\mathrm{st}} \longrightarrow \mathbf E_{\mathrm{phase}}^{\times}`}
          </Math>
          <div className="hero-gapline">
            <span>analytic input</span>
            <span className="sigma">Σ</span>
            <span>categorical assembly</span>
          </div>
          <p>
            Every arrow carries a ledger entry: theorem, proposal, conjecture, open
            comparison, or obstruction.
          </p>
        </aside>
      </section>

      <section className="program-section section-rule" id="program">
        <div className="page-shell">
          <div className="section-heading split-heading">
            <div>
              <p className="eyebrow">The five-stage program</p>
              <h2>A spectral flow with its gap exposed</h2>
            </div>
            <p>
              The coral notch marks the gapless transition locus. It is a boundary to
              analyze, not a categorical shortcut.
            </p>
          </div>
          <SpectralRail />
        </div>
      </section>

      <section className="ledger-section section-rule">
        <div className="page-shell">
          <div className="section-heading split-heading">
            <div>
              <p className="eyebrow">Claim-status ledger</p>
              <h2>What is proved, and what is not</h2>
            </div>
            <p>
              Conditions stay in the scope column. Epistemic labels use the corpus-wide
              vocabulary exactly.
            </p>
          </div>
          <div className="claim-ledger" role="table" aria-label="Claim status ledger">
            <div className="claim-row claim-header" role="row">
              <span role="columnheader">ID</span>
              <span role="columnheader">Status</span>
              <span role="columnheader">Claim</span>
              <span role="columnheader">Scope</span>
            </div>
            {ledgerClaims.map((item) => (
              <div className="claim-row" role="row" key={item.id}>
                <span className="claim-id" role="cell">{item.id}</span>
                <span role="cell"><StatusBadge status={item.status} /></span>
                <strong role="cell">{item.claim}</strong>
                <span className="claim-scope" role="cell">{item.scope}</span>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="papers-section section-rule" id="papers">
        <div className="page-shell">
          <div className="section-heading split-heading">
            <div>
              <p className="eyebrow">Five papers + synthesis</p>
              <h2>The research corpus</h2>
            </div>
            <p>
              Read each paper as HTML, open the canonical PDF, and inspect its matching
              executable and formal artifacts.
            </p>
          </div>
          <div className="paper-grid">
            {papers.map((paper) => (
              <PaperCard key={paper.slug} paper={paper} featured={paper.sequence === "S"} />
            ))}
          </div>
        </div>
      </section>

      <section className="artifact-callout section-rule">
        <div className="page-shell">
          <div className="section-heading split-heading">
            <div>
              <p className="eyebrow">Executable research record</p>
              <h2>Claims paired with things you can inspect</h2>
            </div>
            <Link className="text-link" href="/artifacts/">
              Open the artifact index <ArrowRight aria-hidden="true" size={17} />
            </Link>
          </div>
          <div className="artifact-grid">
            <article>
              <Braces aria-hidden="true" />
              <span className="artifact-count">16</span>
              <h3>Haskell files</h3>
              <p>Finite witnesses and contract checks that reject known false inferences.</p>
            </article>
            <article>
              <Layers3 aria-hidden="true" />
              <span className="artifact-count">10</span>
              <h3>Lean modules</h3>
              <p>Library interfaces that formalize the program without overstating results.</p>
            </article>
            <article>
              <FileCheck2 aria-hidden="true" />
              <span className="artifact-count">2×</span>
              <h3>Review tracks</h3>
              <p>AGY paper review and independent Claude code review for each paper.</p>
            </article>
          </div>
        </div>
      </section>
      </main>
    </>
  );
}
