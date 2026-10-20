#!/bin/bash
# mjgrab.sh <uuid> <n> <outfile>  — full-res frame n of job uuid pulled through Chrome window 1 tab 5 (any logged-in MJ tab)
U="$1"; N="$2"; OUT="$3"
[ -s "$OUT" ] && { echo "have $OUT"; exit 0; }
URL="https://cdn.midjourney.com/$U/0_$N.webp"
K="g_${U:0:8}_$N"
JS1="(()=>{window.__g=window.__g||{};window.__g['$K']='';fetch('$URL').then(r=>r.blob()).then(b=>{const fr=new FileReader();fr.onload=()=>{window.__g['$K']=fr.result.split(',')[1]};fr.readAsDataURL(b)}).catch(e=>{window.__g['$K']='ERR:'+e});return 'started'})()"
osascript -e "tell application \"Google Chrome\" to tell window 1 to tell tab 5 to execute javascript \"$(printf '%s' "$JS1" | sed 's/\\/\\\\/g; s/"/\\"/g')\"" >/dev/null
for i in $(seq 1 40); do
  L=$(osascript -e "tell application \"Google Chrome\" to tell window 1 to tell tab 5 to execute javascript \"(window.__g['$K']||'').length\"")
  [ "${L:-0}" -gt 1000 ] && break; sleep 0.5
done
L=$(osascript -e "tell application \"Google Chrome\" to tell window 1 to tell tab 5 to execute javascript \"(window.__g['$K']||'').length\"")
[ "${L:-0}" -lt 1000 ] && { echo "FAIL $U $N len=$L"; exit 1; }
: > "$OUT.b64"
off=0; while [ $off -lt $L ]; do
  osascript -e "tell application \"Google Chrome\" to tell window 1 to tell tab 5 to execute javascript \"window.__g['$K'].substr($off,400000)\"" | tr -d '\n' >> "$OUT.b64"; off=$((off+400000)); done
base64 -D -i "$OUT.b64" -o "$OUT" && rm "$OUT.b64" && echo "got $OUT $(stat -f %z "$OUT")"
