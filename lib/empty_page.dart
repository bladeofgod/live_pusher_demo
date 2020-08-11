/*
* Author : LiJiqqi
* Date : 2020/8/5
*/


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qqlivedemo/live_page.dart';
import 'package:tencent_im_plugin/enums/log_print_level.dart';
import 'package:tencent_im_plugin/tencent_im_plugin.dart';

class EmptyPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return EmptyPageState();
  }

}

class EmptyPageState extends State<EmptyPage> {

  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      request();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          SizedBox(
            width: 1,height: 50,
          ),
          Text('just for some permissions.',style: TextStyle(color: Colors.black,fontSize: 18),),
        ],
      ),
    );
  }

  void request() async{
    var status = await Permission.camera.status;
    if (status.isGranted) {
      getPusherUrl();
    }else{
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.storage,
        Permission.storage,
        Permission.microphone,
      ].request();
      if(statuses.values.every((element) => element.isGranted)){
        getPusherUrl();
      }
    }

  }

  final String pusherName = 'pusher';
  void getPusherUrl()async{
    String url = '';
    Dio dio = Dio();
    var result = await dio.get('https://api.tripalink.com/index.php',
        queryParameters: {'r':'index/get-push-url','push_name':pusherName});
    if(result != null){
      url = result.data['data']??'';
      debugPrint('push url $url');
      Future.delayed(Duration(milliseconds: 10)).then((value){
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctx){
          return LivePage(pushUrl:url ,);
        }));
      });
    }
  }
}