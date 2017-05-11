-- template_proj proxy registry define

local registry = {
    HALL_SCENE = "hall.proxy.HallSceneProxy";
    HALL_SIGNIN = "hall.proxy.SignInProxy";
    HALL_SETTING = "hall.proxy.SettingProxy";
    HALL_CHOORSERM = "hall.proxy.ChooseRoomProxy";
    HALL_StoreProxy = "hall.proxy.StoreProxy";
    HALL_MATCH = "hall.proxy.MatchProxy";
    HALL_MessageProxy = "hall.proxy.MessageProxy";
	
	HALL_TaskProxy = "hall.proxy.TaskProxy";
    -- 个人详情
    UserInfoProxy = "hall.proxy.UserInfoProxy";
    -- 充值委托
    ChargeProxy = "app.customCharge.ChargeProxy";
    -- 私人房
    SiRenRoomProxy = "hall.proxy.SiRenRoomProxy";
    -- 兑换中心
    ExchangeProxy = "hall.proxy.ExchangeProxy";
    -- 排行榜
    RankProxy = "hall.proxy.RankProxy";
	--房间聊天
	ROOMCHAT 		= "hall.proxy.RoomChatProxy";
	--社交
	SOCIALCONTACT 		= "hall.proxy.SocialContactProxy";
}

return registry