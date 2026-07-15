import type { Metadata } from "next";
import { ArrowUpRight, CircleCheck, Clock3, Database, GitBranch, ReceiptText } from "lucide-react";
import { JsonLd } from "@/components/json-ld";
import { formatInteger, pipelineSnapshot } from "@/data/pipeline";

const origin = "https://condensed-phase-spectrum.vercel.app";
const description =
  "An audited snapshot of agent sessions, model invocations, elapsed time, token coverage, and review status for the condensed phase spectrum research release.";
const cachedInputPercent = pipelineSnapshot.tokens.cachedInputPercent.toFixed(2);
const uncachedInputPercent = pipelineSnapshot.tokens.uncachedInputPercent.toFixed(2);

export const metadata: Metadata = {
  title: "Pipeline Metrics",
  description,
  alternates: { canonical: "/pipeline/" },
  openGraph: {
    type: "website",
    url: "/pipeline/",
    title: "Pipeline Metrics | Spectral Ledger",
    description,
    images: [{
      url: "/og/home.png",
      width: 1200,
      height: 630,
      alt: "Spectral Ledger pipeline metrics",
    }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Pipeline Metrics | Spectral Ledger",
    description,
    images: ["/og/home.png"],
  },
};

const pipelineJsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "WebPage",
      "@id": `${origin}/pipeline/#page`,
      url: `${origin}/pipeline/`,
      name: "Pipeline Metrics | Spectral Ledger",
      description,
      dateModified: "2026-07-15",
      mainEntity: { "@id": `${origin}/pipeline/#dataset` },
    },
    {
      "@type": "Dataset",
      "@id": `${origin}/pipeline/#dataset`,
      name: "Condensed phase spectrum pipeline snapshot",
      description,
      dateCreated: "2026-07-15",
      temporalCoverage: "2026-07-14/2026-07-15",
      creator: { "@type": "Person", name: "Matthew Long" },
      isBasedOn: `https://github.com/YonedaAI/topological-phases-of-matter-chatgpt/commit/${pipelineSnapshot.frozenCommit}`,
      measurementTechnique: [
        "Codex JSONL session token ledgers",
        "Committed AGY and Claude review-round artifacts",
        "Git release timestamps",
      ],
    },
  ],
};

export default function PipelinePage() {
  return (
    <>
      <JsonLd id="pipeline-structured-data" data={pipelineJsonLd} />
      <main id="main-content" className="pipeline-main">
        <header className="pipeline-hero page-shell">
          <div className="pipeline-hero-copy">
            <p className="eyebrow">Audited release telemetry / frozen snapshot</p>
            <h1>What the research pipeline actually ran.</h1>
            <p>
              This ledger separates native agents from isolated review sessions and
              external reviewer calls. Missing billing data stays missing; it is never
              converted into a fictional zero.
            </p>
          </div>
          <div className="pipeline-freeze" role="region" aria-label="Snapshot status">
            <span><CircleCheck aria-hidden="true" size={16} /> {pipelineSnapshot.status}</span>
            <p>Frozen at release completion</p>
            <time dateTime={pipelineSnapshot.completedAt}>15 Jul 2026 · 03:36:21 UTC</time>
            <a
              href={`https://github.com/YonedaAI/topological-phases-of-matter-chatgpt/commit/${pipelineSnapshot.frozenCommit}`}
            >
              commit {pipelineSnapshot.frozenCommitShort}
              <ArrowUpRight aria-hidden="true" size={14} />
            </a>
          </div>
        </header>

        <section className="pipeline-metrics page-shell" aria-label="Pipeline headline metrics">
          <article>
            <GitBranch aria-hidden="true" size={18} />
            <strong data-pipeline-metric="codex-sessions">{pipelineSnapshot.codexSessions}</strong>
            <h2>Codex sessions</h2>
            <p>10 native agent threads + 24 isolated review runs</p>
          </article>
          <article>
            <Database aria-hidden="true" size={18} />
            <strong data-pipeline-metric="model-invocations">{pipelineSnapshot.recordedInvocations}</strong>
            <h2>Model invocations</h2>
            <p>All recorded Codex, AGY, and Claude executions</p>
          </article>
          <article>
            <Clock3 aria-hidden="true" size={18} />
            <strong data-pipeline-metric="approved-runtime">{pipelineSnapshot.approvedRuntime}</strong>
            <h2>Approved runtime</h2>
            <p>Approval to release-completion timestamp</p>
          </article>
          <article>
            <Database aria-hidden="true" size={18} />
            <strong data-pipeline-metric="codex-tokens">{formatInteger(pipelineSnapshot.tokens.grossTotal)}</strong>
            <h2>Tracked Codex tokens</h2>
            <p>Gross logged total, dominated by cached context</p>
          </article>
          <article className="metric-unavailable">
            <ReceiptText aria-hidden="true" size={18} />
            <strong data-pipeline-spend="not-recorded">Not recorded</strong>
            <h2>Monetary spend</h2>
            <p>No billing ledger was retained for this run</p>
          </article>
        </section>

        <section className="pipeline-section section-rule">
          <div className="page-shell">
            <div className="section-heading split-heading">
              <div>
                <p className="eyebrow">Execution accounting</p>
                <h2>34 sessions. 78 model calls.</h2>
              </div>
              <p>
                “Agent” can mean different things. The native Codex team contained 10
                threads; the broader Codex execution record contains 34 sessions. Adding
                the 44 external review calls yields 78 recorded invocations.
              </p>
            </div>
            <div className="pipeline-table-shell" tabIndex={0} role="region" aria-label="Invocation ledger, scrollable on narrow screens">
              <table className="pipeline-table">
                <thead>
                  <tr>
                    <th scope="col">Execution group</th>
                    <th scope="col">Runs</th>
                    <th scope="col">Role</th>
                    <th scope="col">Disposition</th>
                  </tr>
                </thead>
                <tbody>
                  {pipelineSnapshot.invocationGroups.map((group) => (
                    <tr data-pipeline-invocations={group.count} key={group.label}>
                      <th scope="row">{group.label}</th>
                      <td className="table-number">{group.count}</td>
                      <td>{group.role}</td>
                      <td>{group.disposition}</td>
                    </tr>
                  ))}
                </tbody>
                <tfoot>
                  <tr>
                    <th scope="row">Recorded model invocations</th>
                    <td className="table-number">{pipelineSnapshot.recordedInvocations}</td>
                    <td colSpan={2}>Snapshot total across all four groups</td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>
        </section>

        <section className="pipeline-section section-rule">
          <div className="page-shell">
            <div className="section-heading split-heading">
              <div>
                <p className="eyebrow">Model registry</p>
                <h2>Models and effort levels</h2>
              </div>
              <p>
                Counts are recorded executions, not peak concurrency. Early Claude
                artifacts did not retain an exact model alias, so the registry reports
                Opus/high only where it was explicitly pinned.
              </p>
            </div>
            <div className="pipeline-table-shell" tabIndex={0} role="region" aria-label="Model registry, scrollable on narrow screens">
              <table className="pipeline-table pipeline-model-table">
                <thead>
                  <tr>
                    <th scope="col">System</th>
                    <th scope="col">Model</th>
                    <th scope="col">Effort</th>
                    <th scope="col">Runs</th>
                    <th scope="col">Coverage</th>
                  </tr>
                </thead>
                <tbody>
                  {pipelineSnapshot.models.map((model) => (
                    <tr key={model.system}>
                      <th scope="row">{model.system}</th>
                      <td><code>{model.model}</code></td>
                      <td>{model.effort}</td>
                      <td className="table-number">{model.count}</td>
                      <td>{model.coverage}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </section>

        <section className="pipeline-section section-rule">
          <div className="page-shell token-layout">
            <div>
              <p className="eyebrow">Token accounting</p>
              <h2>Gross traffic, with cache made visible</h2>
              <p className="token-intro">
                Codex token events record repeated context as input. That is why the
                gross figure is large: {cachedInputPercent}% of input was cached. AGY and Claude token
                usage was not retained and is outside this total.
              </p>
              <div
                className="cache-composition"
                role="img"
                aria-label={`Codex input composition: ${cachedInputPercent} percent cached and ${uncachedInputPercent} percent uncached`}
              >
                <span className="cache-cached" style={{ width: `${pipelineSnapshot.tokens.cachedInputPercent}%` }} />
                <span className="cache-uncached" style={{ width: `${pipelineSnapshot.tokens.uncachedInputPercent}%` }} />
              </div>
              <div className="cache-legend" aria-hidden="true">
                <span><i className="legend-teal" />{cachedInputPercent}% cached input</span>
                <span><i className="legend-coral" />{uncachedInputPercent}% uncached input</span>
              </div>
            </div>
            <dl className="token-ledger">
              <div>
                <dt>Gross Codex total</dt>
                <dd data-pipeline-token={pipelineSnapshot.tokens.grossTotal}>{formatInteger(pipelineSnapshot.tokens.grossTotal)}</dd>
              </div>
              <div>
                <dt>Input</dt>
                <dd data-pipeline-token={pipelineSnapshot.tokens.input}>{formatInteger(pipelineSnapshot.tokens.input)}</dd>
              </div>
              <div>
                <dt>Cached input</dt>
                <dd data-pipeline-token={pipelineSnapshot.tokens.cachedInput}>{formatInteger(pipelineSnapshot.tokens.cachedInput)}</dd>
              </div>
              <div>
                <dt>Uncached input</dt>
                <dd data-pipeline-token={pipelineSnapshot.tokens.uncachedInput}>{formatInteger(pipelineSnapshot.tokens.uncachedInput)}</dd>
              </div>
              <div>
                <dt>Output</dt>
                <dd data-pipeline-token={pipelineSnapshot.tokens.output}>{formatInteger(pipelineSnapshot.tokens.output)}</dd>
              </div>
              <div>
                <dt>Reasoning output</dt>
                <dd data-pipeline-token={pipelineSnapshot.tokens.reasoningOutput}>{formatInteger(pipelineSnapshot.tokens.reasoningOutput)} <small>subset of output</small></dd>
              </div>
              <div>
                <dt>Native Codex sessions</dt>
                <dd data-pipeline-token={pipelineSnapshot.tokens.nativeCodex}>{formatInteger(pipelineSnapshot.tokens.nativeCodex)}</dd>
              </div>
              <div>
                <dt>Isolated Codex sessions</dt>
                <dd data-pipeline-token={pipelineSnapshot.tokens.isolatedCodex}>{formatInteger(pipelineSnapshot.tokens.isolatedCodex)}</dd>
              </div>
            </dl>
          </div>
        </section>

        <section className="pipeline-section section-rule">
          <div className="page-shell">
            <div className="section-heading split-heading">
              <div>
                <p className="eyebrow">Release loop</p>
                <h2>Code → review → fix → verify → deploy</h2>
              </div>
              <p>
                Each stage advances only after its release evidence exists. Review and
                verification remain separate: a reviewer can find an issue, while a
                build gate confirms that the applied correction survives the corpus.
              </p>
            </div>
            <ol className="execution-trace" aria-label="Completed release stages">
              {pipelineSnapshot.stages.map((stage, index) => (
                <li data-pipeline-stage={stage.id} key={stage.id}>
                  <span className="trace-index">{String(index + 1).padStart(2, "0")}</span>
                  <CircleCheck aria-hidden="true" size={18} />
                  <div>
                    <h3>{stage.label}</h3>
                    <p>{stage.detail}</p>
                  </div>
                  <span className="trace-status">complete</span>
                </li>
              ))}
            </ol>
          </div>
        </section>

        <section className="pipeline-method section-rule">
          <div className="page-shell pipeline-method-grid">
            <div>
              <p className="eyebrow">Coverage and provenance</p>
              <h2>What this snapshot can support</h2>
              <p>
                Counts were reconstructed from Codex session ledgers, committed AGY and
                Claude review-round files, and Git timestamps. The snapshot ends at the
                release-completion record, commit {pipelineSnapshot.frozenCommitShort}.
              </p>
            </div>
            <dl>
              <div>
                <dt>Approved window</dt>
                <dd>
                  <time dateTime={pipelineSnapshot.approvedAt}>00:05:09 UTC</time>
                  {" → "}
                  <time dateTime={pipelineSnapshot.completedAt}>03:36:21 UTC</time>
                </dd>
              </div>
              <div>
                <dt>Request to release</dt>
                <dd>{pipelineSnapshot.requestToReleaseRuntime}</dd>
              </div>
              <div>
                <dt>External token coverage</dt>
                <dd>Not recorded</dd>
              </div>
              <div>
                <dt>Monetary spend</dt>
                <dd>Not recorded; no estimate substituted</dd>
              </div>
            </dl>
          </div>
        </section>
      </main>
    </>
  );
}
