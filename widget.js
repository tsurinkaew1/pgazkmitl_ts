/* Privacy-conscious visitor counter + interactive 3D globe
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

  // Display visitor counter and centered globe.
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

    <div class="vc-globe-section">
      <div id="vc-globe"></div>
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

    /* Center the 3D globe. */
    .vc-globe-section {
      width: 100%;
      margin: 28px auto 0;
      text-align: center;
    }

    #vc-globe {
      width: 100%;
      max-width: 700px;
      height: 420px;
      margin: 0 auto;
      position: relative;
      overflow: hidden;
      cursor: grab;
    }

    #vc-globe:active {
      cursor: grabbing;
    }

    @media (max-width: 600px) {
      #vc-globe {
        height: 320px;
      }
    }
  `;

  document.head.appendChild(style);

  const totalEl = target.querySelector('[data-vc="visitors"]');
  const countriesEl = target.querySelector('[data-vc="countries"]');
  const globeEl = target.querySelector('#vc-globe');

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

  // Load the 3D globe library.
  function loadGlobeLibrary() {
    return new Promise((resolve, reject) => {
      if (window.Globe) {
        resolve();
        return;
      }

      const existingScript = document.getElementById('vc-globe-library');

      if (existingScript) {
        existingScript.addEventListener('load', resolve, { once: true });
        existingScript.addEventListener('error', reject, { once: true });
        return;
      }

      const libraryScript = document.createElement('script');
      libraryScript.id = 'vc-globe-library';
      libraryScript.src = 'https://cdn.jsdelivr.net/npm/globe.gl';
      libraryScript.async = true;

      libraryScript.onload = resolve;
      libraryScript.onerror = reject;

      document.head.appendChild(libraryScript);
    });
  }

  // Escape text for country labels.
  function escapeHTML(value) {
    return String(value).replace(/[&<>"']/g, character => ({
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#39;'
    })[character]);
  }

  // Create the interactive 3D globe.
  async function initGlobe(countryStats = []) {
    try {
      await loadGlobeLibrary();

      // Get visitor counts by country.
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
        throw new Error('Unable to load country map data');
      }

      const geoData = await geoResponse.json();

      // Prepare country polygons.
      const features = geoData.features
        .map(feature => {
          const properties = feature.properties || {};

          const countryCode =
            properties.ISO_A2 ||
            properties.ISO_A2_EH ||
            '';

          const code = String(countryCode).toUpperCase();

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

      // Create globe.
      const globe = new Globe(globeEl, {
        animateIn: true,
        waitForGlobeReady: true
      });

      globe
        .globeImageUrl(
          'https://cdn.jsdelivr.net/npm/three-globe/example/img/earth-day.jpg'
        )
        .backgroundColor('rgba(0,0,0,0)')
        .showAtmosphere(true)
        .atmosphereColor('#75baff')
        .atmosphereAltitude(0.18)

        // Country boundaries.
        .polygonsData(features)

        .polygonAltitude(feature =>
          feature.vcVisitors > 0 ? 0.025 : 0.004
        )

        // Highlight countries with visitors.
        .polygonCapColor(feature =>
          feature.vcVisitors > 0
            ? 'rgba(255, 170, 0, 0.78)'
            : 'rgba(70, 150, 90, 0.18)'
        )

        .polygonSideColor(feature =>
          feature.vcVisitors > 0
            ? 'rgba(255, 170, 0, 0.45)'
            : 'rgba(70, 150, 90, 0.08)'
        )

        .polygonStrokeColor(() =>
          'rgba(40, 80, 55, 0.65)'
        )

        // Country information on hover.
        .polygonLabel(feature => {
          const name = escapeHTML(feature.vcName);
          const code = escapeHTML(feature.vcCode);
          const visitors = Number(
            feature.vcVisitors
          ).toLocaleString();

          return `
            <div style="
              background: white;
              color: black;
              padding: 9px 12px;
              border-radius: 6px;
              font-size: 13px;
            ">
              <strong>${name} (${code})</strong><br>
              Visitors: ${visitors}
            </div>
          `;
        })

        // Click a country to see visitor count.
        .onPolygonClick(feature => {
          if (!feature) return;

          const visitors = Number(
            feature.vcVisitors
          ).toLocaleString();

          // Use a tooltip-style information display.
          globeEl.setAttribute(
            'aria-label',
            `${feature.vcName}, ${feature.vcCode}: ${visitors} unique visitors`
          );

          const info = document.createElement('div');
          info.textContent =
            `${feature.vcName} (${feature.vcCode}): ${visitors} unique visitors`;

          info.style.cssText = `
            position: absolute;
            left: 50%;
            bottom: 12px;
            transform: translateX(-50%);
            background: white;
            color: black;
            padding: 8px 12px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 13px;
            z-index: 5;
            max-width: 90%;
            text-align: center;
          `;

          const oldInfo = globeEl.querySelector('.vc-country-info');
          if (oldInfo) oldInfo.remove();

          info.className = 'vc-country-info';
          globeEl.appendChild(info);
        })

        .polygonsTransitionDuration(800);

      // Initial globe position.
      globe.pointOfView({
        lat: 20,
        lng: 100,
        altitude: 2.3
      }, 1000);

      // Automatic 360-degree rotation.
      const controls = globe.controls();

      controls.autoRotate = true;
      controls.autoRotateSpeed = 0.45;
      controls.enableDamping = true;
      controls.dampingFactor = 0.08;

      // Responsive globe sizing.
      function resizeGlobe() {
        const width = globeEl.clientWidth;
        if (!width) return;

        const height = window.innerWidth <= 600
          ? 320
          : 420;

        globe.width(width);
        globe.height(height);
      }

      resizeGlobe();

      if (window.ResizeObserver) {
        const observer = new ResizeObserver(resizeGlobe);
        observer.observe(globeEl);
      } else {
        window.addEventListener('resize', resizeGlobe);
      }

    } catch (error) {
      console.error('3D globe error:', error);
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

      // Initialize globe with country statistics.
      initGlobe(validCountries);

    } catch (error) {
      console.error('Visitor counter error:', error);

      totalEl.textContent = 'Unavailable';

      countriesEl.replaceChildren();

      const message = document.createElement('span');
      message.className = 'vc-muted';
      message.textContent = 'Unable to load statistics';

      countriesEl.appendChild(message);

      // Try to load globe even if statistics are unavailable.
      initGlobe([]);
    }
  }

  loadStats();
})();