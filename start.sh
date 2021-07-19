#!/bin/sh

tunnel_to_db () {
    # Open a local tunnel to the environment.
    platform tunnel:close -y
    platform tunnel:open -y
    export PLATFORM_RELATIONSHIPS="$(platform tunnel:info --encode)"
}

# Local.
if [ -z ${PLATFORM_PROJECT_ENTROPY+x} ]; then 
    export MB_JETTY_PORT=${PORT}

    # Database Conection Info
    export MB_DB_TYPE=postgres
    export MB_DB_DBNAME=$(echo $PLATFORM_RELATIONSHIPS | base64 --decode | jq -r ".database[0].path")
    export MB_DB_HOST=$(echo $PLATFORM_RELATIONSHIPS | base64 --decode | jq -r ".database[0].host")
    export MB_DB_PORT=$(echo $PLATFORM_RELATIONSHIPS | base64 --decode | jq -r ".database[0].port")
    export MB_DB_USER=$(echo $PLATFORM_RELATIONSHIPS | base64 --decode | jq -r ".database[0].username")
    export MB_DB_PASS=$(echo $PLATFORM_RELATIONSHIPS | base64 --decode | jq -r ".database[0].password")

    # Limit heap size
    export MEM_AVAILABLE=500
    export JAVA_TOOL_OPTIONS="-Xmx${MEM_AVAILABLE}m -XX:+ExitOnOutOfMemoryError -Xlog:gc*"
    export JAR_FILE=$(pwd)/metabase/metabase.jar
else 
    export JAR_FILE=$PLATFORM_APP_DIR/metabase/metabase.jar
fi

echo $JAR_FILE

java -jar $JAR_FILE