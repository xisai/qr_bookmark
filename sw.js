'use strict';

const QR_CACHE_NAME = 'qr-state-v1';
const QR_URL_KEY = 'qr-start-url';
const QR_ICON_KEY = 'qr-icon';

// Intercept manifest.json fetches from the browser.
// event.request.destination === 'manifest' is only set when the browser
// itself requests the manifest (e.g. "Add to Home Screen"), not when
// fetch() is called from JS/SW code — so there is no infinite-loop risk.
self.addEventListener('fetch', (event) => {
  if (event.request.destination === 'manifest') {
    // Strip cache-busting query params (e.g. ?v=...) before fetching.
    const url = new URL(event.request.url);
    url.search = '';
    event.respondWith(serveModifiedManifest(url.toString()));
  } else if (new URL(event.request.url).pathname === '/icons/qr-dynamic-icon.png') {
    event.respondWith(serveQrIcon(event.request));
  }
});

async function serveQrIcon(request) {
  const cache = await caches.open(QR_CACHE_NAME);
  const stored = await cache.match(QR_ICON_KEY);
  if (stored) return stored.clone();
  return fetch('/icons/Icon-512.png');
}

async function serveModifiedManifest(url) {
  try {
    const [manifestResponse, cache] = await Promise.all([
      fetch(url),
      caches.open(QR_CACHE_NAME),
    ]);
    const manifest = await manifestResponse.json();
    const stored = await cache.match(QR_URL_KEY);
    if (stored) {
      manifest.start_url = await stored.text();
    }
    const iconStored = await cache.match(QR_ICON_KEY);
    if (iconStored) {
      const origin = new URL(url).origin;
      const iconUrl = origin + '/icons/qr-dynamic-icon.png';
      manifest.icons = [
        { src: iconUrl, sizes: '192x192', type: 'image/png' },
        { src: iconUrl, sizes: '512x512', type: 'image/png' },
      ];
    }
    return new Response(JSON.stringify(manifest), {
      status: 200,
      headers: { 'Content-Type': 'application/manifest+json' },
    });
  } catch (_) {
    return fetch(url);
  }
}

// Store the QR URL / QR icon sent from the Flutter app via postMessage.
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SET_QR_URL') {
    caches.open(QR_CACHE_NAME).then((cache) => {
      cache.put(QR_URL_KEY, new Response(event.data.url));
    });
  }
  if (event.data && event.data.type === 'SET_QR_ICON') {
    caches.open(QR_CACHE_NAME).then(async (cache) => {
      const response = await fetch(event.data.dataUrl);
      cache.put(QR_ICON_KEY, response);
    });
  }
});

// Import Flutter's generated service worker for asset caching.
// Wrapped in try/catch so manifest interception still works in dev mode
// where flutter_service_worker.js may not be present.
try {
  importScripts('flutter_service_worker.js');
} catch (_) {
  // Development mode: Flutter's asset-caching SW is not available.
}
