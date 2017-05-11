#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

# 配置模块信息
_fileName = { 'name' : 'GDGameModel', 'context' : '游戏牌局模块' };

# 消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
   
    'Msg_GDGameStart_Ret': {
        'comment': '开局消息返回',
        'msgid' : 0x28010D,
        'msgtype': 'read',
        'fields': [
            ('int', 'GamePlayID'),
            ('short', 'PlayType'),
            ('char', 'ZoneWin'),
            ('int', 'FortuneBase'),
            ('char', 'Trump'),
            ('char', 'ContinueFlag'),
            ('char', 'Upgrade'),
            ('short', 'PlayTimeout'),
            ('short', 'JGTimeout'),
            ('short', 'FHTimeout'),
            ('char', 'Jingong'),
            ('loop',   {
                'loopTableKey' :           'playerArr',
                'loopReadType' :           'char',
                 'fields': [
                                ('int', 'UserID'),               
                                ('string', 'card'),
                                ('char', 'PlayLevel'),
                                ('string', 'UserName'),
                                ('int', 'IconID'),
                                ('short', 'VIP'),
                                ('char', 'Gender'),
                                ('string', 'Fortune'),
                                ('char', 'Ranking'),
                            ]
            }),
            ('int', 'NextPlayerID'),
            ('char', 'TrumpCard'),
            ('int', 'TCUserID1'),
            ('int', 'TCUserID2'),
        ],
    },
    'Msg_GDTribute_Send': {
        'comment': '进贡请求',
        'msgid' : 0x28010E,
        'msgtype': 'write',
        'fields': [
            ('int', 'GamePlayID'),
            ('char', 'Type'),
            ('int', 'UserID'),
            ('char', 'Card'),

        ],
    },
        'Msg_GDTribute_Ret': {
        'comment': '进贡返回',
        'msgid' : 0x28010E,
        'msgtype': 'read',
        'fields': [
            ('int', 'GamePlayID'),
            ('char', 'Type'),
            ('int', 'UserID'),
            ('char', 'Card'),

        ],
    },
	'Msg_GDExchangerCard_Ret': {
        'comment': '交换牌',
        'msgid' : 0x28010F,
        'msgtype': 'read',
        'fields': [
            ('int', 'GamePlayID'),
            ('loop',   {
                'loopTableKey' :           'exchangeArr',
                'loopReadType' :           'char',
                 'fields': [
            ('char', 'card'),
            ('int', 'FromUserID'),
            ('int', 'toUserID'),
            ]}),
             ('int', 'NextPlayerID'),
        ],
    },
        'Msg_GDPlayCard_Send': {
        'comment': '打牌请求',
        'msgid' : 0x280110,
        'msgtype': 'write',
        'fields': [
            ('int', 'GamePlayID'),
            ('int', 'UserID'),
            ('string', 'Card'),
            ('string', 'ReplaceCard'),
            ('int', 'NextPlayUseID'),
            ('char', 'Flag'),
            ('string', 'ParnerCard'),
            ('char', 'PlayCardType'),
            ('char', 'PlayCardValue'),
        ],
    },
                      
    'Msg_GDPlayCard_Ret': {
        'comment': '打牌返回',
        'msgid' : 0x280110,
        'msgtype': 'read',
        'fields': [
            ('int', 'GamePlayID'),
            ('int', 'UserID'),
            ('string', 'Card'),
            ('string', 'ReplaceCard'),
            ('int', 'NextPlayUseID'),
            ('char', 'Flag'),
            ('string', 'ParnerCard'),
            ('char', 'PlayCardType'),
            ('char', 'PlayCardValue'),
        ],
    },
   'Msg_GDGameOver_Ret': {
        'comment': '游戏结束',
        'msgid' : 0x280111,
        'msgtype': 'read',
        'fields': [
            ('int', 'GamePlayID'),
            ('int', 'FortuneTax'),
            ('char', 'Upgrade'),
            ('loop',   {
                'loopTableKey' :           'players',
                'loopReadType' :           'char',
                 'fields': [
            ('int', 'UserID'),
            ('char', 'Ranking'),
            ("string","Card"),
            ('string', 'Fortune'),
            ('string', 'TFortune'),
            ]}),
        ],
    },
    'Msg_GDResumeGame_Ret': {
        'comment': '游戏恢复',
        'msgid' : 0x280112,
        'msgtype': 'read',
        'fields': [
            ('int', 'GamePlayID'),
            ('int', 'GameZoneID'),
            ('short', 'PlayType'),
            ('char', 'ZoneWin'),
            ('int', 'FortuneBase'),
            ('char', 'Trump'),
            ('char', 'ContinueFlag'),
            ('char', 'Upgrade'),
            ('short', 'PlayTimeout'),
            ('short', 'JGTimeout'),
            ('char', 'Jingong'),
            ('char', 'Status'),
            ('int', 'LastPlayUserID'),
            ('string', 'LastPlayCards'),
            ('int', 'NextPlayUseID'),
            ('short', 'NextPlayTimeout'),
            ('loop',   {
                'loopTableKey' :           'players',
                'loopReadType' :           'char',
                 'fields': [
            ('int', 'UserID'),
            ('char', 'UserType'),
            ('string', 'Card'),
            ('char', 'PlayLevel'),
            ('string', 'UserName'),
            ('int', 'IconID'),
            ('short', 'VIP'),
            ('char', 'Gender'),
            ('string', 'Fortune'),
            ('char', 'Ranking'),
            ('char', 'JGCard'),
            ('char', 'RecvCard'),
            ]}),
            ('int', 'RoomMultiple'),
            ('int', 'LastRank1User'),
			('char', 'RecordCard'),
			('byteArray', 'RemainCard'),
            ('string', 'GameZoneName')
        ],
    },
    'Msg_GDTableUserState_Ret': {
        'comment': '续局桌子上玩家状态改变通知',
        'msgid' : 0x280113,
        'msgtype': 'read',
        'fields': [
            ('int', 'UserID'),
            ('char', 'Type'),
        ],
    },
    'Msg_GDTrusteeship_send': {
        'comment': '托管消息请求',
        'msgid' : 0x06010F,
        'msgtype': 'write',
        'fields': [
            ('int', 'GameID'),
            ('int', 'gameZoneID'),
            ('int', 'gameplayID'),
            ('int', 'UserID'),
            ('char', 'Type'),
        ],
    },
    'Msg_GDTrusteeship_Ret': {
        'comment': '续托管消息回复',
        'msgid' : 0x06010F,
        'msgtype': 'read',
        'fields': [
            ('int', 'GameID'),
            ('int', 'gameZoneID'),
            ('int', 'gameplayID'),
            ('int', 'UserID'),
            ('char', 'Type'),
        ],
    },
    'Msg_GDHoldAward_Ret': {
        'comment': '打到结算分奖励',
        'msgid' : 0x280114,
        'msgtype': 'read',
        'fields': [
            ('int', 'UserID'),
            ('int', 'gameZoneID'),
            ('char', 'trump'),
            ('char', 'result'),
            ('loop',   {
                'loopTableKey' :           'magics',
                'loopReadType' :           'short',
                 'fields': [
            ('string', 'MagicName'),
            ('int', 'MagicID'),
            ('int', 'MagicCount'),
            ('int', 'MagicFID'),
            ]}),
        ],
    },
    'Msg_GDUserInfo_send': {
        'comment': '请求玩家数据',
        'msgid' : 0x060804,
        'msgtype': 'write',
        'fields': [
            ('char', 'type'),
            ('int', 'UserID'),
            ('string', 'strParam1'),
            ('short', 'GameID'),
        ],
    },
    'Msg_GDGamePlayerInfo_Ret': {
        'comment': '对局中玩家数据',
        'msgid' : 0x060805,
        'msgtype': 'read',
        'fields': [
            ('int', 'UserID'),
            ('string', 'Nickname'),
            ('int', 'IconID'),
            ('short', 'VIP'),
            ('char', 'Gender'),
            ('string', 'Victories'),
            ('int', 'GamePoint'),
            ('int', 'NextLevelPoint'),
            ('short', 'GameLevel'),
        ],
    },                 
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
