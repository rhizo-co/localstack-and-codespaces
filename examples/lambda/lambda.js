const { S3Client, ListBucketsCommand } = require("@aws-sdk/client-s3");

const localstackHostname = process.env['LOCALSTACK_HOSTNAME'];
const s3ClientOptions = localstackHostname ? {
    endpoint: `http://${localstackHostname}:4566`
} : {};

const apiHandler = async (payload, context, callback) => {

    console.log(`Function apiHandler called with payload ${JSON.stringify(payload)}`);
    const s3 = new S3Client(s3ClientOptions)
    const response = await s3.send(new ListBucketsCommand({}))
    console.log(`Function list buckets response ${JSON.stringify(response)}`);

    const bucketNames = response.Buckets?.map(bucket => bucket.Name) || [];
    callback(null, {
        statusCode: 200,
        body: JSON.stringify({
            message: `You have ${bucketNames.length} buckets in S3`,
            buckets: bucketNames
        }),
        headers: {
            'X-Custom-Header': 'ASDF'
        }
    });
}

module.exports = {
    apiHandler,
}
