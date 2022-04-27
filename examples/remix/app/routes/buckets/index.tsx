import { ActionFunction, Form, useLoaderData } from "remix";
import { s3Client } from "../../../backend/s3Client.server";
import { createBucket, listBuckets } from "../../../backend/buckets.server";

type BucketData = {
    name: string;
    createdAt: string;
}

type BucketsList = {
    buckets: BucketData[];
}

// action is executed on the server on incoming POST requests
export const action: ActionFunction = async ({ request }) => {
    let { name } = Object.fromEntries(await request.formData());

    if (typeof name !== "string") {
        throw new Response("Invalid data submitted", { status: 400 });
    }

    await createBucket(s3Client, { Bucket: name as string });
    console.log("created bucket", name);
    return "success";
};

// loader is executed on the server for GET requests
// the result of the loader is accessed using `useLoaderData` on the client
export async function loader(): Promise<BucketsList> {
    const buckets = await listBuckets(s3Client, {});
    return {
        buckets: buckets.map(bucket => ({ name: bucket.Name ?? 'unknown', createdAt: bucket.CreationDate?.toISOString() ?? "unknown" }))
    };
}

// this is a React component that is rendered on the client (and the server)
export default function Index() {
    let data = useLoaderData<BucketsList>();
    const buckets = data.buckets || [];
    return (
        <main>
            <h2>Existing buckets</h2>
            <ol>
                {buckets.map(bucket => <li key={bucket.name}>{bucket.name}, {bucket.createdAt}</li>)}
            </ol>
            <h2>Create a new bucket</h2>
            <Form method="post">
                <div>
                    <label>
                        Name:{" "}
                        <input type="text" name="name" required />
                    </label>
                </div>
                <button type="submit">Create</button>
            </Form>
        </main>
    )
}
