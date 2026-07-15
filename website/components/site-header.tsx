import Link from "next/link";

export function SiteHeader() {
  return (
    <header className="site-header">
      <div className="site-header-inner page-shell">
        <Link className="wordmark" href="/">
          <span className="wordmark-mark" aria-hidden="true">Σ</span>
          <span>
            <strong>Spectral Ledger</strong>
            <small>Condensed phase spectrum</small>
          </span>
        </Link>
        <nav className="site-nav" aria-label="Primary navigation">
          <Link href="/#program">Program</Link>
          <Link href="/papers/">Papers</Link>
          <Link href="/artifacts/">Code + proofs</Link>
        </nav>
      </div>
    </header>
  );
}
