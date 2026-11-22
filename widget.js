/* Embed this script. Configure API_BASE and SITE_ID below, or via data attributes. */
(() => {
  const script = document.currentScript;
  const apiBase = (script?.dataset.api || 'https://YOUR-WORKER.workers.dev').replace(/\/$/, '');
  const siteId = script?.dataset.site || 'mysite';
  const targetId = script?.dataset.target || 'visitor-counter';
  const target = document.getElementById(targetId);
  if (!target) return;

  target.innerHTML = `
    <div class="vc-box" role="group" aria-label="Website visitor statistics">
      <div class="vc-stat"><span class="vc-label">Total views</span><strong data-vc="views">—</strong></div>
      <div class="vc-stat"><span class="vc-label">Unique visitors</span><strong data-vc="visitors">—</strong></div>
      <div class="vc-stat"><span class="vc-label">Today</span><strong data-vc="today">—</strong></div>
    </div>`;

  const style = document.createElement('style');
  style.textContent = `
    .vc-box{display:inline-flex;flex-wrap:wrap;gap:12px;font:14px/1.4 system-ui,sans-serif;color:#202124}
    .vc-stat{min-width:100px;border:1px solid #ddd;border-radius:10px;padding:12px 16px;background:#fff}
    .vc-label{display:block;color:#666;font-size:12px;margin-bottom:4px}
    .vc-stat strong{font-size:20px;font-weight:650}
    @media(prefers-color-scheme:dark){.vc-box{color:#eee}.vc-stat{background:#202124;border-color:#555}.vc-label{color:#bbb}}
  `;
  document.head.appendChild(style);

  let visitorId;
  try {
    visitorId = localStorage.getItem('visitor-counter-id');
    if (!visitorId) {
      visitorId = (crypto.randomUUID ? crypto.randomUUID() : `${Date.now()}-${Math.random().toString(16).slice(2)}-${Math.random().toString(16).slice(2)}`);
      localStorage.setItem('visitor-counter-id', visitorId);
    }
  } catch {
    visitorId = `${Date.now()}-${Math.random().toString(16).slice(2)}-${Math.random().toString(16).slice(2)}`;
  }

  const baseQuery = `?site=${encodeURIComponent(siteId)}`;
  fetch(`${apiBase}/hit${baseQuery}`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ visitorId }), keepalive: true,
  }).catch(() => {});

  fetch(`${apiBase}/stats${baseQuery}`).then(r => {
    if (!r.ok) throw new Error('stats request failed');
    return r.json();
  }).then(data => {
    target.querySelector('[data-vc="views"]').textContent = Number(data.totalViews || 0).toLocaleString();
    target.querySelector('[data-vc="visitors"]').textContent = Number(data.uniqueVisitors || 0).toLocaleString();
    target.querySelector('[data-vc="today"]').textContent = Number(data.todayViews || 0).toLocaleString();
  }).catch(() => {
    target.querySelectorAll('.vc-stat strong').forEach(el => el.textContent = 'Unavailable');
  });
})();
