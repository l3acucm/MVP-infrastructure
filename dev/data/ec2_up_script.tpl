#!/bin/bash
PGPASSWORD=${postgres_password} psql -U ${postgres_username} -h ${postgres_endpoint} -d 'template1' -c 'CREATE DATABASE ${database_name};'
python3 /home/ubuntu/configure_backend.py --project-name=${project_name} --%{ if uses_celery }%{else}no-%{ endif }celery --api-domain=${api_domain} --docker-image-name=${docker_image_name}
python3 /home/ubuntu/configure_backups.py --project-name=${project_name} --parent-directory=${parent_directory} --postgres-username=${postgres_username} --postgres-password=${postgres_password} --postgres-endpoint=${postgres_endpoint} --postgres-port=${postgres_port} --database-name=${database_name} --aws-access-key-id=${aws_backuper_access_key} --aws-secret-access-key=${aws_backuper_secret_key} --aws-region=${aws_region} --aws-s3-bucket=${aws_backups_s3_bucket}
%{ for key in keys_to_authorize }
echo ${key} >> /home/ubuntu/.ssh/authorized_keys
%{ endfor }
