local languageString = { }
-- 根据模块划分
-- 使用方式 i18n:get('str_common', 'comm_appname')
-- 根据模块Key，字符串Key获得文字
-----------------------[[ 配置区Start ]]-----------------------------
-- 通用模块
languageString['str_common'] =
{
    ['comm_sure'] = '确定',
    ['comm_cancel'] = '取消',
    ['comm_submit'] = '提交',
    ['comm_quit_text'] = '是否退出游戏？',
    ['comm_net_closed'] = '您的设备未开启网络连接。请检查网络设备后，重新连接游戏',
    ['comm_net_discontent'] = '网络连接已断开，请重新连接网络',
    ['comm_reconnect'] = '重新连接',
    ['comm_net_connectding'] = '正在为您重新连接中',
    ['comm_loading'] = '资源加载中，请稍候',
    ['comm_waiting'] = '数据加载中，请稍候',
    ['double_login_notify'] = "您的账号已在其他设备上登录",
    ['comm_telNum'] = '400-680-1212',
    ['wan'] = '万',
    ['yi'] = '亿',
    ['yuan'] = '元',
    ['diamond'] = '钻石',
    ['gold'] = '金币',
    ["male"] = "男",
    ["female"] = "女",
    ['comm_minus0'] = '分',
    ['comm_minus1'] = '分钟',
    ['comm_second'] = '秒',
    ['comm_yes'] = '是',
    ['comm_no'] = '否',
    ['comm_ShareContent'] = '独创组队竞技玩法，免费大奖拿到手软',
}

languageString['str_hall'] =
{
    ['hall_waiting'] = '敬请期待!',
    -- ['hall_game_exit'] = '明天签到可得|255,241,10::%d金币|奖励!',
    ['hall_game_exit'] = '明天签到可得更多奖励！',
    ['hall_game_exit_notsign'] = '别忘了领取签到奖励！',
    ['hall_game_notice_scroll'] = '老司机，一起怼他！！！！',
    ['hall_notice_title'] = '公告',
	['hall_people_count'] = '人',
}

-- 个人消息箱
languageString['str_mail'] =
{
    -- 操作消息附件
    operate_attach_succ = "领取成功",
    operate_attach_fail = "网络异常领取失败，请稍后再试",
}

-- 个人详情面板
languageString['str_userInfo'] =
{
    -- 操作消息附件
    request_fail = "网络异常，请稍后再试。",
    sex_prefix = "性别：",
    id_prefix = "ID：",
    region_prefix = "地区：",
    unkown_region = "未知",
    modify_fail = "修改失败",
    modify_succ = "修改成功",
    title_edit = "编辑个人信息",
    title_modify_head = "更换头像",
    title_modify_nick = "更改昵称",
    title_modify_gender = "选择性别",
    uploadSuccess = "头像上传成功，正在等待审核......",
    uploadfailure = "头像上传失败",
    succ_send = "发送成功",
    succ_login = "登录成功",
    succ_logout = "登出成功",
    waiting = "登录账号中，请稍等",
    login = "登录",
    login_1 = "登录已有账号",
    register = "一键注册",
    register_1 = "注册",
    find_psw = "找回密码",
    double_login = "不能重复登录",
    swtich_tourist = "切换账号",
    set_psw = "设置密码",
    reset_psw = "重置密码",
    switch_account = "切换账号",
    input_verify_code = "填写验证码",
    get_verify_code = "获取验证码",
    verify = "验证信息",
    invalid_nick = "您的昵称中含有敏感词汇，修改失败",
    error_verify = "验证码错误",
    send_again = "重新发送(%d)",
    keep_login_dialog_cntnt = "登录失败，请重新登录原有账号",
    login_fail ="登录失败，稍后重试",
    btn_relogin = "重新登录",
    btn_login_tourist = "登录游客账号",
    send = "发送",
    diff_psw = "两次输入密码不一致",
    your_phone = "您的手机号码：%s",
    error_verify_code = "验证码错误",
    invalid_psw = "密码格式不正确",
    invalid_psw_1 = "密码只能由数字或字母组成",
    error_account_psw = "账号或者密码错误，请重新输入",
    bindphone1 = "未定义错误",
    bindphone2 = "验证码发送成功",
    bindphone3 = "您输入的手机号格式不正确",
    bindphone4 = "参数错误",
    bindphone5 = "请60秒后重试",
    bindphone6 = "您输入的手机号未绑定对应蛙号！",
    bindphone7 = "获取验证码次数过多！请明日再操作！",
    bindphone8 = "手机号格式错误或者手机号未绑定",
    bindphone9 = "绑定成功",
    bindphone10 = "手机号或验证码错误",
    bindphone11 = "手机号已绑定过其他蛙号",
    bindphone12 = "蛙号已绑定过手机号，需要先解绑",
    bindphone13 = "用户密码输入错误",
    bindphone14 = "其他错误",
    bindphone15 = "非解绑状态，无需解绑",
    bindphone16 = "重置密码成功",
    bindphone17 = "非解绑状态，不能重置密码",
	['add_friend'] = "+好友",
	['is_friend'] = "已是好友",
}

languageString['str_store'] =
{
    ['store_prop_confirm'] = '是否花费%d钻石购买%s×%d',
    ['store_charge_confirm2'] = '购买成功将会进行扣费，是否支付%d元购买%s',
    ['store_otherGet'] = '加赠',
    ['showBtnRich1'] = '%s;;|%d',
    ['prop_buy_tips1'] = '钻石不足，请更换支付方式',
    ['prop_buy_tips2'] = '钻石不足，无法购买',
    ['ChargeCancel'] = '您已经取消支付！',
    ['ChargeFailue'] = '支付失败！',
}


languageString['str_setting'] =
{
    ['setting_title'] = '设置',
    ['setting_bg_music'] = '背景音乐',
    ['setting_sound_effect'] = '游戏音效',
    ['setting_shake'] = '震动',
    ['setting_card_voice'] = '方言报牌',
    ['setting_game_mode'] = '游戏玩法',
    ['setting_feedback'] = '问题反馈',
    ['setting_clear_cache'] = '清理缓存',
    ['setting_check_update'] = '检查更新',
    ['setting_about_us'] = '关于我们',
    ['setting_current_version'] = '当前版本',
    ['setting_privicy'] = '隐私政策',
    ['setting_service_protocol'] = '服务协议',
    ['setting_feedback_placeholder'] = '您在游戏中遇到的任何问题，或是对我们的产品及服务有任何的困惑、建议甚至不满，都欢迎您在这里向我们倾诉（100字以内）。我们会协助您处理您所遇到的问题，认真拜读您留下的每一个字。',
    ['setting_faq'] = '常见问题',
    ['setting_guandan'] = '游戏规则',
    ['setting_feedback_contentempty'] = '',
    ['setting_feedback_empty'] = '内容不能为空',
    ['setting_feedback_toomuch'] = '内容不能超过%d字',
    ['setting_version_id'] = '版本号',
    ['setting_copyright'] = '版权所有：深圳市金环天朗信息技术服务有限公司',
    ['setting_clear_cache_tip'] = '清除缓存后部分数据可能需要重新下载，是否继续？',
    ['setting_clear_cache_ok'] = '缓存清除成功',
    ['setting_no_update'] = '老板，您的游戏已经是最新版了~',

}
languageString['str_sign'] =
{
    ['sign_card_not_enough'] = '补签卡不足，获取补签卡',
    ['sign_today_ok'] = '今日签到成功，获得%s*%d',
    ['sign_comsume_card'] = '成功使用补签卡，获得%s*%d',
    ['sign_award_ok'] = '恭喜您连续签到%d天，获得%s',
    ['sign_card_number'] = '当前补签卡：%d个',
    ['sign_award_failed'] = '尚未连续签到满%d天，别忘了补签哦！',
    ['sign_day'] = '%d天',
    ['sign_full'] = '满月',
	['sign_today'] = '签到',
	['sign_before'] = '补签',
	['sign_all_over'] = '已签到',
}

languageString['str_chooserm'] =
{
    ['chooserm_account'] = '人',
    ['chooserm_minscore'] = '底分',
    ['chooserm_gold_not_enough'] = '金币不足，无法进入该房间',
    ['chooserm_gold_too_many'] = '您已经很厉害了，正在为您匹配更高的场次',
    ['chooserm_go_lower'] = '去低倍场',
    ['chooserm_buy_gold'] = '购买金币',

}

languageString['str_guandan'] =
{
    ['guandan_continue'] = '继续',
    ['guandan_wait_desk'] = '还有|255,247,1::%d|桌正在比赛中，请稍后',
    ['guandan_wait_begin'] = '245,201,45::%d|人开赛',
    ['guandan_wait_begin_deque'] = '245,201,45::%d|队开赛',
    ['guandan_wait_currank'] = '当前排名: |245,201,45::%d/%d',
    ['guandan_wait_eliminate'] = '共|245,201,45::%d|人被我淘汰',
    ['guandan_wait_eliminate_deque'] = '共|245,201,45::%d|队被我淘汰',
    ['guandan_wait_promotion'] = '245,201,45::%d|人晋级',
    ['guandan_wait_promotion_deque'] = '245,201,45::%d|队晋级',
    ['guandan_wait_settment'] = '恭喜|224,49,32::%s|在|224,49,32::【%s】|中获得',
    ['guandan_wait_settment_rank'] = '第%d名',
    ['guandan_myplayer_set'] = '第|255,23,0::%d|/%d轮-第|255,23,0::%d|/%d局',
    ['guandan_myplayer_rank'] = '本轮后排名前|255,23,0::%d|名',
    ['guandan_myplayer_rank_deque'] = '本轮后排名前|255,23,0::%d|队',
    ['guandan_myplayer_endSet'] = '本轮后确定名次',
    ['guandan_setlayer_play'] = '第|254,24,1::%d|轮-第|254,24,1::%d|局',
    ['guandan_setlayer_cannotexit'] = '比赛中不能退出游戏',
    ['guandan_setlayer_cannotexit_time'] = '比赛即将开始不能退出游戏',
    ['guandan_setlayer_roompoint'] = '底分:|255,165,0::%d',
    ['guandan_setlayer_Banner'] = '恭喜|224,255,0::%s|在|224,255,0::%s|升级到|255,255,0::%s',
    ['guandan_setlayer_Banner_Fail'] = '坚持就是胜利',
    ['guandan_stitute'] = '请勿频繁托管',
    ['guandan_Master'] = '房主退出将解散当前房间，是否退出',
    ['guandan_NoMaster'] = '牌局尚未完成，是否离开房间',
    ['guandan_SirenJieSan'] = '房间已解散',
}


languageString['str_match'] =
{
    ['match_detail'] = '赛事详情',
    ['match_condition'] = '报名条件',
    ['match_reward'] = '排名奖励',
    ['match_free_sign'] = '免费报名',
    ['match_has_signed'] = '已报名',
    ['match_sign_fee'] = '报名费:%d',
    ['match_sign_fee_s'] = '报名费:',
    ['match_sign_not_enough'] = '报名资格不足',
    ['match_sign_ok'] = '报名成功',
    ['match_sign_failed'] = '报名失败',
    ['match_sign_ok_with_pay'] = '报名成功，消耗',
    ['match_sign_quit'] = '退赛',
    ['match_will_start'] = '您报名的%s将在%s后开赛，是否提前进入房间？',
    ['match_will_start_1'] = '您报名的%s将于%s后开始，请安排比赛时间',
    ['match_will_start_2'] = '您报名的%s将于%s后开始，是否放弃当前比赛奖励，参加%s？',
    ['match_will_start_3'] = '您报名的%s将于%s后开始，是否托管该场牌局，参加%s？',
    ['match_secound'] = '秒',
    ['match_hour'] = '时',
    ['match_minus'] = '分',
    ['match_cancel'] = '人数不足，%s被取消',
    ['match_cancel_getaward'] = '人数不足，%s被取消，报名费已退回',
    ['match_quit_ok'] = '退赛成功',
    ['match_quit_ok_with'] = '退赛成功，返还%s',
    ['match_quit_ok_2'] = '退赛成功，比赛已开始，不返回门票',
    ['match_cant_quit_1'] = '正在开赛中，不允许退赛',
    ['match_cant_quit_2'] = '不在比赛中，不允许退赛',
    ['match_friend_cancel'] = '好友%s退赛',
    ['match_invite_friend_cancel'] = '%s已退赛，可自己参赛或邀请其他好友',
    ['match_award_count'] = '前%d名有奖',
    ['match_not_find_friend'] = '未搜索到好友',
    ['match_sure_invite'] = '确认组队',
    ['match_invite_success'] = '组队成功',
    ['match_invite_failed'] = '组队失败',
    ['match_invite_fee'] = '组队:%s',
    ['match_invite_friend'] = '邀请朋友',
    ['match_invited_team_ok'] = '与好友%s组队成功',
    ['match_exit_cancel1'] = '待会回来',
    ['match_exit_sure1'] = '继续等待',
    ['match_exit_cancel2'] = '点错了',
    ['match_exit_sure2'] = '先走了',
    ['match_exit_msg1'] = '比赛即将开始，退出房间容易错过比赛',
    ['match_exit_msg2'] = '比赛即将开始，确定退赛吗？',
    ['match_invite_wait'] = '邀请已发出，请等候',
    ['match_invite_in_game'] = '%s邀请你参加您参加%s',
    ['match_text'] = '比赛',
    ['match_has_start'] = '比赛已开赛，无法参与该比赛',
    ['match_winxin_title'] = '邀请微信好友下载',
    ['match_winxin_content'] = '通过微信发送下载页，好友点击下载',
    ['match_face_title'] = '面对面加好友',
    ['match_face_content'] = '与身边的朋友快速加好友',
    ['match_how_title'] = '如何成为游戏好友并组队参赛？',
    ['match_how_content'] = '1、若好友没下载应用，可点击【邀请微信好友下载】推送下载页；\n2、下载后，双方先通过报名组队赛，并使用面对面加好友功能，成为游戏好友；\n3、成为游戏好友后，便可以在牌友中选择好友共同参加组队赛。',
}

languageString['str_bankrupt'] =
{
    ['bankrupt_get_gold_1'] = '还需%s金币进入该房间',
    ['bankrupt_get_gold_2'] = '还需%s金币继续游戏',
    ['bankrupt_go_lower'] = '前往低倍场',
    ['bankrupt_get_charity'] = '领取救济金',
    ['bankrupt_canot_get_count'] = '今日救济金已全部领取',
    ['bankrupt_get_now'] = '立即领取',

    ['bankrupt_get_success'] = '成功领取%d金币救济金',

}

languageString['str_hotupdate'] =
{
    ['hot_title_download'] = '游戏下载',
    ['hot_title_update'] = '游戏更新',
    ['hot_btn_text'] = '立即下载',
    -- 第|254,24,1::%d|轮-第|254,24,1::%d|局
    ['hot_content_file'] = '为了更好的游戏体验，请您更新至最新版本，本次更新约|0xEF,0x42,0x40::%s|，建议您在稳定的网络环境下进行更新。',
    ['hot_update_success'] = '更新成功',
    ['hot_update_canot_close'] = '请完成更新后进行游戏',
    ['packge_update'] = '发现新版本，前往更新？',
}

languageString['str_roomchat'] =
{
    ['char_input_placeholder'] = '该说点什么好呢？...',
    ['char_input_empty'] = '发送内容不能为空',
    ['char_slow_down'] = '您发送的消息太多了，稍微休息一下吧',

}
languageString['str_dailytask'] =
{
    ['btn_go'] = '前往',
    ['btn_get'] = '领取',
    ['btn_over'] = '已完成',

}
languageString['str_firstcharge'] =
{
    ['btn_buy'] = '%d 元购买',
}

-- 私人房
languageString['str_sirenrm'] =
{
    join_room = "加入房间",
    buy_card = "购买房卡",
    ju = "局",
    guo = "过",
    ju_shu = "局数",
    win_rate = "胜率",
    tou_you = "头游",
    zha_6 = "六炸",
    flush = "同花顺",
    score = "积分",
    release_room = "解散房间",
    quit_room = "退出房间",
    back_room = "返回房间",
    room_released = "房间已被解散",
    history = "历史记录",
    start_game = "开始游戏",
    invalid_status = "网络异常，请重新进入",
    title_invite = "邀请朋友",
    title_fanbei1 = "六炸翻倍",
    title_fanbei2 = "同花顺翻倍",
    title_fanbei3 = "六炸/同花顺翻倍",
    title_receive_invite = "房间号：%d",
    warn_jiesan = "牌局未开始不会消耗房卡，是否解散房间",
    create_room = "创建房间",
    create_room_fail = "房卡不足，创建房间失败",
    hint_input_room = "请输入房间号...",
    exception_create_room = "创建房间异常，请稍后再试",
    exception_room_act = "房间操作异常，请稍后再试",
    share_content = '我在%s%d号私人房等你，不见不散呦',
    share_title = "您有一条游戏邀请",
}

-- 兑换中心
languageString["str_exchange"] = {
    title_1 = "兑换中心",
    title_2 = "商品兑换",
    title_3 = "历史记录",
    item_left = "库存:%d",
    item_left_much = "库存:无限",
    no_history = "暂无历史记录",
    invalid_receiverInfo = "输入信息不符合规则，请修改后重新提交",
    -- 配置了不支持的物品类型。
    invalid_object_type = "网络异常，请稍后重试",
    not_enough_stock = "您所兑换的商品已被抢购一空，下次早点来吧。",
    not_enough_crystal = "还需要%d水晶才能兑换此商品",
    finish_exchange = "已收货",
    sending = "发货中",
    committing = "待发货",
    waiting_exchange = "等待兑换",
    fail_to_exchange = "兑换失败",
    title_exchange_date = "兑换日期",
    title_exchange_name = "商品名称",
    title_exchange_cost = "消耗水晶",
    title_exchange_state = "状态",
    reward_send_delay = "奖励将于7个工作日内发放",
    request_register_account = "注册绑定手机后才能兑换该商品哦~",
    exchange_success = "兑换成功，请等待发货",
    exchange_fail = "兑换失败，请稍后再试",
}

languageString["str_rank"] =
{
    not_in_rank = "未上榜",
}

languageString["str_cardrecorder"] =
{
    success_use_recorder = "成功使用1天记牌器",
    not_enough_zuan = "钻石不足",
    buy_card_recorder_dialog = "是否消耗%d钻石使用1天记牌器",
}

languageString['str_bullfighting'] =
{
    ['bull_join_room_fail'] = '进入房间失败',
    ['bull_money_not_enough'] = '筹码不足',
    ['bull_play_other'] = '在玩其他场次',
    ['bull_room_limit'] = '房间已达到限制',
    ['bull_have_no_desk'] = '没有匹配到空闲桌子',
    ['bull_exit_room'] = '退出房间',
    ['bull_repeat'] = '重新匹配',
    ['bull_haveNiu_havelook'] = '您的牌有牛，仔细看看吧！',
    ['bull_haveNiu_Tips'] = '选中三张牌总和为10的倍数才有牛哦',
    ['bull_cannotexit'] = '牌局进行中，请勿提前离开',
}

languageString['str_cardpartner'] =
{
    ['partner_yestoday'] = '昨天',
	['partner_userid_empty'] = '搜索帐号ID不能为空',
	['partner_search_placeholder'] = '搜索游戏ID',
	['partner_my_id'] = '我的ID：%s',
	['partner_request_send'] = '好友请求已发送',
	['char_input_placeholder'] = '说点什么好呢',
	['chat_content_empty'] = '发送内容不能为空',
	['wx_share_title'] = '收到一条好友申请',
	['wx_share_content'] = '加入《%s》，与我成为好友，一起赢奖励吧！我的ID：%s',
	['partner_invite_wait'] = '邀请已发出，请等候',
	['partner_invite_refuse'] = '%s拒绝了您的邀请',
	['partner_chat_not_friend'] = '我们已经不是好友关系，请先添加为好友',
	['partner_delete_confirm'] = '确认删除好友？',
}
-----------------------[[ 配置区End ]]-----------------------------
return languageString