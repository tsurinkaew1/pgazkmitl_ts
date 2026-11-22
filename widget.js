/* Privacy-conscious visitor counter + responsive 2D world map
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

  // Visitor counter and full-width 2D map.
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

    <div class="vc-map-section">
      <svg
        id="vc-world-map"
        viewBox="0 0 1200 600"
        role="img"
        aria-label="Interactive world map showing visitors by country">
      </svg>

      <div id="vc-map-info" class="vc-map-info" aria-live="polite"></div>
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
      color: #000000;
    }

    .vc-total,
    .vc-countries {
      border: 1px solid;
      border-radius: 10px;
      padding: 12px 16px;
      background: transparent;
    }

    .vc-total {
      min-width: 150px;
    }

    .vc-countries {
      min-width: 170px;
    }

    .vc-label {
      display: block;
      color: #000000;
      font-size: 12px;
      margin-bottom: 7px;
    }

    .vc-total strong {
      display: block;
      font-size: 24px;
      font-weight: 700;
      line-height: 1.3;
      color: #000000;
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

    .vc-country-code {
      font-size: 13px;
      font-weight: 600;
      color: #000000;
    }

    .vc-country-count {
      font-size: 14px;
      font-weight: 650;
      font-variant-numeric: tabular-nums;
      color: #000000;
    }

    .vc-muted {
      color: #000000;
      font-size: 12px;
    }

    /* Responsive full-width 2D world map. */
    .vc-map-section {
      width: 100%;
      max-width: none;
      margin: 24px auto 0;
      padding: 0;
      box-sizing: border-box;
    }

    #vc-world-map {
      display: block;
      width: 100%;
      max-width: none;
      height: auto;
      aspect-ratio: 2 / 1;
      overflow: visible;
      background: transparent;
    }

    .vc-map-country {
      stroke: #ffffff;
      stroke-width: 0.8;
      stroke-linejoin: round;
      cursor: pointer;
      transition: fill 0.2s ease;
    }

    .vc-map-country:hover {
      stroke: #222222;
      stroke-width: 1.8;
    }

    .vc-map-info {
      min-height: 20px;
      margin-top: 8px;
      text-align: center;
      font: 14px/1.5 system-ui, sans-serif;
      color: #000000;
    }

    @media (max-width: 600px) {
      .vc-map-section {
        margin-top: 16px;
      }

      .vc-map-info {
        font-size: 12px;
      }

      .vc-country-flag {
        width: 20px;
        height: 15px;
      }
    }
  `;

  document.head.appendChild(style);

  const totalEl = target.querySelector('[data-vc="visitors"]');
  const countriesEl = target.querySelector('[data-vc="countries"]');
  const mapEl = target.querySelector('#vc-world-map');
  const mapInfoEl = target.querySelector('#vc-map-info');

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

  // Load D3.js for the 2D map.
  function loadD3() {
    return new Promise((resolve, reject) => {
      if (window.d3) {
        resolve();
        return;
      }

      const existingScript = document.getElementById('vc-d3-library');

      if (existingScript) {
        existingScript.addEventListener('load', resolve, { once: true });
        existingScript.addEventListener('error', reject, { once: true });
        return;
      }

      const libraryScript = document.createElement('script');
      libraryScript.id = 'vc-d3-library';
      libraryScript.src = 'https://cdn.jsdelivr.net/npm/d3@7/dist/d3.min.js';
      libraryScript.async = true;

      libraryScript.onload = resolve;
      libraryScript.onerror = reject;

      document.head.appendChild(libraryScript);
    });
  }

  // Create the 2D world map.
  async function initWorldMap(countryStats = []) {
    try {
      await loadD3();

      const d3 = window.d3;

      // Build country visitor lookup.
      const countryCounts = {};

      for (const item of countryStats) {
        if (
          /^[A-Z]{2}$/.test(item.country || '') &&
          item.country !== 'XX'
        ) {
          countryCounts[item.country] = Number(item.visitors || 0);
        }
      }

      // Load country boundary data.
      const geoResponse = await fetch(
        'https://cdn.jsdelivr.net/npm/globe.gl/example/datasets/ne_110m_admin_0_countries.geojson'
      );

      if (!geoResponse.ok) {
        throw new Error('Unable to load world map data');
      }

      const geoData = await geoResponse.json();

      // Attach ISO country codes and visitor counts.
      const features = geoData.features
        .map(feature => {
          const properties = feature.properties || {};

          let code = String(
            properties.ISO_A2 || ''
          ).toUpperCase();

          if (!/^[A-Z]{2}$/.test(code)) {
            code = String(
              properties.ISO_A2_EH || ''
            ).toUpperCase();
          }

          return {
            ...feature,
            vcCode: code,
            vcName:
              properties.ADMIN ||
              properties.NAME ||
              code,
            vcVisitors: countryCounts[code] || 0
          };
        })
        .filter(feature =>
          /^[A-Z]{2}$/.test(feature.vcCode) &&
          feature.vcCode !== 'AQ'
        );

      // Create a clean SVG map.
      const svg = d3.select(mapEl);
      svg.selectAll('*').remove();

      // Flat Natural Earth projection.
      const projection = d3.geoNaturalEarth1()
        .fitExtent(
          [[12, 12], [1188, 588]],
          {
            type: 'FeatureCollection',
            features
          }
        );

      const path = d3.geoPath(projection);

      // Draw country shapes.
      svg
        .selectAll('.vc-map-country')
        .data(features)
        .join('path')
        .attr('class', 'vc-map-country')
        .attr('d', path)
        .attr('fill', feature =>
          feature.vcVisitors > 0
            ? '#f5a623'
            : '#e1e5e8'
        )
        .append('title')
        .text(feature =>
          `${feature.vcName} (${feature.vcCode}) — ${Number(feature.vcVisitors).toLocaleString()} visitors`
        );

      // Click a country to display its visitor count.
      svg
        .selectAll('.vc-map-country')
        .on('click', function(event, feature) {
          const visitors = Number(
            feature.vcVisitors
          ).toLocaleString();

          mapInfoEl.textContent =
            `${feature.vcName} (${feature.vcCode}): ${visitors} unique visitors`;

          // Emphasize the selected country.
          svg
            .selectAll('.vc-map-country')
            .attr('stroke', '#ffffff')
            .attr('stroke-width', 0.8);

          d3.select(this)
            .attr('stroke', '#000000')
            .attr('stroke-width', 2);
        });

      // Start with no selected country.
      mapInfoEl.textContent = '';

    } catch (error) {
      console.error('2D world map error:', error);
      mapInfoEl.textContent = 'Unable to load the world map.';
    }
  }

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
      } else {
        // Display flag, country abbreviation and visitor count.
        for (const item of validCountries) {
          const entry = document.createElement('span');
          entry.className = 'vc-country';

          const flag = document.createElement('img');
          flag.className = 'vc-country-flag';
          flag.src =
            `https://flagcdn.com/24x18/${item.country.toLowerCase()}.png`;
          flag.alt = item.country;
          flag.width = 24;
          flag.height = 18;
          flag.loading = 'lazy';

          flag.onerror = () => {
            flag.style.display = 'none';
          };

          const code = document.createElement('span');
          code.className = 'vc-country-code';
          code.textContent = item.country;

          const count = document.createElement('span');
          count.className = 'vc-country-count';
          count.textContent = Number(
            item.visitors || 0
          ).toLocaleString();

          entry.append(flag, code, count);
          countriesEl.appendChild(entry);
        }
      }

      // Initialize map with country statistics.
      initWorldMap(validCountries);

    } catch (error) {
      console.error('Visitor counter error:', error);

      totalEl.textContent = 'Unavailable';

      countriesEl.replaceChildren();

      const message = document.createElement('span');
      message.className = 'vc-muted';
      message.textContent = 'Unable to load statistics';

      countriesEl.appendChild(message);

      // Still attempt to display the map.
      initWorldMap([]);
    }
  }

  loadStats();
})();