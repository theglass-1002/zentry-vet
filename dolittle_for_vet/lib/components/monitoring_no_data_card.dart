import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/components/monitoring_defalut_card.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class MonitoringNoDataCard extends StatelessWidget {
  final Map? roomInfo;
  MonitoringNoDataCard({Key? key,required this.roomInfo}) : super(key: key);

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
                    child: dataCard(roomInfo))
              ],
            ),
          ),
        ),
      );
  }

 Widget dataCard(var roominfo) {
   if (roominfo['type'] == 0) {
    return Container(
        margin: EdgeInsets.only(left: 50),
        child: SvgPicture.asset('assets/icons/no_bluetooth.svg', height:50, ));
   }else if(roominfo['type']==20){
     return Container(
         margin: EdgeInsets.only(left: 50),
         child: SvgPicture.asset('assets/icons/pause.svg', height: 50));
   }else {
     return Text('None');
   }
 }

}
