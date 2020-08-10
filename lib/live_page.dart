/*
* Author : LiJiqqi
* Date : 2020/8/4
*/

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rtmp_tencent_live/tencent_live.dart';
import 'package:rtmp_tencent_live/tencent_live_push_Controller.dart';
import 'package:tencent_im_plugin/entity/message_entity.dart';
import 'package:tencent_im_plugin/entity/session_entity.dart';
import 'package:tencent_im_plugin/tencent_im_plugin.dart';

class LivePage extends StatefulWidget {
  @override
  _LivePageState createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  TencentLivePushController _controller;

  double value = 0;
  double value2 = 0;
  double value3 = 0;
  double value4 = 0;

  /// 按钮组建
  Widget _buttonList(Icon icons, String title, Function onClick) {
    return InkWell(
      child: Container(
        color: Color.fromARGB(100, 255, 255, 255),
        child: Column(
          children: <Widget>[
            icons,
            Text('$title'),
          ],
        ),
      ),
      onTap: onClick,
    );
  }

  String pushUrl = 'rtmp://look.apitripalink.com/live/tripalink?txSecret=066d815fd1f29490aa2cecd1e695c0e2&txTime=5F3E111C';


  ///IM相关

  final String id =  '@TGS#a2HHHJUGA';
  final SessionType type = SessionType.Group;

  /// 当前消息列表
  List<DataEntity> data = [];

  /// 滚动控制器
  ScrollController scrollController = ScrollController();

  void loginAA()async{
    await TencentImPlugin.login(
      identifier: "pusher",
      userSig:
      "eJyrVgrxCdYrSy1SslIy0jNQ0gHzM1NS80oy0zLBwgWlxUAaIlGckp1YUJCZomRlaGJgYGJgYW5pApFJrSjILEoFipuamhoZGBhAREsyc8FiluYGRsaWphZQUzLTgeaaWpSlaicV*sfom*WWZLjk5PnneYUblTi6ukQEeyVVhOa6l1a5*XpWOBkGG9gq1QIAb9Yx2g__",
    );
//    Navigator.of(context).push(new MaterialPageRoute(
//        builder: (ctx)=>ChatPage(id: '@TGS#a2HHHJUGA',type: SessionType.Group,)));
  }

  /// 监听器
  listener(type, params) {
    debugPrint('监听');
    debugPrint('${type.toString()}----------${params.toString()}');
    // 新消息时更新会话列表最近的聊天记录
    if (type == ListenerTypeEnum.NewMessages) {
      // 更新消息列表
      this.setState(() {
        data.add(DataEntity(data: params));
        debugPrint('data  ------- ${data.last.data.toJson().toString()}');
      });
      // 设置已读
      TencentImPlugin.setRead(sessionId: widget.id, sessionType: widget.type);
    }
    ///test
    ///test
    if (type == ListenerTypeEnum.RefreshConversation) {
      for(var i in params){
        if(i is SessionEntity){
          // 更新消息列表
          debugPrint('refresh data  ${i.message.toJson().toString()}');
          if(i.message.read){
            this.setState(() {
              data.add(DataEntity(data: i.message));

            });
          }

          // 设置已读
          //TencentImPlugin.setRead(sessionId: widget.id, sessionType: widget.type);

        }
      }


    }

    // 消息上传通知
    if (type == ListenerTypeEnum.UploadProgress) {
      Map<String, dynamic> obj = jsonDecode(params);

      // 获得进度和消息实体
      int progress = obj["progress"];
      MessageEntity message = MessageEntity.fromJson(obj["message"]);

      // 更新数据
      this.updateData(DataEntity(
        data: message,
        progress: progress,
      ));
    }
  }

  /// 更新单个数据
  updateData(DataEntity dataEntity) {
    bool exist = false;
    for (var index = 0; index < data.length; index++) {
      DataEntity item = data[index];
      if (item.data == dataEntity.data) {
        this.data[index] = dataEntity;
        exist = true;
        break;
      }
    }

    if (!exist) {
      this.data.add(dataEntity);
    }

    this.setState(() {});
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  @override
  void initState() {

    super.initState();
    // 添加监听器
    TencentImPlugin.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();
    TencentImPlugin.removeListener(listener);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            TencentLiveView(
                rtmpURL:pushUrl,
                onCreated: (controller) {
                  _controller = controller;
                }
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
//                color: Colors.amber,
                child: SafeArea(
                    child: Stack(
                      children: <Widget>[
                        Text('data'),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              bottom: 20.0,
                              top: 20.0,
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    _buttonList(Icon(Icons.ac_unit), '翻转', () {
                                      _controller.setSwitchCamera();
                                    }),
                                    _buttonList(Icon(Icons.ac_unit), '打开后置灯光', () {
                                      _controller.setTurnOnFlashLight();
                                    }),
                                    _buttonList(Icon(Icons.ac_unit), '镜像模式', () {
                                      _controller.setMirror();
                                    }),
                                  ],
                                ),
                                Text('磨皮'),
                                SliderTheme( //自定义风格
                                  data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: Colors.pink, //进度条滑块左边颜色
                                      inactiveTrackColor: Colors.blue, //进度条滑块右边颜色
                                      thumbColor: Colors.yellow, //滑块颜色
                                      overlayColor: Colors.green, //滑块拖拽时外圈的颜色
                                      overlayShape: RoundSliderOverlayShape(//可继承SliderComponentShape自定义形状
                                        overlayRadius: 25, //滑块外圈大小
                                      ),
                                      thumbShape: RoundSliderThumbShape(//可继承SliderComponentShape自定义形状
                                        disabledThumbRadius: 15, //禁用是滑块大小
                                        enabledThumbRadius: 15, //滑块大小
                                      ),
                                      inactiveTickMarkColor: Colors.black,
                                      tickMarkShape: RoundSliderTickMarkShape(//继承SliderTickMarkShape可自定义刻度形状
                                        tickMarkRadius: 4.0,//刻度大小
                                      ),
                                      showValueIndicator: ShowValueIndicator.onlyForDiscrete,//气泡显示的形式
                                      valueIndicatorColor: Colors.red,//气泡颜色
                                      valueIndicatorShape: PaddleSliderValueIndicatorShape(),//气泡形状
                                      valueIndicatorTextStyle: TextStyle(color: Colors.black),//气泡里值的风格
                                      trackHeight: 10 //进度条宽度
                                  ),
                                  child: Slider(
                                    value: value,
                                    onChanged: (v) {
                                      setState(() =>  value = v);
                                      _controller.setDermabrasion(v.toInt());
                                    },
                                    label: "磨皮:$value",//气泡的值
                                    divisions: 10, //进度条上显示多少个刻度点
                                    max: 10,
                                    min: 0,
                                  ),
                                ),
                                Text('美白'),
                                SliderTheme( //自定义风格
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Colors.pink, //进度条滑块左边颜色
                                  ),
                                  child: Slider(
                                    value: value2,
                                    onChanged: (v) {
                                      setState(() =>  value2 = v);
                                      _controller.setWhitening(v.toInt());
                                    },
                                    label: "美白:$value2",//气泡的值
                                    divisions: 10, //进度条上显示多少个刻度点
                                    max: 10,
                                    min: 0,
                                  ),
                                ),
                                Text('红润'),
                                SliderTheme( //自定义风格
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Colors.pink, //进度条滑块左边颜色
                                  ),
                                  child: Slider(
                                    value: value3,
                                    onChanged: (v) {
                                      setState(() =>  value3 = v);
                                      _controller.setUpRuddy(v.toInt());
                                    },
                                    label: "红润:$value3",//气泡的值
                                    divisions: 10, //进度条上显示多少个刻度点
                                    max: 10,
                                    min: 0,
                                  ),
                                ),
                                MaterialButton(
                                  child: Text("开始直播", style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0
                                  )),
                                  color: Colors.blue,
                                  onPressed: (){
                                    _controller.startLive();
                                    loginAA();
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,height: 300,
                child: ListView(
                  controller: scrollController,
                  children: data.map((e){
                    return Container(
                      width: MediaQuery.of(context).size.width,height: 60,
                      child: Text('note : ${e.data.note}',style: TextStyle(color: Colors.black),),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 数据实体
class DataEntity {
  /// 消息实体
  final MessageEntity data;

  /// 进度
  final int progress;

  DataEntity({
    this.data,
    this.progress,
  });
}
