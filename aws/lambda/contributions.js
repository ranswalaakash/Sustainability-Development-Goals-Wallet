const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand, ScanCommand, GetCommand } = require('@aws-sdk/lib-dynamodb');
const crypto = require('crypto');

const client = new DynamoDBClient({ region: process.env.AWS_REGION || 'us-east-1' });
const ddbDocClient = DynamoDBDocumentClient.from(client);
const TABLE = process.env.DYNAMODB_TABLE || 'SDGContributions';

const headers = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'OPTIONS,POST,GET,PUT',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization'
};

exports.handler = async (event) => {
  const method = event.requestContext?.http?.method || event.httpMethod;
  const path = event.requestContext?.http?.path || event.path || '';
  const pathParams = event.pathParameters || {};
  const queryParams = event.queryStringParameters || {};

  if (method === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  try {
    // 1. GET /contributions/{id}
    if (method === 'GET' && pathParams.id) {
      const result = await ddbDocClient.send(new GetCommand({
        TableName: TABLE,
        Key: { id: pathParams.id }
      }));

      if (!result.Item) {
        return { statusCode: 404, headers, body: JSON.stringify({ error: 'Contribution not found' }) };
      }
      return { statusCode: 200, headers, body: JSON.stringify({ contribution: result.Item }) };
    }

    // 2. GET /contributions
    if (method === 'GET') {
      const scanResult = await ddbDocClient.send(new ScanCommand({
        TableName: TABLE
      }));

      let items = scanResult.Items || [];

      if (queryParams.status && queryParams.status !== 'ALL') {
        items = items.filter(c => (c.status || '').toUpperCase() === queryParams.status.toUpperCase());
      }
      if (queryParams.studentId) {
        items = items.filter(c => c.studentId === queryParams.studentId);
      }

      items.sort((a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0));

      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({ contributions: items })
      };
    }

    // 3. POST /contributions (Student Submission)
    if (method === 'POST') {
      const payload = event.body ? JSON.parse(event.body) : {};
      
      const newEntry = {
        id: payload.id || crypto.randomUUID(),
        studentId: payload.studentId || 'std_student',
        studentName: payload.studentName || 'Student Volunteer',
        organisationId: payload.organisationId || 'org_campus',
        departmentId: payload.departmentId || 'dept_sustainability',
        title: payload.title || 'Untitled Action',
        description: payload.description || '',
        latitude: payload.latitude || null,
        longitude: payload.longitude || null,
        locationName: payload.locationName || 'Campus Grounds',
        status: 'PENDING',
        createdAt: new Date().toISOString(),
        sdgIds: payload.sdgIds || [],
        metrics: payload.metrics || {
          treesPlanted: 0,
          wasteRecycledKg: 0,
          energySavedKWh: 0,
          waterSavedLiters: 0,
          peopleReached: 0,
          volunteerHours: 0
        },
        s3ObjectKey: payload.s3ObjectKey || null,
        fileHashSha256: payload.fileHashSha256 || null,
        coordinatorNote: null,
        verifiedBy: null,
        verifiedAt: null
      };

      await ddbDocClient.send(new PutCommand({
        TableName: TABLE,
        Item: newEntry
      }));

      return {
        statusCode: 201,
        headers,
        body: JSON.stringify({ status: 'success', contribution: newEntry })
      };
    }

    return { statusCode: 405, headers, body: JSON.stringify({ error: 'Method not allowed' }) };
  } catch (err) {
    console.error('Error handling DynamoDB contribution request:', err);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Database operation failed', details: err.message })
    };
  }
};
