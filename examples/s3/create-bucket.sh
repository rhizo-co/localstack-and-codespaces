#!/bin/bash

# make bash play nicely
set -euo pipefail

echo -e '\nConfigure AWS \nn.b. With localstack it is fine to use "test" for the Access Key ID and Secret Access Key\n'
aws configure

echo -e '\nCreate an S3 bucket using localstack url\n'
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-bucket

echo -e '\nList created buckets using localstack url\n'
aws --endpoint-url=http://localhost:4566 s3 ls
