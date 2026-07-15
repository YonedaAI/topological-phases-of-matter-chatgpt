type JsonLdValue = Record<string, unknown> | Array<Record<string, unknown>>;

export function JsonLd({ id, data }: { id: string; data: JsonLdValue }) {
  const json = JSON.stringify(data).replace(/</g, "\\u003c");

  return (
    <script
      id={id}
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: json }}
    />
  );
}
