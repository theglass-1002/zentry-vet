import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'monitoring_data.dart';


class MonitoringAlarmCard extends StatefulWidget {
  final Map? roomInfo;
  final String multiAppUUID;

  const MonitoringAlarmCard(
      {Key? key, required this.roomInfo, required this.multiAppUUID})
      : super(key: key);
  @override
  State<MonitoringAlarmCard> createState() => _MonitoringAlarmCard();

}


class _MonitoringAlarmCard extends State<MonitoringAlarmCard> with SingleTickerProviderStateMixin {
  late  AnimationController _controller;
  late  Animation<Color?> _colorAnimation;
  Map? roominfo = {};
  String multiAppUUID = '';


  @override
  void initState() {
    // TODO: implement initState
    if(mounted){
      roominfo = widget.roomInfo;
      multiAppUUID = widget.multiAppUUID;
      _controller=AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      )..repeat(reverse: true);
      _colorAnimation =ColorTween(begin: Colors.red[400], end: Colors.black)
          .animate(_controller);
    }
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if(mounted) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    roominfo = widget.roomInfo;
    multiAppUUID = widget.multiAppUUID;
    return roomType3();
  }

  //심호흡 이상함 겉에 깜빡임
  Widget roomType3(){
    return  SizedBox(
      height: VetTheme.monitorCardSizeByDeviceHeight(this.context),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(
              color: Colors.grey,
            )
        ),
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child){
            return Container(
              color: _colorAnimation.value??Colors.red,
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text('${roominfo!['patientName']}',style: TextStyle(color:Color(0xffDCE31F),
                                fontSize: 20,fontWeight: FontWeight.bold),),
                          ),
                          Expanded(
                            child: Text('Chart No'.tr(args: ['${roominfo!['chartNumber']}']),
                              style: TextStyle(color: Colors.white,fontSize: VetTheme.diviceH(context)<800?10:10

                              ),
                            ),
                          ),
                          Expanded(
                            child: Text('Room No'.tr(args: ['${roominfo!['roomName']}']),
                              style: TextStyle(color: Colors.white,fontSize: VetTheme.diviceH(context)<800?10:10
                            ),
                          ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: roomType(roominfo))
                ],
              ),);
          },

        ),
      ),
    );
  }

  Widget defaultRoom(){
    return  SizedBox(
      height: VetTheme.monitorCardSizeByDeviceHeight(this.context),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(
              color: Colors.grey,
            )
        ),
        child: Container(
          color: Colors.black,
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('${roominfo!['patientName']}',style: TextStyle(color:Color(0xffDCE31F),
                            fontSize: VetTheme.diviceH(this.context)<800?20:20,fontWeight: FontWeight.bold),),
                      ),
                      Expanded(
                        child: Text('Chart No.${roominfo!['chartNumber']}',
                          style: TextStyle(color: Colors.white,fontSize: VetTheme.diviceH(this.context)<800?10:10

                          ),
                        ),
                      ),
                      Expanded(
                        child: Text('Room No.${roominfo!['roomName']}',
                          style: TextStyle(color: Colors.white,fontSize: VetTheme.diviceH(this.context)<800?10:10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                  flex: 3,
                  child: roomType(roominfo))
            ],
          ),
        ),
      ),
    );
  }

  Widget roomType(var roominfo){
    return Selector<MonitoringDataManager, Message2205?>(
        selector: (context, value)=> value.message2205,
        builder: (context, message2205, child){
          if(message2205?.MultiAppUUID==null){
            return Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween,
                children: [
                  Expanded(
                    child: Text('${roominfo?['dataType0'] ?? '-'}',textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: VetTheme.diviceH(context)<800?30:35,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF27C32B)),),
                  ),
                  Expanded(
                    child: Text('${roominfo['dataType1']??'-'}',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: VetTheme.diviceH(context)<800?30:35,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF45A1FF))),
                  ),
                ],),);
          }else {
            var data = MonitoringRoomManager.data;
            if(data['connectedMultiAppCount'] > 0){
              data['multiAppDatas'].forEach((multiAppData){
                if(multiAppData['multiAppUUID']==message2205?.MultiAppUUID){
                  multiAppData['RoomInfos'].forEach((room){
                    if(room['roomId']==message2205?.RoomID){
                      room['dataType${message2205?.DataType}'] = message2205?.Data;
                      if(multiAppUUID==message2205?.MultiAppUUID){
                        if(roominfo?['roomId']==message2205?.RoomID){
                          roominfo?['dataType0'] = room['dataType0'];
                          roominfo?['dataType1'] = room['dataType1'];
                        }
                      }

                      // if(roominfo?['roomId']==message2205?.RoomID){
                      //   roominfo?['dataType0'] = room['dataType0'];
                      //   roominfo?['dataType1'] = room['dataType1'];
                      // }
                    }
                  });
                }
              });
            }
            return MonitoringDataCard(roomInfo: roominfo);
          }
        });
  }

}
