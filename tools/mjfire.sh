#!/bin/bash
# mjfire.sh "<prompt>" — native-setter + Enter into the /imagine textarea of Chrome window 1 tab 7, via AppleScript (base64-shuttled so quoting never bites)
P="$1"
B=$(printf '%s' "$P" | base64 | tr -d '\n')
JS="(()=>{const p=decodeURIComponent(escape(atob('$B')));const ta=document.querySelector('textarea');if(!ta)return 'NO TEXTAREA';const s=Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype,'value').set;ta.focus();s.call(ta,p);ta.dispatchEvent(new Event('input',{bubbles:true}));ta.dispatchEvent(new KeyboardEvent('keydown',{key:'Enter',code:'Enter',keyCode:13,which:13,bubbles:true,cancelable:true}));return 'fired:'+ta.value.length;})()"
osascript -e "tell application \"Google Chrome\" to tell window 1 to tell tab 7 to execute javascript \"$(printf '%s' "$JS" | sed 's/\\/\\\\/g; s/"/\\"/g')\""
