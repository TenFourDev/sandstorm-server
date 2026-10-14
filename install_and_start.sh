#!/bin/bash
set -e

SERVER_DIR="/home/steam/server"

if [ "${RUN_APP_UPDATE:-}" = "true" ]; then
    echo "==> Checking for Insurgency: Sandstorm server updates..."

    gosu steam steamcmd \
        +force_install_dir "$SERVER_DIR" \
        +login anonymous \
        +app_update 581330 \
        +quit

    echo "==> Insurgency: Sandstorm server is up to date."
fi


echo "==> Starting server..."

cd "$SERVER_DIR"

if [ -n "${TIMERSLACK_MODIO_AFTER:-}" ]; then
(
    sleep "${TIMERSLACK_MODIO_AFTER}"
    echo "==> Timerslack Modio processes"
    sandstorm_modiobackground_pids="$( ps Hh -u "steam"  -o tid,comm | grep ModioBackground | grep --only-matching '[0-9]*' )"
    for pid in ${sandstorm_modiobackground_pids} ; do
        echo "==> ModioBackground PID: ${pid}"
        echo 5000000000 > "/proc/${pid}/timerslack_ns"
    done
) &
fi

exec gosu steam ./start.sh