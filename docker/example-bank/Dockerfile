FROM python:3.12.11-alpine3.22

ARG FASTAPI_COMMON_COMMIT=9cf451311e0df2e4efed93531788120a5eeec60d

RUN apk add --no-cache curl git libmagic

WORKDIR /app

RUN pip install --upgrade pip setuptools && \
    pip install --no-cache-dir \
        "greenlet" \
        "jinja2" \
        "packaging" \
        "asyncpg" \
        "psycopg2-binary>=2.9.12" \
        "psycopg[binary]" \
        "celery[redis]" \
        "httpx" \
        "orjson" \
        "fastnanoid" \
        "python-magic" \
        "mt-940" \
        "requests" \
        "gunicorn~=22.0.0" \
        "git+https://github.com/openg2p/openg2p-fastapi-common@${FASTAPI_COMMON_COMMIT}#subdirectory=openg2p-fastapi-common" \
        "git+https://github.com/openg2p/openg2p-fastapi-common@${FASTAPI_COMMON_COMMIT}#subdirectory=openg2p-fastapi-auth" \
        "git+https://github.com/openg2p/openg2p-fastapi-common@${FASTAPI_COMMON_COMMIT}#subdirectory=openg2p-fastapi-auth-models" \
        "git+https://github.com/openg2p/openg2p-fastapi-common@${FASTAPI_COMMON_COMMIT}#subdirectory=openg2p-fastapi-partner-auth"

COPY vendor/bridge/example-bank /src/example-bank

RUN pip install --no-cache-dir --no-deps \
        /src/example-bank/openg2p-example-bank-models \
        /src/example-bank/openg2p-example-bank-api \
        /src/example-bank/openg2p-example-bank-celery-workers \
        /src/example-bank/openg2p-example-bank-celery-beat-producers

ENV PYTHONUNBUFFERED=1
