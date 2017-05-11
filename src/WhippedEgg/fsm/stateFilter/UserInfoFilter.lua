---------------------------------------------
-- module : 帐号升级提示过滤器
-- auther : cruelogre
-- Date:    2016.12.1
-- comment: 帐号升级提示过滤器 进入游戏后，设置升级已经提示
--  		

-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------
local UserInfoFilter = class("UserInfoFilter",require("packages.statebase.FSFilter"))


function UserInfoFilter:ctor(filterId,priority)
	UserInfoFilter.super.ctor(self,filterId,priority)

	--self.filterId = filterId
	self.filterCount = -1 --无限次数
	self.filterType = bit._or(FSConst.FilterType.Filter_Enter,FSConst.FilterType.Filter_Exit)
	
	
end


function UserInfoFilter:doFilter(filterChain,filterType)


	if UserInfoFilter.super.doFilter(self,filterChain,filterType) then
		wwlog(self.logTag,"doFilter filterId %s 自有类型 %d 分发类型 %d 剩余次数 %d",
		tostring(self.filterId),self.filterType,filterType,self.filterCount)
		
		local oldData = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
		if oldData and next(oldData) then
			
			oldData.hasRequestUpdate = true
		end
	
		
	end
	
	return true
end



function UserInfoFilter:finalizer()
	
end

return UserInfoFilter