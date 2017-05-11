#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

# 配置模块信息
_fileName = { 'name' : 'userInfoModel', 'context' : '用户信息模块' };

# 消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_NewUpdateUserInfo_send': {
        'comment': '更新用户信息',
        'msgid' : 0x01012e,
        'msgtype': 'write',
        'fields': [
            ('int', 'Type'),
            ('string', 'Param1'),
            ('string', 'Param2'),
            ('string', 'Param3'),
            ('string', 'Param4'),
        ],
    },
    'Msg_GDUserInfo_send': {
        'comment': '请求灌蛋玩家个人信息',
        'msgid' : 0x060804,
        'msgtype': 'write',
        'fields': [
            ('char', 'Type'),
            ('int', 'UserID'),
            ('string', 'strParam1'),
            ('short', 'GameID'),
        ],
    },
    'Msg_GDUserInfo_Ret': {
        'comment': '灌蛋玩家个人信息',
        'msgid' : 0x060806,
        'msgtype': 'read',
        'fields': [
            ('int', 'UserID'),
            ('string', 'Nickname'),
            ('int', 'IconID'),
            ('short', 'VIP'),
            ('char', 'Gender'),
            ('string', 'Region'),
            ('string', 'GameCash'),
            ('string', 'Diamond'),
        ],
    },                 
   'Msg_RUserGameScore_Ret': {
        'comment': '玩家游戏数据信息',
        'msgid' : 0x060807,
        'msgtype': 'read',
        'fields': [
            ('int', 'UserID'),
            ('short', 'GameID'),
            ('loop',   {
                'loopTableKey' :           'scoreList',
                'loopReadType' :           'char',
                 'fields': [
                                ('short', 'PlayType'),               
                                ('int', 'AllPlay'),
                                ('int', 'AllWin'),
                            ]
            }),
        ],
    },
    'Msg_GDAwardNotify_Ret': {
        'comment': '平台奖励通知',
        'msgid' : 0x060808,
        'msgtype': 'read',
        'fields': [
            ('char', 'Type'),
            ('loop',   {
                'loopTableKey' :           'awardList',
                'loopReadType' :           'char',
                 'fields': [
                                ('char', 'AwardType'),               
                                ('int', 'MagicID'),
                                ('int', 'FID'),
                                ('int', 'AwardData'),
                            ]
            }),
        ],
    },
    'Msg_GDTaskList_Ret': {
        'comment': '灌蛋的每日任务',
        'msgid' : 0x06080A,
        'msgtype': 'read',
        'fields': [
           ('loop',   {
                'loopTableKey' :           'TaskList',
                'loopReadType' :           'short',
                 'fields': [
                                ('int', 'TaskID'),               
                                ('char', 'TaskType'),
                                ('int', 'FID'),
                                ('int', 'TaskParam1'),
                                ('string', 'Name'),
                                ('string', 'Description'),
                                ('int', 'IconID'),
                                ('int', 'TargetValue'),
                                ('int', 'MagicID'),
                                ('char', 'Status'),
                                ('int', 'FinishCount'),
                            ]
            }),
        ],
    },
	'Msg_BindPhoneReq_send': {
        'comment': '手机绑定|解除绑定请求',
        'msgid' : 0x010126,
        'msgtype': 'write',
        'fields': [
            ('int', 'userID'),
            ('string', 'Mdn'),
            ('char', 'Type'),
			('int', 'verifyCode'),
			('int', 'Sp'),
			('string', 'Userpwd'),
			('int', 'gameID'),
        ],
    },
	'Msg_unregisterReq_send': {
        'comment': '用户注销请求',
        'msgid' : 0x020103,
        'msgtype': 'write',
        'fields': [
            ('int', 'UserID'),
            ('string', 'ExitType'),
        ],
    },
    'Msg_ReqUserInfo_send': {
        'comment': '用户信息请求',
        'msgid' : 0x010101,
        'msgtype': 'write',
        'fields': [
            ('int', 'ObjectID'),
            ('char', 'Type'),
            ('int', 'Parameter1'),
            ('int', 'Parameter2'),
            ('string', 'StrParam'),
        ],
    },
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
