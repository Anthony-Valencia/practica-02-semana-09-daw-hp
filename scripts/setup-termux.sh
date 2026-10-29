#!/usr/bin/env bash
# Instala PHP, JDK 17, Tomcat 9 y la librería JSTL en Termux.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOMCAT_VERSION="${TOMCAT_VERSION:-9.0.98}"
TOMCAT_DIR="$HOME/tomcat9"

pkg update -y
pkg install -y php openjdk-21 curl git tar

if [ ! -d "$TOMCAT_DIR/bin" ]; then
  echo ">> Descargando Tomcat $TOMCAT_VERSION ..."
  curl -fL -o "$HOME/tomcat.tar.gz" \
    "https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz"
  mkdir -p "$TOMCAT_DIR"
  tar xzf "$HOME/tomcat.tar.gz" --strip-components=1 -C "$TOMCAT_DIR"
  rm -f "$HOME/tomcat.tar.gz"
fi

mkdir -p "$ROOT/jsp-app/WEB-INF/lib"
if [ ! -f "$ROOT/jsp-app/WEB-INF/lib/jstl-1.2.jar" ]; then
  echo ">> Descargando JSTL 1.2 ..."
  curl -fL -o "$ROOT/jsp-app/WEB-INF/lib/jstl-1.2.jar" \
    https://repo1.maven.org/maven2/javax/servlet/jstl/1.2/jstl-1.2.jar
fi

echo
php -v | head -n1
java -version 2>&1 | head -n1
echo "Listo. Usa: bash scripts/run-php.sh  |  bash scripts/run-jsp.sh"
