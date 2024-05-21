'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"main.dart.js": "d2951f6246da1e3e9efc0ea69e239778",
"version.json": "1c4bb18853dec2d3d50816f1b1d1ac41",
"assets/assets/flower.jpg": "3c84eb473f80fd82b010cadd0eec1fb5",
"assets/assets/flower_dark.jpg": "408ed705677d8442a54393c6a6ee4cc0",
"assets/fonts/MaterialIcons-Regular.otf": "81705383afc1e326db067b69096e70d2",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "ff451ce95b99b232277df44be6e75d69",
"assets/AssetManifest.bin": "3c02476c5436dee326c5e0ba9d1b4be6",
"assets/AssetManifest.bin.json": "0d13c07b882a4cbfa5182caea4d3feb5",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/NOTICES": "373f118954767e96f819910f1150f48a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/favicon.ico": "c5f4f7f7606bf56e0567a7c877c03cd6",
"icons/android-icon-36x36.png": "f58427232d992624df5b52e3d73b043b",
"icons/android-icon-48x48.png": "3bac4705c48ebfc4f5e3adb359bb660b",
"icons/android-icon-72x72.png": "aa0cee4623c3a7096ec1763f9f2ef0c0",
"icons/android-icon-96x96.png": "a1d80299961d5bc263642a6b5e66017f",
"icons/android-icon-144x144.png": "9f668538e745db1325a1912dabd3f809",
"icons/android-icon-192x192.png": "0afc2a27371dbdc9cb3adea10a06acbc",
"icons/apple-icon.png": "948d602204ae83fc98fe35d9f522bd9e",
"icons/apple-icon-57x57.png": "a8b815e1ec6f0bf1612ff2c4387bdb5b",
"icons/apple-icon-60x60.png": "0bb50b461ab42ab4fee5297c4b6b4959",
"icons/apple-icon-72x72.png": "aa0cee4623c3a7096ec1763f9f2ef0c0",
"icons/apple-icon-76x76.png": "92865db306b611caf2eab07be6f8dc11",
"icons/apple-icon-114x114.png": "f0ca4f35a890c409932cfd07f99e1c68",
"icons/apple-icon-120x120.png": "47e4fe6c6fa0920f8726f7bdb43caeb9",
"icons/apple-icon-144x144.png": "9f668538e745db1325a1912dabd3f809",
"icons/apple-icon-152x152.png": "523f4c61648b3246142f2dea5db9e06c",
"icons/apple-icon-180x180.png": "439c474527ea7f340d6783ed152d863a",
"icons/apple-icon-precomposed.png": "948d602204ae83fc98fe35d9f522bd9e",
"icons/favicon-16x16.png": "9a0d463ef285903e380c0f8dca813848",
"icons/favicon-32x32.png": "a4aec37c962040594d54fc7512d869b7",
"icons/favicon-96x96.png": "a1d80299961d5bc263642a6b5e66017f",
"icons/ms-icon-70x70.png": "d4610d694a8f73f4de7c5a1463da8260",
"icons/ms-icon-144x144.png": "9f668538e745db1325a1912dabd3f809",
"icons/ms-icon-150x150.png": "5911adc4dc4d1d10ccd6b0e9e3f433ee",
"icons/ms-icon-310x310.png": "7ad985ad539e30aaba8cfe7e8f051393",
"manifest.json": "295fe8f0948d9f1987733e342047f252",
"flutter_bootstrap.js": "45555323e61f0dbc068b1469ed8e58ae",
"index.html": "32bf05d224c31cf87103bf52e3470818",
"/": "32bf05d224c31cf87103bf52e3470818"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
