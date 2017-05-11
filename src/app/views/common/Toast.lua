local Toast = class("Toast")
local Queue = {}
local threshold = 0
local TOP_ZORDER = 1000
function Toast:ctor()
	self:init()
end
function Toast:init()
	self.node = require("csb.common.ToastNode"):create().root
	
	self.node:setPosition(cc.p(display.center.x,display.center.y))	
end

function Toast:makeToast(content,duration)

	local ts = Toast:create()
	ts:initView(content,duration)
	return ts
end

function Toast:clear()
	while #Queue>threshold do
		local temp = Queue[#Queue]
		if isLuaNodeValid(temp.node) then
			temp.node:removeFromParent()
		end
		table.remove(Queue,1)
	end
end

function Toast:initView(content,duration)
	self.content = content
	self.duration = duration
	--toast_bg
	local c = self.node:getChildByName("toast_bg"):getChildByName("Text_content")
	if c then
		local text = tolua.cast(c,"ccui.Text")
		if text then
			text:setString(content)

			local toast_bg = self.node:getChildByName("toast_bg")
			local width = math.max(text:getContentSize().width+200,toast_bg:getContentSize().width)
			toast_bg:setContentSize(cc.size(width,text:getContentSize().height+ 20) )

			text:setPosition(cc.p(toast_bg:getContentSize().width/2,toast_bg:getContentSize().height/2))
		end
	end
end

function Toast:show(closeCB)
	self:clear()
	self._closeCB = closeCB
	table.insert(Queue,#Queue+1,self)
	cc.Director:getInstance():getRunningScene():addChild(self.node,ww.topOrder)
	self:runAnim(self.node)
	
end
function Toast:runAnim(node)
	local f1 = cc.FadeIn:create(0.2)
	local f2 = cc.FadeOut:create(0.2)
	local d1 = cc.DelayTime:create(self.duration)
	node:runAction(cc.Sequence:create(f1,d1,f2,cc.CallFunc:create(handler(self,self.removeSelf))))
end
function Toast:removeSelf()
	local index = -1
	for i,v in ipairs(Queue) do
		if v==self then
			index = i
			break
		end
	end
	if index>0 then
		if self._closeCB then
			self._closeCB()
		end
		self._closeCB = nil
		Queue[index].node:removeFromParent()
		table.remove(Queue,index)
	else
		if self._closeCB then
			self._closeCB()
		end
		self._closeCB = nil
		self.node:removeFromParent()
	end
	
end
return Toast