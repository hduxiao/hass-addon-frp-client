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

bashio::log.info "Using configuration file at ${CONFIG_PATH}."
mkdir -p /share/frp/log

bashio::log.info "Starting frp client"

cat $CONFIG_PATH

cd /usr/src
./frpc -c $CONFIG_PATH & WAIT_PIDS+=($!)

tail -f /share/frp/log/frpc.log &

trap "stop_frpc" SIGTERM SIGHUP
wait "${WAIT_PIDS[@]}"
