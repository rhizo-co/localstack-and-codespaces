import { S3Client, ListBucketsCommandInput, ListBucketsCommand, CreateBucketCommandInput, CreateBucketCommand } from '@aws-sdk/client-s3';

export async function listBuckets(s3: S3Client, bucketsParams: ListBucketsCommandInput) {
    const data = await s3.send(new ListBucketsCommand(bucketsParams));

    return data.Buckets ?? [];
}

export async function createBucket(s3: S3Client, bucketsParams: CreateBucketCommandInput) {
    const data = await s3.send(new CreateBucketCommand(bucketsParams));

    return data.Location;
}
