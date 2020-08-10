/*
* Author : LiJiqqi
* Date : 2020/8/5
*/


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
    TencentImPlugin.init(
        appid: "1400408794", logPrintLevel: LogPrintLevel.debug);
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
      Future.delayed(Duration(milliseconds: 10)).then((value){
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctx){
          return LivePage();
        }));
      });
    }else{
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.storage,
        Permission.storage,
        Permission.microphone,
      ].request();
      if(statuses.values.every((element) => element.isGranted)){
        Future.delayed(Duration(milliseconds: 10)).then((value){
          Navigator.of(context).push(new MaterialPageRoute(builder: (ctx){
            return LivePage();
          }));
        });
      }
    }

  }
}