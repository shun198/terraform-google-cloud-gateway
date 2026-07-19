import { ClientApiHello } from "./api-hello";

export default function HomePage() {
  return (
    <main style={{ padding: "3rem 1.5rem", maxWidth: 720, margin: "0 auto" }}>
      <h1>Next.js + API on Cloud Run</h1>
      <p>
        LB で <code>/</code> → Next.js、<code>/api/*</code> → Backend API
        に振り分けます。API が Cloud SQL（Private IP）へ接続します。
      </p>

      <section style={{ marginTop: "2rem" }}>
        <h2>API sample</h2>
        <p>
          Browser fetch: <code>/api/hello</code>
        </p>
        <ClientApiHello />
      </section>
    </main>
  );
}
