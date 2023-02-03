#!/bin/bash
set -e

if [[ ! -t 0 ]]; then
    /bin/bash /etc/banner.sh
fi

NODE_USER="node"
NODE_HOME=$(eval echo ~$NODE_USER)

NODE_HOME="/vue"


DEVID=$(id -u "$NODE_USER")
if [ "$DEVID" != "$CURRENT_UID" ]; then
    echo "Fixing uid of user ${NODE_USER} from $DEVID to $CURRENT_UID..."
    usermod -u "$CURRENT_UID" "$NODE_USER"
fi

GROUPID=$(id -g $NODE_USER)
if [ "$GROUPID" != "$CURRENT_GID" ]; then
    echo "Fixing gid of user $NODE_USER from $GROUPID to $CURRENT_GID..."
    groupmod -og "$CURRENT_GID" "$NODE_USER"
fi


echo "Running in $(pwd) as ${NODE_USER} (uid $(id -u ${NODE_USER}))"


# Defaults
if [ -z APP_MODE ]; then
    APP_MODE="development"
fi

run_as_node() {
    HOME="${NODE_HOME}" su -p "${NODE_USER}" -c "${1}"
}

if [ "$APP_MODE" == "test" ]; then
    export BACKEND_HOST=${CYPRESS_BACKEND_HOST}
fi


echo "checking..."
if [[ ! -f "/vue-src" ]]; then
    rsync /vue /vue-src
else
    if [[ ! -f "/vue-src/package.json" ]]; then
        rsync /vue /vue-src
    fi    
fi    
if [[ -f "/vue-src/package.json" ]]; then
    NODE_HOME="/vue-src"
else
    NODE_HOME="/vue"
fi  
# https://github.com/yarnpkg/berry/tree/master/packages/plugin-typescript#yarnpkgplugin-typescript
# run_as_node "yarn plugin import typescript"

cd ${NODE_HOME}     
chown -R node ${NODE_HOME}
chmod u+w ${NODE_HOME}


if [ "$APP_MODE" == "production" ]; then

    if [[ -z $FRONTEND_URL ]];
    then
        FRONTEND_URL="https://${BASE_HREF}${FRONTEND_PREFIX}"
    elif [[ $FRONTEND_URL != */ ]];
    then
        FRONTEND_URL="${FRONTEND_URL}/"
    fi
    echo "Building in $(pwd) as $(whoami)..."
    run_as_node "yarn install"
    run_as_node "yarn build"    
    echo "Build finished !"
    

elif [ "$APP_MODE" == "development" ]; then
    
    run_as_node "yarn install"
    run_as_node "yarn serve"


elif [ "$APP_MODE" == "test" ]; then

    sleep infinity

else
    echo "Unknown APP_MODE: ${APP_MODE}"
fi

