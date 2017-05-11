---------------------------------------------
-- module : 网络处理模块
-- auther : diyal.yin
-- comment: 这里统一处理协议内容，跟回调派发
---------------------------------------------
local NetWorkBridge = class("NetWorkBridge")

NetWorkBridge.events = {
	EVENT_MSG_RECV		= "NetworkBridge:event_msg_recv";
	EVENT_ROOT_MSG_RECV	= "NetworkBridge:event_root_msg_recv";
	EVENT_MSG_NETEVENT	= "NetworkBridge:event_msg_netevent";
	EVENT_UPGRADE_NETEVENT	= "NetworkBridge:event_upgrade_netevent";
}

local TAG = "<NetWorkBridge | "

function NetWorkBridge:ctor()
	-- body
	cc.bind(self, "event")
	self:init()
end

function NetWorkBridge:init()

	self._senders = {}
	self._readers = {}
end

function NetWorkBridge:send(sendMsgID, tParams, target)
	-- body
	if sendMsgID == nil or type(tParams) ~= "table" then 
		printInfo(TAG.."send - parameter error.")
		return 	
	end 
	target = tostring(target)

	local sender = self._senders[sendMsgID] or {}
	local functor = nil
	for k, v in ipairs(sender) do 	
		if v.target == target then 
			functor = v.functor 
			break
		end 
	end 
	if not functor then 
		printInfo(TAG.."send - not register functor")
		return 
	end 

	local wwbuff = functor(tParams)
	if wwbuff then 
		cc.exports.WWNetDelegate:sendBuffer(wwbuff)
	else 
		printInfo(TAG.."send - builder is error?")
	end 
end

function NetWorkBridge:throughRecMsg(netWWBuffer)
	if type(netWWBuffer) ~= "userdata" then 
		printInfo(TAG.."throughRecMsg - parameter is error")
		return 
	end 

	local msgId = netWWBuffer:readChar3ToInt()
	printInfo(TAG.."throughRecMsg - recv(%x)", msgId)
	local reader = self._readers[msgId] or {}
	local findItem = nil
	local buffer = netWWBuffer:readData(netWWBuffer:getReadableSize())
	
	for k, v in ipairs(reader) do 
		buffer:markReaderIndex()
		local result = v.functor(msgId, buffer)
		self:dispatchEvent({
			name=self.events.EVENT_MSG_RECV;
			_userdata={msgId=msgId, msgTable=result, target=v.target}
			})
		buffer:resetReaderIndex()
	end 
end

function NetWorkBridge:throughRecMsg2(msgId,msgTable)
	if type(msgTable) ~= "table" then 
		printInfo(TAG.."throughRecMsg2 - parameter is error")
		return 
	end 
	-- dump(msgTable)
	printInfo(TAG.."throughRecMsg2 - recv(%x)", msgId)
	local reader = self._readers[msgId] or {}
	
	for k, v in ipairs(reader) do 
		self:dispatchEvent({
			name=self.events.EVENT_MSG_RECV;
			_userdata={msgId=msgId, msgTable=msgTable, target=v.target}
			})
	end 
end


local net_cppCallLuafunc = function(netWWBuffer)
	cc.exports.NetWorkBridge:throughRecMsg(netWWBuffer)
end

local net_cppCallLuafunc2 = function (msgId,msgTable)
	cc.exports.NetWorkBridge:throughRecMsg2(msgId,msgTable)
end
local net_cppRootMsgToLua = function(buffer)

	assert(type(buffer) == "userdata")

	local msgId = buffer:readChar3ToInt()
	local vusrid = buffer:readInt()
	local vResult = buffer:readChar()
	local vreason = buffer:readLengthAndString()
	local vreasonType = buffer:readShort()
	cclog("通用消息id: %x", msgId)
	--dump(table, "打印通用消息")
	
	local table = { kUserId = vusrid, kResult = vResult, kReason = vreason, kReasonType = vreasonType }

	
	
	if not cc.exports.NetWorkBridge then
		print(string.format("======net_cppRootMsgToLua unprocessed rootMsgId(%s)", tostring(msgId)))
		return
	end

	cc.exports.NetWorkBridge:dispatchEvent({
		name = NetWorkBridge.events.EVENT_ROOT_MSG_RECV;
		_userdata = {msgId = msgId; msgTable = table};
		})
end
local net_cppEvent = function(name,data)
	--assert(type(data) == "userdata")
	print("net_cppEvent")
	
	cc.exports.NetWorkBridge:dispatchEvent({
		name = NetWorkBridge.events.EVENT_MSG_NETEVENT;
		_userdata= {msgId = name;msgData = data};
		})
end

local net_upradeEvent = function (eventid,data)
	
	cc.exports.NetWorkBridge:dispatchEvent({
	 name = NetWorkBridge.events.EVENT_UPGRADE_NETEVENT;
	_userdata= {msgId = eventid;msgTable = data};
	})
end
-- 注册发送消息映射
function NetWorkBridge:setMsgWriterReflex(n_wmsgID, f_writerFunc, target)
	assert(nil ~= target)
	target = tostring(target)
	self._senders = self._senders or {}
	self._senders[n_wmsgID] = self._senders[n_wmsgID] or {}
	local findResult = nil
	for k, v in ipairs(self._senders[n_wmsgID]) do 
		if v.target == target then 
			findResult = v 
			break
		end 
	end 
	if not findResult then 
		table.insert(self._senders[n_wmsgID], {target=target, functor=f_writerFunc})
	else
		printInfo(TAG.."setMsgWriterReflex - maybe something error?")
		findResult.functor = f_writerFunc
	end 
end

function NetWorkBridge:setMsgReadReflex(n_rmsgID, f_readFunc, target)
	assert(nil ~= target)
	target = tostring(target)
	self._readers = self._readers or {}
	self._readers[n_rmsgID] = self._readers[n_rmsgID] or {}
	local findResult = nil
	for k, v in ipairs(self._readers[n_rmsgID]) do 
		if v.target == target then 
			findResult = v 
			break
		end 
	end 
	if not findResult then 
		table.insert(self._readers[n_rmsgID], {target=target, functor=f_readFunc})
	else 
		printInfo(TAG.."setMsgReadReflex - maybe something error?")
		findResult.functor = f_readFunc
	end
end

-- 往G表存东西的时候，不能直接使用_G
ww.WWConfigManager:getInstance():initConfig("WWPlatform/wwConfig.xml")
cc.exports.WWNetDelegate = ww.WWMsgManager:getInstance() -- 取得C++层的网络层单例对象
cc.exports.wawaOnMessage = net_cppCallLuafunc
cc.exports.wawaOnInfoMessage = net_cppCallLuafunc2
cc.exports.wawaOnRootMessage = net_cppRootMsgToLua
cc.exports.wawaOnNetEvent = net_cppEvent
cc.exports.wawaOnUpgradeEvent = net_upradeEvent
cc.exports.NetWorkBridge = cc.exports.NetWorkBridge or NetWorkBridge:create()



return cc.exports.NetWorkBridge
