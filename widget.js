/* Privacy-conscious visitor counter widget
   Cloudflare Workers + D1
*/
(() => {
  const script = document.currentScript;

  const apiBase = (
    script?.dataset.api ||
    'https://YOUR-WORKER.workers.dev'
  ).replace(/\/$/, '');

  const siteId = script?.dataset.site || 'mysite';
  const targetId = script?.dataset.target || 'visitor-counter';

  const target = document.getElementById(targetId);
  if (!target) return;

  // Display the counter layout.
  target.innerHTML = `
    <div class="vc-box" role="group" aria-label="Website visitor statistics">
      <div class="vc-total">
        <span class="vc-label">Total unique visitors</span>
        <strong data-vc="visitors">—</strong>
      </div>

      <div class="vc-countries">
        <span class="vc-label">Visitors by country</span>
        <div class="vc-country-list" data-vc="countries">
          <span class="vc-muted">Loading...</span>
        </div>
      </div>
    </div>
  `;

  // Widget styling.
  const style = document.createElement('style');

  style.textContent = `
    .vc-box {
      display: inline-flex;
      flex-wrap: wrap;
      align-items: stretch;
      gap: 12px;
      font: 14px/1.4 system-ui, sans-serif;
      color: #202124;
    }

    .vc-total,
    .vc-countries {
      border: 1px solid #ddd;
      border-radius: 10px;
      padding: 12px 16px;
      background: #fff;
    }

    .vc-total {
      min-width: 150px;
    }

    .vc-countries {
      min-width: 170px;
    }

    .vc-label {
      display: block;
      color: #666;
      font-size: 12px;
      margin-bottom: 7px;
    }

    .vc-total strong {
      display: block;
      font-size: 24px;
      font-weight: 700;
      line-height: 1.3;
    }

    .vc-country-list {
      display: flex;
      flex-wrap: wrap;
      gap: 10px 14px;
      align-items: center;
    }

    .vc-country {
      display: inline-flex;
      align-items: center;
      gap: 5px;
      font-size: 17px;
    }

    .vc-country-flag {
      width: 24px;
      height: 18px;
      object-fit: contain;
      display: inline-block;
      vertical-align: middle;
      border-radius: 2px;
    }

    .vc-country-count {
      font-size: 14px;
      font-weight: 650;
      font-variant-numeric: tabular-nums;
    }

    .vc-muted {
      color: #777;
      font-size: 12px;
    }

    @media (prefers-color-scheme: dark) {
      .vc-box {
        color: #eee;
      }

      .vc-total,
      .vc-countries {
        background: #202124;
        border-color: #555;
      }

      .vc-label {
        color: #bbb;
      }

      .vc-muted {
        color: #aaa;
      }
    }
  `;

  document.head.appendChild(style);

  // Keep the existing browser visitor ID.
  let visitorId;

  try {
    visitorId = localStorage.getItem('visitor-counter-id');

    if (!visitorId) {
      visitorId = crypto.randomUUID
        ? crypto.randomUUID()
        : `${Date.now()}-${Math.random().toString(16).slice(2)}-${Math.random().toString(16).slice(2)}`;

      localStorage.setItem('visitor-counter-id', visitorId);
    }
  } catch {
    visitorId = `${Date.now()}-${Math.random().toString(16).slice(2)}-${Math.random().toString(16).slice(2)}`;
  }

  const baseQuery = `?site=${encodeURIComponent(siteId)}`;

  const totalEl = target.querySelector('[data-vc="visitors"]');
  const countriesEl = target.querySelector('[data-vc="countries"]');

  // Load visitor statistics.
  async function loadStats() {
    try {
      // Record this visit first.
      const hitResponse = await fetch(
        `${apiBase}/hit${baseQuery}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ visitorId }),
          keepalive: true
        }
      );

      if (!hitResponse.ok) {
        throw new Error('Visitor hit request failed');
      }

      // Retrieve lifetime statistics.
      const statsResponse = await fetch(
        `${apiBase}/stats${baseQuery}`
      );

      if (!statsResponse.ok) {
        throw new Error('Stats request failed');
      }

      const data = await statsResponse.json();

      // Display lifetime unique visitors.
      totalEl.textContent = Number(
        data.uniqueVisitors || 0
      ).toLocaleString();

      // Read country statistics.
      const countryStats = Array.isArray(data.countryStats)
        ? data.countryStats
        : [];

      const validCountries = countryStats
        .filter(item =>
          /^[A-Z]{2}$/.test(item.country || '') &&
          item.country !== 'XX'
        )
        .sort((a, b) =>
          Number(b.visitors || 0) -
          Number(a.visitors || 0)
        );

      countriesEl.replaceChildren();

      if (validCountries.length === 0) {
        const empty = document.createElement('span');
        empty.className = 'vc-muted';
        empty.textContent = 'No country data yet';
        countriesEl.appendChild(empty);
        return;
      }

      // Display flag images and counts only.
      for (const item of validCountries) {
        const entry = document.createElement('span');
        entry.className = 'vc-country';

        // Use an image instead of a Unicode flag emoji.
        const flag = document.createElement('img');
        flag.className = 'vc-country-flag';
        flag.src = `https://flagcdn.com/24x18/${item.country.toLowerCase()}.png`;
        flag.alt = item.country;
        flag.width = 24;
        flag.height = 18;
        flag.loading = 'lazy';

        // Hide the flag image if it cannot be loaded.
        flag.onerror = () => {
          flag.style.display = 'none';
        };

        const count = document.createElement('span');
        count.className = 'vc-country-count';
        count.textContent = Number(
          item.visitors || 0
        ).toLocaleString();

        entry.append(flag, count);
        countriesEl.appendChild(entry);
      }

    } catch (error) {
      console.error('Visitor counter error:', error);

      totalEl.textContent = 'Unavailable';

      countriesEl.replaceChildren();

      const message = document.createElement('span');
      message.className = 'vc-muted';
      message.textContent = 'Unable to load statistics';

      countriesEl.appendChild(message);
    }
  }

  loadStats();
})();
