'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "fac82cf7367f68cda21ef4163cd7b5bc",
"assets/AssetManifest.bin.json": "a1a17e5a8d8fb3c7a159fc87ccc6de21",
"assets/AssetManifest.json": "ac21c2338e50f1d410a42d656a97711b",
"assets/assets/AssetManifest.bin": "7c6d0e7c5b3ff4897be38c8d7a6c02a3",
"assets/assets/AssetManifest.bin.json": "2419ed13a36adf5cf7bda1c216ee639a",
"assets/assets/AssetManifest.json": "53940de1c702756ca91188617b3f4a14",
"assets/assets/chunk.json": "eb7f72abc376f773e263489df90330d5",
"assets/assets/Dhara%2520UI%2520Text%2520Refineing%2520sheet%2520-%2520Sheet1.csv": "8b51ff2b501c54733e2ad9faf71fcf0f",
"assets/assets/FontManifest.json": "07990b8cc052ebbf2348f5de41e7b168",
"assets/assets/fonts/NotoSansBengali-Bold.ttf": "4f3e35acd120b95e6793e29070eabfa2",
"assets/assets/fonts/NotoSansBengali-Regular.ttf": "0d4b009f5db0110aab74e4736fdf9b4e",
"assets/assets/fonts/NotoSansDevanagari-Bold.ttf": "0dd464e4bd6190cd2711bf3810835ef0",
"assets/assets/fonts/NotoSansDevanagari-Regular.ttf": "6280ee10957050f070e385b5ffe6b250",
"assets/assets/fonts/NotoSansGujarati-Bold.ttf": "a5077204599a35b1a8fda9900e5c7dbd",
"assets/assets/fonts/NotoSansGujarati-Regular.ttf": "0e88235b12a3affe7c50341210aab966",
"assets/assets/fonts/NotoSansGurmukhi-Bold.ttf": "ddc3c0d88b8148119dfd0aadbfb64349",
"assets/assets/fonts/NotoSansGurmukhi-Regular.ttf": "1fc899121c87fba5e950461f0caa8e74",
"assets/assets/fonts/NotoSansKannada-Bold.ttf": "0d636ec72436b959a48e7c92fdff5ea2",
"assets/assets/fonts/NotoSansKannada-Regular.ttf": "bbdf0b63a18f59f44017a80231cb239e",
"assets/assets/fonts/NotoSansMalayalam-Bold.ttf": "c29341dcc976bd81ed2f773e30d28265",
"assets/assets/fonts/NotoSansMalayalam-Regular.ttf": "dd526d7494dbd847149724e07205f0e5",
"assets/assets/fonts/NotoSansOriya-Bold.ttf": "2e2cdd0bc9c2db98d0a260e873bca2c7",
"assets/assets/fonts/NotoSansOriya-Regular.ttf": "e83bdef5b8b4157c60e39834e7673f79",
"assets/assets/fonts/NotoSansTamil-Bold.ttf": "1b9b01ae9f096efeb9e983012473102a",
"assets/assets/fonts/NotoSansTamil-Regular.ttf": "ef60ee4b035cd3cabf5ff8003606a840",
"assets/assets/fonts/NotoSansTelugu-Bold.ttf": "7d45ed56adfb3410d6f89be7372966a1",
"assets/assets/fonts/NotoSansTelugu-Regular.ttf": "57877c1829b6c151640c0601346da740",
"assets/assets/img/Dhara.png": "5574377d9c730c6539f9eb93129d68df",
"assets/assets/img/Dhara_logo.png": "55660528947cc169adf04a2c6776efc2",
"assets/assets/NOTICES": "cf47519c852653ef87546fa76676d669",
"assets/assets/prashna.json": "14bb7f08d2f8d1558395c17a785aa54c",
"assets/assets/prashnaold.json": "7af1f9ed3a3e1ea8abf352e8d629e3c7",
"assets/assets/svg/Dhara_vector.svg": "6714ab03b8d1e734df3dc8fe5115dfe8",
"assets/assets/svg/google_icon.svg": "d305798dcb4795dad7a3056dba215787",
"assets/assets/unified.json": "be01c06ec387a5df43aef37587fdeb4b",
"assets/FontManifest.json": "07990b8cc052ebbf2348f5de41e7b168",
"assets/fonts/MaterialIcons-Regular.otf": "77cc681d06a5e9e8163a1c1c31413ff4",
"assets/NOTICES": "cf47519c852653ef87546fa76676d669",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "6da51b53d1156663fffd04fb183e91c2",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "093c00afa4bef7bd77895a2600ec2c61",
"icons/Icon-192.png": "f6bb0b2c166fdfd6fb997ad380f11cc9",
"icons/Icon-512.png": "abb67c98635f8736b0250a20308de36f",
"icons/Icon-maskable-192.png": "f6bb0b2c166fdfd6fb997ad380f11cc9",
"icons/Icon-maskable-512.png": "abb67c98635f8736b0250a20308de36f",
"index.html": "173f1f27ea1b575bbdbcd7aa2e88317f",
"/": "173f1f27ea1b575bbdbcd7aa2e88317f",
"main.dart.js": "59080584a247c9652a7a6b43dd68c639",
"manifest.json": "d6f69112daf29d4e771147d514439e38",
"netlify.toml": "28eb7e228e00f4240755f3aec667ce52",
"vercel.json": "6a91628e7b6214811a3baabdd45bb800",
"version.json": "b70009ec65ff3b8ac78486901fe056d9"};
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
