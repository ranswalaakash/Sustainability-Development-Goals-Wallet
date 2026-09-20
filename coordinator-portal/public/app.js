// Coordinator Portal Frontend Logic
let currentFilter = 'PENDING';
let allData = [];
let activeItem = null;

// UN SDG Color and Name Mapping
const SDG_MAP = {
  1: { title: "No Poverty", color: "#E5243B" },
  2: { title: "Zero Hunger", color: "#DDA63A" },
  3: { title: "Good Health", color: "#4C9F38" },
  4: { title: "Quality Education", color: "#C5192D" },
  5: { title: "Gender Equality", color: "#FF3A21" },
  6: { title: "Clean Water", color: "#26BDE2" },
  7: { title: "Clean Energy", color: "#FCC30B" },
  8: { title: "Decent Work", color: "#A21942" },
  9: { title: "Innovation", color: "#FD6925" },
  10: { title: "Reduced Inequalities", color: "#DD1367" },
  11: { title: "Sustainable Cities", color: "#FD9D24" },
  12: { title: "Responsible Consumption", color: "#BF8B2E" },
  13: { title: "Climate Action", color: "#3F7E44" },
  14: { title: "Life Below Water", color: "#0A97D9" },
  15: { title: "Life on Land", color: "#56C02B" },
  16: { title: "Peace & Justice", color: "#00689D" },
  17: { title: "Partnerships", color: "#19486A" }
};

document.addEventListener('DOMContentLoaded', () => {
  fetchData();
  // Auto-refresh every 6 seconds for live updates from students
  setInterval(fetchData, 6000);
});

async function fetchData() {
  try {
    const [contribRes, statsRes] = await Promise.all([
      fetch('/api/contributions'),
      fetch('/api/stats')
    ]);

    if (contribRes.ok && statsRes.ok) {
      const contribJson = await contribRes.json();
      const statsJson = await statsRes.json();

      allData = contribJson.contributions || [];
      updateStats(statsJson);
      renderList();
    }
  } catch (error) {
    console.error('Error fetching data from API:', error);
  }
}

function updateStats(stats) {
  document.getElementById('stat-pending').innerText = stats.pendingCount || 0;
  document.getElementById('stat-verified').innerText = stats.verifiedCount || 0;
  document.getElementById('stat-trees').innerText = stats.metrics?.totalTrees || 0;
  document.getElementById('stat-waste').innerHTML = `${stats.metrics?.totalWasteKg || 0} <span class="text-sm font-normal text-slate-500">kg</span>`;
  document.getElementById('stat-energy').innerHTML = `${stats.metrics?.totalEnergyKWh || 0} <span class="text-sm font-normal text-slate-500">kWh</span>`;
  document.getElementById('stat-hours').innerHTML = `${stats.metrics?.totalVolunteerHours || 0} <span class="text-sm font-normal text-slate-500">hrs</span>`;

  document.getElementById('tab-badge-pending').innerText = stats.pendingCount || 0;
  document.getElementById('tab-badge-verified').innerText = stats.verifiedCount || 0;
  document.getElementById('tab-badge-changes').innerText = stats.changesRequestedCount || 0;
}

function setFilter(filter) {
  currentFilter = filter;
  document.querySelectorAll('.filter-btn').forEach(btn => {
    if (btn.dataset.filter === filter) {
      btn.className = 'filter-btn active-tab px-4 py-2 rounded-xl text-sm font-semibold transition-all bg-amber-500 text-white shadow-sm flex items-center space-x-2';
    } else {
      btn.className = 'filter-btn px-4 py-2 rounded-xl text-sm font-semibold text-slate-600 hover:bg-slate-100 transition-all flex items-center space-x-2';
    }
  });
  renderList();
}

function filterList() {
  renderList();
}

function renderList() {
  const container = document.getElementById('contributions-container');
  const search = (document.getElementById('search-input').value || '').toLowerCase();

  let items = [...allData];

  if (currentFilter !== 'ALL') {
    items = items.filter(c => (c.status || '').toUpperCase() === currentFilter.toUpperCase());
  }

  if (search) {
    items = items.filter(c =>
      (c.title || '').toLowerCase().includes(search) ||
      (c.studentName || '').toLowerCase().includes(search) ||
      (c.description || '').toLowerCase().includes(search) ||
      (c.locationName || '').toLowerCase().includes(search)
    );
  }

  if (items.length === 0) {
    container.innerHTML = `
      <div class="bg-white rounded-2xl p-12 text-center border border-slate-200">
        <div class="w-16 h-16 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3 text-2xl">
          <i class="fa-solid fa-folder-open"></i>
        </div>
        <h3 class="text-base font-bold text-slate-800">No Submissions in ${currentFilter}</h3>
        <p class="text-xs text-slate-500 mt-1">When students submit or update initiatives, they will appear here in real-time.</p>
      </div>
    `;
    return;
  }

  container.innerHTML = items.map(item => createCardHTML(item)).join('');
}

function createCardHTML(item) {
  const statusBadge = getStatusBadge(item.status);
  const formattedDate = item.createdAt ? new Date(item.createdAt).toLocaleDateString('en-US', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : 'Recently';

  const sdgBadges = (item.sdgIds || []).map(id => {
    const info = SDG_MAP[id] || { title: `Goal ${id}`, color: '#10B981' };
    return `<span class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-bold text-white shadow-xs" style="background-color: ${info.color}">SDG ${id} • ${info.title}</span>`;
  }).join(' ');

  const metricsSummary = getMetricsSummary(item.metrics);

  return `
    <div class="bg-white rounded-2xl border border-slate-200/90 p-5 shadow-sm hover:shadow-md transition-all duration-200 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
      
      <div class="flex items-start space-x-4 flex-1">
        
        <!-- Thumbnail / Photo Icon -->
        <div class="w-16 h-16 rounded-xl bg-slate-100 border border-slate-200 flex-shrink-0 flex items-center justify-center text-slate-400 text-2xl overflow-hidden">
          <i class="fa-solid fa-camera"></i>
        </div>

        <div class="space-y-1.5 flex-1">
          <div class="flex flex-wrap items-center gap-2">
            ${statusBadge}
            <span class="text-xs font-semibold text-slate-500">${item.studentName || 'Student Volunteer'} (${item.departmentId || 'Main Campus'})</span>
            <span class="text-xs text-slate-400">• ${formattedDate}</span>
          </div>

          <h3 class="text-base font-bold text-slate-900 leading-snug">${item.title || 'Untitled Initiative'}</h3>

          <p class="text-xs text-slate-600 line-clamp-2">${item.description || 'No description provided.'}</p>

          <div class="flex flex-wrap items-center gap-2 pt-1">
            ${sdgBadges}
            ${item.locationName ? `<span class="inline-flex items-center text-[11px] text-slate-500 bg-slate-100 px-2 py-0.5 rounded"><i class="fa-solid fa-location-dot text-emerald-500 mr-1"></i> ${item.locationName}</span>` : ''}
          </div>

          ${metricsSummary ? `<div class="text-xs font-bold text-emerald-700 bg-emerald-50/70 border border-emerald-200/60 px-2.5 py-1 rounded-lg inline-block mt-1">${metricsSummary}</div>` : ''}
          
          ${item.coordinatorNote ? `<div class="text-xs text-slate-600 bg-amber-50/80 border border-amber-200/60 p-2 rounded-lg mt-1"><span class="font-bold text-amber-800">Reviewer Note:</span> ${item.coordinatorNote}</div>` : ''}
        </div>
      </div>

      <!-- Action Button -->
      <div class="flex md:flex-col items-center justify-end w-full md:w-auto gap-2">
        <button onclick="openReviewModal('${item.id}')" class="w-full md:w-auto px-4 py-2.5 rounded-xl bg-slate-900 hover:bg-slate-800 text-white text-xs font-bold transition-colors flex items-center justify-center space-x-2 shadow-sm">
          <i class="fa-solid fa-magnifying-glass-chart"></i>
          <span>Review & Audit</span>
        </button>
      </div>

    </div>
  `;
}

function getStatusBadge(status) {
  switch ((status || '').toUpperCase()) {
    case 'VERIFIED':
      return `<span class="bg-emerald-100 text-emerald-800 border border-emerald-300 text-[10px] font-bold px-2 py-0.5 rounded-full flex items-center"><i class="fa-solid fa-check-circle mr-1 text-emerald-600"></i> Verified</span>`;
    case 'CHANGES_REQUESTED':
      return `<span class="bg-amber-100 text-amber-800 border border-amber-300 text-[10px] font-bold px-2 py-0.5 rounded-full flex items-center"><i class="fa-solid fa-triangle-exclamation mr-1 text-amber-600"></i> Changes Requested</span>`;
    case 'REJECTED':
      return `<span class="bg-rose-100 text-rose-800 border border-rose-300 text-[10px] font-bold px-2 py-0.5 rounded-full flex items-center"><i class="fa-solid fa-circle-xmark mr-1 text-rose-600"></i> Rejected</span>`;
    default:
      return `<span class="bg-amber-500 text-white text-[10px] font-bold px-2 py-0.5 rounded-full flex items-center"><i class="fa-solid fa-clock mr-1"></i> Awaiting Audit</span>`;
  }
}

function getMetricsSummary(m) {
  if (!m) return '';
  const parts = [];
  if (m.treesPlanted > 0) parts.push(`🌳 ${m.treesPlanted} Trees`);
  if (m.wasteRecycledKg > 0) parts.push(`♻️ ${m.wasteRecycledKg} kg Waste`);
  if (m.energySavedKWh > 0) parts.push(`⚡ ${m.energySavedKWh} kWh`);
  if (m.waterSavedLiters > 0) parts.push(`💧 ${m.waterSavedLiters} L`);
  if (m.volunteerHours > 0) parts.push(`⏱️ ${m.volunteerHours} hrs`);
  return parts.join(' • ');
}

// Modal Handling
function openReviewModal(id) {
  activeItem = allData.find(c => c.id === id);
  if (!activeItem) return;

  document.getElementById('modal-title').innerText = activeItem.title || 'Untitled Submission';
  document.getElementById('modal-status-badge').innerHTML = getStatusBadge(activeItem.status);
  document.getElementById('modal-student-name').innerText = activeItem.studentName || 'Student Volunteer';
  document.getElementById('modal-student-id').innerText = activeItem.studentId || 'std_1001';
  document.getElementById('modal-location').innerText = activeItem.locationName || 'Campus Ground';
  document.getElementById('modal-coords').innerText = activeItem.latitude ? `${activeItem.latitude.toFixed(4)}° N, ${activeItem.longitude?.toFixed(4)}° E` : 'Coordinates Recorded';
  document.getElementById('modal-date').innerText = activeItem.createdAt ? new Date(activeItem.createdAt).toLocaleString() : 'Recent';
  document.getElementById('modal-description').innerText = activeItem.description || 'No narrative provided.';

  document.getElementById('modal-s3-key').innerText = activeItem.s3ObjectKey || `evidence/${activeItem.organisationId || 'org_campus'}/${activeItem.studentId || 'std'}/${activeItem.id}.jpg`;
  document.getElementById('modal-hash').innerText = activeItem.fileHashSha256 || 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

  // Metrics Inputs
  document.getElementById('metric-trees').value = activeItem.metrics?.treesPlanted || 0;
  document.getElementById('metric-waste').value = activeItem.metrics?.wasteRecycledKg || 0;
  document.getElementById('metric-energy').value = activeItem.metrics?.energySavedKWh || 0;
  document.getElementById('metric-water').value = activeItem.metrics?.waterSavedLiters || 0;
  document.getElementById('metric-hours').value = activeItem.metrics?.volunteerHours || 0;
  document.getElementById('metric-people').value = activeItem.metrics?.peopleReached || 0;

  document.getElementById('modal-feedback-input').value = activeItem.coordinatorNote || '';

  // Photos
  const photosContainer = document.getElementById('modal-photos');
  photosContainer.innerHTML = `
    <div class="aspect-square bg-slate-100 rounded-2xl border border-slate-200 flex flex-col items-center justify-center text-slate-400 p-4 text-center">
      <i class="fa-solid fa-image text-3xl mb-2 text-slate-300"></i>
      <span class="text-xs font-semibold text-slate-500">Verified Evidence Photo</span>
      <span class="text-[10px] text-slate-400 mt-1 font-mono">S3 Stored</span>
    </div>
  `;

  document.getElementById('review-modal').classList.remove('hidden');
}

function closeModal() {
  document.getElementById('review-modal').classList.add('hidden');
  activeItem = null;
}

async function submitDecision(newStatus) {
  if (!activeItem) return;

  const note = document.getElementById('modal-feedback-input').value.trim();
  const trees = parseInt(document.getElementById('metric-trees').value) || 0;
  const waste = parseFloat(document.getElementById('metric-waste').value) || 0;
  const energy = parseFloat(document.getElementById('metric-energy').value) || 0;
  const water = parseFloat(document.getElementById('metric-water').value) || 0;
  const hours = parseFloat(document.getElementById('metric-hours').value) || 0;
  const people = parseInt(document.getElementById('metric-people').value) || 0;

  try {
    const res = await fetch(`/api/contributions/${activeItem.id}/verify`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        status: newStatus,
        coordinatorNote: note,
        verifiedBy: 'Prof. Sarah Chen (Sustainability Coordinator)',
        metrics: {
          treesPlanted: trees,
          wasteRecycledKg: waste,
          energySavedKWh: energy,
          waterSavedLiters: water,
          volunteerHours: hours,
          peopleReached: people
        }
      })
    });

    if (res.ok) {
      showToast(newStatus === 'VERIFIED' ? 'Contribution Approved & Impact Verified!' : (newStatus === 'CHANGES_REQUESTED' ? 'Revision Request Sent to Student' : 'Submission Rejected'));
      closeModal();
      fetchData();
    } else {
      showToast('Error updating status', true);
    }
  } catch (e) {
    console.error('Error submitting decision:', e);
    showToast('Failed to connect to backend', true);
  }
}

function showToast(msg, isError = false) {
  const toast = document.getElementById('toast');
  const text = document.getElementById('toast-message');
  const icon = document.getElementById('toast-icon');

  text.innerText = msg;
  icon.className = isError ? 'fa-solid fa-circle-exclamation text-rose-400' : 'fa-solid fa-check text-emerald-400';

  toast.classList.remove('translate-y-20', 'opacity-0');
  setTimeout(() => {
    toast.classList.add('translate-y-20', 'opacity-0');
  }, 3500);
}
