const fs = require('fs'), path = require('path');
const dir = process.argv[2], sheetFile = process.argv[3], maxRows = Number(process.argv[4] || 40);
const ss = [];
const raw = fs.readFileSync(path.join(dir, 'xl/sharedStrings.xml'), 'utf8');
for (const si of raw.split('<si>').slice(1)) {
  const txt = (si.match(/<t[^>]*>([\s\S]*?)<\/t>/g) || []).map((t) => t.replace(/<[^>]+>/g, '')).join('');
  ss.push(txt.replace(/&amp;/g,'&').replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&quot;/g,'"').replace(/&#39;|&apos;/g,"'"));
}
const sheet = fs.readFileSync(path.join(dir, 'xl', sheetFile), 'utf8');
const rows = sheet.split('<row ').slice(1);
let n = 0;
for (const r of rows) {
  if (n++ >= maxRows) break;
  const cells = {};
  for (const c of r.split('<c ').slice(1)) {
    const ref = (c.match(/r="([A-Z]+)\d+"/) || [])[1];
    const isStr = /t="s"/.test(c);
    const v = (c.match(/<v>([\s\S]*?)<\/v>/) || [])[1];
    const inline = (c.match(/<is>[\s\S]*?<t[^>]*>([\s\S]*?)<\/t>/) || [])[1];
    let val = inline !== undefined ? inline : v;
    if (val !== undefined && isStr) val = ss[Number(val)];
    if (val !== undefined) cells[ref] = String(val).replace(/\s+/g, ' ').trim();
  }
  console.log(JSON.stringify(cells));
}
