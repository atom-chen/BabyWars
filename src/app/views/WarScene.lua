
local WarScene = class("WarScene", function()
	return display.newScene()
end)
local Requirer			= require"app.utilities.Requirer"
local Actor				= Requirer.actor()
local ViewWarField		= Requirer.view("ViewWarField")
local ModelWarField		= Requirer.model("ModelWarField")
local TypeChecker		= Requirer.utility("TypeChecker")
local ComponentManager	= Requirer.component("ComponentManager")

local function requireSceneData(param)
	local t = type(param)
	if (t == "table") then
		return param
	elseif (t == "string") then
		return Requirer.templateWarScene(param)
	else
		return nil
	end
end

local function createWarFieldActor(warFieldData)
	local view = ViewWarField.createInstance(warFieldData)
	assert(view, "WarScene--createWarFieldActor() failed to create a ViewWarField.")

	ComponentManager.bindComponent(view, "DraggableWithinBoundary")
	view:setDragBoundaryRect({x = 10, y = 10, width = display.width - 60, height = display.height - 10})
	
	local model = ModelWarField.createInstance(warFieldData)
	assert(model, "WarScene--createWarFieldActor() failed to create a ModelWarField.")

	return Actor.createWithModelAndViewInstance(model, view)
end

local function createChildrenActors(param)
	local sceneData = requireSceneData(param)
	assert(TypeChecker.isWarSceneData(sceneData))

	local warFieldActor = createWarFieldActor(sceneData.WarField)
	assert(warFieldActor, "WarScene--createChildrenActors() failed to create WarField actor.")

	return {WarFieldActor = warFieldActor}	
end

function WarScene:ctor(param)
	if (param) then self:load(param) end
	
	return self
end

function WarScene:load(param)
	local actorsInScene = createChildrenActors(param)
	assert(actorsInScene, "WarScene:load() failed to create actors in scene with param.")
	
	local warFieldActor = actorsInScene.WarFieldActor

	self.m_ViewWarFieldActor_ = warFieldActor
	self:removeAllChildren()
		:addChild(warFieldActor:getView())
		
	return self
end

function WarScene.createInstance(param)
	local warScene = WarScene.new():load(param)
	assert(warScene, "WarScene.createInstance() failed.")
	
	return warScene
end

return WarScene
