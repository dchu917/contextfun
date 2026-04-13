const state = {
  workstreams: [],
};

async function api(path, options = {}) {
  const response = await fetch(path, {
    headers: { "Content-Type": "application/json" },
    ...options,
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    const message = data.error || data.stderr || `Request failed (${response.status})`;
    throw new Error(message);
  }
  return data;
}

function escapeHtml(value) {
  return String(value || "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}

function formatDate(value) {
  if (!value) {
    return "unknown date";
  }
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return value;
  }
  return date.toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

function sourceLabel(item) {
  const sources = Array.isArray(item.sources) ? item.sources : [];
  if (sources.includes("codex") && sources.includes("claude")) {
    return "both";
  }
  if (sources.includes("codex")) {
    return "codex";
  }
  if (sources.includes("claude")) {
    return "claude";
  }
  return "other";
}

function resumeCommands(slug) {
  return {
    claude: `/ctx resume ${slug}`,
    codex: `ctx resume ${slug}`,
  };
}

function startCommands(slug) {
  return {
    claude: `/ctx start ${slug} --pull`,
    codex: `ctx start ${slug} --pull`,
  };
}

function recentItem(entry) {
  return `
    <article class="recent-item">
      <div class="recent-head">
        <strong>S${entry.session_id} ${escapeHtml(entry.type)}</strong>
        <span class="muted">${escapeHtml(formatDate(entry.created_at))}</span>
      </div>
      <div class="muted">${escapeHtml(entry.session_title)}</div>
      <div class="value">${escapeHtml(entry.preview)}</div>
    </article>
  `;
}

async function workstreamCard(item) {
  const detail = await api(`/api/workstreams/${encodeURIComponent(item.slug)}`);
  const latest = detail.recent_entries[0]?.preview || item.latest || "No recent task recorded yet.";
  const resume = resumeCommands(item.slug);
  const start = startCommands(item.slug);
  return `
    <details class="ws-item">
      <summary>
        <div class="ws-row">
          <div>
            <div class="ws-title">${escapeHtml(item.title)}</div>
            <div class="ws-slug">${escapeHtml(item.slug)}</div>
            <div class="ws-copy">This workstream was focused on ${escapeHtml(item.goal || item.title)}. Most recent task: ${escapeHtml(latest)}</div>
          </div>
          <div class="ws-meta">
            <span class="pill">${escapeHtml(formatDate(item.last_activity_at))}</span>
            <span class="pill source">${escapeHtml(sourceLabel(item))}</span>
          </div>
        </div>
      </summary>
      <div class="ws-body">
        <div class="info-grid">
          <div>
            <p class="label">What This Workstream Did</p>
            <p class="value">${escapeHtml(item.goal || item.title)}</p>
          </div>
          <div>
            <p class="label">Most Recent Task</p>
            <p class="value">${escapeHtml(latest)}</p>
          </div>
        </div>

        <div class="command-grid">
          <div class="command-card">
            <p class="label">Resume In Claude Code</p>
            <pre>${escapeHtml(resume.claude)}</pre>
          </div>
          <div class="command-card">
            <p class="label">Resume In Codex</p>
            <pre>${escapeHtml(resume.codex)}</pre>
          </div>
          <div class="command-card">
            <p class="label">Start Fresh Session In Claude Code</p>
            <pre>${escapeHtml(start.claude)}</pre>
          </div>
          <div class="command-card">
            <p class="label">Start Fresh Session In Codex</p>
            <pre>${escapeHtml(start.codex)}</pre>
          </div>
        </div>

        <div>
          <p class="label">Recent Context</p>
          <div class="recent-list">
            ${
              detail.recent_entries.length
                ? detail.recent_entries.slice(0, 4).map(recentItem).join("")
                : `<div class="empty-state">No recent context saved yet.</div>`
            }
          </div>
        </div>
      </div>
    </details>
  `;
}

async function renderWorkstreams(items) {
  state.workstreams = items;
  const root = document.getElementById("workstream-list");
  document.getElementById("list-count").textContent = `${items.length} streams`;
  if (!items.length) {
    root.innerHTML = `<div class="empty-state">No workstreams found.</div>`;
    return;
  }
  root.innerHTML = `<div class="empty-state">Loading workstreams…</div>`;
  const cards = await Promise.all(items.map((item) => workstreamCard(item)));
  root.innerHTML = cards.join("");
}

async function loadWorkstreams(query = "") {
  const url = query ? `/api/workstreams?query=${encodeURIComponent(query)}` : "/api/workstreams";
  const payload = await api(url);
  await renderWorkstreams(payload.items);
}

function bindEvents() {
  document.getElementById("filter-query").addEventListener("input", async (event) => {
    await loadWorkstreams(event.target.value.trim());
  });
}

async function boot() {
  bindEvents();
  await loadWorkstreams();
}

boot().catch((error) => {
  document.getElementById("workstream-list").innerHTML = `<div class="empty-state">${escapeHtml(error.message)}</div>`;
});
