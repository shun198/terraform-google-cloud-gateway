"use client";

import { useEffect, useState } from "react";

export function ClientApiHello({ initial }) {
  const [data, setData] = useState(initial);
  const [loading, setLoading] = useState(!initial);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setLoading(true);
      try {
        const base = process.env.NEXT_PUBLIC_API_BASE_PATH || "/api";
        const res = await fetch(`${base}/hello`, { cache: "no-store" });
        const json = await res.json();
        if (!cancelled) setData(json);
      } catch (error) {
        if (!cancelled) {
          setData({
            error: error instanceof Error ? error.message : "fetch failed",
          });
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, []);

  if (loading) return <pre>Loading /api/hello ...</pre>;

  return (
    <pre style={{ background: "#f4f4f5", padding: "1rem", overflow: "auto" }}>
      {JSON.stringify(data, null, 2)}
    </pre>
  );
}
