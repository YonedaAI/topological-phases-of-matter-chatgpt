import Image from "next/image";
import Link from "next/link";
import { ArrowUpRight, FileText } from "lucide-react";
import type { Paper } from "@/data/papers";
import { StatusBadge } from "@/components/status-badge";

export function PaperCard({
  paper,
  featured = false,
  headingLevel = 3,
}: {
  paper: Paper;
  featured?: boolean;
  headingLevel?: 2 | 3;
}) {
  const CardHeading = headingLevel === 2 ? "h2" : "h3";

  return (
    <article className={`paper-card accent-${paper.accent}${featured ? " paper-featured" : ""}`}>
      <Link className="paper-cover-link" href={`/papers/${paper.slug}/`} aria-label={`Read ${paper.title}`}>
        <Image
          className="paper-cover"
          src={`/covers/${paper.slug}.webp`}
          alt={`Page one of ${paper.title}`}
          width={840}
          height={1087}
          sizes={featured ? "(max-width: 760px) 100vw, 48vw" : "(max-width: 760px) 100vw, 31vw"}
        />
      </Link>
      <div className="paper-card-body">
        <div className="paper-card-meta">
          <span>Paper {paper.sequence}</span>
          <span>{paper.pages} pages</span>
        </div>
        <StatusBadge status={paper.status} />
        <CardHeading>
          <Link href={`/papers/${paper.slug}/`}>{paper.shortTitle}</Link>
        </CardHeading>
        <p className="paper-subtitle">{paper.subtitle}</p>
        <p>{paper.description}</p>
        <div className="paper-card-actions">
          <Link className="text-link" href={`/papers/${paper.slug}/`}>
            Read paper <ArrowUpRight aria-hidden="true" size={16} />
          </Link>
          <a className="text-link text-link-muted" href={`/papers/${paper.slug}.pdf`}>
            PDF <FileText aria-hidden="true" size={15} />
          </a>
        </div>
      </div>
    </article>
  );
}
