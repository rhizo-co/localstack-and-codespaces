# Example Lambda Deployment with Localstack

This is mostly copied from @crypticmind 's excellent gist https://gist.github.com/crypticmind/c75db15fd774fe8f53282c3ccbe3d7ad

The lambda function calls the AWS S3 API and returns some information about the buckets that it finds. This allows it to demonstrate that calling localstack from running Lambda functions works as expected.

## Usage

1. Run localstack
1. Run `setup.sh`
