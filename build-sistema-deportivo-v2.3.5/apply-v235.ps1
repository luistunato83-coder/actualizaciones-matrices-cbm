$rendererPath = "app-v234/src/renderer.js"
$renderer = Get-Content $rendererPath -Raw

$oldGate = @'
gate.innerHTML=`<div class="activationCard"><div class="activationBrand">⚽</div><h1>SISTEMA DEPORTIVO</h1><p class="activationLead">Activación requerida para utilizar el sistema en esta computadora.</p>${reason}<div class="activationCode"><span>Código de dispositivo</span><b>${esc(licenseState.machineCode||session.machineCode||'')}</b></div><p class="muted">Envíe este código al Administrador propietario para recibir su archivo de licencia. La activación funciona sin Internet y queda vinculada a este equipo.</p><div class="activationActions"><button id="gateActivate" class="btn primary">Cargar licencia</button><button id="gateAdmin" class="btn">Administrador propietario</button></div><div id="gateAdminArea"></div><div class="activationAuthor">© 2026–2027 L.A.T.C. · Todos los derechos reservados<br>WhatsApp: 0987 19 47 18 · luis.tunato.83@gmail.com</div></div>`;
'@
$newGate = @'
gate.innerHTML=`<div class="activationCard"><div class="activationBrand">⚽</div><h1>SISTEMA DEPORTIVO</h1><p class="activationLead">Activación requerida para utilizar el sistema en esta computadora.</p>${reason}<p class="muted">Seleccione el archivo de licencia entregado por el Administrador propietario. El sistema reconocerá y validará automáticamente esta computadora, sin pedirle ningún código.</p><div class="activationActions"><button id="gateActivate" class="btn primary">Cargar licencia</button><button id="gateAdmin" class="btn">Administrador propietario</button></div><div id="gateAdminArea"></div><div class="activationAuthor">© 2026–2027 L.A.T.C. · Todos los derechos reservados<br>WhatsApp: 0987 19 47 18 · luis.tunato.83@gmail.com</div></div>`;
'@
if (!$renderer.Contains($oldGate.Trim())) { throw "No se encontró la pantalla de activación esperada" }
$renderer = $renderer.Replace($oldGate.Trim(), $newGate.Trim())

$oldVersion = @'
<p><b>Versión:</b> ${esc(session.version||'')} · <b>Código de este dispositivo:</b> <span class="code">${esc(ls.machineCode)}</span></p>
'@
$newVersion = @'
<p><b>Versión:</b> ${esc(session.version||'')}${session.mode==='admin'?` · <b>Código de este dispositivo:</b> <span class="code">${esc(ls.machineCode)}</span>`:''}</p>
'@
if (!$renderer.Contains($oldVersion.Trim())) { throw "No se encontró la línea de versión/código de dispositivo" }
$renderer = $renderer.Replace($oldVersion.Trim(), $newVersion.Trim())

Set-Content $rendererPath $renderer -Encoding UTF8
