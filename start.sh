#!/usr/bin/env sh

if [ -f ./.env ]; then
    set -a
    . ./.env
    set +a
fi

cp ./Insurgency/Saved/Config/LinuxServer/_Game.ini ./Insurgency/Saved/Config/LinuxServer/Game.ini
cp ./Insurgency/Saved/Config/LinuxServer/_Engine.ini ./Insurgency/Saved/Config/LinuxServer/Engine.ini

MOD_DOWNLOAD_TRAVEL_TO="$(awk -f ./Insurgency/Config/Server/random_map.awk -v seed=$$ -v maxplayers=8 -v mapfile=./Insurgency/Config/Server/ScenarioMap.txt ./Insurgency/Config/Server/MapCycle.txt 2>/dev/null)"
if [ -z "$MOD_DOWNLOAD_TRAVEL_TO" ]; then
    MOD_DOWNLOAD_TRAVEL_TO="Precinct?Scenario=Scenario_Precinct_Checkpoint_Security?Lighting=Day?MaxPlayers=8?Mutators=Diff7"
fi

echo "==> Random starting map: $MOD_DOWNLOAD_TRAVEL_TO"

Insurgency/Binaries/Linux/InsurgencyServer-Linux-Shipping \
    Tell?Scenario=Scenario_Tell_Survival?Mutators=Diff7?MaxPlayers=8 \
    -ModDownloadTravelTo="$MOD_DOWNLOAD_TRAVEL_TO" \
    -MapCycle=MapCycle.txt -Mods -SecurityCode=none -Port=27102 -QueryPort=27131 -NoEAC -GameStats \
    -mutators=Flashlight_Shadows,MapVoteLabels,AdminCommands,JoinLeaveMessage,PingExt,NoRestrictedArea,StallCounter,ImprovedAI,CapCount,Canoeing,AwardWaves,EnemyBoatSpotted_OldFire,EBSTechnicals \
    -GameStatsToken="${GAME_STATS_TOKEN}" -GSLTToken="${GSLT_TOKEN}" \
    -hostname="[Ten Four] Checkpoint 8vs40 0.8-1.0 (EBS, Waves)"