# OnLog Infrastructure (Terraform + GitHub Actions)

온로그(OnLog) 프로젝트의 AWS 인프라를 **Terraform + GitHub Actions** 기반으로 관리하는 저장소입니다.
모든 인프라는 코드로 정의되며(dev/prod), Git 브랜치 기반의 CI/CD 파이프라인으로 자동 배포됩니다.

---

## 🔧 Infrastructure Overview

### 기술 스택

* **Terraform v1.14.0**
* **AWS Provider v6.x**
* **GitHub Actions**
* **S3 (Terraform state 저장소)**
* **DynamoDB (Terraform lock 관리)**

### 환경 구조

* `main` 브랜치 → **dev 환경 배포**
* `prod` 브랜치 → **prod 환경 배포**
* `env/dev` 및 `env/prod` 내의 코드가 각 환경에 반영됨

---

## 📁 Repository Structure

```
onlog-infra/
├── providers.tf               # 공통 AWS provider 설정
├── env/
│   ├── dev/
│   │   ├── backend.tf         # dev state backend
│   │   └── main.tf            # dev 인프라 정의
│   └── prod/
│       ├── backend.tf         # prod state backend
│       └── main.tf            # prod 인프라 정의
└── modules/
    └── vpc/                   # VPC 재사용 module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## 🚀 CI/CD Workflow

GitHub Actions는 브랜치 기반으로 두 개의 workflow가 동작합니다.

### 1) **terraform-dev.yml**

* 동작 브랜치: `main`
* Pull Request:

  * `fmt`, `validate`, `plan`
  * plan 결과가 PR 코멘트로 자동 작성
* main push:

  * `init`, `plan`, `apply` 자동 수행 → dev 환경 배포

### 2) **terraform-prod.yml**

* 동작 브랜치: `prod`
* Pull Request:

  * `fmt`, `validate`, `plan`
* prod push:

  * `init`, `plan`, `apply` → prod 환경 배포

---

## 🔐 GitHub Secrets

아래 4개가 Actions에서 사용됩니다.

### dev 환경

* `AWS_DEV_ACCESS_KEY_ID`
* `AWS_DEV_SECRET_ACCESS_KEY`

### prod 환경

* `AWS_PROD_ACCESS_KEY_ID`
* `AWS_PROD_SECRET_ACCESS_KEY`

---

## 🗄 Terraform Backend (S3 + DynamoDB)

모든 Terraform 상태는 S3에 저장되고 DynamoDB로 Lock을 관리합니다.

* Bucket: `onlog-terraform-state`
* Lock Table: `onlog-terraform-lock`
* dev state 경로: `dev/terraform.tfstate`
* prod state 경로: `prod/terraform.tfstate`

---

## 🌱 Development Flow

1. Issue 생성
2. Feature 브랜치 생성
3. Terraform 코드 작성 (`env/dev`, `modules/…`)
4. PR 생성 (→ main)
5. PR에서 plan 결과 확인
6. Merge → dev 환경 자동 적용
7. 안정화 후 main → prod merge
8. prod 환경 자동 적용

---
