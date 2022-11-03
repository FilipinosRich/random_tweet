# Tutorial for deploying an end-to-end serverless project using AWS (Free Tier)
[![Build Status](https://github.com/FilipinosRich/random_tweet/actions/workflows/deps/badge.svg)]
[![Build Status](https://github.com/FilipinosRich/random_tweet/actions/workflows/terraformprod/badge.svg)]
[![License](https://img.shields.io/github/license/FilipinosRich/random_tweet)]

This project consists of a small tutorial which deploys and end-to-end serverless project using components of the free tier of AWS.
It also discusses briefly some pitfalls and ways to improve when moving to paid components.

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
- GitHub Action 2 deploys the infrastructure using Terraform
- The infrastructure consists of the following components: 
  - S3 for storing the model and the dependencies as well as the Terraform state
  - Lambda for creating the tweet and posting it
  - EventBridge for scheduling the lambda

## 3. Prerequisites

To be able to deploy this repo to create your own Twitter Bot, you need a few prerequisites:
- An AWS account
- GitHub Account
- A Twitter developer account with an application in production, so you have write permissions

## 4. How-to

So now how do you deploy this serverless application? This section will be split up into multiple parts.

### GitHub Account

You have to configure a GitHub repo and store a few things in GitHub Secrets. This allows for your GitHub Actions to use these. 
You have to store your credentials to AWS as well as to the Twitter API.

For more information on this, see here: https://docs.github.com/en/actions/security-guides/encrypted-secrets

### AWS Account and Terraform

You need to configure the Terraform state to be saved in an AWS bucket. 
A proper tutorial on this can be found here: https://angelo-malatacca83.medium.com/aws-terraform-s3-and-dynamodb-backend-3b28431a76c1

### Twitter Account

You need to configure your Twitter Developer Account.
Here is the documentation on how to do that: https://developer.twitter.com/en/docs/twitter-api/getting-started/getting-access-to-the-twitter-api
Keep in mind that you might have to ask for elevated access.

### Deploying

Now you want to deploy, currently the GitHub Actions are configured so that they run in the staging environment 'prod' when you push to main.
You should obviously best protect your main branch (as best practice) to not be able to directly push to main. 
Since there is no action on merge, we use on push because the merging of a PR acts like a push to main.

In the infra folder, inside main.tf you can change some of the variables such as project-name. 
This will determine the naming of the resources in AWS.
Make sure that the values of the bucket and the key to where you model is stored is adjusted in lambda_function.py. 
As of now, the storing of the model on S3 is done manually, this could also be done in GitHub Actions by downloading the model to the GitHub Runner and then uploading it to AWS.

We use the GPT2 model from HuggingFace (https://huggingface.co/gpt2?text=My+name+is+Mariama%2C+my+favorite)

## 5. Lessons Learned

If you have made it this far, you are probably wondering about why we decided to use certain services.
In this section we will briefly discuss our choices and the pitfalls of these choices.

- Lambda without EFS: if you read through the Python code, you might notice that we save the model to a temporary location on every incovation.
We could have just used EFS and attach it to the Lambda and if the model is on there load it from there. Even though EFS is free for the first 12 months,
we wanted to go truly serverless. It also did not prove to be that easy to dump the model on EFS.
- ZIP: both the code and dependencies are zipped. This proved to be the biggest pitfall when in development. We could definitely not zip
everything together, but we could make use of Lambda Layers. But these proved to be not so evident as well, as the max size of the .zip unzipped is 250MB.
Seeing as torch is quite a large package and we only needed it for inference we opted for a cpu torch version. The only problem is that
it already exceeds the 250MB quite fast. We ended up settling on v1.6.0 and we zip torch inside the zip (zipception!).
We could have opted for a Docker image on ECR, this would have been a lot easier but only the first 500 MB on ECR are free.

These are the two main lessons learned, we are sure there are a lot more pitfalls to this setup but we feel it is a good introduction.

## 6. Conclusion

The goal of this tutorial was to give a short introduction on how to deploy an end-to-end serverless project on the cloud using CICD.
The aim was also to get it to work using only free services (or at least free for the first 12 months) on AWS.
<!-- BEGIN_TF_DOCS -->


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_TWITTER_ACCESS_KEY_ID"></a> [TWITTER\_ACCESS\_KEY\_ID](#input\_TWITTER\_ACCESS\_KEY\_ID) | Twitter Access Key | `any` | n/a | yes |
| <a name="input_TWITTER_ACCESS_KEY_SECRET"></a> [TWITTER\_ACCESS\_KEY\_SECRET](#input\_TWITTER\_ACCESS\_KEY\_SECRET) | Twitter Access Key Secret | `any` | n/a | yes |
| <a name="input_TWITTER_API_KEY_ID"></a> [TWITTER\_API\_KEY\_ID](#input\_TWITTER\_API\_KEY\_ID) | Twitter API Key | `any` | n/a | yes |
| <a name="input_TWITTER_API_KEY_SECRET"></a> [TWITTER\_API\_KEY\_SECRET](#input\_TWITTER\_API\_KEY\_SECRET) | Twitter API Key Secret | `any` | n/a | yes |
| <a name="input_TWITTER_BEARER_TOKEN"></a> [TWITTER\_BEARER\_TOKEN](#input\_TWITTER\_BEARER\_TOKEN) | Twitter Bearer Token | `any` | n/a | yes |
| <a name="input_lambda_function_key"></a> [lambda\_function\_key](#input\_lambda\_function\_key) | S3 key where the lambda source code zip will be stored | `any` | n/a | yes |
| <a name="input_lambda_layer_key"></a> [lambda\_layer\_key](#input\_lambda\_layer\_key) | S3 key where the lambda layer zip will be stored | `any` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"random_tweet"` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | Cron schedule on which to schedule the lambda | `any` | n/a | yes |


<!-- END_TF_DOCS -->