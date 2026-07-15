const invocationGroups = [
  {
    label: "Native Codex agent threads",
    count: 10,
    role: "Authoring, synthesis, implementation, and audits",
    disposition: "Release record",
  },
  {
    label: "Isolated Codex review sessions",
    count: 24,
    role: "Early schema-bound reviewer attempts",
    disposition: "Superseded by Claude reviews",
  },
  {
    label: "AGY review rounds",
    count: 20,
    role: "Scientific peer review of five papers and synthesis",
    disposition: "Canonical paper-review record",
  },
  {
    label: "Claude review rounds",
    count: 24,
    role: "Haskell, Lean, and website code review",
    disposition: "Canonical code-review record",
  },
] as const;

const cachedInput = 1_767_338_496;
const uncachedInput = 40_665_511;
const input = cachedInput + uncachedInput;
const output = 5_125_595;
const grossTotal = input + output;
const nativeCodex = 1_791_555_257;
const isolatedCodex = 21_574_345;

if (nativeCodex + isolatedCodex !== grossTotal) {
  throw new Error("Codex session token subtotals must equal the gross token total");
}

export const pipelineSnapshot = {
  title: "Condensed phase spectrum research release",
  status: "Released",
  approvedAt: "2026-07-15T00:05:09.813Z",
  completedAt: "2026-07-15T03:36:21.520Z",
  approvedRuntime: "3 h 31 m 12 s",
  requestToReleaseRuntime: "3 h 38 m 21 s",
  frozenCommit: "503ead5c0c8ff9de52a2c608395fe50f881a68e7",
  frozenCommitShort: "503ead5",
  codexSessions: 34,
  recordedInvocations: invocationGroups.reduce((total, group) => total + group.count, 0),
  spend: null,
  invocationGroups,
  models: [
    {
      system: "Codex native team",
      model: "gpt-5.6-sol",
      effort: "xhigh, then Ultra",
      count: 10,
      coverage: "Native authoring and audit threads",
    },
    {
      system: "Codex isolated review",
      model: "gpt-5.5",
      effort: "xhigh",
      count: 24,
      coverage: "Superseded reviewer attempts",
    },
    {
      system: "AGY",
      model: "Gemini 3.1 Pro",
      effort: "High",
      count: 20,
      coverage: "Paper and synthesis review rounds",
    },
    {
      system: "Claude CLI",
      model: "Claude",
      effort: "Opus / high where explicitly pinned",
      count: 24,
      coverage: "Code and website review rounds; some early artifacts omit the exact alias",
    },
  ],
  tokens: {
    grossTotal,
    input,
    cachedInput,
    uncachedInput,
    output,
    reasoningOutput: 1_954_724,
    cachedInputPercent: Number(((cachedInput / input) * 100).toFixed(2)),
    uncachedInputPercent: Number(((uncachedInput / input) * 100).toFixed(2)),
    nativeCodex,
    isolatedCodex,
  },
  stages: [
    {
      id: "code",
      label: "Code",
      detail: "Five papers plus synthesis, six Haskell packages, and a Lean library representation produced.",
    },
    {
      id: "review",
      label: "Review",
      detail: "20 AGY scientific rounds and 24 Claude code-review rounds recorded.",
    },
    {
      id: "fix",
      label: "Fix",
      detail: "Valid mathematical, interface, accessibility, and release findings resolved.",
    },
    {
      id: "verify",
      label: "Verify",
      detail: "Paper, Haskell, Lean, static export, SEO, and responsive gates passed.",
    },
    {
      id: "deploy",
      label: "Deploy",
      detail: "Public repository and zero-client-JavaScript website released.",
    },
  ],
} as const;

export function formatInteger(value: number) {
  return new Intl.NumberFormat("en-US").format(value);
}
