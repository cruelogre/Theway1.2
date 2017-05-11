-----------------------------------------------------------
-- Desc:     ToolCom
-- Author:   Jackie刘龙
-- Date:  	 2015-12-15
-- Last: 	
-- Content: 杂七杂八的实用方法
-- getFormatNum 金额格式化
-- splitNumFix 金额格式化
-- setNodeGray 将按钮置灰
-- getWapUrl 获得平台相应的URL
-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------------------

local ToolCom = { }
local JsonDecorator = import(".JsonDecorator", "app.utilities."):create()
local Toast = require("app.views.common.Toast")

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

-- 只显示bits位数字，比如默认的4位，1001亿，100.1亿，数字大小不限
-- getFormatNum('100000000000000000000000') = 1000万亿亿
function ToolCom:getFormatNum(target, bits)
    bits = bits or 4
    if not target then
        return ""
    end
    -- 位
    local ret = ""
    local strNum = "" .. target
    local posDot = string.find(strNum, "%.")
    posDot = posDot or #strNum + 1
    -- 去掉小数点
    strNum = string.gsub(strNum, "%.", "")
    local bit = #string.sub(strNum, 1, posDot - 1) -1
    local Yis = math.floor(bit / 8)
    local Wans = math.floor((bit % 8) / 4)
    local tmp = bit + 1 - Yis * 8 - Wans * 4
    -- 整数部分
    local tmpLen = 1
    while (tmpLen < bits + 1) and(tmpLen <= #strNum) do
        if tmp == #ret then
            ret = ret .. '.'
        else
            ret = ret .. string.sub(strNum, tmpLen, tmpLen)
            tmpLen = tmpLen + 1
        end
    end
    if ret[#ret] == "." then
        ret = string.sub(ret, 1, #ret - 1)
    end
    local posDot = string.find(ret, "%.")
    if posDot then
        while ((string.sub(ret, #ret, #ret) == '0' and posDot < #ret) or string.sub(ret, #ret, #ret) == '.') do
            ret = string.sub(ret, 1, #ret - 1)
        end
    end
    while Wans > 0 do
        ret = ret .. i18n:get("str_common", 'wan')
        Wans = Wans - 1
    end
    while Yis > 0 do
        ret = ret .. i18n:get("str_common", 'yi')
        Yis = Yis - 1
    end
    return ret
end

function ToolCom.splitNumFix(num)
    -- body
    local  positive = true
    if num > 0 then
        positive = true
    elseif num == 0 then
        return "0"
    else
        num = math.abs(num)
        positive = false
    end

    local strNum = "0"
    local tenMillion = math.floor(num / 10000000)
    -- 千万
    if tenMillion > 0 then
        local hundredMillion = math.floor(num / 100000000)
        -- 亿
        if hundredMillion > 0 then
            strNum = hundredMillion .. "亿"
        else
            local tenThousand = math.floor(num / 10000)
            -- 万
            strNum = tenThousand .. "万"
        end
    else
        local splitNum = { }

        while num > 0 do
            local _modNum = num % 1000
            local _devNum = math.floor(num / 1000)
            table.insert(splitNum, _modNum)
            num = _devNum
        end

        if #splitNum <= 0 then
            strNum = "0"
        elseif #splitNum == 1 then
            strNum = tostring(splitNum[1])
        else
            strNum = tostring(splitNum[#splitNum])

            for i = #splitNum - 1, 1, -1 do
                strNum = strNum .. "," .. string.format("%03d", splitNum[i])
            end
        end
    end

    if positive then
        return strNum
    else
        return "-"..strNum
    end
end

-- 快速创建按钮
function ToolCom:createBtn(normal, callbackEnded, callbackBegan, callbackMoved, callbackCancelled)
    local ret = nil
    if type(normal) == 'string' then
        ret = ww.NewButton:create(normal)
        if ret then
            ret:addTouchEventListener( function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    if callbackEnded then
                        callbackEnded(ret)
                    end
                elseif eventType == ccui.TouchEventType.began then
                    if callbackBegan then
                        callbackBegan(ret)
                    end
                elseif eventType == ccui.TouchEventType.moved then
                    if callbackMoved then
                        callbackMoved(ret)
                    end
                elseif eventType == ccui.TouchEventType.canceled then
                    if callbackCancelled then
                        callbackCancelled(ret)
                    end
                end
            end )
        end
    end
    return ret
end

function ToolCom:setNodeGray(target, isChildGray)
    target:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName("ShaderUIGrayScale"))
    if checkbool(isChildGray) then
        for k, v in pairs(target:getChildren()) do
            ToolCom:setNodeGray(v, isChildGray)
        end
    end
end

function ToolCom:sprRemoveGray(target, isChildGray)
    target:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName("ShaderPositionTextureColor_noMVP"))
    if checkbool(isChildGray) then
        for k, v in pairs(target:getChildren()) do
            ToolCom:sprRemoveGray(v, isChildGray)
        end
    end
end 

--[[
--获得Live800 URL
--]]
function ToolCom:getLive800URL(callback)
    local userid = DataCenter:getUserdataInstance():getValueByKey("userid")
    local username = DataCenter:getUserdataInstance():getValueByKey("nickname")
    local password = ww.WWGameData:getInstance():getStringForKey("pwd", 0)
    local nowTime = tostring(os.time())
    local strMd5 = string.lower(md5.sumhexa(nowTime .. password))

    local ver = ww.IPhoneTool:getInstance():getVersionCode()
    local model = ww.IPhoneTool:getInstance():getMobileModel()
    local hallid = wwConfigData.GAME_HALL_ID
    local gameid = wwConfigData.GAME_ID
    local op = wwConst.OP
    local sp = wwConst.SP
    local clientname = wwConst.CLIENTNAME
    -- local clientname = "真人斗地主2"
    local net = ww.IPhoneTool:getInstance():checkNetState()
    local ip = ww.IPhoneTool:getInstance():getIpAddress()
    local package = ""
    local width = ww.IPhoneTool:getInstance():getScreenWidth()
    local height = ww.IPhoneTool:getInstance():getScreenHeight()
    local imsi = ""
    local imei = ww.IPhoneTool:getInstance():getIMEI()

    local strContent = string.format("userid=%s;username=%s;password=%s;ver=%d;model=%s;hallid=%d;gameid=%d;op=%d;sp=%d;clientname=%s;net=%s;ip=%s;package=%s;width=%f;height=%f;imsi=%s;imei=%s"
    , userid
    , username
    , strMd5
    , ver
    , model
    , hallid
    , gameid
    , op
    , sp
    , clientname
    , net
    , ip
    , package
    , width
    , height
    , imsi
    , imei)

    wwlog("Live800 URL:", strContent)

    -- strContent = string.urlencode(strContent)

    self.xhr = cc.XMLHttpRequest:new()
    self.xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    self.xhr:open("POST", wwURLConfig.LIVE800_URL)

    local function onReadyStateChange()
        if self.xhr.readyState == 4 and(self.xhr.status >= 200 and self.xhr.status < 207) then
            print("Recived http url: " .. self.xhr.response)
            callback(self.xhr.response)
        else
            print("xhr.readyState is:", "%s,%s", self.xhr.readyState, self.xhr.status)
        end
        self.xhr:unregisterScriptHandler()
        self.xhr = nil
    end
    self.xhr:registerScriptHandler(onReadyStateChange)
    self.xhr:send(strContent)

    print("getLive800URL 参数：", strContent)

end

--[[
--获得平台对应的URL
--根据WAP协定
local para = {}
para.vt = 1
para.st = 10008001
para.uid = 100220719
para.picid = matchid
para.mst = 1
para.phototype = 1
--]]
function ToolCom:getWapUrl(para)
    -- vt为预留参数，目前固定为1
    local vt = para.vt or 1
    -- 资源类型(8位数字)
    local st = para.st
    -- 蛙号
    local uid = para.uid
    local sp = wwConst.SP
    local gid = wwConfigData.GAME_ID
    local hid = wwConfigData.GAME_HALL_ID
    local picid = para.picid or 0
    local mst = para.mst or 0
    -- 屏幕尺寸常量定义
    local phototype = para.phototype or 0

    local baseUrl
    if DEBUG == 0 then
        baseUrl = wwURLConfig.PLATFORM_URL
    else
        baseUrl = wwURLConfig.PLATFORM_URL_TEST
    end
    local url = string.format("%s?vt=%d&st=%d&uid=%d&sp=%d&gid=%d&hid=%d&picid=%d&mst=%d&phototype=%d", baseUrl, vt, st, uid, sp, gid, hid, picid, mst, phototype)

    -- wwlog("getWapUrl = " .. url)

    return url
end

-- 清除内存中的纹理
function ToolCom.clearTexture()
    -- 先删除失败的
    DataCenter:clearData(COMMON_TAG.C_NETSPRITE_FAILED)

    local downloadedDatas = DataCenter:getData(COMMON_TAG.C_NETSPRITE_DOWNLOAD)
    if downloadedDatas then
        for _, downloadTexture in pairs(downloadedDatas) do
            cc.Director:getInstance():getTextureCache():removeTextureForKey(downloadTexture)
        end
    end
    DataCenter:clearData(COMMON_TAG.C_NETSPRITE_DOWNLOAD)
end

-- 获取选区头像的Path
function ToolCom:getHeadNativePath()
    local userid = DataCenter:getUserdataInstance():getValueByKey("userid")

    local endPath

    if (cc.PLATFORM_OS_ANDROID == targetPlatform) or
        cc.PLATFORM_OS_WINDOWS == targetPlatform then
        local userid = DataCenter:getUserdataInstance():getValueByKey("userid")
        endPath = ww.WWGameData:getInstance():getStringForKey("UploadHeadPath_" .. userid, "")
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform)
        or((cc.PLATFORM_OS_IPAD == targetPlatform))
        or((cc.PLATFORM_OS_MAC == targetPlatform)) then
        local headNativePath = device.writablePath .. "%d_upload_head.png"
        endPath = string.format(headNativePath, userid)
    end

    return endPath
end

-- 上传头像
-- android下 传过来的地址
function ToolCom:uploadHead(nacivePicPath)
    local nowTime = tostring(os.time())
    local userid = ww.WWGameData:getInstance():getIntegerForKey("userid", 0)
    local password = ww.WWGameData:getInstance():getStringForKey("pwd", 0)
    local md5Password = string.lower(md5.sumhexa(nowTime .. password))

    wwlog("nowTime", nowTime)
    wwlog("userid", userid)
    wwlog("password", password)
    wwlog("md5Password", md5Password)

    local serverURLStr
    if DEBUG == 0 then
        serverURLStr = wwURLConfig.PLATFORM_UPLOAD_URL
    else
        Toast:makeToast(nacivePicPath, 1.0):show()
        serverURLStr = wwURLConfig.PLATFORM_UPLOAD_URL_TEST
    end

    local strUrl = string.format("%s?clientver=1.0&apiver=1.0&time=%s&userid=%d&password=%s&imgtype=PNG&uploadtype=0&logontype=0",
    serverURLStr,
    nowTime,
    userid,
    md5Password
    )

    ww.IPhoneTool:getInstance():uploadHead(strUrl, nacivePicPath)
end

--[[
--获取远程头像地址
--]]
function ToolCom:getRemoteHeadURL(pType, userid)
    local para = { }
    para.vt = 1
    para.st = 10202001
    para.uid = userid
    para.mst = 8
    -- 256 * 256
    para.picid = 1
    para.phototype = pType

    return ToolCom:getWapUrl(para)
end

function ToolCom.isSpriteFrameValid(name)
	if name and type(name)=="string" then
		return isLuaNodeValid(cc.SpriteFrameCache:getInstance():getSpriteFrame(name))
	end
	return false
end

function ToolCom:getActivityUrl(userid,pwd)
   
	local activityCode = function (userid,pwd)
		if not pwd or string.len(pwd)<=0 then
			pwd = "111"
		end
		userid = userid or 0
		local pwdStr = pwd.."WaComnuity91"
		
--[[	long P1 = (long) pwdstr.at(0) * pwdstr.at(3) * pwdstr.at(6)
			* pwdstr.at(9);
	long P2 = (long) pwdstr.at(1) * pwdstr.at(4) * pwdstr.at(7)
			* pwdstr.at(10);
	long P3 = (long) pwdstr.at(2) * pwdstr.at(5) * pwdstr.at(8)
			* pwdstr.at(11);
	long P = P1 + P2 + P3;

	long P4 = (pwdstr.at(1) + pwdstr.at(2) + pwdstr.at(3)
			+ pwdstr.at(4)) * 2;
	long U1 = (long) (UserID + 5318929) * (Password.length() + 1);
	long U2 = (long) (UserID % 100000);
	long U = U1 + U2 * P4;

	long VerifyCode = P + U;
	return StringUtils::format("%ld", VerifyCode)--]]
		
		local P1 = string.byte(pwdStr,1)*string.byte(pwdStr,4)*string.byte(pwdStr,7)*string.byte(pwdStr,10)
		local P2 = string.byte(pwdStr,2)*string.byte(pwdStr,5)*string.byte(pwdStr,8)*string.byte(pwdStr,11)
		local P3 = string.byte(pwdStr,3)*string.byte(pwdStr,6)*string.byte(pwdStr,9)*string.byte(pwdStr,12)
		local P = P1+P2+P3
		local P4 = (string.byte(pwdStr,2) + string.byte(pwdStr,3) + string.byte(pwdStr,4) + string.byte(pwdStr,5))*2
		local U1 = (userid + 5318929) *(string.len(pwd) + 1)
		local U2 = userid % 100000
		local U = U1 +U2 * P4
		local VerifyCode = P + U
		return string.format("%d",VerifyCode)
	end


	local method = "loginByClient" --固定内容为loginByClient，表求登录执行这个方法，大小写敏感
	local t = 2 --默认值为2，可扩充参数
	local v= 10 --跳转地址内容：v=10跳转活动大厅，v=100暂无活动，v=101不再支持
	local u = userid or 0 --用户id
	local sp = wwConst.SP --客户sp
	local op = wwConst.OP --运营商标识id
	local p = activityCode(userid,pwd) --由用户密码通过算法生成的较验码
	local hid = wwConfigData.GAME_HALL_ID --大厅id
	local cv = wwConfigData.GAME_VERSION --客户端版本号
	local gameid = wwConfigData.GAME_ID
    local baseUrl
    if DEBUG == 0 then
        baseUrl = wwURLConfig.ACTIVITY_URL
    else
        baseUrl = wwURLConfig.ACTIVITY_URL_TEST
    end
    local url = string.format("%s?method=%s&t=%d&v=%d&u=%d&sp=%d&op=%d&p=%s&hid=%d&cv=%s&gameid=%d", 
								baseUrl,method,t,v,u,sp,op,p,hid,cv,gameid)

    wwlog("getActivityUrl = " .. url)
	
    return url
end

--自动换行的字符串格式化
--@param context 内容
--@param maxLine 最大字符计算长度
function ToolCom:wrapString( context ,maxLine)
	-- body
	local length = string.len(context)
	local hanzi = 0
	local yinwen = 0

	local str = ""
	local ibyte = 1
	local lineCount = 1
	for i=1,length do
		local cValue = string.byte(context,ibyte)
		if cValue and cValue > 0 and cValue < 127 then
			str = str..string.sub(context,ibyte,ibyte)
			yinwen = yinwen + 1
			ibyte = ibyte + 1
			
		else --utf8中文占3个字符
			str = str..string.sub(context,ibyte,ibyte+2)
			hanzi = hanzi + 1
			ibyte = ibyte + 3
		end
		
		if cValue and ibyte >=lineCount*maxLine then --超过了，换行
			lineCount = lineCount + 1
			str = str.."\n"
		end
	end
	return str
end
--[[
百度定位、上传头像
--]]
function ToolCom:getLocation(callBack)

    local endURL

    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        -- mcode = 安全码sha1;包名
        endURL = string.format(wwURLConfig.PLATFORM_BAIDULOCATION_URL .. "?ak=%s&mcode=%s;%s",
        wwURLConfig.LOCATION_AK,
        wwURLConfig.LOCATION_MCODE_PART1,
        wwURLConfig.LOCATION_MCODE_PART2
        )
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform)
        or((cc.PLATFORM_OS_IPAD == targetPlatform))
        or((cc.PLATFORM_OS_MAC == targetPlatform)) then
        -- mcode=包名
        endURL = string.format(wwURLConfig.PLATFORM_BAIDULOCATION_URL .. "?ak=%s&mcode=%s",
        wwURLConfig.LOCATION_AK_IOS,
        wwURLConfig.LOCATION_MCODE_PART2
        )
    else
        endURL = string.format(wwURLConfig.PLATFORM_BAIDULOCATION_URL .. "?ak=%s&mcode=%s",
        wwURLConfig.LOCATION_AK,
        wwURLConfig.LOCATION_MCODE_PART2
        )
    end

    wwlog("定位URL", endURL)

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", endURL)

    local function onReadyStateChange()
        -- print("http", xhr.status,xhr.readyState,self.url)
        if xhr.readyState == 4 and(xhr.status >= 200 and xhr.status < 207) then
            local response = xhr.response

            local ret, locationInfos = JsonDecorator:decode(response)

            if ret then
                dump(locationInfos, ret)

                if callBack then
                    callBack(locationInfos)
                end
            end


        else
            -- wwlog("xhr.readyState/status is: %d, %d", xhr.readyState,xhr.status)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()

end

-- 上传当前场景ID
local netWorkProxy = nil
function ToolCom:uploadSceneID(sceneID)
    if not netWorkProxy then
        netWorkProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().NET_WORK)
    end
    netWorkProxy:uploadSceneID(sceneID)
end

-- 获取物品图片URL
-- defaultImg:默认图片
-- para.picid 道具ID，EquipID
-- para.mst=1 800x480标清图片
-- mst=2 1280x720高清图片
-- mst=3 1920x1080超高清图片
-- mst=4 表示取配置的gif图片
function ToolCom:createGoodsSprite(equipID, defaultImg)
    local WWNetSprite = require("app.views.customwidget.WWNetSprite")
    local para = {
        uid = DataCenter:getUserdataInstance():getValueByKey("userid"),
        st = 10007001,
        mst = 1,
        picid = equipID,
        phototype = "-1"
    }

    return WWNetSprite:create(defaultImg or "common/goods/item_default_1.png", ToolCom:getWapUrl(para), false)
end

function ToolCom.traverseNode(node, callback, table)
    local name = node:getName()
    if table then
        table[name] = node
    end
    if callback then
        callback(name, node)
    end
    for idx, child in pairs(node:getChildren()) do
        ToolCom.traverseNode(child, callback, table)
    end
end

-- proxy中批量注册网络消息，和下面的批量注销网络消息
-- 防止手动注销的时候，漏掉。
ToolCom.registerNetMsgListener = function(proxy, msgCallback, rootMsgCallback, ...)
    assert(proxy and msgCallback and rootMsgCallback)
    local _prefix_tag_ = proxy.__cname
    local headers = { }
    for k, v in pairs( { ...}) do
        v:create(proxy)
        for k1, v1 in pairs(v.MSG_ID) do
            assert(not(headers[k1]), "same msgheader name")
            headers[k1] = v1
            if string.match(k1, "_Ret$") or string.match(k1, "_ret$") then
                -- 响应消息头
                proxy:registerMsgId(v1, handler(proxy, msgCallback), table.concat( { _prefix_tag_, "_", v1 }, ""))
            elseif string.match(k1, "_Send$") or string.match(k1, "_send$") then
                -- 请求消息头
                proxy:registerRootMsgId(v1, handler(proxy, rootMsgCallback), table.concat( { _prefix_tag_, "_", v1 }, ""))
            else
                assert(false, k1 .. "must be ended with _R(r)et or _S(s)end")
            end
        end
    end
    return headers
end

ToolCom.unregisterNetMsgListener = function(proxy, ...)
    local _prefix_tag_ = proxy.__cname
    for k, v in pairs( { ...}) do
        for k1, v1 in pairs(v.MSG_ID) do
            if string.match(k1, "_Ret$") or string.match(k1, "_ret$") then
                -- 响应消息头
                proxy:unregisterMsgId(v1, table.concat( { _prefix_tag_, "_", v1 }, ""))
            elseif string.match(k1, "_Send$") or string.match(k1, "_send$") then
                -- 请求消息头
                proxy:unregisterRootMsgId(v1, table.concat( { _prefix_tag_, "_", v1 }, ""))
            else
                assert(false, k1 .. " must be ended with _R(r)et or _S(s)end")
            end
        end
    end
end

return ToolCom
