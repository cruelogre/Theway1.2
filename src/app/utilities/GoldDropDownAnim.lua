local GoldDropDownAnim = class("GoldDropDownAnim",function ()
	return display.newLayer()
end)
local defaultCount = 50
function GoldDropDownAnim:ctor()
	self:setTouchEnabled(true)
	self:setSwallowsTouches(true)
	self:setTouchMode(cc.TOUCHES_ONE_BY_ONE)
	self:addTo(cc.Director:getInstance():getRunningScene(),0xffffff)
	
end
function GoldDropDownAnim:play(count)
	playSoundEffect("sound/effect/jinbidiaoluo")

	if self:getNumberOfRunningActions()>0 then
		return
	end
	
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	if count<=0 then
		count = defaultCount
	end
	for i=0,count do
		local goldSp = cc.Sprite:create("common/common_gold_efficon.png")
		local randX = math.random(0,display.width)
		local randY = math.random(0,display.height) + display.height
		goldSp:setPosition(cc.p(randX,randY))
		goldSp:setRotation(math.random(0,360))
		local randTime = (math.random(0,5)+15)*0.1
		local act1 = cc.EaseBounceOut:create(cc.MoveTo:create(randTime,cc.p(randX,-100)))
		goldSp:runAction(cc.Sequence:create(act1,cc.RemoveSelf:create(true)))
		self:addChild(goldSp,i)
	end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.RemoveSelf:create(true)))
end

return GoldDropDownAnim