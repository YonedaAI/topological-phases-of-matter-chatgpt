import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { stages } from "@/data/papers";

const stageLinks = [
  "/papers/locality-condensed-families/",
  "/papers/condensed-observables/",
  "/papers/thermodynamic-gaps/",
  "/papers/microscopic-effective-theories/",
  "/papers/invertible-condensed-phase-spectrum/",
];

export function SpectralRail() {
  return (
    <div className="spectral-frame" aria-label="Five-stage research program">
      <div className="spectral-rail">
        {stages.map((stage, index) => (
          <div className={`rail-step rail-${stage.tone}`} key={stage.index}>
            {index === 2 ? (
              <div className="gap-notch" aria-label="Gapless transition locus Sigma">
                <span>Σ</span>
                <small>gapless locus</small>
              </div>
            ) : null}
            <Link href={stageLinks[index]}>
              <span className="rail-index">0{stage.index}</span>
              <span className="rail-notation">{stage.notation}</span>
              <strong>{stage.label}</strong>
              <span className="rail-claim">{stage.claim}</span>
              <ArrowRight aria-hidden="true" size={17} strokeWidth={1.7} />
            </Link>
          </div>
        ))}
      </div>
      <p className="rail-caption">
        The arrows define the research program. They are not assertions of equivalence.
      </p>
    </div>
  );
}
