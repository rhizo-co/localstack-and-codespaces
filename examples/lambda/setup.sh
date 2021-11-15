#!/bin/bash

# make bash play nicely
set -euo pipefail

# configure aws

if which awslocal; then
    USE_AWSLOCAL="true"
    echo "awslocal detected, using awslocal"
else
    USE_AWSLOCAL="false"
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

# install npm dependencies
npm install

# zip it all to create the lambda
zip -r api-handler.zip lambda.js node_modules/

API_NAME="${API_NAME:-api}"
REGION=us-east-1
STAGE=test

function fail() {
    echo $2
    exit $1
}

awslocalstack lambda create-function \
    --region ${REGION} \
    --function-name ${API_NAME} \
    --runtime nodejs14.x \
    --handler lambda.apiHandler \
    --memory-size 128 \
    --zip-file fileb://api-handler.zip \
    --role "arn:aws:iam::123456:role/irrelevant"

[ $? == 0 ] || fail 1 "Failed: AWS / lambda / create-function"

LAMBDA_ARN=$(awslocalstack lambda list-functions --query "Functions[?FunctionName==\`${API_NAME}\`].FunctionArn" --output text --region ${REGION})

awslocalstack apigateway create-rest-api \
    --region ${REGION} \
    --name ${API_NAME}

[ $? == 0 ] || fail 2 "Failed: AWS / apigateway / create-rest-api"

API_ID=$(awslocalstack apigateway get-rest-apis --query "items[?name==\`${API_NAME}\`].id" --output text --region ${REGION})
PARENT_RESOURCE_ID=$(awslocalstack apigateway get-resources --rest-api-id ${API_ID} --query 'items[?path==`/`].id' --output text --region ${REGION})

awslocalstack apigateway create-resource \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --parent-id ${PARENT_RESOURCE_ID} \
    --path-part "{somethingId}"

[ $? == 0 ] || fail 3 "Failed: AWS / apigateway / create-resource"

RESOURCE_ID=$(awslocalstack apigateway get-resources --rest-api-id ${API_ID} --query 'items[?path==`/{somethingId}`].id' --output text --region ${REGION})

awslocalstack apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method GET \
    --request-parameters "method.request.path.somethingId=true" \
    --authorization-type "NONE" \

[ $? == 0 ] || fail 4 "Failed: AWS / apigateway / put-method"

awslocalstack apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN}/invocations \
    --passthrough-behavior WHEN_NO_MATCH \

[ $? == 0 ] || fail 5 "Failed: AWS / apigateway / put-integration"

awslocalstack apigateway create-deployment \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --stage-name ${STAGE} \

[ $? == 0 ] || fail 6 "Failed: AWS / apigateway / create-deployment"

ENDPOINT=http://localhost:4566/restapis/${API_ID}/${STAGE}/_user_request_/HowMuchIsTheFish

echo "API available at: curl -i -w '\n' ${ENDPOINT}"

echo -e '\nTesting GET: (this may take a few minutes because localstack has to start a new docker container to execute the lambda)\n'
curl -i -w '\n' ${ENDPOINT}
