import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'monitoring_data.dart';

class MonitoringDefalutCard extends StatelessWidget {
  final Map? roomInfo;
  final String multiAppUUID;

   MonitoringDefalutCard({Key? key,required this.roomInfo, required this.multiAppUUID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: VetTheme.monitorCardSizeByDeviceHeight(context),
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
                        child: Text('${roomInfo!['patientName']}',style: TextStyle(color:Color(0xffDCE31F),
                            fontSize: VetTheme.diviceH(context)<800?20:20,fontWeight: FontWeight.bold),),
                      ),
                      Expanded(
                        child: Text('Chart No'.tr(args: ['${roomInfo!['chartNumber']}']),
                          style: TextStyle(color: Colors.white,fontSize: VetTheme.diviceH(context)<800?10:10
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text('Room No'.tr(args: ['${roomInfo!['roomName']}']),
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
                  child: Selector<MonitoringDataManager, Message2205?>(
                    selector: (context, value)=>value.message2205,
                    builder: (context, message2205, child){
                      if(message2205?.MultiAppUUID==null){
                        return Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween,
                            children: [
                              Expanded(
                                child: Text('${roomInfo?['dataType0'] ?? '-'}',textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontSize: VetTheme.diviceH(context)<800?30:35,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF27C32B)),),
                              ),
                              Expanded(
                                child: Text('${roomInfo?['dataType1']??'-'}',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        fontSize: VetTheme.diviceH(context)<800?30:35,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF45A1FF))),
                              ),
                            ],),);
                        } else{
                        var data = MonitoringRoomManager.data;
                        if(data['connectedMultiAppCount'] > 0){
                          data['multiAppDatas'].forEach((multiAppData){
                            if(multiAppData['multiAppUUID']==message2205?.MultiAppUUID){
                              multiAppData['RoomInfos'].forEach((room){
                                if(room['roomId']==message2205?.RoomID){
                                  room['dataType${message2205?.DataType}'] = message2205?.Data;
                                  if(multiAppUUID==message2205?.MultiAppUUID){
                                    if(roomInfo?['roomId']==message2205?.RoomID){
                                      roomInfo?['dataType0'] = room['dataType0'];
                                      roomInfo?['dataType1'] = room['dataType1'];
                                    }
                                  }
                                }
                              });
                            }
                          });
                        }
                        return MonitoringDataCard(roomInfo:roomInfo);
                      }
                    },
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
