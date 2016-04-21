
local CaptureTaker = class("CaptureTaker")

local TypeChecker        = require("app.utilities.TypeChecker")
local ComponentManager   = require("global.components.ComponentManager")
local GridIndexFunctions = require("app.utilities.GridIndexFunctions")

local EXPORTED_METHODS = {
    "getCurrentCapturePoint",
    "getMaxCapturePoint",
}

--------------------------------------------------------------------------------
-- The util functions.
--------------------------------------------------------------------------------
local function isCapturerMovedAway(selfGridIndex, beginningGridIndex, endingGridIndex)
    return ((GridIndexFunctions.isEqual(selfGridIndex, beginningGridIndex)) and
            (not GridIndexFunctions.isEqual(beginningGridIndex, endingGridIndex)))
end

local function isCapturerDestroyed(selfGridIndex, capturer)
    return ((GridIndexFunctions.isEqual(selfGridIndex, capturer:getGridIndex())) and
            (capturer:getCurrentHP() <= 0))
end

--------------------------------------------------------------------------------
-- The constructor and initializers.
--------------------------------------------------------------------------------
function CaptureTaker:ctor(param)
    self:loadTemplate(param.template)
        :loadInstantialData(param.instantialData)

    return self
end

function CaptureTaker:loadTemplate(template)
    assert(template.maxCapturePoint, "CaptureTaker:loadTemplate() the param template.maxCapturePoint is invalid.")
    self.m_Template = template

    return self
end

function CaptureTaker:loadInstantialData(data)
    assert(data.currentCapturePoint, "CaptureTaker:loadInstantialData() the param data.currentCapturePoint is invalid.")
    self.m_CurrentCapturePoint = data.currentCapturePoint

    return self
end

function CaptureTaker:setRootScriptEventDispatcher(dispatcher)
    self.m_RootScriptEventDispatcher = dispatcher

    return self
end

function CaptureTaker:unsetRootScriptEventDispatcher()
    self.m_RootScriptEventDispatcher = nil

    return self
end

--------------------------------------------------------------------------------
-- The callback functions on ComponentManager.bindComponent()/unbindComponent().
--------------------------------------------------------------------------------
function CaptureTaker:onBind(target)
    assert(self.m_Target == nil, "CaptureTaker:onBind() the component has already bound a target.")

    ComponentManager.setMethods(target, self, EXPORTED_METHODS)
    self.m_Target = target

    return self
end

function CaptureTaker:onUnbind()
    assert(self.m_Target ~= nil, "CaptureTaker:onUnbind() the component has not bound a target.")

    ComponentManager.unsetMethods(self.m_Target, EXPORTED_METHODS)
    self.m_Target = nil

    return self
end

--------------------------------------------------------------------------------
-- The functions for doing the actions.
--------------------------------------------------------------------------------
function CaptureTaker:doActionCapture(action)
    local modelTile       = self.m_Target
    local maxCapturePoint = self:getMaxCapturePoint()
    if ((action.prevTarget) and (modelTile == action.prevTarget)) then
        self.m_CurrentCapturePoint = maxCapturePoint
    else
        self.m_CurrentCapturePoint = math.max(self.m_CurrentCapturePoint - action.capturer:getCaptureAmount(), 0)
        if (self.m_CurrentCapturePoint <= 0) then
            self.m_CurrentCapturePoint = maxCapturePoint
            modelTile:updateWithPlayerIndex(action.capturer:getPlayerIndex())
        end
    end

    return self
end

function CaptureTaker:doActionAttack(action, isAttacker)
    local path = action.path
    local selfGridIndex = self.m_Target:getGridIndex()

    --[[ -- These codes are working but too complicated.
    if (GridIndexFunctions.isEqual(selfGridIndex, beginningGridIndex)) then
        if ((not GridIndexFunctions.isEqual(beginningGridIndex, endingGridIndex)) or
            (action.attacker:getCurrentHP() <= 0)) then
            self.m_CurrentCapturePoint = self:getMaxCapturePoint()
        end
    elseif (GridIndexFunctions.isEqual(selfGridIndex, action.target:getGridIndex())) then
        if ((action.targetType == "unit") and (action.target:getCurrentHP() <= 0)) then
            self.m_CurrentCapturePoint = self:getMaxCapturePoint()
        end
    end
    ]]

    if ((isCapturerMovedAway(selfGridIndex, path[1], path[#path])) or
        (isCapturerDestroyed(selfGridIndex, action.attacker)) or
        ((action.targetType == "unit") and (isCapturerDestroyed(selfGridIndex, action.target)))) then
        self.m_CurrentCapturePoint = self:getMaxCapturePoint()
    end

    return self
end

function CaptureTaker:doActionWait(action)
    local path = action.path
    if (isCapturerMovedAway(self.m_Target:getGridIndex(), path[1], path[#path])) then
        self.m_CurrentCapturePoint = self:getMaxCapturePoint()
    end

    return self
end

--------------------------------------------------------------------------------
-- The exported functions.
--------------------------------------------------------------------------------
function CaptureTaker:getCurrentCapturePoint()
    return self.m_CurrentCapturePoint
end

function CaptureTaker:getMaxCapturePoint()
    return self.m_Template.maxCapturePoint
end

return CaptureTaker
