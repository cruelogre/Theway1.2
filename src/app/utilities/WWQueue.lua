-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.11
-- Last: 
-- Content:  双向队列 实现类

-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------


local WWQueue = class("WWQueue")

--双向队列  
function WWQueue:ctor()  
    self.first = 1  
    self.last = 0  
    self.list = {}  
    self.listManager = {}
end
  
function WWQueue:pushFront(_tempObj)  
	self.first = self.first - 1  
	self.list[self.first] = _tempObj  
end  
function WWQueue:pushBack(_tempObj)  
	self.last = self.last + 1  
	self.list[self.last] = _tempObj  
end  
function WWQueue:getFront()  
	if self:isEmpty() then  
		return nil  
	else  
		local val = self.list[self.first]  
		return val  
	end  
end  
function WWQueue:getBack()  
	if self:isEmpty() then  
		return nil  
	else  
		local val = self.list[self.last]  
		return val  
	end  
end  
function WWQueue:popFront()  
	self.list[self.first] = nil  
	self.first = self.first + 1  
end  
function WWQueue:popBack()  
	self.list[self.last] = nil  
	self.last = self.last - 1  
end  
function WWQueue:clear()  
	while false == self:isEmpty() do  
	self:popFront()  
end  
end  
function WWQueue:isEmpty()  
	if self.first > self.last then  
		self.first = 1  
		self.last = 0  
		return true  
	else  
		return false  
	end  
end  
function WWQueue:getSize()  
	if  self:isEmpty() then  
		return 0  
	else  
		return self.last - self.first + 1  
	end  
end 

return WWQueue