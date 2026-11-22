/* Privacy-conscious visitor counter */
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

  // Make the widget occupy the available parent width.
  target.style.width = '100%';
  target.style.maxWidth = '100%';
  target.style.boxSizing = 'border-box';

  // Visitor counter and world map.
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

      <div id="vc-map-tooltip" class="vc-map-tooltip"></div>
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
      max-width: 100%;
      box-sizing: border-box;
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

    /* Map container */
    .vc-map-section {
      position: relative;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      width: 100%;
      max-width: 100%;
      margin: 0px auto 0;
      padding: 0;
      box-sizing: border-box;
    }

    /* Desktop map size */
    #vc-world-map {
      display: block;
      width: 220%;
      max-width: none;
      height: auto;
      aspect-ratio: 2 / 1;
      transform: translateX(40px);
      margin-left: auto;
      margin-right: auto;
      overflow: visible;
      background: transparent;
    }

    /* Country appearance */
    .vc-map-country {
      stroke: #ffffff;
      stroke-width: 0.8;
      stroke-linejoin: round;
      cursor: pointer;
      transition: fill 0.2s ease, stroke 0.15s ease;
    }

    .vc-map-country:hover {
      stroke: #222222;
      stroke-width: 1.8;
    }

    /* Popup above hovered or tapped country */
    .vc-map-tooltip {
      display: none;
      position: fixed;
      z-index: 99999;
      transform: translate(-50%, -100%);
      padding: 7px 12px;
      border-radius: 6px;
      background: #222222;
      color: #ffffff;
      font: 13px/1.4 system-ui, sans-serif;
      font-weight: 600;
      white-space: nowrap;
      pointer-events: none;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.25);
    }

    /* Smartphone responsive layout */
    @media (max-width: 600px) {

      .vc-box {
        display: flex;
        flex-direction: column;
        width: 100%;
        max-width: 100%;
        gap: 10px;
        box-sizing: border-box;
      }

      .vc-total,
      .vc-countries {
        width: 100%;
        min-width: 0;
        box-sizing: border-box;
      }

      .vc-total strong {
        font-size: 22px;
      }

      .vc-country-list {
        gap: 8px 12px;
      }

      .vc-country {
        font-size: 15px;
      }

      .vc-country-flag {
        width: 20px;
        height: 15px;
      }

      .vc-map-section {
        width: 100%;
        max-width: 100%;
        margin-top: 12px;
        overflow: hidden;
      }

      #vc-world-map {
        width: 100% !important;
        max-width: 100% !important;
        height: auto;
        aspect-ratio: 2 / 1;
        margin: 0 auto;
      }

      .vc-map-tooltip {
        font-size: 12px;
        padding: 6px 10px;
      }
    }
  `;

  document.head.appendChild(style);

  const totalEl = target.querySelector('[data-vc="visitors"]');
  const countriesEl = target.querySelector('[data-vc="countries"]');
  const mapEl = target.querySelector('#vc-world-map');
  const tooltip = target.querySelector('#vc-map-tooltip');

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
        if (existingScript.dataset.loaded === 'true') {
          resolve();
        } else {
          existingScript.addEventListener('load', resolve, { once: true });
          existingScript.addEventListener('error', reject, { once: true });
        }
        return;
      }

      const libraryScript = document.createElement('script');
      libraryScript.id = 'vc-d3-library';
      libraryScript.src = 'https://cdn.jsdelivr.net/npm/d3@7/dist/d3.min.js';
      libraryScript.async = true;

      libraryScript.onload = () => {
        libraryScript.dataset.loaded = 'true';
        resolve();
      };

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

      // Fit the world projection to the SVG.
      const projection = d3.geoNaturalEarth1()
        .fitExtent(
          [[0, 0], [1200, 600]],
          {
            type: 'FeatureCollection',
            features
          }
        );

      const path = d3.geoPath(projection);

      // Draw countries.
      const countries = svg
        .selectAll('.vc-map-country')
        .data(features)
        .join('path')
        .attr('class', 'vc-map-country')
        .attr('d', path)
        .attr('fill', feature =>
          feature.vcVisitors > 0
            ? '#2563eb'
            : '#e1e5e8'
        );

      // Country name and visitor count on native SVG title.
      countries
        .append('title')
        .text(feature =>
          `${feature.vcName} (${feature.vcCode}) — ${Number(feature.vcVisitors).toLocaleString()} visitors`
        );

      // Show country information on hover or tap.
      function showTooltip(event, feature) {
        const visitors = Number(
          feature.vcVisitors
        ).toLocaleString();

        tooltip.textContent =
          `${feature.vcCode} ${visitors}`;

        tooltip.style.display = 'block';

        // Keep popup inside the screen horizontally.
        const popupWidth = tooltip.offsetWidth;
        const halfWidth = popupWidth / 2;

        const x = Math.max(
          halfWidth + 5,
          Math.min(
            event.clientX,
            window.innerWidth - halfWidth - 5
          )
        );

        // Position popup above the pointer.
        const y = Math.max(tooltip.offsetHeight + 8, event.clientY - 12);

        tooltip.style.left = `${x}px`;
        tooltip.style.top = `${y}px`;
      }

      countries
        .on('pointerenter', function(event, feature) {
          showTooltip(event, feature);

          d3.select(this)
            .attr('stroke', '#000000')
            .attr('stroke-width', 1.8);
        })

        .on('pointermove', function(event, feature) {
          // Follow the mouse on desktop.
          if (event.pointerType !== 'touch') {
            showTooltip(event, feature);
          }
        })

        .on('pointerdown', function(event, feature) {
          // On touchscreen, tapping a country displays its popup.
          if (event.pointerType === 'touch') {
            showTooltip(event, feature);

            d3.select(this)
              .attr('stroke', '#000000')
              .attr('stroke-width', 1.8);
          }
        })

        .on('pointerleave', function(event) {
          // Do not immediately hide the popup on touchscreens.
          if (event.pointerType !== 'touch') {
            tooltip.style.display = 'none';

            d3.select(this)
              .attr('stroke', '#ffffff')
              .attr('stroke-width', 0.8);
          }
        });

      // Tapping elsewhere on the map dismisses the popup on touchscreens.
      svg.on('pointerdown', function(event) {
        if (event.pointerType === 'touch' &&
            event.target === mapEl) {
          tooltip.style.display = 'none';

          countries
            .attr('stroke', '#ffffff')
            .attr('stroke-width', 0.8);
        }
      });

    } catch (error) {
      console.error('2D world map error:', error);
      tooltip.textContent = 'Unable to load the world map.';
      tooltip.style.display = 'block';
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