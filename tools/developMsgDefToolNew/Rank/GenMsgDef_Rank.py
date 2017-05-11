#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息
_fileName = { 'name' : 'ranknetModel', 'context' : '排行榜模块（社区关系请求）' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_MemberRequest_send': {
        'comment': '社区关系请求',
        'msgid' : 0x030101,
        'msgtype': 'write', 
        'fields': [
            ('int',                   'UserID'),
            ('int',                     'ObjectID'),
			('char',                     'Type'),
			('short',                     'Start'),
			('short',                     'Count'),
			('int',                     'Parameter1'),
			('int',                     'Parameter2'),
        ],
    },
    'Msg_RankInfo_Ret': {
        'comment': '排行榜数据',
        'msgid' : 0x03011b,
        'msgtype': 'read', 
        'fields': [
            ('int',                    'TopType'),
            ('string',                    'TimeStr'),
            ('int',                    'MyNo'),
            ('string',                     'MyScore'),
			('loop',   {
                'loopTableKey' :           'rankInfo',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',             'No'),
                    ('int',            'UserID'),
                    ('string',            'Nickname'),
					('string',            'Province'),
					('string',            'Score'),
                ],
            }),
			('loop',   {
                'loopTableKey' :           'headInfo',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',             'IconID'),
                    ('string',            'IconTS'),
                ],
            }),
			('loop',   {
                'loopTableKey' :           'otherInfo',
                'loopReadType' :           'none',
                 'fields': [
                    ('string',             'Region'),
                    ('int',            'Servicecode'),
                ],
            }),
			('loop',   {
                'loopTableKey' :           'genderInfo',
                'loopReadType' :           'none',
                 'fields': [
                    ('char',             'Gender'),
                ],
            }),
        ],
    },
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
