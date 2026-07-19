# study-api

Cloud Run 向けの最小バックエンド API（Hono + TypeScript + **pnpm**）です。

| Path | 説明 |
|---|---|
| `GET /api/health` | ヘルスチェック |
| `GET /api/hello` | サンプルレスポンス |
| `GET /api/db/ping` | Cloud SQL (`DATABASE_URL`) 疎通確認 |

```bash
corepack enable
pnpm install
pnpm dev
```

本番イメージ:

```bash
docker build -t api:latest .
```
