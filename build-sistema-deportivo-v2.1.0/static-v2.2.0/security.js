const crypto=require('crypto'),os=require('os');const {execFileSync}=require('child_process');
const PUBLIC_KEY=`-----BEGIN PUBLIC KEY-----
MCowBQYDK2VwAyEAkHGdCqHSIacmxI0MqnzHhqczs3gDt25iRl8gJ00Agc0=
-----END PUBLIC KEY-----
`;
function rawMachineId(){if(process.platform==='win32'){try{const out=execFileSync('reg',['query','HKLM\\SOFTWARE\\Microsoft\\Cryptography','/v','MachineGuid'],{encoding:'utf8',windowsHide:true});const m=out.match(/MachineGuid\s+REG_SZ\s+([^\r\n]+)/i);if(m)return m[1].trim()}catch{}}const cpus=os.cpus()||[];return[os.hostname(),os.platform(),os.arch(),cpus[0]?.model||''].join('|')}
function stableMachineCode(){return crypto.createHash('sha256').update(rawMachineId()).digest('hex').slice(0,24).toUpperCase()}
function canonicalPayload(o){return JSON.stringify(o)}
function verifyLicense(license){try{const {signature,...payload}=license||{};if(!signature||!payload.licenseId||!payload.holder)return{ok:false,reason:'Licencia incompleta'};if(!['GESTOR_FUTBOL7','SISTEMA_DEPORTIVO_F7'].includes(payload.product))return{ok:false,reason:'Licencia de otro producto'};const ok=crypto.verify(null,Buffer.from(canonicalPayload(payload)),PUBLIC_KEY,Buffer.from(signature,'base64'));if(!ok)return{ok:false,reason:'Firma digital no válida'};if(payload.machineCode&&payload.machineCode!==stableMachineCode())return{ok:false,reason:'Esta licencia pertenece a otro dispositivo'};return{ok:true,payload}}catch{return{ok:false,reason:'Licencia dañada'}}}
function hashPassword(password,salt){return crypto.scryptSync(String(password),salt,64).toString('hex')}
module.exports={PUBLIC_KEY,stableMachineCode,verifyLicense,hashPassword,canonicalPayload};
