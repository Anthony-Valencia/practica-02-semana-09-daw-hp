#!/usr/bin/env bash
# QA: pruebas HTTP automáticas.  Uso:  bash scripts/pruebas-http.sh php   |   bash scripts/pruebas-http.sh jsp
APP="${1:-php}"
if [ "$APP" = "jsp" ]; then BASE="http://localhost:8080/jsp-app"; EXT="jsp"; else BASE="http://localhost:8000"; EXT="php"; fi
JAR="$(mktemp)"
PASS=0; FAIL=0

check() { # descripcion esperado obtenido
  if [ "$2" = "$3" ]; then echo "  [OK]   $1 -> $3"; PASS=$((PASS+1)); else echo "  [FAIL] $1 -> esperado $2, obtenido $3"; FAIL=$((FAIL+1)); fi
}
code() { curl -s -o /dev/null -w "%{http_code}" -b "$JAR" -c "$JAR" "$@"; }
post() { code -X POST "$@"; }

echo "== Pruebas $APP en $BASE =="
TOKEN="$(curl -s -b "$JAR" -c "$JAR" "$BASE/index.$EXT" | sed -n 's/.*name="csrf" value="\([a-f0-9]*\)".*/\1/p' | head -n1)"
[ -n "$TOKEN" ] && echo "  [OK]   token CSRF obtenido" && PASS=$((PASS+1)) || { echo "  [FAIL] no se obtuvo token CSRF (¿servidor activo?)"; FAIL=$((FAIL+1)); }

EMAIL="ana$RANDOM@correo.com"
echo "-- Método, CSRF y validación"
check "GET procesar.$EXT (método no permitido)" 405 "$(code "$BASE/procesar.$EXT")"
check "POST sin token CSRF"                     403 "$(post --data-urlencode "nombre=Ana" --data-urlencode "correo=$EMAIL" "$BASE/procesar.$EXT")"
check "POST correo inválido"                    422 "$(post --data-urlencode "csrf=$TOKEN" --data-urlencode "nombre=Ana" --data-urlencode "correo=no-es-correo" "$BASE/procesar.$EXT")"
check "POST con intento XSS en nombre"          422 "$(post --data-urlencode "csrf=$TOKEN" --data-urlencode "nombre=<script>alert(1)</script>" --data-urlencode "correo=x@y.com" "$BASE/procesar.$EXT")"
check "POST sin parámetros (con token)"         422 "$(post --data-urlencode "csrf=$TOKEN" "$BASE/procesar.$EXT")"

echo "-- Flujo correcto"
check "POST válido (redirige 303)"              303 "$(post --data-urlencode "csrf=$TOKEN" --data-urlencode "nombre=Ana Pérez" --data-urlencode "correo=$EMAIL" "$BASE/procesar.$EXT")"
check "POST correo duplicado"                   409 "$(post --data-urlencode "csrf=$TOKEN" --data-urlencode "nombre=Ana" --data-urlencode "correo=$EMAIL" "$BASE/procesar.$EXT")"
check "GET registros"                           200 "$(code "$BASE/registros.$EXT")"

echo "-- Escape XSS en la salida (O'Brien)"
check "POST nombre con apóstrofe"               303 "$(post --data-urlencode "csrf=$TOKEN" --data-urlencode "nombre=O'Brien" --data-urlencode "correo=ob$RANDOM@correo.com" "$BASE/procesar.$EXT")"
CUERPO="$(curl -s -b "$JAR" -c "$JAR" "$BASE/registros.$EXT")"
if echo "$CUERPO" | grep -q "O&#039;Brien\|O&#39;Brien"; then echo "  [OK]   apóstrofe escapado en HTML"; PASS=$((PASS+1)); else echo "  [FAIL] apóstrofe sin escapar"; FAIL=$((FAIL+1)); fi

echo "-- Eliminar y errores"
ID="$(echo "$CUERPO" | sed -n 's/.*name="id" value="\([^"]*\)".*/\1/p' | head -n1)"
check "POST eliminar sin token"                 403 "$(post --data-urlencode "id=$ID" "$BASE/eliminar.$EXT")"
check "POST eliminar registro"                  303 "$(post --data-urlencode "csrf=$TOKEN" --data-urlencode "id=$ID" "$BASE/eliminar.$EXT")"
check "Recurso inexistente"                     404 "$(code "$BASE/no-existe")"

echo "-- Cabeceras de seguridad"
CAB="$(curl -s -D - -o /dev/null "$BASE/index.$EXT")"
for h in "X-Content-Type-Options" "Content-Security-Policy" "X-Frame-Options"; do
  if echo "$CAB" | grep -qi "^$h:"; then echo "  [OK]   $h presente"; PASS=$((PASS+1)); else echo "  [FAIL] falta $h"; FAIL=$((FAIL+1)); fi
done

echo "== Cabeceras de una respuesta (ejemplo) =="
echo "$CAB" | head -n 12

rm -f "$JAR"
echo; echo "Resultado: $PASS OK, $FAIL fallidas"
[ "$FAIL" -eq 0 ]
