#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

# 配置模块信息
_fileName = { 'name' : 'GDMatchModel', 'context' : '游戏比赛模块' };

# 消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
   'Msg_GDMatchData_Send': {
        'comment': '比赛数据请求',
        'msgid' : 0x280301,
        'msgtype': 'write',
        'fields': [
            ('char', 'Type'),
            ('int', 'Param1'),
            ('int', 'Param2'),

        ],
    },
    'Msg_GDMatchList_Ret': {
        'comment': '比赛列表',
        'msgid' : 0x280302,
        'msgtype': 'read',
        'fields': [
            ('loop',   {
                'loopTableKey' :           'MatchList',
                'loopReadType' :           'short',
                 'fields': [
                                ('int', 'MatchID'),               
                                ('string', 'MatchName'),
                                ('char', 'BeginType'),
                                ('string', 'Flag'),
                                ('string', 'Requirement'),
                                ('char', 'MyEnterFlag'),
                                ('int', 'EnterCount'),
                                ('char', 'EnterType'),
                                ('string', 'EnterData'),
                                ('char', 'EnterEnough'),
                                ('int', 'Countdown'),
                                ('int', 'Interval'),
                            ]
            }),
            ('loop',   {
                'loopTableKey' :           'PlayTypeList',
                'loopReadType' :           'short',
                 'fields': [
                    ('short',             'PlayType'),
                ],
            }),
        ],
    },
    'Msg_GDMatchInfo_Ret': {
        'comment': '比赛详情',
        'msgid' : 0x280303,
        'msgtype': 'read',
        'fields': [
            ('int', 'MatchID'),
            ('string', 'Name'),
            ('char', 'BeginType'),
            ('char', 'TeamWork'),
            ('int', 'TeammateID'),
            ('string', 'Requirement'),
            ('char', 'MyEnterFlag'),
            ('int', 'InstID'),
            ('int', 'Countdown'),
            ('int', 'Interval'),
            ('char', 'EnterType'),
            ('string', 'EnterData'),
            ('char', 'EnterEnough'),
            ('int', 'EnterCount'),
            ('string', 'Desc'),
            ('string', 'SignupTermDesc'),
            ('loop',   {
                'loopTableKey' :           'awardList',
                'loopReadType' :           'short',
                 'fields': [
                                ('short', 'BeginRankNo'),               
                                ('short', 'EndRankNo'),
                                ('string', 'Award'),
                                 ('loop',   {
                                             'loopTableKey' :           'magicList',
                                             'loopReadType' :           'short',
                                             'fields': [
                                                        ('int', 'MagicID'),
                                                        ('int', 'FID'),
                                                        ('string', 'MagicName'),
                                                        ('int', 'MagicCount'),
                                
                                                        ]
                                             }),
                            ]
            }),
            ('short','PlayType'),
        ],
    },
    'Msg_GDFoundMates_Ret': {
        'comment': '玩家列表',
        'msgid' : 0x280304,
        'msgtype': 'read',
        'fields': [
            ('char', 'Type'),
            ('loop',   {
                'loopTableKey' :           'mateList',
                'loopReadType' :           'short',
                 'fields': [
                                ('int', 'UserID'),               
                                ('string', 'Nickname'),
                                ('int', 'IconID'),
                                ('char', 'OnlineFlag'),
                                ('int', 'Param1'),
                                ('char', 'Gender'),
                            ]
            }),
        ],
    },
    'Msg_GDMatchAddBuddy_Send': {
        'comment': '比赛添加好友发送',
        'msgid' : 0x28030A,
        'msgtype': 'write',
        'fields': [
            ('char', 'type'),
            ('int', 'toUserID'),
            ('int', 'IconID'),
            ('string', 'nickname'),
            ('int', 'Param1'),
            ('int', 'Param2'),
            ('char', 'Gender'),
        ],
    },
    'Msg_GDMatchAddBuddy_Ret': {
        'comment': '比赛添加好友接受',
        'msgid' : 0x28030A,
        'msgtype': 'read',
        'fields': [
            ('char', 'type'),
            ('int', 'toUserID'),
            ('int', 'IconID'),
            ('string', 'nickname'),
            ('int', 'Param1'),
            ('int', 'Param2'),
           ('char', 'Gender'),
        ],
    },
    'Msg_GDMatchEnter_Send': {
        'comment': '比赛报名和退赛',
        'msgid' : 0x280305,
        'msgtype': 'write',
        'fields': [
            ('char', 'Type'),
            ('int', 'MatchID'),
            ('char', 'EnterType'),
            ('int', 'EnterData'),
            ('int', 'FriendID'),
            ('char', 'Confirm'),
        ],
    },
    'Msg_GDMatchNotifyUser_Ret': {
        'comment': '比赛通知消息',
        'msgid' : 0x280306,
        'msgtype': 'read',
        'fields': [
            ('char', 'Type'),
            ('int', 'MatchID'),
            ('string', 'MatchName'),
            ('int', 'InstMatchID'),
            ('int', 'Param1'),
            ('string', 'RespInfo'),
        ],
    },
    'Msg_GDMatchGameStart_Ret': {
        'comment': '比赛对局开局',
        'msgid' : 0x280307,
        'msgtype': 'read',
        'fields': [
            ('int', 'GamePlayID'),
            ('int', 'InstMatchID'),
            ('short', 'PlayType'),
            ('char', 'ZoneWin'),
            ('short', 'SetNo'),
            ('short', 'PlayNo'),
            ('int', 'ScoreBase'),
            ('char', 'Trump'),
            ('short', 'PlayTimeout'),
            ('short', 'FHTimeout'),
            ('loop',   {
                'loopTableKey' :           'playerList',
                'loopReadType' :           'char',
                 'fields': [
                                ('int', 'UserID'),               
                                ('string', 'card'),
                                ('string', 'UserName'),
                                ('int', 'IconID'),
                                ('short', 'VIP'),
                                ('char', 'Gender'),
                                ('int', 'Score'),
                                ('int', 'MRanking'),
                            ]
            }),
            ('int', 'NextPlayerID'),
            ('char', 'TrumpCard'),
            ('int', 'TCUserID1'),
            ('int', 'TCUserID2'),
        ],
    },
    'Msg_GDMatchGameOver_Ret': {
        'comment': '比赛对局结束',
        'msgid' : 0x280308,
        'msgtype': 'read',
        'fields': [
            ('int', 'GamePlayID'),
            ('int', 'InstMatchID'),
            # ('short', 'PlayType'),
            ('loop',   {
                'loopTableKey' :           'playerList',
                'loopReadType' :           'char',
                 'fields': [
                                ('int', 'UserID'), 
                                ('char', 'Ranking'),
                                ('int', 'MRanking'),          
                                ('string', 'Card'),
                                ('int', 'Score'),
                                ('int', 'TScore'),
                            ]
            }),
        ],
    },
    'Msg_GDMatchResumeGame_Ret': {
        'comment': '比赛恢复对局',
        'msgid' : 0x280309,
        'msgtype': 'read',
        'fields': [
            ('int', 'GamePlayID'),
            ('int', 'MatchID'),
            ('string', 'MatchName'),
            ('int', 'InstMatchID'),
            ('short', 'PlayType'),
            ('char', 'ZoneWin'),
            ('short', 'SetNo'),
            ('short', 'PlayNo'),
            ('short', 'NeedPlayNo'),
            ('int', 'WinCount'),
            ('int', 'PlayerCount'),
            ('int', 'ScoreBase'),
            ('char', 'Trump'),
            ('short', 'PlayTimeout'),
            ('int', 'LastPlayUserID'),
            ('string', 'LastPlayCards'),
            ('int', 'NextPlayUseID'),
            ('short', 'NextPlayTimeout'),

            ('loop',   {
                'loopTableKey' :           'playerList',
                'loopReadType' :           'char',
                 'fields': [
                                ('int', 'UserID'), 
                                ('char', 'UserType'),
                                ('string', 'card'),
                                ('string', 'UserName'),
                                ('int', 'IconID'),
                                ('short', 'VIP'),
                                ('char', 'Gender'),
                                ('int', 'Score'),
                                ('int', 'MRanking'),          
                              
                            ]
            }),
            ('char', 'BeginType'),
        ],
    },
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
