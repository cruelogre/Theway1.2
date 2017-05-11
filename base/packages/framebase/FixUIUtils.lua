--[[
@brief:功能函数类
@by 李俊
]]

local FixUIUtils = {}
--[[local BUI = bf.UIManager:getInstance()--]]
---自定义Cocos Studio屏幕像素
local designSize = cc.size(CC_DESIGN_RESOLUTION.width, CC_DESIGN_RESOLUTION.height)
local screenSize = cc.Director:getInstance():getWinSize()
local widthScale = screenSize.width/designSize.width
local heightScale = screenSize.height/designSize.height
local minScale = math.min(screenSize.height/designSize.height,screenSize.width/designSize.width)
local maxScale = math.max(screenSize.height/designSize.height,screenSize.width/designSize.width)
local offsetHeight=(screenSize.height*0.5-designSize.height*0.5)/heightScale
--屏幕宽、高分别和设计分辨率宽、高计算缩放因子，取较(小)者作为宽、高的缩放因子。
--适用于控件的缩放
function FixUIUtils.setScaleMin(node)
	local layout = node:getComponent("__ui_layout")
	
	--layout:setSize({width = 335.0000, height = 108.0000})
	if layout then
		local percentX = layout:getPositionPercentX()
		local percentY = layout:getPositionPercentY()
		layout:setPositionPercentXEnabled(true)
		layout:setPositionPercentYEnabled(true)
		layout:setPositionPercentX(percentX*widthScale)
		layout:setPositionPercentY(percentY*heightScale)
		
		if iskindof(node,"ccui.Widget") then
			local p_heght = layout:getPercentHeight()
			local p_width = layout:getPercentWidth()
			--layout:setStretchHeightEnabled(true)
			--layout:setStretchWidthEnabled(true)
			--layout:setPercentHeight(p_heght*heightScale)
			--layout:setPercentWidth(p_width*widthScale)
			
		end
		layout:refreshLayout()
	end
	
    local nodeX = node:getScaleX()
    local nodeY = node:getScaleY()
    nodeX = nodeX*minScale
    nodeY = nodeY*minScale
    node:setScaleX(nodeX) 
    node:setScaleY(nodeY) 
end

--屏幕宽、高分别和设计分辨率宽、高计算缩放因子，取较(大)者作为宽、高的缩放因子。
--适用于背景的缩放
function FixUIUtils.setScaleMax(node)
	local layout = node:getComponent("__ui_layout")
	
	--layout:setSize({width = 335.0000, height = 108.0000})
	if layout then
		local percentX = layout:getPositionPercentX()
		local percentY = layout:getPositionPercentY()
		layout:setPositionPercentXEnabled(true)
		layout:setPositionPercentYEnabled(true)
		layout:setPositionPercentX(percentX*widthScale)
		layout:setPositionPercentY(percentY*heightScale)
		
		if iskindof(node,"ccui.Widget") then
			
		end
		layout:refreshLayout()
	end
	
    local nodeX = node:getScaleX()
    local nodeY = node:getScaleY()
    nodeX = nodeX*maxScale
    nodeY = nodeY*maxScale
    node:setScaleX(nodeX) 
    node:setScaleY(nodeY) 
end

--[[function FixUIUtils.setRootNodewithFIXED()
    local moveX = (designSize.width-screenSize.width)/2
    local moveY = (designSize.height-screenSize.height)/2
    BUI:getSceneRoot():setPosition(cc.p(-moveX ,-moveY))
end

function FixUIUtils.fixScene() 
    local node = BUI:getSceneRoot()
    local ChildrenList = node:getChildren()
    for _,child in pairs(ChildrenList) do
        local name = child:getName()
        if(name=="SceneBack") then
            FixUIUtils.setScaleMax(child)
        else
            FixUIUtils.setScaleMin(child)
        end
    end
    FixUIUtils.setRootNodewithFIXED()
end--]]
--修正界面坐标，全屏界面，修正所有子节点位置
function FixUIUtils.fixUI(node)
	
    local ChildrenList = node:getChildren()
    for _,child in pairs(ChildrenList) do
		FixUIUtils.setScaleMin(child)
		
    end
end
function FixUIUtils.stretchUI(node)
	local layout = node:getComponent("__ui_layout")
	
		--layout:setSize({width = 335.0000, height = 108.0000})
	if layout then
		local size = layout:getSize()
		size.width = size.width*widthScale
		size.height = size.height*heightScale
		layout:setSize(size)
		
		layout:refreshLayout()
		node:setContentSize(size)
	end

end


--修正根节点坐标，非全屏界面，只修正位置
function FixUIUtils.setRootNodewithFIXED(node)
	local moveX = (designSize.width-screenSize.width)/2
    local moveY = (designSize.height-screenSize.height)/2
	local p = {}
	p.x = node:getPositionX()
	p.y = node:getPositionY()
	
	node:setPosition(cc.p(p.x-moveX,p.y-moveY))
	
end


cc.exports.FixUIUtils = cc.exports.FixUIUtils or FixUIUtils
return FixUIUtils
