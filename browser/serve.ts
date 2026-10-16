const fixturePath = import.meta.dir;
const repo = process.argv[2];
if(!repo) throw new Error('Pass frozen production source directory');
if(!await Bun.file(repo+'/tgui/public/tgui.bundle.css').exists()) throw new Error('Canonical production CSS is missing; build the frozen source first');
const resolve=(path,directory)=>Bun.resolveSync(path,directory).replaceAll('\\','/');
const result=await Bun.build({entrypoints:[fixturePath+'/browser.tsx'],outdir:fixturePath+'/dist',target:'browser',tsconfig:repo+'/tgui/tsconfig.json',jsx:{runtime:'automatic'},define:{'process.env.NODE_ENV':'"production"'},plugins:[{name:'fixture-singletons',setup(builder){
 builder.onResolve({filter:/\.scss$/},()=>({path:'fixture-empty-scss',namespace:'fixture-empty-scss'}));
 builder.onLoad({filter:/.*/,namespace:'fixture-empty-scss'},()=>({contents:'',loader:'js'}));
 builder.onResolve({filter:/^tgui\//},({path})=>({path:resolve(repo+'/tgui/packages/'+path,repo+'/tgui')}));
 builder.onResolve({filter:/^react(?:-dom)?(?:\/.*)?$/},({path})=>({path:resolve(path,repo+'/tgui')}));
 builder.onResolve({filter:/^tgui-core(?:\/.*)?$/},({path})=>({path:resolve(path,repo+'/tgui')}));
 builder.onResolve({filter:/^\.{1,2}\//},({path,resolveDir})=>({path:resolve(path,resolveDir)}));
}}]});
if(!result.success){console.error(result.logs);process.exit(1);}
const html='<!doctype html><html><head><meta charset="utf-8"><link rel="stylesheet" href="/tgui.css"><link rel="stylesheet" href="/font-awesome/css/all.min.css"></head><body style="background:#20282e"><div style="color:#e0cf73;font:14px sans-serif;padding:6px">TEMP fixture | frozen source components | synthetic backend | browser only</div><div id="react-root"></div><script>window.__acts=[];window.Byond={windowId:"modularity-fixture",sendMessage:(...args)=>window.__acts.push(args),winset:()=>{},winget:()=>Promise.resolve({}),subscribeTo:()=>()=>{}};</script><script type="module" src="/browser.js"></script></body></html>';
const server=Bun.serve({hostname:'127.0.0.1',port:0,async fetch(request){const path=new URL(request.url).pathname;
if(path==='/')return new Response(html,{headers:{'Content-Type':'text/html; charset=utf-8'}});
if(path==='/browser.js')return new Response(Bun.file(fixturePath+'/dist/browser.js'));
if(path==='/tgui.css'){return new Response(Bun.file(repo+'/tgui/public/tgui.bundle.css'),{headers:{'Content-Type':'text/css'}});}
if(path==='/favicon.ico')return new Response(null,{status:204});
if(path.startsWith('/font-awesome/css/')&&path.endsWith('.woff2'))return new Response(Bun.file(repo+'/html/font-awesome/webfonts/'+path.split('/').at(-1)));
if(path.startsWith('/font-awesome/'))return new Response(Bun.file(repo+'/html'+path));
if(path.startsWith('/fonts/')||path.startsWith('/font/'))return new Response(Bun.file(repo+'/tgui/public'+path));
if(path.startsWith('/tgui-core/assets/'))return new Response(Bun.file(repo+'/tgui/node_modules'+path));
if(path==='/stop'){setTimeout(()=>process.exit(0),50);return new Response('Stopped');}
return new Response('Not found',{status:404});}});
console.log('UI_FIXTURE '+JSON.stringify({url:server.url.href,temp:fixturePath,pid:process.pid}));