#!/usr/bin/env sh
set -e

if [ -f ./.env ]; then
    set -a
    . ./.env
    set +a
fi

if [ -z "${PORT:-}" ]; then
    echo "ERROR: PORT environment variable is required." >&2
    exit 1
fi
if [ -z "${QUERY_PORT:-}" ]; then
    echo "ERROR: QUERY_PORT environment variable is required." >&2
    exit 1
fi

echo "==> Applying server config..."
cp ./Insurgency/Saved/Config/LinuxServer/_Game.ini ./Insurgency/Saved/Config/LinuxServer/Game.ini
cp ./Insurgency/Saved/Config/LinuxServer/_Engine.ini ./Insurgency/Saved/Config/LinuxServer/Engine.ini

CONFIG_DIR="./Insurgency/Config/Server"

DEFAULT_MAP="Precinct?Scenario=Scenario_Precinct_Checkpoint_Security?Lighting=Day"
if [ -n "${MAX_PLAYERS:-}" ]; then
    DEFAULT_MAP="$DEFAULT_MAP?MaxPlayers=$MAX_PLAYERS"
fi

cycle_path() {
    if [ -f "$CONFIG_DIR/$1" ]; then
        printf '%s' "$CONFIG_DIR/$1"
    else
        printf '%s' "$1"
    fi
}

pick_random_map() {
    cycle_file="$(cycle_path "$1")"
    awk -f "$CONFIG_DIR/random_map.awk" \
        -v seed=$$ \
        -v maxplayers="${MAX_PLAYERS:-}" \
        -v mapfile="$CONFIG_DIR/ScenarioMap.txt" \
        "$cycle_file" 2>/dev/null || true
}

# Starting map
RANDOM_MAP=""
if [ -n "${MAP_CYCLE:-}" ]; then
    RANDOM_MAP="$(pick_random_map "$MAP_CYCLE")"
fi

START_MAP="${START_MAP:-$RANDOM_MAP}"
if [ -z "$START_MAP" ]; then
    START_MAP="$DEFAULT_MAP"
fi

# Mods
MODS_ENABLED=false
case "${MODS:-false}" in
    1|true|TRUE|True|yes|YES) MODS_ENABLED=true ;;
esac

MOD_DOWNLOAD_TRAVEL_TO=""
if [ "$MODS_ENABLED" = "true" ]; then
    MOD_DOWNLOAD_TRAVEL_TO="${MOD_DOWNLOAD_TRAVEL_TO:-$RANDOM_MAP}"
    if [ -z "$MOD_DOWNLOAD_TRAVEL_TO" ]; then
        MOD_DOWNLOAD_TRAVEL_TO="$START_MAP"
    fi
fi

echo "==> Starting map: $START_MAP"
if [ -n "$MOD_DOWNLOAD_TRAVEL_TO" ]; then
    echo "==> Mod download travel map: $MOD_DOWNLOAD_TRAVEL_TO"
fi

# Build the command
set -- Insurgency/Binaries/Linux/InsurgencyServer-Linux-Shipping
set -- "$@" "$START_MAP"

# Mods + ModDownloadTravelTo
if [ "$MODS_ENABLED" = "true" ]; then
    set -- "$@" -Mods "-ModDownloadTravelTo=$MOD_DOWNLOAD_TRAVEL_TO"
fi

if [ -n "${RCON_PORT:-}" ]; then
    set -- "$@" -Rcon
    if [ -n "${RCON_PASSWORD:-}" ]; then
        set -- "$@" "-RconPassword=$RCON_PASSWORD"
    else
        echo "==> WARNING: RCON_PORT is set but RCON_PASSWORD is empty." >&2
    fi
    set -- "$@" "-RconListenPort=$RCON_PORT"
elif [ -n "${RCON_PASSWORD:-}" ]; then
    echo "==> WARNING: RCON_PASSWORD is set but RCON_PORT is missing; RCON is disabled." >&2
fi

if [ -n "${MAP_CYCLE:-}" ]; then
    set -- "$@" "-MapCycle=$MAP_CYCLE"
fi
if [ -n "${SECURITY_CODE:-}" ]; then
    set -- "$@" "-SecurityCode=$SECURITY_CODE"
fi
if [ -n "${MOTD:-}" ]; then
    set -- "$@" "-motd=$MOTD"
fi

set -- "$@" "-Port=$PORT" "-QueryPort=$QUERY_PORT" -NoEAC -GameStats

if [ -n "${MUTATORS:-}" ]; then
    set -- "$@" "-mutators=$MUTATORS"
fi

if [ -n "${GAME_STATS_TOKEN:-}" ]; then
    set -- "$@" "-GameStatsToken=$GAME_STATS_TOKEN"
else
    echo "==> WARNING: GAME_STATS_TOKEN is not set." >&2
fi
if [ -n "${GSLT_TOKEN:-}" ]; then
    set -- "$@" "-GSLTToken=$GSLT_TOKEN"
else
    echo "==> WARNING: GSLT_TOKEN is not set." >&2
fi

set -- "$@" "-hostname=${SERVER_NAME:-Sandstorm Server}"

if [ -n "${EXTRA_ARGS:-}" ]; then
    set -f
    set -- "$@" $EXTRA_ARGS
    set +f
fi

echo "==> Launching: $*"
exec "$@"
