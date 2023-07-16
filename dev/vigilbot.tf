resource "random_uuid" "vigil_bot_secret_key" {}

resource "aws_instance" "vigil_bot_ec2_instance" {
  ami                         = var.ec2_ami
  instance_type               = "t3.small"
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  subnet_id                   = aws_subnet.ec2_subnet.id
  associate_public_ip_address = true
  depends_on                  = [aws_key_pair.user_kp]

  tags = {
    Name = "vigil-bot"
  }
  provisioner "file" {
    destination = "/home/ubuntu/${var.vigil_bot_project_name}.env"
    content     = templatefile(
      "data/vigil_bot_env.tpl",
      {
        django_secret_key      = random_uuid.vigil_bot_secret_key.result,
        a_record               = var.vigil_bot_a_record,
        domain                 = var.vigil_bot_domain,
        postgres_database_name = var.vigil_bot_database_name,
        postgres_username      = var.postgres_username,
        postgres_password      = var.postgres_password,
        postgres_endpoint      = aws_db_instance.rds_database.address,
        sentry_dsn             = var.vigil_bot_sentry_dsn
      }
    )
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.user_pk.private_key_pem
      host        = self.public_ip
    }
  }

  user_data = templatefile(
    "data/vigil_bot_up_script.tpl",
    {
      postgres_endpoint       = aws_db_instance.rds_database.address,
      postgres_username       = var.postgres_username,
      postgres_password       = var.postgres_password,
      database_name           = var.vigil_bot_database_name,
      api_domain              = "${var.vigil_bot_a_record}.${var.vigil_bot_domain}",
      project_name            = var.vigil_bot_project_name
      docker_image_name       = var.vigil_bot_docker_image_name
      parent_directory        = "/home/ubuntu/"
      postgres_port           = aws_db_instance.rds_database.port
      aws_backuper_access_key = var.aws_keys["backuper"].access
      aws_backuper_secret_key = var.aws_keys["backuper"].secret
      aws_backups_s3_bucket   = aws_s3_bucket.backups_bucket.bucket
      aws_region              = var.aws_region
      keys_to_authorize       = [
        join(" ", [trimspace(tls_private_key.user_pk.public_key_openssh), "user"]),
        join(" ", [trimspace(tls_private_key.github_pk.public_key_openssh), "github"]),
      ]
    }
  )
}

resource "cloudflare_record" "vigil_bot_api" {
  zone_id = var.vigil_bot_cloudflare_zone_id
  name    = var.vigil_bot_a_record
  value   = aws_instance.vigil_bot_ec2_instance.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "github_repository" "vigil_bot_backend_repository" {
  name        = var.vigil_bot_backend_repository_name
  description = "My awesome codebase"
  depends_on  = [aws_instance.backend_ec2_instance]

  lifecycle {
    prevent_destroy = true
  }
  visibility = "private"
}

resource "github_repository" "vigil_bot_frontend_repository" {
  name        = var.vigil_bot_frontend_repository_name
  description = "My awesome codebase"

  lifecycle {
    prevent_destroy = true
  }
  visibility = "private"
}

resource "github_repository" "vigil_bot_source_repository" {
  name        = var.vigil_bot_backend_repository_name
  description = "My awesome codebase"
  depends_on  = [aws_instance.backend_ec2_instance]

  lifecycle {
    prevent_destroy = true
  }
  visibility = "private"
}

resource "github_actions_secret" "vigil_bot_ssh_private_key_github_uses_to_deploy_new_image" {
  repository      = github_repository.vigil_bot_source_repository.name
  secret_name     = "SSH_PRIVATE_KEY"
  plaintext_value = tls_private_key.github_pk.private_key_pem
}

resource "github_actions_secret" "vigil_bot_dockerhub_token_for_github" {
  repository      = github_repository.vigil_bot_source_repository.name
  secret_name     = "DOCKERHUB_TOKEN"
  plaintext_value = var.dockerhub_token_for_github
}

resource "github_actions_variable" "vigil_bot_dockerhub_username" {
  repository    = github_repository.vigil_bot_source_repository.name
  variable_name = "DOCKERHUB_USERNAME"
  value         = var.dockerhub_username
}

resource "github_actions_variable" "vigil_bot_ssh_host" {
  repository    = github_repository.vigil_bot_source_repository.name
  variable_name = "SSH_HOST"
  value         = aws_instance.vigil_bot_ec2_instance.public_ip
}

resource "github_actions_variable" "vigil_bot_docker_image" {
  repository    = github_repository.vigil_bot_source_repository.name
  variable_name = "DOCKER_IMAGE"
  value         = var.vigil_bot_docker_image_name
}
