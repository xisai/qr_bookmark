'use strict';

const QR_CACHE_NAME = 'qr-state-v1';
const QR_URL_KEY = 'qr-start-url';

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
  }
});

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
    return new Response(JSON.stringify(manifest), {
      status: 200,
      headers: { 'Content-Type': 'application/manifest+json' },
    });
  } catch (_) {
    return fetch(url);
  }
}

// Store the QR URL sent from the Flutter app via postMessage.
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SET_QR_URL') {
    caches.open(QR_CACHE_NAME).then((cache) => {
      cache.put(QR_URL_KEY, new Response(event.data.url));
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
