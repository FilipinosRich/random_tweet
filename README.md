# Tutorial for deploying an end-to-end serverless project using AWS Free Tier

This project consists of a small tutorial which deploys and end-to-end serverless project using components of the free tier of AWS.
It also discusses briefly some of the pitfalls and ways to improve when moving to paid components.

## 1.  Tech stack
We use the following components:
- AWS for the infrastructure
- GitHub Actions for CICD
- Terraform for IaC
- Python for the Lambda function
- HuggingFace Models for the model - GPT2 in this case

## 2. Workflow
Now that we have the tech stack, we can briefly explain the workflow.

It works in the following steps:
- PR from dev to main gets merged: trigger GitHub Action 1
- GitHub Action 1 zips the lambda source code and the dependencies and uploads those to S3
- Once GitHub Action 1 is successfully completed it triggers GitHub Action 2
- GitHub Action 2 deploys the infrastructure using Terraform.
- The infrastructure consists of the following components: S3 for storing the model 
