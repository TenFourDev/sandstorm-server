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
    -Rcon -RconPassword="${RCON_PASSWORD}" -RconListenPort=27506 \
    -MapCycle=MapCycleVanilla.txt -motd=MotdVanilla -Port=27106 -QueryPort=27135 -NoEAC -GameStats \
    -GameStatsToken="${GAME_STATS_TOKEN}" -GSLTToken="${GSLT_TOKEN_VANILLA_EASY}" \
    -hostname="[Ten Four] 8vs40 - Normal / 0.8 (Smoke Limit, Day Only, Waves)"