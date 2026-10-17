$mainPath = "app-v234/src/main.js"
$main = Get-Content $mainPath -Raw

if (!$main.Contains("const XLSX=require('xlsx');")) {
  $main = $main.Replace("const ExcelJS=require('exceljs');", "const ExcelJS=require('exceljs');`nconst XLSX=require('xlsx');")
}

$newHandler = @'
ipcMain.handle('data:importExcel',async()=>{requireLicensed();const r=await dialog.showOpenDialog({properties:['openFile'],filters:[{name:'Excel',extensions:['xlsx','xlsm']}]});if(r.canceled)return{ok:false,canceled:true};let book;try{const buf=fs.readFileSync(r.filePaths[0]);book=XLSX.read(buf,{type:'buffer',cellDates:false,raw:false})}catch(e){throw new Error('No se pudo leer el archivo Excel. Verifique que sea un .xlsx o .xlsm válido. Detalle: '+(e?.message||e))}if(!book||!Array.isArray(book.SheetNames)||!book.Sheets)throw new Error('El archivo Excel no contiene una estructura de hojas válida.');const rows=name=>{const real=book.SheetNames.find(n=>String(n).trim().toUpperCase()===name);if(!real||!book.Sheets[real])return null;return XLSX.utils.sheet_to_json(book.Sheets[real],{header:1,defval:'',raw:false})};const wt=rows('EQUIPOS'),wp=rows('JUGADORES'),wd=rows('DIRECTIVA'),wr=rows('ARBITROS');if(!wt)throw new Error('Falta la hoja EQUIPOS.');const cell=(row,i)=>String((row&&row[i])??'').trim();const names=new Map();let teamsAdded=0,playersAdded=0,refsAdded=0,directivesUpdated=0;for(let n=1;n<wt.length;n++){const row=wt[n],name=cell(row,0);if(!name)continue;let t=D().teams.find(x=>String(x.name).trim().toLowerCase()===name.toLowerCase());if(!t){t={id:nextId('teams'),name,short_name:cell(row,1),shield:cell(row,2),president:'',delegate:'',coach:'',phone:'',color:'',notes:''};D().teams.push(t);teamsAdded++}else{if(cell(row,1))t.short_name=cell(row,1);if(cell(row,2))t.shield=cell(row,2)}names.set(name.toLowerCase(),t.id)}if(wd)for(let n=1;n<wd.length;n++){const row=wd[n],team=cell(row,0),tid=names.get(team.toLowerCase())||D().teams.find(x=>String(x.name).trim().toLowerCase()===team.toLowerCase())?.id,t=byId(D().teams,tid);if(!t)continue;t.president=cell(row,1)||t.president||'';t.vicepresident=cell(row,2)||t.vicepresident||'';t.secretary=cell(row,3)||t.secretary||'';t.treasurer=cell(row,4)||t.treasurer||'';t.delegate=cell(row,5)||t.delegate||'';t.coach=cell(row,6)||t.coach||'';t.phone=cell(row,7)||t.phone||'';directivesUpdated++}if(wp)for(let n=1;n<wp.length;n++){const row=wp[n],team=cell(row,0),full=cell(row,2),tid=names.get(team.toLowerCase())||D().teams.find(x=>String(x.name).trim().toLowerCase()===team.toLowerCase())?.id;if(tid&&full){const doc=cell(row,3),exists=D().players.some(x=>Number(x.team_id)===Number(tid)&&((doc&&String(x.document||'')===doc)||(!doc&&String(x.full_name||'').trim().toLowerCase()===full.toLowerCase())));if(!exists){D().players.push({id:nextId('players'),team_id:tid,number:cell(row,1),full_name:full,document:doc,birth_date:cell(row,4),position:cell(row,5),photo:'',status:cell(row,6)||'Activo'});playersAdded++}}}if(wr)for(let n=1;n<wr.length;n++){const row=wr[n],full=cell(row,0);if(full){const doc=cell(row,1),exists=D().referees.some(x=>(doc&&String(x.document||'')===doc)||(!doc&&String(x.full_name||'').trim().toLowerCase()===full.toLowerCase()));if(!exists){D().referees.push({id:nextId('referees'),full_name:full,document:doc,phone:cell(row,2),category:cell(row,3),availability:'',notes:cell(row,4)});refsAdded++}}}save();return{ok:true,file:r.filePaths[0],teamsAdded,playersAdded,refsAdded,directivesUpdated,sheets:book.SheetNames}});
'@

$pattern = "ipcMain\.handle\('data:importExcel',async\(\)=>\{.*?\}\);\r?\nipcMain\.handle\('backup:json'"
$rx = [regex]::new($pattern,[System.Text.RegularExpressions.RegexOptions]::Singleline)
if (!$rx.IsMatch($main)) { throw "No se encontró data:importExcel para sustituirlo" }
$main = $rx.Replace($main, $newHandler.Trim() + "`r`nipcMain.handle('backup:json'", 1)
Set-Content $mainPath $main -Encoding UTF8

$packagePath = "app-v234/package.json"
$p = Get-Content $packagePath -Raw | ConvertFrom-Json
if (!$p.dependencies) { $p | Add-Member -NotePropertyName dependencies -NotePropertyValue ([pscustomobject]@{}) }
$p.dependencies | Add-Member -NotePropertyName xlsx -NotePropertyValue '^0.18.5' -Force
$p | ConvertTo-Json -Depth 20 | Set-Content $packagePath -Encoding UTF8
