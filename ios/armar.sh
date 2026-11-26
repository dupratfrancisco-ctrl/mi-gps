#!/bin/bash
# Arma el proyecto de Xcode de Mi GPS y lo abre.
set -e
cd "$(dirname "$0")"

if [ ! -d /Applications/Xcode.app ]; then
  echo ""
  echo "⚠️  Falta Xcode. Instalalo desde la App Store, abrilo una vez y volvé a correr este comando."
  open "macappstore://apps.apple.com/app/xcode/id497799835" || true
  exit 1
fi

mkdir -p .tools
if [ ! -x .tools/xcodegen/bin/xcodegen ]; then
  echo "Descargando XcodeGen (herramienta que arma el proyecto)…"
  curl -fsSL https://github.com/yonaskolb/XcodeGen/releases/latest/download/xcodegen.zip -o .tools/xcodegen.zip
  unzip -oq .tools/xcodegen.zip -d .tools
fi

# Recordar el equipo de firma (tu Apple ID) para no tener que elegirlo de nuevo
if [ -f MiGPS.xcodeproj/project.pbxproj ]; then
  T=$(grep -o 'DEVELOPMENT_TEAM = [A-Z0-9]*' MiGPS.xcodeproj/project.pbxproj | head -1 | awk '{print $3}')
  [ -n "$T" ] && echo "$T" > .team
fi
export DEVELOPMENT_TEAM="$(cat .team 2>/dev/null)"

echo "Armando el proyecto…"
.tools/xcodegen/bin/xcodegen generate --quiet
echo "✅ Listo. Abriendo Xcode…"
open MiGPS.xcodeproj
