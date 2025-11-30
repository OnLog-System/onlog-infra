# 📘 OnLog Infrastructure (Terraform + GitHub Actions)

OnLog 프로젝트의 AWS 인프라는 **Terraform 기반 IaC(Infrastructure as Code)** 형태로 관리되며,
**GitHub Actions로 dev/prod 환경에 자동 배포되는 완전한 CI/CD 파이프라인**을 제공합니다.

---

# 🔧 기술 스택

* **Terraform v1.14.0**
* **AWS Provider v6.x**
* **GitHub Actions**
* **S3 + DynamoDB (Terraform State & Lock)**
* **S3 (환경 변수: tfvars 저장소)**

---

# 🏗 Infrastructure Overview

## 💡 환경 분리 방식

* `main` 브랜치 → **dev 환경 자동 배포**
* `prod` 브랜치 → **prod 환경 자동 배포**

## 💡 구성 특징

* VPC, SG, ALB, EKS, MSK 등 모두 **modules**로 재사용 가능하게 설계
* dev/prod 환경의 변수 값은 **tfvars(S3에서 관리)** 로 분리
* GitHub Actions는 항상 **S3에서 최신 tfvars 읽기 → plan/apply 실행**

---

# 📁 Repository Structure

```
onlog-infra/
├── .github/workflows/
│   ├── terraform-dev.yml       # main → dev 자동 배포
│   └── terraform-prod.yml      # prod → prod 자동 배포
│
├── global/
│   └── s3/                     # tfvars 저장용 S3 버킷
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── env/
│   ├── dev/
│   │   ├── backend.tf          # dev backend (S3 + DynamoDB)
│   │   ├── main.tf             # dev 인프라 정의 (모듈 호출)
│   │   ├── variables.tf        # 환경 변수 정의
│   │   ├── terraform.tfvars    # (gitignore) 환경별 값
│   │   └── terraform.tfvars.example
│   │
│   └── prod/
│       ├── backend.tf
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── terraform.tfvars.example
│
├── modules/
│   ├── vpc/
│   ├── sg/
│   ├── alb/
│   ├── endpoints/
│   ├── eks/
│   ├── nodegroup/
│   ├── msk-serverless/
│   └── msk-provisioned/
│
├── providers.tf
├── versions.tf
└── README.md
```

---

# 🔐 Terraform State Backend

Terraform state는 AWS에 저장됩니다.

| 항목            | 값                        |
| ------------- | ------------------------ |
| State Bucket  | `onlog-terraform-state`  |
| Lock DynamoDB | `onlog-terraform-lock`   |
| dev state 경로  | `dev/terraform.tfstate`  |
| prod state 경로 | `prod/terraform.tfstate` |

---

# 📦 tfvars 저장 구조 (중요!)

환경 변수 파일(`terraform.tfvars`)은 보안/공개 이슈 때문에 **레포에 포함하지 않음**
→ 대신 **전용 S3 버킷에서만 관리**합니다.

### tfvars 저장 버킷

* `onlog-tfvars-config`

### 개발자 로컬에서 tfvars 업로드

```
aws s3 cp env/dev/terraform.tfvars s3://onlog-tfvars-config/dev.tfvars
```

### GitHub Actions에서는 항상 S3에서 다운로드하여 실행

```
aws s3 cp s3://onlog-tfvars-config/dev.tfvars terraform.tfvars
```

---

# 🚀 GitHub Actions (CI/CD)

## ✔ terraform-dev.yml (main → dev)

* PR: fmt, validate, plan → PR 댓글 자동 작성
* main push: init + plan + apply → dev 자동 배포
* 시작 전 S3에서 tfvars 다운로드

## ✔ terraform-prod.yml (prod → prod)

* prod 브랜치 동일한 방식으로 동작

---

# 🌱 개발/배포 Workflow

1. Issue 생성
2. feature/{task} 브랜치 생성
3. `modules/` 또는 `env/dev`에서 Terraform 작성
4. `terraform.tfvars` 수정 후 S3에 업로드
   → `aws s3 cp env/dev/terraform.tfvars s3://onlog-tfvars-config/dev.tfvars`
5. PR 생성 → GitHub Actions plan 확인
6. Merge → dev 자동 배포
7. 검증 후 main → prod merge → prod 자동 배포

---

# 📌 요약

* **tfvars는 S3에서만 관리 (레포 포함 X)**
* **dev/prod 완전 분리**
* **모듈 기반 구조로 확장 쉬움**
* **GitHub Actions 자동 배포**
* **Terraform state는 S3 + DynamoDB 백엔드**
