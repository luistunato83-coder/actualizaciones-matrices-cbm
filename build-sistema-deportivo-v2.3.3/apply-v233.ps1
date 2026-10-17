$mainPath = "app-v233/src/main.js"
$main = Get-Content $mainPath -Raw
$old = "return{ok:true,file,...payload}});"
$new = "return{ok:true,file:out,...payload}});"
if (!$main.Contains($old)) { throw "No se encontró el retorno defectuoso de license:generate" }
$main = $main.Replace($old,$new)
Set-Content $mainPath $main -Encoding UTF8

$rendererPath = "app-v233/src/renderer.js"
$renderer = Get-Content $rendererPath -Raw
$oldTheme = "`${select('theme','Modo',a.theme||'light',['light','dark'])}"
$newTheme = '`${`<div class="field"><label>Modo</label><select data-k="theme"><option value="light" ${(a.theme||''light'')===''light''?''selected'':''}>Claro</option><option value="dark" ${a.theme===''dark''?''selected'':''}>Oscuro</option></select></div>`}'
if (!$renderer.Contains($oldTheme)) { throw "No se encontró el selector de tema light/dark" }
$renderer = $renderer.Replace($oldTheme,$newTheme)
Set-Content $rendererPath $renderer -Encoding UTF8

$cssPath = "app-v233/src/styles.css"
$css = Get-Content $cssPath -Raw
$append = @'

/* v2.3.3 - consistencia completa de temas Claro/Oscuro */
button,input,select,textarea{font:inherit}
button{color:var(--text)}
.tab{color:var(--text)}
.zoomBox button{background:var(--card);color:var(--text);border:1px solid var(--border)}
.ownerGate input{background:var(--card);color:var(--text);border-color:var(--border)}
.field select option{background:var(--card);color:var(--text)}
body.dark .btn:not(.primary):not(.danger),body.dark .tab:not(.active),body.dark .zoomBox button{background:var(--card);color:var(--text);border-color:var(--border)}
body.dark .btn.primary,body.dark .tab.active{color:#fff}
body.dark .btn.danger{background:#3a201e;color:#ffaaa3;border-color:#70403b}
body.dark .notice{background:#302b18;color:#f4df86;border-color:#5c5128}
body.dark .code{background:#26302b;color:#edf4ef}
body.dark .badge{background:#28332d;color:#edf4ef}
body.dark .badge.ok{background:#173a24;color:#b9f4ca}
body.dark .badge.bad{background:#452020;color:#ffc9c9}
body.dark .badge.admin{background:#423717;color:#ffe49a}
body.dark .activationCard{background:var(--card);color:var(--text)}
body.dark .activationError{background:#452020;color:#ffc9c9}
body.dark input,body.dark select,body.dark textarea{background:var(--card);color:var(--text);border-color:var(--border)}
body.dark input::placeholder,body.dark textarea::placeholder{color:#89978f;opacity:1}
body.dark .status-inh{color:#ff9d95}
'@
if (!$css.Contains('v2.3.3 - consistencia completa de temas Claro/Oscuro')) { $css += $append }
Set-Content $cssPath $css -Encoding UTF8
