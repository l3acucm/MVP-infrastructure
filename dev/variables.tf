variable "aws_keys" {
  type = map(object({
    access = string
    secret = string
  }))
}

variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

variable "ec2_ami" {
  description = "AMI for ec2 machine"
  type        = string
}

variable "ec2_cidr_block" {
  description = "CIDR block for the EC2"
  type        = string
}
variable "rds_cidr_block" {
  description = "CIDR block for the RDS"
  type        = string
}

variable "postgres_username" {
  description = "Postgres username"
  type        = string
}

variable "postgres_password" {
  description = "Postgres password"
  type        = string
}


variable "dockerhub_token_for_github" {
  description = "AWS Secret Access Key"
  type        = string
}

variable "github_private_requirement_owner_token_secret" {
  description = "AWS Secret Access Key"
  type        = string
}

variable "aws_s3_backups_bucket_name" {
  description = "Backups bucket name"
  type        = string
}

variable "dockerhub_username" {
  description = "Dockerhub username"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
}

variable "github_token" {
  description = "GitHub provider token"
  type        = string
}

variable "vigil_bot_a_record" {
  description = "A record for vigil bot"
  type        = string
}

variable "vigil_bot_domain" {
  description = "Domain for vigil bot"
  type        = string
}

variable "vigil_bot_database_name" {
  description = "DB name of vigil bot"
  type        = string
}

variable "vigil_bot_sentry_dsn" {
  description = "Sentry DSN for vigil bot"
  type        = string
}

variable "vigil_bot_docker_image_name" {
  description = "Vigil bot docker image name"
  type        = string
}

variable "vigil_bot_project_name" {
  description = "Vigil bot project name"
  type        = string
}

variable "vigil_bot_backend_repository_name" {
  description = "Vigil bot backend repo name"
  type        = string
}
variable "vigil_bot_frontend_repository_name" {
  description = "Vigil bot frontend repo name"
  type        = string
}

variable "vigil_bot_cloudflare_zone_id" {
  description = "Vigil bot cloudflare zone id"
  type        = string
}


variable "projects" {
  description = "Projects"
  type        = list(object({
    name                     = string
    backend_repository_name  = string
    frontend_repository_name = string
    website_bucket_name      = string
    frontend_framework       = string
    database_name            = string
    sentry_dsn               = string
    docker_image_name        = string
    cloudflare_zone_id       = string
    domain                   = string
    backend_a_record         = string
    frontend_a_record        = string
    uses_celery              = bool
  }))
}
