/* Installed at document start in open.spotify.com only. Never fabricates tokens. */
(function () {
  if (window.__lokalSpotifySessionHook) return;
  window.__lokalSpotifySessionHook = true;
  const operations = new Set(['home', 'canvas', 'searchTracks', 'fetchPlaylist', 'fetchLibraryTracks', 'libraryV3', 'addToLibrary']);
  const report = value => { try { const bridge=window.KonnektedSpotifyTokenBridge;const data=JSON.stringify(value);if(bridge.postMessage)bridge.postMessage(data);else bridge.onSessionPayload(data); } catch (_) {} };
  const spotify = raw => { if(typeof raw!=='string')return false;try { const u = new URL(raw, location.href); return u.protocol === 'https:' && (u.hostname === 'spotify.com' || u.hostname.endsWith('.spotify.com')); } catch (_) { return false; } };
  function headers(raw, input, init) {
    if (!spotify(raw)) return;
    try {
      const h = new Headers(init && init.headers || input && input.headers || {});
      const auth = h.get('authorization'), client = h.get('client-token');
      if (auth || client) report({kind:'headers', authorization:auth, clientToken:client});
      let body = init && init.body;
      if (!body) { const u = new URL(raw, location.href); body = JSON.stringify({operationName:u.searchParams.get('operationName'),extensions:JSON.parse(u.searchParams.get('extensions') || '{}')}); }
      if (typeof body === 'string') {
        const q = JSON.parse(body), hash = q.extensions && q.extensions.persistedQuery && q.extensions.persistedQuery.sha256Hash;
        if (operations.has(q.operationName) && /^[a-f0-9]{64}$/.test(hash || '')) report({kind:'hash',operation:q.operationName,hash});
      }
    } catch (_) {}
  }
  function payload(raw, text) {
    if (!spotify(raw)) return;
    try {
      const u = new URL(raw, location.href), data = JSON.parse(text);
      if (/\/api\/token|\/get_access_token/.test(u.pathname)) report({kind:'access',data});
      else if (u.hostname === 'clienttoken.spotify.com' && u.pathname === '/v1/clienttoken') report({kind:'client',data});
    } catch (_) {}
  }
  const originalFetch = window.fetch;
  if (originalFetch) window.fetch = function(input, init) {
    const raw = input && input.url || input;
    headers(raw,input,init);
    const result = originalFetch.apply(this,arguments);
    if (spotify(raw)) result.then(res => {
      try { const u = new URL(raw,location.href); if (/\/api\/token|\/get_access_token|\/v1\/clienttoken/.test(u.pathname)) res.clone().text().then(text=>payload(raw,text)).catch(()=>{}); } catch (_) {}
    }).catch(()=>{});
    return result;
  };
  const open = XMLHttpRequest.prototype.open, send = XMLHttpRequest.prototype.send, set = XMLHttpRequest.prototype.setRequestHeader;
  XMLHttpRequest.prototype.open = function(method,url) { this.__lokalUrl=url;this.__lokalHeaders={};return open.apply(this,arguments); };
  XMLHttpRequest.prototype.setRequestHeader = function(key,value) { (this.__lokalHeaders || (this.__lokalHeaders={}))[key]=value;return set.apply(this,arguments); };
  XMLHttpRequest.prototype.send = function(body) {
    const xhr=this;headers(xhr.__lokalUrl,null,{headers:xhr.__lokalHeaders,body});
    xhr.addEventListener('load',()=>{try {payload(xhr.__lokalUrl,xhr.responseText);}catch(_){}});
    return send.apply(this,arguments);
  };
  // Public query hashes also appear in the player's own JS. Read a small,
  // bounded set of loaded bundles; credentials never accompany these requests.
  const scripts = new Set();
  function scanScripts() {
    for (const entry of performance.getEntriesByType('resource')) {
      if (scripts.size >= 12 || scripts.has(entry.name)) continue;
      let u;try {u=new URL(entry.name);}catch(_){continue;}
      if (u.protocol!=='https:' || !(/^(open\.spotify\.com|[^/]+\.scdn\.co)$/.test(u.hostname)) || !u.pathname.endsWith('.js')) continue;
      scripts.add(entry.name);
      originalFetch(entry.name,{credentials:'omit'}).then(r=>r.text()).then(js=>{
        if(js.length>8000000)return;
        const pattern=/["'](canvas|searchTracks|libraryV3|fetchLibraryTracks|addToLibrary|home|fetchPlaylist)["']\s*,\s*["'](?:query|mutation)["']\s*,\s*["']([0-9a-f]{64})["']/g;
        let m;while((m=pattern.exec(js)))report({kind:'hash',operation:m[1],hash:m[2]});
      }).catch(()=>{});
    }
  }
  if (originalFetch) { scanScripts();const interval=setInterval(scanScripts,700);setTimeout(()=>clearInterval(interval),12000); }
})();
