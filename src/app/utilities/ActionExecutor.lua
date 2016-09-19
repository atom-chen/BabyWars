
local ActionExecutor = {}

local GameConstantFunctions = require("src.app.utilities.GameConstantFunctions")
local LocalizationFunctions = require("src.app.utilities.LocalizationFunctions")
local SingletonGetters      = require("src.app.utilities.SingletonGetters")
local Actor                 = require("src.global.actors.Actor")

local IS_SERVER             = GameConstantFunctions.isServer()
local WebSocketManager      = (not IS_SERVER) and (require("src.app.utilities.WebSocketManager")) or (nil)
local ActorManager          = (not IS_SERVER) and (require("src.global.actors.ActorManager"))     or (nil)

local getLocalizedText         = LocalizationFunctions.getLocalizedText
local getModelMessageIndicator = SingletonGetters.getModelMessageIndicator
local getModelTileMap          = SingletonGetters.getModelTileMap
local getModelUnitMap          = SingletonGetters.getModelUnitMap
local getSceneWarFileName      = SingletonGetters.getSceneWarFileName
local getScriptEventDispatcher = SingletonGetters.getScriptEventDispatcher

--------------------------------------------------------------------------------
-- The util functions.
--------------------------------------------------------------------------------
local function runSceneMain(modelSceneMainParam, playerAccount, playerPassword)
    assert(not IS_SERVER, "ActionExecutor-runSceneMain() the main scene can't be run on the server.")

    local modelSceneMain = Actor.createModel("sceneMain.ModelSceneMain", modelSceneMainParam)
    local viewSceneMain  = Actor.createView( "sceneMain.ViewSceneMain")

    WebSocketManager.setLoggedInAccountAndPassword(playerAccount, playerPassword)
    ActorManager.setAndRunRootActor(Actor.createWithModelAndViewInstance(modelSceneMain, viewSceneMain), "FADE", 1)
end

local function requestReloadSceneWar(message)
    assert(not IS_SERVER, "ActionExecutor-requestReloadSceneWar() the server shouldn't request reload.")

    getModelMessageIndicator():showMessage(message or "")
        :showPersistentMessage(getLocalizedText(80, "TransferingData"))
    getScriptEventDispatcher():dispatchEvent({
        name    = "EvtIsWaitingForServerResponse",
        waiting = true,
    })

    WebSocketManager.sendAction({
        actionName = "GetSceneWarData",
        fileName   = getSceneWarFileName(),
    })
end

local function moveModelUnitWithAction(action)
    local path       = action.path
    local pathLength = #path

    if (pathLength > 1) then
        local sceneWarFileName   = action.fileName
        local modelUnitMap       = getModelUnitMap(sceneWarFileName)
        local beginningGridIndex = path[1]
        local endingGridIndex    = path[pathLength]
        local launchUnitID       = action.launchUnitID
        local focusModelUnit     = modelUnitMap:getFocusModelUnit(beginningGridIndex, launchUnitID)

        if (focusModelUnit.setCapturingModelTile) then
            focusModelUnit:setCapturingModelTile(false)
        end
        if (focusModelUnit.setCurrentFuel) then
            focusModelUnit:setCurrentFuel(focusModelUnit:getCurrentFuel() - path.fuelConsumption)
        end
        if (focusModelUnit.setBuildingModelTile) then
            focusModelUnit:setBuildingModelTile(false)
        end
        if (focusModelUnit.getLoadUnitIdList) then
            for _, loadedModelUnit in pairs(modelUnitMap:getLoadedModelUnitsWithLoader(focusModelUnit, true)) do
                loadedModelUnit:setGridIndex(endingGridIndex, false)
            end
        end

        focusModelUnit:setGridIndex(endingGridIndex, false)
        if (launchUnitID) then
            modelUnitMap:getModelUnit(beginningGridIndex):removeLoadUnitId(launchUnitID)
                :updateView()
                :showNormalAnimation()
            modelUnitMap:setActorUnitUnloaded(launchUnitID, endingGridIndex)
        else
            modelUnitMap:swapActorUnit(beginningGridIndex, endingGridIndex)

            local modelTile = getModelTileMap(sceneWarFileName):getModelTile(beginningGridIndex)
            if (modelTile.setCurrentBuildPoint) then
                modelTile:setCurrentBuildPoint(modelTile:getMaxBuildPoint())
            end
            if (modelTile.setCurrentCapturePoint) then
                modelTile:setCurrentCapturePoint(modelTile:getMaxCapturePoint())
            end
        end
    end
end

--------------------------------------------------------------------------------
-- The private executors.
--------------------------------------------------------------------------------
local function executeLogout(action)
    if (not IS_SERVER) then
        runSceneMain({confirmText = action.message})
    end
end

local function executeMessage(action)
    if (not IS_SERVER) then
        getModelMessageIndicator():showMessage(action.message)
    end
end

local function executeError(action)
    if (not IS_SERVER) then
        error("ActionExecutor-executeError() " .. (action.error or ""))
    end
end

local function executeRunSceneMain(action)
    if (not IS_SERVER) then
        local param = {
            isPlayerLoggedIn = true,
            confirmText      = action.message,
        }
        runSceneMain(param, WebSocketManager.getLoggedInAccountAndPassword())
    end
end

local function executeGetSceneWarData(action)
    if (not IS_SERVER) then
        if (action.message) then
            getModelMessageIndicator():showPersistentMessage(action.message)
        end

        local actorSceneWar = Actor.createWithModelAndViewName("sceneWar.ModelSceneWar", action.data, "sceneWar.ViewSceneWar")
        ActorManager.setAndRunRootActor(actorSceneWar, "FADE", 1)
    end
end

local function executeReloadCurrentScene(action)
    if (not IS_SERVER) then
        requestReloadSceneWar(action.message)
    end
end

local function executeWait(action)
    local path           = action.path
    local focusModelUnit = getModelUnitMap(action.fileName):getFocusModelUnit(path[1], action.launchUnitID)
    moveModelUnitWithAction(action)

    focusModelUnit:setStateActioned()
        :moveViewAlongPath(path, function()
            focusModelUnit:updateView()
                :showNormalAnimation()
        end)
end

--------------------------------------------------------------------------------
-- The public function.
--------------------------------------------------------------------------------
function ActionExecutor.execute(action)
    local modelSceneWar = SingletonGetters.getModelScene(action.fileName)
    if ((not modelSceneWar) or (not modelSceneWar.getModelWarField)) then
        return
    end

    local actionName = action.actionName
    if     (actionName == "Logout")             then return executeLogout(            action)
    elseif (actionName == "Message")            then return executeMessage(           action)
    elseif (actionName == "Error")              then return executeError(             action)
    elseif (actionName == "RunSceneMain")       then return executeRunSceneMain(      action)
    elseif (actionName == "GetSceneWarData")    then return executeGetSceneWarData(   action)
    elseif (actionName == "ReloadCurrentScene") then return executeReloadCurrentScene(action)
    end

    local actionID = action.actionID
    if (actionID ~= modelSceneWar:getActionId() + 1) then
        assert(not IS_SERVER, "ActionExecutor.execute() the actionID is invalid on the server: " .. (actionID or ""))
        getModelMessageIndicator():showPersistentMessage(getLocalizedText(81, "OutOfSync"))
        requestReloadSceneWar()
        return
    end
    modelSceneWar:setActionId(actionID)

    if (actionName == "Wait") then executeWait(action)
    end

    if (not IS_SERVER) then
        getModelMessageIndicator():hidePersistentMessage(getLocalizedText(80, "TransferingData"))
        getScriptEventDispatcher():dispatchEvent({
                name    = "EvtIsWaitingForServerResponse",
                waiting = false,
            })
            :dispatchEvent({name = "EvtModelTileMapUpdated"})
            :dispatchEvent({name = "EvtModelUnitMapUpdated"})
    end
end

return ActionExecutor
