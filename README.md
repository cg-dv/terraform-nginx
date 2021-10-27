# nginx on EC2 

Terraform configuraton defining a VPC, an Internet Gateway, an application load balancer (ALB), EC2 instances in an auto scaling group (ASG) across two availability zones, and a web security group. The launch configuration defined for the auto scaling group includes a script to install and start nginx on each EC2 instance.

## Diagram

<img src="diagram/AWS-terraform-nginx.png?raw=true">

## Usage

Initalize Terraform:

`terraform init`

Build infrastructure:

`terraform apply`

## Outputs

The only output for this config is the ALB URL.  This architecture does not use an SSL certificate.  The traffic to/from the ALB will be over HTTP if you build/deploy this Terraform config - so remove the 'S' from the default 'https' URL that AWS uses for ALB URLs while testing.
