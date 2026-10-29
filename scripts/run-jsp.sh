#!/usr/bin/env bash
# Despliega jsp-app en Tomcat -> http://localhost:8080/jsp-app/
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export CATALINA_HOME="${CATALINA_HOME:-$HOME/tomcat9}"
export JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"

[ -d "$CATALINA_HOME/bin" ] || { echo "Tomcat no instalado. Ejecuta: bash scripts/setup-termux.sh"; exit 1; }
[ -f "$ROOT/jsp-app/WEB-INF/lib/jstl-1.2.jar" ] || { echo "Falta JSTL. Ejecuta: bash scripts/setup-termux.sh"; exit 1; }

rm -rf "$CATALINA_HOME/webapps/jsp-app"
cp -r "$ROOT/jsp-app" "$CATALINA_HOME/webapps/jsp-app"

sh "$CATALINA_HOME/bin/catalina.sh" start
echo "Esperando a Tomcat (10-20 s)... abre http://localhost:8080/jsp-app/"
sleep 3
tail -f "$CATALINA_HOME/logs/catalina.out"
