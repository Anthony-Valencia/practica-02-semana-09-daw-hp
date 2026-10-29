#!/usr/bin/env bash
export CATALINA_HOME="${CATALINA_HOME:-$HOME/tomcat9}"
export JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"
sh "$CATALINA_HOME/bin/catalina.sh" stop
