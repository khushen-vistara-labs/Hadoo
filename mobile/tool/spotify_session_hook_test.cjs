// Exercises the exact script bundled into Android, without a browser/account.
const {readFileSync}=require('node:fs');
const vm=require('node:vm');
const assert=require('node:assert/strict');
const reports=[];
class XHR {open(){}send(){}setRequestHeader(){}addEventListener(){}}
const hash='d'.repeat(64);
const context={window:{},location:{href:'https://open.spotify.com/'},URL,Headers,XMLHttpRequest:XHR,
  performance:{getEntriesByType:()=>[]},setInterval:()=>1,setTimeout:()=>1,clearInterval:()=>{}};
context.window.fetch=async url=>({clone:()=>({text:async()=>JSON.stringify(String(url).includes('clienttoken')
  ? {granted_token:{token:'web-player-client'}} : {accessToken:'web-player-access',isAnonymous:false})})});
vm.createContext(context);
vm.runInContext(readFileSync('assets/spotify/session_hook.js','utf8'),context);
// Native bridge injection can follow the early page-start fallback hook.
context.window.KonnektedSpotifyTokenBridge={postMessage:s=>reports.push(JSON.parse(s))};
(async()=>{
 await context.window.fetch('https://open.spotify.com/get_access_token');
 await context.window.fetch('https://clienttoken.spotify.com/v1/clienttoken');
 await context.window.fetch('https://api-partner.spotify.com/pathfinder/v2/query',{headers:{Authorization:'Bearer browser-token','client-token':'browser-client'},body:JSON.stringify({operationName:'home',extensions:{persistedQuery:{sha256Hash:hash}}})});
 await new Promise(resolve=>setImmediate(resolve));
 assert(reports.some(r=>r.kind==='access'&&r.data.accessToken==='web-player-access'));
 assert(reports.some(r=>r.kind==='client'&&r.data.granted_token.token==='web-player-client'));
 assert(reports.some(r=>r.kind==='hash'&&r.operation==='home'&&r.hash===hash));
 const before=reports.length;
 await context.window.fetch('https://spotify.com.attacker.example/api/token',{headers:{Authorization:'Bearer private'}});
 await new Promise(resolve=>setImmediate(resolve));
 assert.equal(reports.length,before,'non-Spotify origins cannot report tokens or query hashes');
 console.log('Spotify WebPlayer hook: real access/client responses, live hashes and origin guard passed.');
})().catch(e=>{console.error(e);process.exitCode=1;});
