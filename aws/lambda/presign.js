const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');

const s3 = new S3Client({ region: process.env.AWS_REGION || 'us-east-1' });
const BUCKET = process.env.S3_BUCKET;

const headers = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'OPTIONS,POST,GET,PUT',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization'
};

exports.handler = async (event) => {
  if (event.requestContext?.http?.method === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  try {
    const body = event.body ? JSON.parse(event.body) : {};
    const { filename, contentType, studentId, organisationId } = body;
    
    const safeOrg = (organisationId || 'org_campus').replace(/[^a-zA-Z0-9_-]/g, '_');
    const safeStudent = (studentId || 'student').replace(/[^a-zA-Z0-9_-]/g, '_');
    const safeFilename = (filename || 'evidence.jpg').replace(/[^a-zA-Z0-9_.-]/g, '_');
    
    const s3ObjectKey = `evidence/${safeOrg}/${safeStudent}/${Date.now()}_${safeFilename}`;
    
    const command = new PutObjectCommand({
      Bucket: BUCKET,
      Key: s3ObjectKey,
      ContentType: contentType || 'image/jpeg'
    });

    const uploadUrl = await getSignedUrl(s3, command, { expiresIn: 900 });

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        uploadUrl,
        s3ObjectKey,
        bucket: BUCKET,
        expiresInSeconds: 900
      })
    };
  } catch (err) {
    console.error('Error generating S3 presigned upload URL:', err);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Failed to generate upload URL', details: err.message })
    };
  }
};
