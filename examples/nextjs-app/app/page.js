export default function HomePage() {
  return (
    <main style={{ padding: "3rem 1.5rem", maxWidth: 720, margin: "0 auto" }}>
      <h1>Next.js on Cloud Run</h1>
      <p>
        Global HTTPS LB → Cloud Armor → CDN → Serverless NEG → Cloud Run →
        Cloud SQL (Private IP)
      </p>
      <p>
        DATABASE_URL is injected from Secret Manager. Cloud Run uses Direct VPC
        Egress for private connectivity.
      </p>
    </main>
  );
}
