const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, GetCommand, PutCommand } = require('@aws-sdk/lib-dynamodb');

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
  if (method === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  try {
    const pathParams = event.pathParameters || {};
    const id = pathParams.id;
    if (!id) {
      return { statusCode: 400, headers, body: JSON.stringify({ error: 'Missing contribution ID' }) };
    }

    const payload = event.body ? JSON.parse(event.body) : {};
    const { status, coordinatorNote, verifiedBy, metrics } = payload;

    const existing = await ddbDocClient.send(new GetCommand({
      TableName: TABLE,
      Key: { id }
    }));

    if (!existing.Item) {
      return { statusCode: 404, headers, body: JSON.stringify({ error: 'Contribution not found' }) };
    }

    const item = existing.Item;
    item.status = (status || 'VERIFIED').toUpperCase();
    item.coordinatorNote = coordinatorNote || null;
    item.verifiedBy = verifiedBy || 'Campus Sustainability Coordinator';
    item.verifiedAt = new Date().toISOString();

    if (metrics) {
      item.metrics = {
        treesPlanted: metrics.treesPlanted !== undefined ? Number(metrics.treesPlanted) : (item.metrics?.treesPlanted || 0),
        wasteRecycledKg: metrics.wasteRecycledKg !== undefined ? Number(metrics.wasteRecycledKg) : (item.metrics?.wasteRecycledKg || 0),
        energySavedKWh: metrics.energySavedKWh !== undefined ? Number(metrics.energySavedKWh) : (item.metrics?.energySavedKWh || 0),
        waterSavedLiters: metrics.waterSavedLiters !== undefined ? Number(metrics.waterSavedLiters) : (item.metrics?.waterSavedLiters || 0),
        peopleReached: metrics.peopleReached !== undefined ? Number(metrics.peopleReached) : (item.metrics?.peopleReached || 0),
        volunteerHours: metrics.volunteerHours !== undefined ? Number(metrics.volunteerHours) : (item.metrics?.volunteerHours || 0)
      };
    }

    await ddbDocClient.send(new PutCommand({
      TableName: TABLE,
      Item: item
    }));

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ status: 'success', contribution: item })
    };
  } catch (err) {
    console.error('Error verifying contribution in DynamoDB:', err);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Verification failed', details: err.message })
    };
  }
};
