FROM python:3.10.12-alpine3.18

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    PORT=8000

RUN apk add --no-cache tzdata bash ca-certificates

WORKDIR /app

RUN addgroup minio
RUN adduser -S -G minio minio
RUN chown minio:minio /app
USER minio

RUN python -m venv venv
ENV PATH=/app/venv/bin/:$PATH

# Install the project requirements.
COPY requirements.txt /app
RUN pip install -r /app/requirements.txt

COPY run.py /app

ENV MINIO_ENDPOINT "minio.minio.svc.cluster.local:9000"
ENV MINIO_ENDPOINT_SECURITY "False"
ENV MINIO_ACCESS_KEY ""
ENV MINIO_SECRET_KEY ""
ENV MINIO_BUCKET ""

ENTRYPOINT ["python", "run.py"]
