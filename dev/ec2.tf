resource "tls_private_key" "user_pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "github_pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "user_kp" {
  key_name   = "user-key"
  public_key = tls_private_key.user_pk.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.user_pk.private_key_pem}' > ./user-key.pem && chmod 400 user-key.pem"
  }
}

resource "aws_key_pair" "github_kp" {
  key_name   = "github-key"
  public_key = tls_private_key.github_pk.public_key_openssh
}

resource "random_uuid" "django_secret_key" {
  count = length(var.projects)
}

resource "aws_instance" "backend_ec2_instance" {
  tags = {
    Name = var.projects[count.index].name
  }
  count                       = length(var.projects)
  ami                         = var.ec2_ami
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  subnet_id                   = aws_subnet.ec2_subnet.id
  associate_public_ip_address = true
  depends_on                  = [aws_key_pair.user_kp]

  provisioner "file" {
    destination = "/home/ubuntu/${var.projects[count.index].name}.env"
    content     = templatefile(
      "data/project_env.tpl",
      {
        a_record               = var.projects[count.index].backend_a_record,
        domain                 = "${var.projects[count.index].backend_a_record}.${var.projects[count.index].domain}",
        postgres_database_name = var.projects[count.index].database_name,
        postgres_username      = var.postgres_username,
        postgres_password      = var.postgres_password,
        postgres_endpoint      = aws_db_instance.rds_database.address,
        django_secret_key      = random_uuid.django_secret_key[count.index].result,
        sentry_dsn             = var.projects[count.index].sentry_dsn,
        aws_django_access_key  = var.aws_keys["django"].access
        aws_django_secret_key  = var.aws_keys["django"].secret
        aws_bucket_name=var.projects[count.index].website_bucket_name
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
    "data/ec2_up_script.tpl",
    {
      postgres_endpoint = aws_db_instance.rds_database.address,
      postgres_username = var.postgres_username,
      postgres_password = var.postgres_password,
      database_name     = var.projects[count.index].database_name,
      api_domain        = join(".", [
        var.projects[count.index].backend_a_record, var.projects[count.index].domain
      ]),
      docker_image_name       = var.projects[count.index].docker_image_name
      uses_celery             = var.projects[count.index].uses_celery
      project_name            = var.projects[count.index].name
      parent_directory        = "/home/ubuntu/"
      postgres_port           = aws_db_instance.rds_database.port
      aws_backuper_access_key = var.aws_keys["backuper"].access
      aws_backuper_secret_key = var.aws_keys["backuper"].secret
      aws_region              = var.aws_region
      aws_backups_s3_bucket   = aws_s3_bucket.backups_bucket.bucket
      keys_to_authorize       = [
        join(" ", [trimspace(tls_private_key.user_pk.public_key_openssh), "user"]),
        join(" ", [trimspace(tls_private_key.github_pk.public_key_openssh), "github"]),
      ]
    }
  )
}

