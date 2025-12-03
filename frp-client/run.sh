#!/usr/bin/env bashio
WAIT_PIDS=()
CONFIG_PATH='/share/frp/frpc.toml'
DEFAULT_CONFIG_PATH='/frpc.toml'

function stop_frpc() {
    bashio::log.info "Shutdown frpc client"
    kill -15 "${WAIT_PIDS[@]}"
}

if [[ ! -f "$CONFIG_PATH" ]]; then
    bashio::log.info "Initializing configuration from template."
    mkdir -p "$(dirname "$CONFIG_PATH")"
    cp "$DEFAULT_CONFIG_PATH" "$CONFIG_PATH"
fi

bashio::log.info "Copying configuration."
mkdir -p /share/frp/log
sed -i "s/serverAddr = \"your_server_addr\"/serverAddr = \"$(bashio::config 'serverAddr')\"/" $CONFIG_PATH
sed -i "s/serverPort = 7000/serverPort = $(bashio::config 'serverPort')/" $CONFIG_PATH
sed -i "s/auth.token = \"123456789\"/auth.token = \"$(bashio::config 'authToken')\"/" $CONFIG_PATH
sed -i "s/webServer.port = 7400/webServer.port = $(bashio::config 'webServerPort')/" $CONFIG_PATH
sed -i "s/webServer.user = \"admin\"/webServer.user = \"$(bashio::config 'webServerUser')\"/" $CONFIG_PATH
sed -i "s/webServer.password = \"123456789\"/webServer.password = \"$(bashio::config 'webServerPassword')\"/" $CONFIG_PATH
sed -i "s/customDomains = \[\"your_domain\"\]/customDomains = [\"$(bashio::config 'customDomain')\"]/" $CONFIG_PATH
sed -i "s/name = \"your_proxy_name\"/name = \"$(bashio::config 'proxyName')\"/" $CONFIG_PATH

WEB_PORT=$(bashio::config 'webServerPort')
INGRESS_PORT=$(bashio::addon.ingress_port)

if [[ "${WEB_PORT}" != "${INGRESS_PORT}" ]]; then
    bashio::log.warning "webServerPort (${WEB_PORT}) differs from ingress_port (${INGRESS_PORT}); the sidebar link will use port ${INGRESS_PORT}."
fi


bashio::log.info "Starting frp client"

cat $CONFIG_PATH

cd /usr/src
./frpc -c $CONFIG_PATH & WAIT_PIDS+=($!)

tail -f /share/frp/log/frpc.log &

trap "stop_frpc" SIGTERM SIGHUP
wait "${WAIT_PIDS[@]}"
