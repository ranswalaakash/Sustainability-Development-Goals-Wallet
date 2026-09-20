const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;
const DATA_FILE = path.join(__dirname, 'data', 'contributions.json');

// Ensure data directory exists
if (!fs.existsSync(path.join(__dirname, 'data'))) {
  fs.mkdirSync(path.join(__dirname, 'data'), { recursive: true });
}

// Initial default contributions store if empty
function loadContributions() {
  if (fs.existsSync(DATA_FILE)) {
    try {
      const raw = fs.readFileSync(DATA_FILE, 'utf-8');
      return JSON.parse(raw);
    } catch (e) {
      console.error('Error parsing contributions.json:', e);
    }
  }
  return [];
}

function saveContributions(items) {
  try {
    fs.writeFileSync(DATA_FILE, JSON.stringify(items, null, 2));
  } catch (e) {
    console.error('Error saving contributions:', e);
  }
}

let contributions = loadContributions();

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));
app.use(express.static(path.join(__dirname, 'public')));

// MARK: - API Routes

// 1. Health Check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', time: new Date().toISOString(), totalContributions: contributions.length });
});

// 2. S3 Presign Upload Mock Endpoint
app.post(['/contributions/presign', '/api/contributions/presign'], (req, res) => {
  const { filename, contentType, studentId, organisationId } = req.body || {};
  const s3Key = `evidence/${organisationId || 'org_campus'}/${studentId || 'student'}/${Date.now()}_${filename || 'evidence.jpg'}`;
  res.json({
    uploadUrl: `http://localhost:${PORT}/api/mock-s3-upload?key=${encodeURIComponent(s3Key)}`,
    s3ObjectKey: s3Key,
    bucket: 'sdg-wallet-evidence-bucket',
    expiresInSeconds: 900
  });
});

app.put('/api/mock-s3-upload', (req, res) => {
  res.status(200).send('Uploaded');
});

// 3. List All Contributions (for Coordinator Portal & Mobile Client)
app.get(['/contributions', '/api/contributions'], (req, res) => {
  const { status, studentId } = req.query;
  let filtered = [...contributions];
  
  if (status && status !== 'ALL') {
    filtered = filtered.filter(c => c.status && c.status.toUpperCase() === status.toUpperCase());
  }
  if (studentId) {
    filtered = filtered.filter(c => c.studentId === studentId);
  }
  
  // Sort reverse chronological
  filtered.sort((a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0));
  res.json({ contributions: filtered });
});

// 4. Get Single Contribution
app.get(['/contributions/:id', '/api/contributions/:id'], (req, res) => {
  const item = contributions.find(c => c.id === req.params.id);
  if (!item) {
    return res.status(404).json({ error: 'Contribution not found' });
  }
  res.json({ contribution: item });
});

// 5. Submit / Create Contribution (Called by iOS App)
app.post(['/contributions', '/api/contributions'], (req, res) => {
  const payload = req.body || {};
  const newEntry = {
    id: payload.id || require('crypto').randomUUID(),
    studentId: payload.studentId || 'std_student',
    studentName: payload.studentName || 'Student Volunteer',
    organisationId: payload.organisationId || 'org_main_campus',
    departmentId: payload.departmentId || 'dept_sustainability',
    title: payload.title || 'Untitled Action',
    description: payload.description || '',
    latitude: payload.latitude || null,
    longitude: payload.longitude || null,
    locationName: payload.locationName || 'Campus Ground',
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

  // Check if updating an existing entry
  const existingIdx = contributions.findIndex(c => c.id === newEntry.id);
  if (existingIdx >= 0) {
    contributions[existingIdx] = { ...contributions[existingIdx], ...newEntry, status: 'PENDING' };
  } else {
    contributions.unshift(newEntry);
  }
  
  saveContributions(contributions);
  res.status(201).json({ status: 'success', contribution: newEntry });
});

// 6. Coordinator Review & Verification Action (Approve / Request Changes / Reject)
app.post('/api/contributions/:id/verify', (req, res) => {
  const { status, coordinatorNote, verifiedBy, metrics } = req.body || {};
  const item = contributions.find(c => c.id === req.params.id);
  
  if (!item) {
    return res.status(404).json({ error: 'Contribution not found' });
  }

  // Update status & audit trail
  item.status = (status || 'VERIFIED').toUpperCase();
  item.coordinatorNote = coordinatorNote || null;
  item.verifiedBy = verifiedBy || 'Campus Sustainability Coordinator';
  item.verifiedAt = new Date().toISOString();

  if (metrics) {
    item.metrics = {
      treesPlanted: Number(metrics.treesPlanted) || 0,
      wasteRecycledKg: Number(metrics.wasteRecycledKg) || 0,
      energySavedKWh: Number(metrics.energySavedKWh) || 0,
      waterSavedLiters: Number(metrics.waterSavedLiters) || 0,
      peopleReached: Number(metrics.peopleReached) || 0,
      volunteerHours: Number(metrics.volunteerHours) || 0
    };
  }

  saveContributions(contributions);
  res.json({ status: 'success', contribution: item });
});

// 7. Coordinator Dashboard Stats
app.get('/api/stats', (req, res) => {
  const pending = contributions.filter(c => c.status === 'PENDING').length;
  const verified = contributions.filter(c => c.status === 'VERIFIED');
  const changes = contributions.filter(c => c.status === 'CHANGES_REQUESTED').length;
  const rejected = contributions.filter(c => c.status === 'REJECTED').length;

  const totalTrees = verified.reduce((sum, c) => sum + (c.metrics?.treesPlanted || 0), 0);
  const totalWaste = verified.reduce((sum, c) => sum + (c.metrics?.wasteRecycledKg || 0), 0);
  const totalEnergy = verified.reduce((sum, c) => sum + (c.metrics?.energySavedKWh || 0), 0);
  const totalWater = verified.reduce((sum, c) => sum + (c.metrics?.waterSavedLiters || 0), 0);
  const totalHours = verified.reduce((sum, c) => sum + (c.metrics?.volunteerHours || 0), 0);

  res.json({
    pendingCount: pending,
    verifiedCount: verified.length,
    changesRequestedCount: changes,
    rejectedCount: rejected,
    totalContributions: contributions.length,
    metrics: {
      totalTrees,
      totalWasteKg: totalWaste,
      totalEnergyKWh: totalEnergy,
      totalWaterLiters: totalWater,
      totalVolunteerHours: totalHours
    }
  });
});

// 8. Student Verified Impact Summary
app.get(['/student/impact', '/api/student/impact'], (req, res) => {
  const { studentId } = req.query;
  let verified = contributions.filter(c => c.status === 'VERIFIED');
  if (studentId) {
    verified = verified.filter(c => c.studentId === studentId);
  }

  const allSdgs = new Set();
  verified.forEach(c => (c.sdgIds || []).forEach(id => allSdgs.add(id)));

  const totalTrees = verified.reduce((sum, c) => sum + (c.metrics?.treesPlanted || 0), 0);
  const totalWaste = verified.reduce((sum, c) => sum + (c.metrics?.wasteRecycledKg || 0), 0);
  const totalEnergy = verified.reduce((sum, c) => sum + (c.metrics?.energySavedKWh || 0), 0);
  const totalWater = verified.reduce((sum, c) => sum + (c.metrics?.waterSavedLiters || 0), 0);
  const totalHours = verified.reduce((sum, c) => sum + (c.metrics?.volunteerHours || 0), 0);
  const totalPeople = verified.reduce((sum, c) => sum + (c.metrics?.peopleReached || 0), 0);

  res.json({
    studentId: studentId || 'std_all',
    verifiedCount: verified.length,
    verifiedSdgs: Array.from(allSdgs),
    metrics: {
      treesPlanted: totalTrees,
      wasteRecycledKg: totalWaste,
      energySavedKWh: totalEnergy,
      waterSavedLiters: totalWater,
      peopleReached: totalPeople,
      volunteerHours: totalHours
    },
    pillars: {
      planet: totalTrees > 0 || totalWaste > 0 ? 1 : 0,
      people: totalPeople > 0 ? 1 : 0,
      prosperity: totalEnergy > 0 ? 1 : 0,
      peace: 0,
      partnership: totalHours > 0 ? 1 : 0
    }
  });
});

app.listen(PORT, () => {
  console.log(`\n======================================================`);
  console.log(`🌱 SDG Wallet Coordinator Web Portal & API Server`);
  console.log(`🌐 Web Portal URL: http://localhost:${PORT}`);
  console.log(`📡 API Endpoints Ready: http://localhost:${PORT}/api/`);
  console.log(`======================================================\n`);
});
