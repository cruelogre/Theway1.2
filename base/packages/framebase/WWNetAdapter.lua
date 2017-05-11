local WWNetAdapter = class("WWNetAdapter")
import(".NetWorkBridge", "packages.framebase.")
local TAG = "<WWNetAdapter | "

function WWNetAdapter:ctor()
	-- body
	self:init()
end

function WWNetAdapter:init()
	-- body
	self._rootMsgIds = {}
	self._msgIds = {}
	self._netEventMsgIds = {}
	self._upgradeEventMsgIds = {}
	local function onMsgReceived(event)
		-- body
		local msgId = event._userdata.msgId
		local msgTable = event._userdata.msgTable
		local msgTarget = event._userdata.target

		self:msgFilter(msgId, msgTable, msgTarget)
	end
	local function onRootMsgReceived(event)
		-- body
		local msgId = event._userdata.msgId
		local msgTable = event._userdata.msgTable

		self:rootMsgFilter(msgId, msgTable)
	end

	local function onNetEventReceived(event)
		local msgId = event._userdata.msgId
		local msgData = event._userdata.msgData
		self:NetEventFilter(msgId,msgData)
		
	end
	local function onUpgradeEventRecived(event)
		local msgId = event._userdata.msgId
		local msgData = event._userdata.msgTable
		self:upgradeEventFilter(msgId,msgData)
	end
	
	NetWorkBridge:addEventListener(NetWorkBridge.events.EVENT_MSG_RECV, onMsgReceived)
	NetWorkBridge:addEventListener(NetWorkBridge.events.EVENT_ROOT_MSG_RECV, onRootMsgReceived)
	NetWorkBridge:addEventListener(NetWorkBridge.events.EVENT_MSG_NETEVENT, onNetEventReceived)
	NetWorkBridge:addEventListener(NetWorkBridge.events.EVENT_UPGRADE_NETEVENT,onUpgradeEventRecived)
	
end

function WWNetAdapter:msgFilter(msgId, msgTable, msgTarget)
	-- body
	if not self._msgIds[msgId] then 
		print(TAG .. string.format("msgFilter - msgId(%s) filter unregistered.", tostring(msgId)))
		return 
	end

	local filters = self._msgIds[msgId]
	for _, v in pairs(filters) do
		if v.target == msgTarget then 
			v.callback(msgId, msgTable)
		end 
	end
end

function WWNetAdapter:rootMsgFilter(msgId, msgTable)
	-- body
	if not self._rootMsgIds[msgId] then
		print(TAG .. string.format("rootMsgFilter - msgId(%s) filter unregistered.", tostring(msgId)))
		return
	end

	local filters = self._rootMsgIds[msgId]
	for _, v in pairs(filters) do
		v.callback(msgId, msgTable)
	end
end

function WWNetAdapter:NetEventFilter(msgId, msgData)
	-- body
	if not self._netEventMsgIds[msgId] then
		print(TAG .. string.format("NetEventFilter - msgId(%s) filter unregistered.", tostring(msgId)))
		return
	end

	local filters = self._netEventMsgIds[msgId]
	for _, v in pairs(filters) do
		v.callback(msgId, msgData)
	end
end

function WWNetAdapter:upgradeEventFilter(msgId, msgData)
	-- body
	if not self._upgradeEventMsgIds[msgId] then
		print(TAG .. string.format("upgradeEventFilter - msgId(%s) filter unregistered.", tostring(msgId)))
		return
	end

	local filters = self._upgradeEventMsgIds[msgId]
	for _, v in pairs(filters) do
		v.callback(msgId, msgData)
	end
end


function WWNetAdapter:registerRootMsgId(msgId, callback, tag, target)
	-- body
	if not self._rootMsgIds[msgId] then
		ww.MsgLuaFilter:getInstance():registerRootMsgId(msgId)
	end

	target = tostring(target)
	self._rootMsgIds[msgId] = self._rootMsgIds[msgId] or {}
	local cached = self._rootMsgIds[msgId]
	for _, v in pairs(cached) do
		if v.tag == tag and v.target == target then
			print(TAG .. string.format("registerRootMsgId - msgId(%s), tag(%s) exist, change callback forcible", 
				tostring(msgId), tostring(tag)))
			v.callback = callback
			return
		end
	end
	table.insert(cached, {msgId = msgId; callback = callback; tag = tag; target = target;})
end

function WWNetAdapter:registerMsgId(msgId, callback, tag, target)
	-- body
	if not self._msgIds[msgId] then
		ww.MsgLuaFilter:getInstance():registerMsgId(msgId)
	end

	target = tostring(target)
	self._msgIds[msgId] = self._msgIds[msgId] or {}
	local cached = self._msgIds[msgId]
	for _, v in pairs(cached) do
		if v.tag == tag and v.target == target then
			print(TAG .. string.format("registerMsgId - msgId(%s), tag(%s) exist, change callback forcible",
				tostring(msgId), tostring(tag)))
			v.callback = callback
			return
		end
	end

	table.insert(cached, {msgId = msgId; callback = callback; tag = tag; target = target;})
end
function WWNetAdapter:bindMsgTable(msgId,msgStruct)
	-- if self._msgIds[msgId] then
		ww.MsgLuaFilter:getInstance():bindMsgId(msgId,msgStruct)
	-- else
	-- 	print(TAG .. string.format("bindMsgTable - msgId(%s), must register MsgId first",
	-- 			tostring(msgId)))
	-- end
end

function WWNetAdapter:registerNetEventMsg(msgId, callback, tag, target)
	-- body
	if not self._netEventMsgIds[msgId] then
		ww.MsgLuaFilter:getInstance():registerNetEventId(msgId)
	end

	target = tostring(target)
	self._netEventMsgIds[msgId] = self._netEventMsgIds[msgId] or {}
	local cached = self._netEventMsgIds[msgId]
	for _, v in pairs(cached) do
		if v.tag == tag and v.target == target then
			print(TAG .. string.format("registerNetEventMsg - msgId(%s), tag(%s) exist, change callback forcible", 
				tostring(msgId), tostring(tag)))
			v.callback = callback
			return
		end
	end
	table.insert(cached, {msgId = msgId; callback = callback; tag = tag; target = target;})
end

function WWNetAdapter:registerUpgradeEventMsg(msgId, callback, tag, target)
	-- body
	if not self._upgradeEventMsgIds[msgId] then
		ww.MsgLuaFilter:getInstance():registerUpgradeEventId(msgId)
	end

	target = tostring(target)
	self._upgradeEventMsgIds[msgId] = self._upgradeEventMsgIds[msgId] or {}
	local cached = self._upgradeEventMsgIds[msgId]
	for _, v in pairs(cached) do
		if v.tag == tag and v.target == target then
			print(TAG .. string.format("registerUpgradeEventMsg - msgId(%s), tag(%s) exist, change callback forcible", 
				tostring(msgId), tostring(tag)))
			v.callback = callback
			return
		end
	end
	table.insert(cached, {msgId = msgId; callback = callback; tag = tag; target = target;})
end


function WWNetAdapter:unregisterRootMsgId(msgId, tag, target)
	-- body
	if not self._rootMsgIds[msgId] then
		return 
	end

	target = tostring(target)
	local cached = self._rootMsgIds[msgId]
	for i = 1, #cached do
		if cached[i].tag == tag and cached[i].target == target then
			table.remove(cached, i)
			break
		end
	end

	if #cached == 0 then
		self._rootMsgIds[msgId] = nil
		ww.MsgLuaFilter:getInstance():unRegisterRootMsgId(msgId)
	end
end

function WWNetAdapter:unregisterAllRootMsgId(tag, target)
	-- body
	target = tostring(target)
	for k, v in pairs(self._rootMsgIds) do
		for i = 1, #v do
			if v[i].tag == tag and v[i].target == target then
				table.remove(v, i)
				break
			end
		end

		if #v == 0 then
			self._rootMsgIds[k] = nil
			ww.MsgLuaFilter:getInstance():unRegisterRootMsgId(k)
		end
	end
end

function WWNetAdapter:unregisterMsgId(msgId, tag, target)
	-- body
	if not self._msgIds[msgId] then
		return 
	end

	target = tostring(target)
	local cached = self._msgIds[msgId]
	for i = 1, #cached do
		if cached[i].tag == tag and cached[i].target == target then
			table.remove(cached, i)
			break;
		end
	end

	if #cached == 0 then
		self._msgIds[msgId] = nil
		ww.MsgLuaFilter:getInstance():unRegisterMsgId(msgId)
	end
end

function WWNetAdapter:unregisterAllMsgId(tag, target)
	-- body
	target = tostring(target)
	for k, v in pairs(self._msgIds) do
		for i = 1, #v do
			if v[i].tag == tag and v[i].target == target then
				table.remove(v, i)
				break
			end
		end

		if #v == 0 then
			self._msgIds[k] = nil
			ww.MsgLuaFilter:getInstance():unRegisterMsgId(k)
		end
	end
end



function WWNetAdapter:unregisterNetEvent(msgId, tag, target)
	-- body
	if not self._netEventMsgIds[msgId] then
		return 
	end

	target = tostring(target)
	local cached = self._netEventMsgIds[msgId]
	for i = 1, #cached do
		if cached[i].tag == tag and cached[i].target == target then
			table.remove(cached, i)
			break;
		end
	end
	if #cached == 0 then
		self._netEventMsgIds[msgId] = nil
		ww.MsgLuaFilter:getInstance():unRegisterNetEventId(msgId)
	end
end

function WWNetAdapter:unregisterAllNetEvent(tag, target)
	-- body
	target = tostring(target)
	for k, v in pairs(self._netEventMsgIds) do
		for i = 1, #v do
			if v[i].tag == tag and v[i].target == target then
				table.remove(v, i)
				break
			end
		end

		
	end
	ww.MsgLuaFilter:getInstance():clearNetEventId()
end



function WWNetAdapter:unregisterUpgradeEvent(msgId, tag, target)
	-- body
	if not self._upgradeEventMsgIds[msgId] then
		return 
	end

	target = tostring(target)
	local cached = self._upgradeEventMsgIds[msgId]
	for i = 1, #cached do
		if cached[i].tag == tag and cached[i].target == target then
			table.remove(cached, i)
			break;
		end
	end
	if #cached == 0 then
		self._upgradeEventMsgIds[msgId] = nil
		ww.MsgLuaFilter:getInstance():unRegisterUpgradeEvent(msgId)
	end
end

function WWNetAdapter:unregisterAllUpgradeEvent(tag, target)
	-- body
	target = tostring(target)
	for k, v in pairs(self._upgradeEventMsgIds) do
		for i = 1, #v do
			if v[i].tag == tag and v[i].target == target then
				table.remove(v, i)
				break
			end
		end

		
	end
	ww.MsgLuaFilter:getInstance():clearUpgradeEvent()
end


cc.exports.WWNetAdapter = cc.exports.WWNetAdapter or WWNetAdapter:create()
return cc.exports.WWNetAdapter