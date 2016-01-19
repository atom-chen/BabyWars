
local ViewTileMap = class("ViewTileMap", function()
	return display.newNode()
end)

function ViewTileMap:ctor(param)
	if (param) then self:load(param) end
	
	return self
end

function ViewTileMap:load(param)
	return self
end

function ViewTileMap.createInstance(param)
	local view = ViewTileMap.new():load(param)
	assert(view, "ViewTileMap.createInstance() failed.")

	return view
end

return ViewTileMap
