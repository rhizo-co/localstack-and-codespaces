#!/bin/bash

# make bash play nicely
set -euo pipefail

# Check which aws cli we can use
if which awslocal; then
    USE_AWSLOCAL="true"
    echo "awslocal detected, using awslocal"
else
    USE_AWSLOCAL="false"
    # configure aws then
    echo -e '\nConfigure AWS \nn.b. With localstack it is fine to use "test" for the Access Key ID and Secret Access Key\n'
    aws configure
fi

# create localstack alias
function awslocalstack() {
    if [[ "${USE_AWSLOCAL}" == "true" ]]; then
        awslocal "$@"
    else
        aws --endpoint-url=http://localhost:4566 "$@"
    fi
}

echo -e '\nCreate an S3 bucket using localstack url\n'
awslocalstack --endpoint-url=http://localhost:4566 s3 mb s3://my-bucket

echo -e '\nList created buckets using localstack url\n'
awslocalstack --endpoint-url=http://localhost:4566 s3 ls
