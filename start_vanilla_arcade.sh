#!/usr/bin/env sh

if [ -f ./.env ]; then
    set -a
    . ./.env
    set +a
fi

cp ./Insurgency/Saved/Config/LinuxServer/_Game.ini ./Insurgency/Saved/Config/LinuxServer/Game.ini
cp ./Insurgency/Saved/Config/LinuxServer/_Engine.ini ./Insurgency/Saved/Config/LinuxServer/Engine.ini

TRAVEL_TO="$(awk -f ./Insurgency/Config/Server/random_map.awk -v maxplayers=8 -v mapfile=./Insurgency/Config/Server/ScenarioMap.txt ./Insurgency/Config/Server/MapCycleVanilla.txt 2>/dev/null)"
if [ -z "$TRAVEL_TO" ]; then
    TRAVEL_TO="Precinct?Scenario=Scenario_Precinct_Checkpoint_Security?Lighting=Day?MaxPlayers=8"
fi

echo "==> Random starting map: $TRAVEL_TO"

Insurgency/Binaries/Linux/InsurgencyServer-Linux-Shipping \
    "$TRAVEL_TO" \
    -Rcon -RconPassword="${RCON_PASSWORD}" -RconListenPort=27507 \
    -MapCycle=MapCycleVanilla.txt -motd=MotdVanillaArcade -Port=27107 -QueryPort=27136 -NoEAC -GameStats \
    -mutators=FullyLoaded,FastMovement \
    -GameStatsToken="${GAME_STATS_TOKEN}" -GSLTToken="${GSLT_TOKEN_VANILLA_ARCADE}" \
    -hostname="[Ten Four] 8vs48 - Arcade (Fast Respawn & Movement, Gun Master, Smoke Limit)"