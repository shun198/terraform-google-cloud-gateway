# terraform-google-cloud-gateway

勉強用の GCP 構成です。**Next.js を Cloud Run に載せ**、Global HTTPS LB / Cloud CDN / Cloud Armor (WAF) / VPC / Cloud NAT / Cloud SQL まで一式を Terraform で作ります。

## アーキテクチャ

```text
Internet
  → Cloud Armor (WAF / rate limit)
  → Global External HTTPS LB (+ Cloud CDN)
  → Serverless NEG
  → Cloud Run (Next.js, Direct VPC Egress)
       → Cloud SQL PostgreSQL (Private IP via PSA)
       → Cloud NAT（必要な外向き通信）
Secret Manager / Artifact Registry
```

| コンポーネント | 役割 |
|---|---|
| VPC + Subnet | Cloud Run Direct VPC Egress / private DB 接続 |
| Cloud NAT | プライベート経路からの外向き通信 |
| Private Service Access | Cloud SQL の Private IP |
| Cloud SQL (PostgreSQL) | アプリ DB |
| Secret Manager | `DATABASE_URL` など |
| Artifact Registry | Next.js コンテナ |
| Cloud Run | Next.js (`output: "standalone"`) |
| Serverless NEG + Global LB | 入口 + CDN |
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

初回はサンプル Hello イメージで Cloud Run が立ちます。Next.js に差し替える流れ:

```bash
# apply 後の output を確認
terraform output artifact_registry_url
terraform output lb_ip_address

gcloud auth configure-docker asia-northeast1-docker.pkg.dev
docker build -t "$(terraform output -raw artifact_registry_url)/web:latest" ./examples/nextjs-app
docker push "$(terraform output -raw artifact_registry_url)/web:latest"
```

`terraform.tfvars` にイメージを書いて再 apply:

```hcl
cloud_run_image = "asia-northeast1-docker.pkg.dev/<project>/study-app/web:latest"
```

ブラウザで `http://<lb_ip_address>` を開きます。

HTTPS にする場合は `domain` を設定し、DNS A レコードを LB IP に向けてから再 apply（Managed SSL が発行されます）。

## モジュール構成

```text
.
├── main.tf / variables.tf / outputs.tf / apis.tf
├── modules/
│   ├── networking/     # VPC, subnet, PSA, NAT, firewall
│   ├── security/       # Cloud Armor
│   ├── database/       # Cloud SQL + Secret Manager
│   ├── cloudrun/       # Cloud Run + Artifact Registry + SA
│   └── loadbalancing/  # NEG, backend, CDN, LB
└── examples/nextjs-app # 最小 Next.js + Dockerfile
```

## コスト注意（勉強用）

- Cloud SQL (`db-f1-micro`) と Global LB は常時課金になりやすいです
- 使わないときは `terraform destroy` 推奨
- Cloud Run は `min_instances = 0` でアイドル時コストを抑えられます

## Cloud Run を選んだ理由

- Next.js（SSR / App Router）をコンテナ一発で載せやすい
- LB + Armor + CDN + Private Cloud SQL の学習に十分
- GKE より運用が軽い（勉強の第一歩向き）

サイドカー必須・複雑な Service Mesh などが必要になったら GKE を検討してください。
