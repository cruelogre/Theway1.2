-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.21
-- Last: 
-- Content:  HTTP请求封装类
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local WWHttpRequest = class("WWHttpRequest")
function WWHttpRequest:ctor(handlerCB)
	self.xhr = cc.XMLHttpRequest:new()
	self._handlerCB = handlerCB
    self.xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING

    local function onReadyStateChanged()
		if self.xhr.readyState == 4 and (self.xhr.status >= 200 and self.xhr.status < 207) then
            print("ERROR: labelStatusCode is invalid!"..self.xhr.statusText)
        else
            print("xhr.readyState is:", self.xhr.readyState, "xhr.status is: ",self.xhr.status)
        end
		self.xhr:unregisterScriptHandler()
		if self._handlerCB and type(self._handlerCB)=="function" then
			self._handlerCB(self.xhr.response)
		end
	end
       self.xhr:registerScriptHandler(onReadyStateChanged)        
end

function WWHttpRequest:request(method,url)
	self.xhr:open(method, url)
	self.xhr:send()
end
function WWHttpRequest:clear()
	self._handlerCB = nil
end

return WWHttpRequest