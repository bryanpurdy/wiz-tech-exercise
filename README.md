# Wiz Technical Exercise – Tasky App Deployment

This repository contains the deliverables for the Wiz technical exercise. It demonstrates containerization, Kubernetes deployment, Terraform-based infrastructure provisioning, and DevSecOps CI/CD integration.

---

## 🚀 Overview
- **Application:** Tasky (Go web app)
- **Containerization:** Docker with embedded `wizexercise.txt`
- **Infrastructure:** AWS VPC, EKS cluster, EC2-hosted MongoDB, S3 bucket, and ECR repo
- **Orchestration:** Kubernetes manifests for Tasky (Deployment, Service, Ingress, RBAC, Secrets)
- **CI/CD:** GitHub Actions workflow that builds and pushes images to Amazon ECR

---

## 📂 Repo Structure
tasky-main/
├── Dockerfile
├── wizexercise.txt
├── infra/ # Terraform modules
│ ├── provider.tf
│ ├── variables.tf
│ ├── vpc.tf
│ ├── eks.tf
│ ├── ec2-mongo.tf
│ ├── s3.tf
│ └── ecr.tf
├── k8s/ # Kubernetes manifests
│ ├── namespace.yaml
│ ├── secret-mongo.yaml
│ ├── deployment.yaml
│ ├── service.yaml
│ ├── ingress.yaml
│ └── rbac.yaml
└── .github/workflows/ # CI/CD pipeline
└── build-and-publish.yml



# Provided Instructions
# Docker
A Dockerfile has been provided to run this application.  The default port exposed is 8080.

# Environment Variables
The following environment variables are needed.
|Variable|Purpose|example|
|---|---|---|
|`MONGODB_URI`|Address to mongo server|`mongodb://servername:27017` or `mongodb://username:password@hostname:port` or `mongodb+srv://` schema|
|`SECRET_KEY`|Secret key for JWT tokens|`secret123`|

Alternatively, you can create a `.env` file and load it up with the environment variables.

# Running with Go

Clone the repository into a directory of your choice Run the command `go mod tidy` to download the necessary packages.

You'll need to add a .env file and add a MongoDB connection string with the name `MONGODB_URI` to access your collection for task and user storage.
You'll also need to add `SECRET_KEY` to the .env file for JWT Authentication.

Run the command `go run main.go` and the project should run on `locahost:8080`

# License

This project is licensed under the terms of the MIT license.

Original project: https://github.com/dogukanozdemir/golang-todo-mongodb