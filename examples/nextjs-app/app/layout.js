export const metadata = {
  title: "Study Next.js on Cloud Run",
  description: "Sample app for terraform-google-cloud-gateway",
};

export default function RootLayout({ children }) {
  return (
    <html lang="ja">
      <body style={{ fontFamily: "system-ui, sans-serif", margin: 0 }}>
        {children}
      </body>
    </html>
  );
}
