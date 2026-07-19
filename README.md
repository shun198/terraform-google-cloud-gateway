# terraform-google-cloud-gateway

勉強用の GCP 構成です。**Next.js（フロント）と Backend API をそれぞれ Cloud Run** に載せ、Global HTTPS LB / Cloud CDN / Cloud Armor (WAF) / VPC / Cloud NAT / Cloud SQL まで一式を Terraform で作ります。

## アーキテクチャ

```text
Internet
  → Cloud Armor (WAF / rate limit)
  → Global External HTTPS LB (+ Cloud CDN on frontend)
       ├─ /api/*  → Serverless NEG → Cloud Run API
       │                              → Cloud SQL (Private IP)
       └─ /*      → Serverless NEG → Cloud Run Next.js
Secret Manager / Artifact Registry / Cloud NAT
```

| コンポーネント | 役割 |
|---|---|
| VPC + Subnet | Cloud Run Direct VPC Egress / private DB 接続 |
| Cloud NAT | プライベート経路からの外向き通信 |
| Private Service Access | Cloud SQL の Private IP |
| Cloud SQL (PostgreSQL) | アプリ DB（API から接続） |
| Secret Manager | `DATABASE_URL` など |
| Artifact Registry | web / api コンテナ |
| Cloud Run (web) | Next.js (`output: "standalone"`) |
| Cloud Run (api) | Hono API |
| Serverless NEG + Global LB | 入口。`/api/*` とそれ以外を振り分け |
| Cloud Armor | WAF / throttle / Adaptive Protection |

## 前提

- GCP プロジェクトと課金有効化
- ローカルに `gcloud` / `terraform` (>= 1.5) / Docker
- 権限: Project Owner または相当（API 有効化・IAM・ネットワーク作成）

## 使い方

```bash
cp terraform.tfvars.example terraform.tfvars
# project_id などを編集

terraform init
terraform plan
terraform apply
```

初回はサンプル Hello イメージで Cloud Run が立ちます。Next.js / API に差し替える流れ:

```bash
terraform output artifact_registry_url
terraform output lb_ip_address

gcloud auth configure-docker asia-northeast1-docker.pkg.dev
docker build -t "$(terraform output -raw artifact_registry_url)/web:latest" ./examples/nextjs-app
docker build -t "$(terraform output -raw artifact_registry_url)/api:latest" ./examples/api
docker push "$(terraform output -raw artifact_registry_url)/web:latest"
docker push "$(terraform output -raw artifact_registry_url)/api:latest"
```

`terraform.tfvars` にイメージを書いて再 apply:

```hcl
cloud_run_web_image = "asia-northeast1-docker.pkg.dev/<project>/study-app/web:latest"
cloud_run_api_image = "asia-northeast1-docker.pkg.dev/<project>/study-app/api:latest"
```

- Frontend: `http://<lb_ip_address>`
- API health: `http://<lb_ip_address>/api/health`
- DB ping: `http://<lb_ip_address>/api/db/ping`

HTTPS にする場合は `domain` を設定し、DNS A レコードを LB IP に向けてから再 apply。

## モジュール構成

```text
.
├── main.tf / variables.tf / outputs.tf / apis.tf
├── modules/
│   ├── networking/     # VPC, subnet, PSA, NAT, firewall
│   ├── security/       # Cloud Armor
│   ├── database/       # Cloud SQL + Secret Manager
│   ├── cloudrun/       # web + api Cloud Run, Artifact Registry, SA
│   └── loadbalancing/  # NEG, path-based routing, CDN, LB
└── examples/
    ├── nextjs-app/     # フロント (pnpm)
    └── api/            # バックエンド API (pnpm + Hono)
```

ローカル開発:

```bash
# API
cd examples/api && corepack enable && pnpm install && pnpm dev

# Frontend（別ターミナル）
cd examples/nextjs-app && corepack enable && pnpm install && pnpm dev
```

ローカルでは Next.js が `http://localhost:3000`、API が `http://localhost:8080` です。ブラウザから `/api` を叩く場合は Next.js の rewrite か、LB 経由で確認してください。

## コスト注意（勉強用）

- Cloud SQL (`db-f1-micro`) と Global LB は常時課金になりやすいです
- 使わないときは `terraform destroy` 推奨
- Cloud Run は `min_instances = 0` でアイドル時コストを抑えられます

## Cloud Run を選んだ理由

- Next.js / API をコンテナ単位で分けやすい
- LB + Armor + CDN + Private Cloud SQL の学習に十分
- GKE より運用が軽い（勉強の第一歩向き）

サイドカー必須・複雑な Service Mesh などが必要になったら GKE を検討してください。
