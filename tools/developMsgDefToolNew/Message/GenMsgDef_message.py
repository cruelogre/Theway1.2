#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息
_fileName = { 'name' : 'messageModel', 'context' : '消息公告模块' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_MsgListRequest_send': {
        'comment': '获取消息列表',
        'msgid' : 0x040101,
        'msgtype': 'write', 
        'fields': [
            ('char',                      'Boxid'),
            ('short',                     'start'),
            ('short',                      'count'),
        ],
    },
    'Msg_MsgContentRequest_send': {
        'comment': '获取消息内容 公告',
        'msgid' : 0x040104,
        'msgtype': 'write', 
        'fields': [
            ('int',                      'Msgid'),
            ('char',                     'Boxid'),
        ],
    },
    'Msg_MsgContent_Ret': {
        'comment': '公告详细',
        'msgid' : 0x040105,
        'msgtype': 'read', 
        'fields': [
            ('string',                'Content'),
            ('char',                'Response'),
            ('char',                'haveNew'),
            ('int',                'Msgid'),
            ('char',                'Boxid'),
        ],
    }, 
    'Msg_UserMsgDataReq_send': {
        'comment': '请求玩家消息箱数据',
        'msgid' : 0x040B01,
        'msgtype': 'write', 
        'fields': [
            ('char',                      'Type'),
            ('string',                     'MsgID'),
            ('int',                      'Param1'),
            ('int',                      'Param2'),
        ],
    },
    'Msg_MsgList_Ret': {
        'comment': '未读消息列表',
        'msgid' : 0x040B02,
        'msgtype': 'read', 
        'fields': [
            ('loop',   {
                'loopTableKey' :           'messages',
                'loopReadType' :           'short',
                 'fields': [
                    ('string',             'MsgID'),
                    ('int',                'FromWay'),
                    ('char',                'MsgType'),
                    ('short',               'MsgSubType'),
                    ('string',              'CreateTime'),
                    ('string',              'Content'),
                    ('loop',   {
                        'loopTableKey' :           'rewards',
                        'loopReadType' :           'short',
                         'fields': [
                            ('char',             'ReferType'),
                            ('int',                'Refer1'),
                            ('int',                'Refer2'),
                            ('string',            'ReferDesc'),
                        ],
                    }),
                ],
            }),
            ('loop',   {
                'loopTableKey' :           'Subjects',
                'loopReadType' :           'none',
                 'fields': [
                     ('string',              'Subject'),
                ],
            }),
        ],
    }, 
    'Msg_NoticeList_Ret': {
        'comment': '公告列表',
        'msgid' : 0x040103,
        'msgtype': 'read', 
        'fields': [
            ('loop',   {
                'loopTableKey' :           'notices',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',             'MsgID'),
                    ('char',                'Owner'),
                    ('int',                'OwnerID'),
                    ('string',                'ModifiedTime'),
                    ('string',                'Subject'),
                ],
            }),
        ],
    }, 
    'Msg_SendTalk_Ret': {
        'comment': '发送滚报消息',
        'msgid' : 0x040401,
        'msgtype': 'read', 
        'fields': [
            ('int',             'fromID'),
            ('string',             'fromName'),
            ('loop',   {
                'loopTableKey' :           'User2Users',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',              'fromUserID'),
                    ('string',           'fromNickName'),
                ],
            }),
            ('char',                'rollType'),
            ('int',                'EvenType'),
            ('char',                'language'),
            ('string',                'Content'),
            ('short',                'DisplayInterval'),
            ('loop',   {
                'loopTableKey' :           'flashinfos',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',              'moduleID'),
                ],
            }),
            ('string',              'currDateTime'),
        ],
    }, 
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
