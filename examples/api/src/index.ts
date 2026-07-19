import { serve } from "@hono/node-server";
import { Hono } from "hono";
import { cors } from "hono/cors";
import pg from "pg";

const { Pool } = pg;

const app = new Hono().basePath("/api");

app.use(
  "*",
  cors({
    origin: "*",
    allowMethods: ["GET", "POST", "OPTIONS"],
  }),
);

app.get("/health", (c) =>
  c.json({
    status: "ok",
    service: "study-api",
    timestamp: new Date().toISOString(),
  }),
);

app.get("/hello", (c) =>
  c.json({
    message: "Hello from Cloud Run API",
  }),
);

app.get("/db/ping", async (c) => {
  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    return c.json(
      {
        ok: false,
        error: "DATABASE_URL is not set",
      },
      500,
    );
  }

  const pool = new Pool({
    connectionString: databaseUrl,
    connectionTimeoutMillis: 5000,
  });

  try {
    const result = await pool.query("select 1 as ok, now() as now");
    return c.json({
      ok: true,
      row: result.rows[0],
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "unknown error";
    return c.json(
      {
        ok: false,
        error: message,
      },
      500,
    );
  } finally {
    await pool.end();
  }
});

const port = Number(process.env.PORT || 8080);

serve({ fetch: app.fetch, port, hostname: "0.0.0.0" }, (info) => {
  console.log(`API listening on http://${info.address}:${info.port}`);
});
