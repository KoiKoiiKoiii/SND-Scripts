--[[

  ****************************************
  *          Cosmic Exploration          *
  *            Fishing Script            *
  ****************************************

  ***********
  * Version *
  *  0.0.1  *
  ***********

  ***************
  * Description *
  ***************

  This is meant to be used for fishing in Cosmic Exploration.
  It will automatically extract materia and process the fishing mission when you're in the right zone, and on the right mission.

  *********************
  *  Required Plugins *
  *********************


  Plugins that are used are:
  -> Ferret's Library : https://github.com/OhKannaDuh/Ferret/
  -> Something Need Doing [Expanded Edition] : https://puni.sh/api/repository/croizat
  -> AutoHook
    -> You'll need presets named after the mission names in the ToDoList table.
    -> The script will automatically set the preset for you when you start the mission.
  -> Ice's Cosmic Exploration
    -> Make sure 'Only Grab Mission' is enabled in the Mission Settings.
]]

--[[

  **************
  *  Settings  *
  **************
  ]]

local ToDoList = {
    { missionName = "A-1: Aquatic Inspection I" },
}

--[[

  ************
  *  Script  *
  *   Start  *
  ************

]]

require("Ferret/Library")
FerretCore = require('Ferret/FerretCore')
require('Ferret/CosmicExploration/Library')

Ferret = FerretCore("Koi's Test")



function isMissionInToDoList(mission)
    for _, todo in ipairs(ToDoList) do
        if todo.missionName == mission then
            return true
        end
    end
    return false
end

function MateriaExtract()
    if CanExtractMateria(100) then
        yield("/generalaction \"Materia Extraction\"")
        yield("/waitaddon Materialize")

        while CanExtractMateria(100) == true do
            yield("/callback Materialize true 2 0")
            yield("/wait 0.5")
            if IsAddonVisible("MaterializeDialog") then
                yield("/callback MaterializeDialog true 0")
            end
            while GetCharacterCondition(39) do
                yield("/wait 3")
            end
            yield("/wait 2")
        end

        yield("/wait 1")
        yield("/callback Materialize true -1")
    end
end

Addons.WKSMissionInfomation:graceful_open()

function getMission()
    return Addons.WKSMissionInfomation:get_node_text(29)
end

MateriaExtract()

-- Variable to track if mission actions have been executed
local missionExecuted = false

while true do
    local mission = getMission()

    -- Wait until player starts a mission (mission ~= 29)
    while mission == 29 do
        yield("/wait 1")
        mission = getMission()
    end

    -- Stay in mission until it ends (mission == 29 again)
    while mission ~= 29 do
        mission = getMission()
        if isMissionInToDoList(mission) and not missionExecuted then
            MateriaExtract()
            yield("/ahpreset " .. mission)
            yield("/wait 0.4")
            yield("/ahon")
            yield("/ahstart")
            missionExecuted = true
        end
        yield("/wait 0.5")
    end

    missionExecuted = false

end
