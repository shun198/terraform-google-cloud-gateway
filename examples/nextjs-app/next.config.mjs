/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "standalone",
  async rewrites() {
    // ローカル開発時: /api/* → examples/api (pnpm dev on :8080)
    // 本番 (Cloud Run + LB) では LB が /api を振り分けるため不要だが、
    // 同一オリジン fetch のままローカルでも動くようにする。
    if (process.env.NODE_ENV === "development") {
      return [
        {
          source: "/api/:path*",
          destination: "http://127.0.0.1:8080/api/:path*",
        },
      ];
    }
    return [];
  },
};

export default nextConfig;
