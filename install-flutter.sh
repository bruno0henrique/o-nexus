#!/bin/bash
# ──────────────────────────────────────────────
# install-flutter.sh
# Baixa o Flutter SDK (canal stable) e builda o
# projeto para Flutter Web (usado pela Vercel).
# ──────────────────────────────────────────────
set -e

FLUTTER_DIR="$HOME/flutter"

echo "==> Buscando release estável mais recente do Flutter..."
RELEASES_JSON=$(curl -fsSL \
  "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json")

ARCHIVE=$(echo "$RELEASES_JSON" | python3 - <<'EOF'
import json, sys
data = json.load(sys.stdin)
stable_hash = data["current_release"]["stable"]
for r in data["releases"]:
    if r["hash"] == stable_hash:
        print(r["archive"])
        break
EOF
)

echo "==> Baixando Flutter: $ARCHIVE"
curl -fsSLo flutter.tar.xz \
  "https://storage.googleapis.com/flutter_infra_release/releases/$ARCHIVE"

echo "==> Extraindo Flutter SDK..."
tar -xf flutter.tar.xz -C "$HOME"
rm flutter.tar.xz

export PATH="$PATH:$FLUTTER_DIR/bin"

echo "==> Versão do Flutter:"
flutter --version --no-version-check

echo "==> Habilitando suporte a Web..."
flutter config --enable-web --no-analytics

echo "==> Instalando dependências..."
flutter pub get

echo "==> Buildando para Flutter Web (CanvasKit)..."
flutter build web --release --web-renderer canvaskit \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

echo "==> Build concluído! Saída em: build/web"
