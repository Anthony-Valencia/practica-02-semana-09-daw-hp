#!/usr/bin/env bash
# QA: pruebas HTTP automáticas.  Uso:  bash scripts/pruebas-http.sh php   |   bash scripts/pruebas-http.sh jsp
APP="${1:-php}"
if [ "$APP" = "jsp" ]; then BASE="http://localhost:8080/jsp-app"; EXT="jsp"; else BASE="http://localhost:8000"; EXT="php"; fi
JAR="$(mktemp)"
PASS=0; FAIL=0

check() { # descripcion esperado obtenido
  if [ "$2" = "$3" ]; then echo "  [OK]   $1 -> $3"; PASS=$((PASS+1)); else echo "  [FAIL] $1 -> esperado $2, obtenido $3"; FAIL=$((FAIL+1)); fi
}
code() { curl -s -o /dev/null -w "%{http_code}" "$@"; }

echo "== Pruebas $APP en $BASE =="
check "GET procesar.$EXT (método no permitido)" 405 "$(code "$BASE/procesar.$EXT")"
check "POST válido"                              200 "$(code -c "$JAR" -b "$JAR" -X POST --data-urlencode "nombre=Ana Pérez" --data-urlencode "correo=ana@correo.com" "$BASE/procesar.$EXT")"
check "POST correo inválido"                     422 "$(code -X POST --data-urlencode "nombre=Ana" --data-urlencode "correo=no-es-correo" "$BASE/procesar.$EXT")"
check "POST con intento XSS en nombre"           422 "$(code -X POST --data-urlencode "nombre=<script>alert(1)</script>" --data-urlencode "correo=x@y.com" "$BASE/procesar.$EXT")"
check "POST sin parámetros"                      422 "$(code -X POST "$BASE/procesar.$EXT")"
check "Recurso inexistente"                      404 "$(code "$BASE/no-existe")"

echo "== Escape de caracteres especiales (O'Brien) =="
CUERPO="$(curl -s -c "$JAR" -b "$JAR" -X POST --data-urlencode "nombre=O'Brien" --data-urlencode "correo=ob@correo.com" "$BASE/procesar.$EXT")"
if echo "$CUERPO" | grep -q "O&#039;Brien\|O&#39;Brien"; then echo "  [OK]   apóstrofe escapado en HTML"; PASS=$((PASS+1)); else echo "  [FAIL] apóstrofe sin escapar"; FAIL=$((FAIL+1)); fi

echo "== Cabeceras de la respuesta (ejemplo) =="
curl -s -i -X POST --data-urlencode "nombre=Luis" --data-urlencode "correo=luis@correo.com" "$BASE/procesar.$EXT" | head -n 12

rm -f "$JAR"
echo; echo "Resultado: $PASS OK, $FAIL fallidas"
[ "$FAIL" -eq 0 ]
