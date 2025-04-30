CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"
    /usr/local/metastore/bin/schematool -initSchema -dbType mysql
    /usr/local/metastore/bin/start-metastore
else
    echo "-- Not first container startup --"
    /usr/local/metastore/bin/start-metastore
fi