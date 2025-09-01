#!/bin/bash
set -e

TEMPLATES=(angular react nextjs fastapi django wordpress)

echo "🟢 Enter project name (short):"
read NAME

echo "🌐 Enter domain (e.g. blog.example.org):"
read DOMAIN

echo "🔧 Choose stack:"
select stack in "${TEMPLATES[@]}"; do
  TYPE=$stack
  break
done

SRC="./templates/$TYPE"
DST="./apps/$NAME"

if [ -d "$DST" ]; then
  echo "❌ Project already exists!"
  exit 1
fi

cp -r "$SRC" "$DST"

echo "✅ Project '$NAME' created with domain '$DOMAIN' using stack '$TYPE'"

echo
echo "🔧 Paste into docker-compose.yml:"
echo
cat <<EOF
  $NAME:
    build: ./apps/$NAME
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.$NAME.rule=Host(\`$DOMAIN\`)"
      - "traefik.http.routers.$NAME.entrypoints=websecure"
      - "traefik.http.routers.$NAME.tls.certresolver=myresolver"
    networks:
      - web
EOF
