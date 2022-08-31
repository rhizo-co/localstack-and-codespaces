import { S3Client, ListBucketsCommandInput, ListObjectsV2Command, ListObjectsV2CommandInput, ListObjectsV2CommandOutput, S3ClientConfig, ListBucketsCommand } from '@aws-sdk/client-s3';

export const s3Client = new S3Client({ region: 'eu-central-1', endpoint: 'http://localhost:4566' });
