-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.11
-- Last: 
-- Content:  双向队列 实现类

-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------


local WWList = class("WWList")

--双向队列  
function WWList:ctor()  
    self.first = 1  
    self.last = 0  
    self.list = {}  
    self.listManager = {}
end
  
function WWList:pushFront(_tempObj)
	local got,index = self:contains(_tempObj)
	if got then
		self:removeAt(index)
	end
	self.first = self.first - 1  
	self.list[self.first] = _tempObj
	
  
end  
function WWList:pushBack(_tempObj)
	local got,index = self:contains(_tempObj)
	if got then
		self:removeAt(index)
	end
	self.last = self.last + 1  
	self.list[self.last] = _tempObj
	
end
function WWList:contains(_tempObj)
	local got = false
	local index = 0
	for i,v in pairs(self.list) do
		if v == _tempObj then
			got = true
			index = i
			break
		end
	end
	return got,index
end

function WWList:removeAt(index)
	if index<self.first or index> self.last then
		return
	end
	self.list[index] = nil
	if index<self.last then
		local tempTable = {}
		for tempIndex=index+1,self.last do
			table.insert(tempTable,tempIndex-1,self.list[tempIndex])
			self.list[tempIndex] = nil
		end
		table.merge(self.list,tempTable)
	end
	self.last = self.last - 1
end
function WWList:remove(_tempObj)
	local index = 0
	for i,v in pairs(self.list) do
		if v==_tempObj then
			index = i
			break
		end
	end
	if index>0 then
		self:removeAt(index)
	end
end
function WWList:getFront()  
	if self:isEmpty() then  
		return nil  
	else  
		local val = self.list[self.first]  
		return val  
	end  
end  
function WWList:getBack()  
	if self:isEmpty() then  
		return nil  
	else  
		local val = self.list[self.last]  
		return val  
	end  
end  
function WWList:popFront()  
	self.list[self.first] = nil  
	self.first = self.first + 1  
end  
function WWList:popBack()  
	self.list[self.last] = nil  
	self.last = self.last - 1  
end  
function WWList:clear()  
	while false == self:isEmpty() do  
	self:popFront()  
end  
end  
function WWList:isEmpty()  
	if self.first > self.last then  
		self.first = 1  
		self.last = 0  
		return true  
	else  
		return false  
	end  
end  
function WWList:getSize()  
	
	if  self:isEmpty() then  
		return 0  
	else  
		return self.last - self.first + 1  
	end  
end 

return WWList