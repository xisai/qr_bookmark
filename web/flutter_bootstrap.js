{{flutter_js}}
{{flutter_build_config}}

// Register our custom service worker (sw.js) which wraps Flutter's
// flutter_service_worker.js and additionally intercepts manifest.json
// requests to inject the current QR URL as start_url.
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('sw.js');
}

// Load Flutter without its built-in SW registration, since sw.js
// handles that via importScripts('flutter_service_worker.js').
_flutter.loader.load();
