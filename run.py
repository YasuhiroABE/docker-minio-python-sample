#!/usr/bin/python

import io
from minio import Minio
from environs import Env
env = Env()
env.read_env()

MINIO_ENDPOINT_SECURITY = env.bool('MINIO_ENDPOINT_SECURITY', False)
MINIO_ENDPOINT = env.str('MINIO_ENDPOINT', '')
MINIO_ACCESS_KEY = env.str('MINIO_ACCESS_KEY', '')
MINIO_SECRET_KEY = env.str('MINIO_SECRET_KEY', '')
MINIO_BUCKET = env.str('MINIO_BUCKET', 'my-minio-local')

client = Minio(MINIO_ENDPOINT,
               access_key=MINIO_ACCESS_KEY,
               secret_key=MINIO_SECRET_KEY,
               secure=MINIO_ENDPOINT_SECURITY,)

message = "Helo world!"

client.put_object(MINIO_BUCKET, "my/message.txt",
                  io.BytesIO(message), length=len(message),)
