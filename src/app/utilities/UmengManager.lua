-------------------------------------------------------------------------
-- Desc:    友盟
-- Author:  diyal.yin
-- Date:    2016.11.24
-- Last:
-- Notice:  友盟统计
-- Content:  
--------------------------------------------------------------------------


local UmengManager = class("UmengManager")

local LuaNativeBridge = require('app.utilities.LuaNativeBridge'):create()

function UmengManager:ctor()
	-- body
end

function UmengManager:eventCount( eventKey )
	local info = wwCsvCfg.csvTable.umengEvent[eventKey]
	-- wwdump(wwCsvCfg.csvTable)
	--wwdump(info, "umengevent->".. eventKey)
	if info and next(info) then
		local eventType = info.EventType
		if tonumber(eventType) == 0 then
			LuaNativeBridge:umengevent(eventKey)
		end
	end
end

--[[
--统计aa事件 发生的bb数
--]]
function UmengManager:eventCount2( eventKey, eventValue)
	local info = wwCsvCfg.csvTable.umengEvent[eventKey]
	
	wwdump(info, "umengevent2->".. eventKey)
	if info and next(info) then
		local eventType = info.EventType
		if tonumber(eventType) == 0 then
			LuaNativeBridge:umengevent2(eventKey, eventValue)
		end
	end
end

--[[
--统计eventPay事件 
-- 
--]]
function UmengManager:eventPay(eventType, cash, source, coin, item, amount, price)
	LuaNativeBridge:eventPay(eventType, cash, source, coin, item, amount, price)
end

--[[
--统计eventBuy事件 
-- 
--]]
function UmengManager:eventBuy(item, amount, price)
	LuaNativeBridge:eventBuy(item, amount, price)
end

cc.exports.UmengManager = cc.exports.UmengManager or UmengManager:create();
return cc.exports.UmengManager;