#!/bin/bash
# Teste do APK no Android virtual: abre o jogo, toca nas telas e tira fotos (vão para o ramo ci-shots).
mkdir -p shots
adb install -r TurboEstrada.apk
adb logcat -c
adb shell settings put secure immersive_mode_confirmations confirmed
adb shell monkey -p com.claude.turboestrada -c android.intent.category.LAUNCHER 1
sleep 30
n=0
shot(){ n=$((n+1)); adb exec-out screencap -p > "shots/$(printf %02d $n)-$1.png"; }
# toca no texto $1; se não achar, usa a posição $2,$3 (pixels da tela 2340x1080)
tap(){
  adb shell uiautomator dump /sdcard/u.xml >> shots/dump.txt 2>&1; adb pull /sdcard/u.xml u.xml >/dev/null 2>&1
  B=$(grep -o "text=\"$1\"[^>]*bounds=\"\[[0-9]*,[0-9]*\]\[[0-9]*,[0-9]*\]\"" u.xml 2>/dev/null | tail -1 | grep -o '[0-9][0-9]*' | tail -4 | tr '\n' ' ')
  if [ -n "$B" ]; then set -- $B; adb shell input tap $(( ($1+$3)/2 )) $(( ($2+$4)/2 )); echo "achei: $1" >> shots/toques.txt
  else adb shell input tap $2 $3; echo "posição: $1 $2 $3" >> shots/toques.txt; fi
  rm -f u.xml
}
back(){ adb shell input keyevent 4; sleep 2; }
shot inicio
tap "CAMPEONATO" 440 690; sleep 3; shot campeonato
tap "Rota do Sol" 300 300; sleep 9; shot corrida
adb shell input swipe 150 924 150 924 2500; shot virando
sleep 6; shot corrida2
back; shot pausa
tap "SAIR" 1170 660; sleep 3; shot menu
tap "GARAGEM" 650 860; sleep 3; shot garagem
tap "►" 800 220; sleep 2; shot garagem2
back
tap "ONLINE" 250 860; sleep 3; shot online
tap "CRIAR SALA" 580 590; sleep 10; shot sala
back; sleep 2
tap "ESTRADA SEM FIM" 440 800; sleep 14; shot semfim
back; shot pausa2
adb logcat -d > shots/logcat.txt
true
