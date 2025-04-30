# aws-webapp-infras 

# Scalable Web Application Infrastructure on AWS

## ✅ Technologies Used
- Terraform (IaC)
- EKS (Production)
- ECS Fargate (Dev)
- MongoDB (EC2)
- Jenkins + ArgoCD + CodeDeploy (CI/CD)
- ELK + Prometheus + Grafana (Monitoring)

## 🚀 Structure
- `terraform/`: Infrastructure code
- `k8s/`: Kubernetes manifests for ArgoCD
- `codedeploy/`: AppSpec file for ECS
- `app/`: Dockerized app (React, Node.js, MongoDB)
- `Jenkinsfile`: CI/CD pipeline

## 📌 Setup Instructions
See `terraform/README.md` for full provisioning steps.

## 💰 Cost Optimization
- Auto-scaling node groups
- Spot instance support (WIP)
- Centralized logging

## 📈 Monitoring
- Prometheus + Grafana dashboards for EKS/ECS and MongoDB
