SECRET_KEY=${django_secret_key}
DEBUG=0
DOCKER=1
ALLOWED_HOSTS=${a_record}.${domain}
REDIS_DOMAIN=redis
DOMAIN=${a_record}.${domain}
POSTGRES_DATABASE_NAME=${postgres_database_name}
POSTGRES_USERNAME=${postgres_username}
POSTGRES_PASSWORD=${postgres_password}
POSTGRES_ENDPOINT=${postgres_endpoint}
SENTRY_DSN=${sentry_dsn}
