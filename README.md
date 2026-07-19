# terraform-google-cloud-gateway

勉強用の GCP 構成です。**Shared VPC** でネットワークを host project に集約し、環境別（dev / stg / prd）の service project に Next.js + API（Cloud Run）を載せます。

## アーキテクチャ

```text
host-project (Shared VPC)
  VPC + Cloud NAT + PSA
  subnets: study-dev / study-stg / study-prd
       │
       ├─ service-dev  → Cloud Run (web/api) + Cloud SQL + LB/CDN/Armor
       ├─ service-stg  → Cloud Run (web/api) + Cloud SQL + LB/CDN/Armor
       └─ service-prd  → Cloud Run (web/api) + Cloud SQL + LB/CDN/Armor

Internet → Cloud Armor → Global HTTPS LB (+ CDN on frontend)
  ├─ /api/* → Cloud Run API → Cloud SQL (Private IP on Shared VPC)
  └─ /*     → Cloud Run Next.js
```

## ディレクトリ

```text
modules/
  networking/      # VPC, env subnets, NAT, PSA, firewall
  shared_vpc/      # host enable + service attach + subnet IAM
  cloudrun/        # web + api
  database/        # Cloud SQL + Secret Manager
  loadbalancing/   # path-based LB + CDN
  security/        # Cloud Armor
environments/
  host/            # Shared VPC host stack（先に apply）
  service/         # 環境別 app stack（dev/stg/prd）
examples/
  nextjs-app/      # Frontend (pnpm, Node 26)
  api/             # Backend API (pnpm, Node 26)
```

## Apply 順序

### 1. Host（Shared VPC）

```bash
cd environments/host
cp terraform.tfvars.example terraform.tfvars
# host_project_id / service_projects(project_id + project_number) を設定

terraform init
terraform apply
terraform output
```

`project_number` は次で取得できます:

```bash
gcloud projects describe YOUR_PROJECT_ID --format='value(projectNumber)'
```

### 2. Service（環境ごと）

```bash
cd environments/service
cp terraform.tfvars.example terraform.tfvars.dev
# host の output を見て network_* / subnet_* / project_id を設定

terraform init
terraform workspace select dev || terraform workspace new dev
terraform apply -var-file=terraform.tfvars.dev
```

stg / prd も同様（`terraform.tfvars.stg.example` / `terraform.tfvars.prd.example` 参照）。

### 3. アプリイメージ

```bash
# service ディレクトリで
terraform output artifact_registry_url
docker build -t "$(terraform output -raw artifact_registry_url)/web:latest" ../../examples/nextjs-app
docker build -t "$(terraform output -raw artifact_registry_url)/api:latest" ../../examples/api
docker push ...
# tfvars の cloud_run_*_image を更新して再 apply
```

## Shared VPC で付与している権限

| 対象 | ロール | 場所 |
|---|---|---|
| Cloud Run Service Agent（service project） | `roles/compute.networkUser` | host の env subnet |
| Cloud Services SA（service project） | `roles/compute.networkUser` | host の env subnet |
| Cloud Run runtime SA | `roles/compute.networkUser` | service stack が host subnet に付与 |

## 前提

- GCP 組織（またはフォルダ）配下に host / service プロジェクト
- Shared VPC 利用権限（host で Shared VPC Admin 相当）
- ローカル: `gcloud` / `terraform` (>= 1.5) / Docker / Node.js 26

## コスト注意

- 環境を増やすと Cloud SQL / Global LB が環境数ぶん課金されます
- 勉強中は dev だけ作り、不要時は `terraform destroy` 推奨

## ローカル開発（example）

```bash
cd examples/api && corepack enable && pnpm install && pnpm dev
cd examples/nextjs-app && corepack enable && pnpm install && pnpm dev
```
