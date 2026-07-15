import type { Metadata } from "next";
import { IBM_Plex_Mono, Manrope, Newsreader } from "next/font/google";
import "katex/dist/katex.min.css";
import "./globals.css";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";

const newsreader = Newsreader({
  subsets: ["latin"],
  variable: "--font-serif",
  display: "swap",
});

const manrope = Manrope({
  subsets: ["latin"],
  variable: "--font-sans",
  display: "swap",
});

const plexMono = IBM_Plex_Mono({
  subsets: ["latin"],
  weight: ["400", "500", "600"],
  variable: "--font-mono",
  display: "swap",
});

const siteUrl = "https://condensed-phase-spectrum.vercel.app";

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: {
    default: "Spectral Ledger | Topological Phases of Matter",
    template: "%s | Spectral Ledger",
  },
  description:
    "Five papers and a synthesis develop the analytic and categorical program from local quantum interactions to an invertible condensed phase spectrum.",
  authors: [{ name: "Matthew Long" }],
  creator: "Matthew Long",
  publisher: "Spectral Ledger",
  alternates: { canonical: "/" },
  openGraph: {
    type: "website",
    locale: "en_US",
    url: siteUrl,
    siteName: "Spectral Ledger",
    title: "Topological Phases of Matter in Condensed Mathematics",
    description:
      "A five-stage research program with six papers, executable checks, Lean interfaces, and independent reviews.",
    images: [
      {
        url: "/og/home.png",
        width: 1200,
        height: 630,
        alt: "Spectral Ledger research program",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Topological Phases of Matter in Condensed Mathematics",
    description: "Five papers plus a synthesis, code, formal interfaces, and reviews.",
    images: ["/og/home.png"],
  },
  robots: { index: true, follow: true },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${newsreader.variable} ${manrope.variable} ${plexMono.variable}`}>
      <body>
        <a className="skip-link" href="#main-content">Skip to content</a>
        <SiteHeader />
        {children}
        <SiteFooter />
      </body>
    </html>
  );
}
