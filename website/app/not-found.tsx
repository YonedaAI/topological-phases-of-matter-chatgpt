import Link from "next/link";
import { ArrowLeft } from "lucide-react";

export default function NotFound() {
  return (
    <main id="main-content" className="not-found page-shell">
      <p className="eyebrow">404 / outside the moduli</p>
      <h1>This state is not in the indexed family.</h1>
      <p>The requested page is absent from the static research ledger.</p>
      <Link className="button button-primary" href="/">
        <ArrowLeft aria-hidden="true" size={17} /> Return to the program
      </Link>
    </main>
  );
}
