resource "github_repository" "frontend_repository" {
  count       = length(var.projects)
  name        = var.projects[count.index].frontend_repository_name
  description = "My awesome codebase"

  lifecycle {
    prevent_destroy = true
  }

  visibility = "private"

  template {
    owner                = "vassilyvv"
    repository           = "${var.projects[count.index].frontend_framework}-template"
    include_all_branches = false
  }
}

resource "github_repository" "backend_repository" {
  count       = length(var.projects)
  name        = var.projects[count.index].backend_repository_name
  description = "My awesome codebase"
  depends_on  = [aws_instance.backend_ec2_instance]

  lifecycle {
    prevent_destroy = true
  }

  visibility = "private"

  template {
    owner                = "vassilyvv"
    repository           = "django-template"
    include_all_branches = false
  }
}

resource "github_actions_secret" "ssh_private_key_github_uses_to_deploy_new_image" {
  count           = length(var.projects)
  repository      = github_repository.backend_repository[count.index].name
  secret_name     = "SSH_PRIVATE_KEY"
  plaintext_value = tls_private_key.github_pk.private_key_pem
}

resource "github_actions_secret" "github_private_requirement_owner_token_secret" {
  count           = length(var.projects)
  repository      = github_repository.backend_repository[count.index].name
  secret_name     = "PRIVATE_REQUIREMENT_OWNER_TOKEN_SECRET"
  plaintext_value = var.github_private_requirement_owner_token_secret
}

resource "github_actions_secret" "dockerhub_token_for_github" {
  count           = length(var.projects)
  repository      = github_repository.backend_repository[count.index].name
  secret_name     = "DOCKERHUB_TOKEN"
  plaintext_value = var.dockerhub_token_for_github
}

resource "github_actions_variable" "dockerhub_username" {
  count         = length(var.projects)
  repository    = github_repository.backend_repository[count.index].name
  variable_name = "DOCKERHUB_USERNAME"
  value         = var.dockerhub_username
}

resource "github_actions_variable" "ssh_host" {
  count         = length(var.projects)
  repository    = github_repository.backend_repository[count.index].name
  variable_name = "SSH_HOST"
  value         = aws_instance.backend_ec2_instance[count.index].public_ip
}

resource "github_actions_variable" "docker_image" {
  count         = length(var.projects)
  repository    = github_repository.backend_repository[count.index].name
  variable_name = "DOCKER_IMAGE"
  value         = var.projects[count.index].docker_image_name
}

resource "github_actions_secret" "frontend_aws_secret_key" {
  count           = length(var.projects)
  repository      = github_repository.frontend_repository[count.index].name
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = var.aws_keys["cd"]["access"]
}

resource "github_actions_secret" "frontend_aws_access_key" {
  count           = length(var.projects)
  repository      = github_repository.frontend_repository[count.index].name
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.aws_keys["cd"]["secret"]
}

resource "github_actions_variable" "frontend_aws_region_variable" {
  count         = length(var.projects)
  repository    = github_repository.frontend_repository[count.index].name
  variable_name = "AWS_REGION"
  value         = var.aws_region
}

resource "github_actions_variable" "frontend_api_host_variable" {
  count         = length(var.projects)
  repository    = github_repository.frontend_repository[count.index].name
  variable_name = "API_HOST"
  value         = "https://${var.projects[count.index].backend_a_record}.${var.projects[count.index].domain}"
}
