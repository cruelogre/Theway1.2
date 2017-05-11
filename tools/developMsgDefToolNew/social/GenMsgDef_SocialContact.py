#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息
_fileName = { 'name' : 'SocialContactModel', 'context' : '社交模块' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_RSCData_Req': {
        'comment': '请求社交数据',
        'msgid' : 0x06081F,
        'msgtype': 'write', 
        'fields': [
            ('char',                      'type'),
            ('int',                     'Param1'),
            ('short',                      'Start'),
            ('short',                      'Count'),
            ('string',                      'StrParam1'),
        ],
    },
                      
       'Msg_RSCBuddyList_Ret': {
        'comment': '好友列表',
        'msgid' : 0x060820,
        'msgtype': 'read', 
        'fields': [
            ('char',                      'Type'),
            ('loop',   {
                'loopTableKey' :           'friendList',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',             'UserID'),
                    ('string',            'Nickname'),
                    ('int',            'IconID'),
                    ('char',            'Gender'),
                    ('string',            'GameCash'),
                    ('string',            'Diamond'),
                    ('char',            'OnlineFlag'),
                    ('int',            'Param1'),
                ],
            }),
        ],
    },
       'Msg_RSCBuddyTalk_Req': {
        'comment': '好友聊天',
        'msgid' : 0x060821,
        'msgtype': 'write', 
        'fields': [
            ('short',                      'type'),
            ('int',                      'FromUserID'),
            ('int',                      'ToUserID'),
            ('string',                      'Content'),
            ('string',                      'TalkMsgID'),
          
        ],
    },
       'Msg_RSCBuddyTalk_Ret': {
        'comment': '好友聊天',
        'msgid' : 0x060821,
        'msgtype': 'read', 
        'fields': [
            ('short',                      'type'),
            ('int',                      'FromUserID'),
            ('int',                      'ToUserID'),
            ('string',                      'Content'),
            ('string',                      'TalkMsgID'),
          
        ],
    },
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
