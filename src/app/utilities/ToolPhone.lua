-- ÔÝÎÞÊµÏÖ£¬ºóÐø¸ù¾ÝluaÄ£¿éµÄÐèÇóÔÙÌí¼Ó

local phoneTool = {}

-- 输入电话号码判断
phoneTool.inputCheckOfPhoneNumber = function(strTelNum)
	
	strTelNum = strTelNum or "";

	if #strTelNum ~= 11 then
		return false;
	end

	local tmpStr = string.sub(strTelNum, 1, 1);
	if (tonumber(tmpStr) ~= 1) then
		return false;
	end

	local strList = "0123456789";

	for index=1,11 do
		tmpStr = string.sub(strTelNum, index, index);
		if not string.find(strList, tmpStr) then
			return false;
		end
	end

	return true;
end

return phoneTool