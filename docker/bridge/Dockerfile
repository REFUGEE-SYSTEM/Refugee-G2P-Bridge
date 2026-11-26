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
        "novu-py" \
        "requests" \
        "gunicorn~=22.0.0" \
        "openg2p-g2pconnect-common-lib>=2.0.0" \
        "openg2p-g2pconnect-mapper-lib>=2.0.0" \
        "git+https://github.com/openg2p/openg2p-fastapi-common@${FASTAPI_COMMON_COMMIT}#subdirectory=openg2p-fastapi-common" \
        "git+https://github.com/openg2p/openg2p-fastapi-common@${FASTAPI_COMMON_COMMIT}#subdirectory=openg2p-fastapi-auth" \
        "git+https://github.com/openg2p/openg2p-fastapi-common@${FASTAPI_COMMON_COMMIT}#subdirectory=openg2p-fastapi-auth-models" \
        "git+https://github.com/openg2p/openg2p-fastapi-common@${FASTAPI_COMMON_COMMIT}#subdirectory=openg2p-fastapi-partner-auth"

COPY vendor/spar/models /src/spar-models
COPY vendor/bridge/core/models /src/bridge-models
COPY vendor/bridge/connectors /src/connectors
COPY vendor/bridge/core/partner-api /src/partner-api
COPY vendor/bridge/core/celery-workers /src/celery-workers
COPY vendor/bridge/core/celery-beat-producers /src/celery-beat-producers

RUN pip install --no-cache-dir --no-deps \
        /src/spar-models \
        /src/bridge-models \
        /src/connectors/bank-connectors \
        /src/connectors/mapper-connectors \
        /src/connectors/geo-resolver \
        /src/connectors/warehouse-allocator \
        /src/connectors/agency-allocator \
        /src/connectors/notification-connectors \
        /src/partner-api \
        /src/celery-workers \
        /src/celery-beat-producers

ENV PYTHONUNBUFFERED=1
