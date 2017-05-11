local BaseRequest = class("BaseRequest")

require("app.config.wwConfigData")
require("app.config.wwConst")
BaseRequest.basicTable = {
	string={"string"};
	number = {"char","short","int","ushort"};
	boolean = {"bool"};
}

function BaseRequest:ctor()
	
end
function BaseRequest:init(orderTable)
	self.data = self.data or {}
	if self.fields then
		removeAll(self.fields)
	end
	removeAll(self.data)
	
	self.fields = orderTable
	assert(type(orderTable)=="table")
	for i,v in pairs(orderTable) do
		assert(type(v)=="table")
		
		if v[2]=="string" then
			table.insert(self.data,"")
		else
			table.insert(self.data,0)
		end
		
	end
end
function BaseRequest:setField(fName,fValue)
	--find fName index in dataTable
	local index = self:findIndex(self.fields,fName)
	if index > 0 then
		if self:equal(type(fValue),self.fields[index][2]) then
			--self.fields[index][2]
			
			self.data[index] = fValue
			return true
		end
		return false
	end
	return false
end
function BaseRequest:equal(fValueType,filedType)
	local ret = false
	for _,v in pairs(BaseRequest.basicTable[fValueType]) do
		if v ==filedType then
			ret = true
			break
		end
	end
	
	return ret
end

function BaseRequest:findIndex(orderTable,fName)
	local index = 0
	for i,v in pairs(orderTable) do
		if v[1]==fName then
			index = i
			break
		end
	end
	return index
end
function BaseRequest:formatHeader(msgParam,headers)
	local retTable = {}
	copyTable(msgParam,retTable)
	if type(headers)=="table" then
		for i,v in pairs(headers) do
			table.insert(retTable,i,v)
		end
	end
	return retTable
end

function BaseRequest:formatHeader2(msgParam,headerId)
	local headers = {}
	
	table.insert(headers,bit.band(bit.rshift(headerId,4*4),0xff))
	table.insert(headers,bit.band(bit.rshift(headerId,4*2),0xff))
	table.insert(headers,bit.band(bit.rshift(headerId,4*0),0xff))
	
	local retTable = {}
	copyTable(msgParam,retTable)
	if type(headers)=="table" then
		for i,v in pairs(headers) do
			table.insert(retTable,i,v)
		end
	end
	return retTable
end

return BaseRequest