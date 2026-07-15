import type { ClaimStatus } from "@/data/papers";

export function StatusBadge({ status }: { status: ClaimStatus }) {
  return <span className={`status-badge status-${status}`}>{status.toUpperCase()}</span>;
}
