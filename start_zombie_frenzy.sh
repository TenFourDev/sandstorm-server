#!/usr/bin/env sh

if [ -f ./.env ]; then
    set -a
    . ./.env
    set +a
fi

cp ./Insurgency/Saved/Config/LinuxServer/_Game.ini ./Insurgency/Saved/Config/LinuxServer/Game.ini
cp ./Insurgency/Saved/Config/LinuxServer/_Engine.ini ./Insurgency/Saved/Config/LinuxServer/Engine.ini

MOD_DOWNLOAD_TRAVEL_TO="$(awk -f ./Insurgency/Config/Server/random_map.awk -v maxplayers=5 -v mapfile=./Insurgency/Config/Server/ScenarioMap.txt ./Insurgency/Config/Server/MapCycleZombie.txt 2>/dev/null)"
if [ -z "$MOD_DOWNLOAD_TRAVEL_TO" ]; then
    MOD_DOWNLOAD_TRAVEL_TO="Precinct?Scenario=Scenario_Precinct_Checkpoint_Security?Lighting=Night?MaxPlayers=5?Mutators=Mid"
fi

echo "==> Random starting map: $MOD_DOWNLOAD_TRAVEL_TO"

Insurgency/Binaries/Linux/InsurgencyServer-Linux-Shipping \
    Tell?Scenario=Scenario_Tell_Survival?Lighting=Night?MaxPlayers=5 \
    -ModDownloadTravelTo="$MOD_DOWNLOAD_TRAVEL_TO" \
    -MapCycle=MapCycleZombie.txt -SecurityCode=none -motd=MotdZombieFrenzy -Mods -Port=27104 -QueryPort=27133 -NoEAC -GameStats \
    -mutators=Flashlight_Shadows,MapVoteLabels,MoreAmmoPlus,MoreAmmo,FullyLoaded,AdminCommands,JoinLeaveMessage,PingExt,StallCounter,ImprovedAI_2,Reloads,Bolts,Quickdraw,ZombiesLiteRegular,CapCount,Canoeing,AwardWaves,Healthy,healthmodifier,FastMovement \
    -GameStatsToken="${GAME_STATS_TOKEN}" -GSLTToken="${GSLT_TOKEN_ZOMBIE_FRENZY}" \
    -hostname="[Ten Four] Zombie Frenzy 4vs128 (Gun Master, Waves)"