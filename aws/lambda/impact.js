const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, ScanCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({ region: process.env.AWS_REGION || 'us-east-1' });
const ddbDocClient = DynamoDBDocumentClient.from(client);
const TABLE = process.env.DYNAMODB_TABLE || 'SDGContributions';

const headers = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'OPTIONS,POST,GET,PUT',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization'
};

const FIVE_PILLARS = {
  people: [1, 2, 3, 4, 5],
  planet: [6, 12, 13, 14, 15],
  prosperity: [7, 8, 9, 10, 11],
  peace: [16],
  partnership: [17]
};

exports.handler = async (event) => {
  const method = event.requestContext?.http?.method || event.httpMethod;
  const path = event.requestContext?.http?.path || event.path || '';
  const queryParams = event.queryStringParameters || {};

  if (method === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  try {
    const scanResult = await ddbDocClient.send(new ScanCommand({
      TableName: TABLE
    }));

    const items = scanResult.Items || [];

    // Route 1: GET /api/stats (Department Overview)
    if (path.includes('/stats')) {
      const pending = items.filter(c => (c.status || '').toUpperCase() === 'PENDING').length;
      const verifiedItems = items.filter(c => (c.status || '').toUpperCase() === 'VERIFIED');
      const changes = items.filter(c => (c.status || '').toUpperCase() === 'CHANGES_REQUESTED').length;
      const rejected = items.filter(c => (c.status || '').toUpperCase() === 'REJECTED').length;

      const metrics = verifiedItems.reduce((acc, c) => {
        acc.totalTrees += (c.metrics?.treesPlanted || 0);
        acc.totalWasteKg += (c.metrics?.wasteRecycledKg || 0);
        acc.totalEnergyKWh += (c.metrics?.energySavedKWh || 0);
        acc.totalWaterLiters += (c.metrics?.waterSavedLiters || 0);
        acc.totalVolunteerHours += (c.metrics?.volunteerHours || 0);
        acc.totalPeopleReached += (c.metrics?.peopleReached || 0);
        return acc;
      }, {
        totalTrees: 0,
        totalWasteKg: 0,
        totalEnergyKWh: 0,
        totalWaterLiters: 0,
        totalVolunteerHours: 0,
        totalPeopleReached: 0
      });

      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
          totalSubmissions: items.length,
          pendingCount: pending,
          verifiedCount: verifiedItems.length,
          changesRequestedCount: changes,
          rejectedCount: rejected,
          metrics
        })
      };
    }

    // Route 2: GET /student/impact
    const studentId = queryParams.studentId || 'std_student';
    const verified = items.filter(c => c.studentId === studentId && (c.status || '').toUpperCase() === 'VERIFIED');

    const metrics = verified.reduce((acc, c) => {
      acc.treesPlanted += (c.metrics?.treesPlanted || 0);
      acc.wasteRecycledKg += (c.metrics?.wasteRecycledKg || 0);
      acc.energySavedKWh += (c.metrics?.energySavedKWh || 0);
      acc.waterSavedLiters += (c.metrics?.waterSavedLiters || 0);
      acc.volunteerHours += (c.metrics?.volunteerHours || 0);
      acc.peopleReached += (c.metrics?.peopleReached || 0);
      return acc;
    }, {
      treesPlanted: 0,
      wasteRecycledKg: 0,
      energySavedKWh: 0,
      waterSavedLiters: 0,
      volunteerHours: 0,
      peopleReached: 0
    });

    const verifiedSdgs = Array.from(new Set(verified.flatMap(c => c.sdgIds || [])));

    const pillars = {};
    for (const [pillar, sdgList] of Object.entries(FIVE_PILLARS)) {
      pillars[pillar] = verified.filter(c => (c.sdgIds || []).some(id => sdgList.includes(id))).length;
    }

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        studentId,
        verifiedCount: verified.length,
        verifiedSdgs,
        metrics,
        pillars,
        policyNote: "Designed to reduce greenwashing through human verification and audit trails."
      })
    };
  } catch (err) {
    console.error('Error calculating impact from DynamoDB:', err);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Failed to aggregate impact', details: err.message })
    };
  }
};
