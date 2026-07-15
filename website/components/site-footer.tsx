import Link from "next/link";

export function SiteFooter() {
  return (
    <footer className="site-footer">
      <div className="page-shell footer-grid">
        <div>
          <p className="eyebrow">Research status</p>
          <p className="footer-statement">
            A precise program with established analytic inputs, proposed categorical
            assembly, and explicit open comparisons.
          </p>
        </div>
        <div className="footer-links">
          <Link href="/papers/">Six papers</Link>
          <Link href="/artifacts/">Haskell, Lean, reviews</Link>
          <a href="/reviews/final-cross-paper-mathematical-audit.md">Cross-paper audit</a>
        </div>
        <p className="footer-fineprint">
          Research corpus by Matthew Long. The website reports the claim status recorded
          in the papers; it does not promote conjectures to theorems.
        </p>
      </div>
    </footer>
  );
}
