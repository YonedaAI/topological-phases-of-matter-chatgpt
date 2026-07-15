import parse from "html-react-parser";
import katex from "katex";

type MathProps = {
  children: string;
  display?: boolean;
  label?: string;
};

export function Math({ children, display = false, label }: MathProps) {
  const html = katex.renderToString(children, {
    displayMode: display,
    throwOnError: false,
    strict: false,
    trust: false,
    output: "htmlAndMathml",
  });
  return (
    <span
      className={display ? "math-display" : "math-inline"}
      role={label ? "math" : undefined}
      aria-label={label}
    >
      {parse(html)}
    </span>
  );
}
