
local UICircleNode = class("UICircleNode", cc.ClippingNode)

--[[

diameter:	直径 

return:		返回一个按'直径'裁剪好的模板，可自行添加其他node进行裁剪

]]

function UICircleNode:ctor(diameter)
	self:setContentSize(cc.size(diameter, diameter))
	self:setAnchorPoint(cc.p(0.5, 0.5))

	local circleStencil = cc.DrawNode:create()
	circleStencil:drawSolidCircle(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2), diameter / 2, math.pi / 2, 90, cc.c4f(1, 1, 1, 1))

	self:setStencil(circleStencil)
end


--[[

dameter:	直径 
spritePath:	精灵名

return:		返回一个按'直径'裁剪好的精灵

]]

function UICircleNode:ctor(diameter, spritePath)
	self:setContentSize(cc.size(diameter, diameter))
	self:setAnchorPoint(cc.p(0.5, 0.5))

	local circleStencil = cc.DrawNode:create()
	circleStencil:drawSolidCircle(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2), diameter / 2, math.pi / 2, 90, cc.c4f(1, 1, 1, 1))

	self:setStencil(circleStencil)

	display.newSprite(spritePath):move(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2)):addTo(self)

end

return UICircleNode