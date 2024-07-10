import 'package:age_calculator/age_calculator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class NotiyCard extends StatelessWidget {
  final PushMessages? pushMessages;
  final User? user;
  const NotiyCard({Key? key , required this.pushMessages,required this.user}) : super(key: key);



  /*
    0 : 올바르지 않은 타입
    1 : 이벤트/공지
    2 : 병원 등록
    3 : 병원 정보 업데이트 완료
    4 : 병원 정보 제거 (폐업처리)
    5 : 수의사 등록
    6 : 수의사 제거
    7 : 수의사 권한 변경
    8 : 심장병 알림
    */

  @override
  Widget build(BuildContext context) {
    return  Card(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color(0xff2e3d80),),
                  child: Text(messageTitle(pushMessages!),style: const TextStyle(color: Colors.white),)),
              Text( messageBody(pushMessages!)),
              Text(DateTime.parse(pushMessages!.createdAt!).toLocal().toString().substring(0,19)),
            ],
          ),
        )
    );
  }
  
  
  String messageTitle(PushMessages pushMessages){
    String title = "";
    switch(pushMessages.type){
      case 1:
        title = "Event/Notice".tr();
       break;
      case 2:
        title = "Registration of hospital authority".tr();
        break;
      case 3:
        title = "Hospital Information Update".tr();
        break;
      case 4:
        title = "Termination of hospital authority".tr();
        break;
      case 5:
        title = "Registration of authority".tr();
        break;
      case 6:
        title ="Termination of authority".tr();
        break;
      case 7:
        title ="authority change".tr();
        break;
      case 8:
        title ="Heart disease notification".tr();
        break;
      case 9:
        title ="Application for transfer".tr();
        break;
      
    }
    return title;
  }

  String messageBody(PushMessages pushMessages){
    String body = "";
    switch(pushMessages.type){
      case 1:
        body = "Event/Notice".tr();
        break;
      case 2:
        body = "Registration of hospital authority".tr();
        break;
      case 3:
        body = "Hospital Information Update".tr();
        break;
      case 4:
        body = "Termination of hospital authority".tr();
        break;
      case 5:
        body = "⌜${user?.name}⌟${"Registration of authority".tr()}";
        break;
      case 6:
        body ="⌜${user?.name}⌟${"Termination of authority".tr()}";
        break;
      case 7:
        body ="⌜${user?.name}⌟${"authority change".tr()}";
        break;
      case 8:
        body ="Heart disease notification".tr();
        break;
      case 9:
        body ="Application for transfer".tr();
        break;

    }
    return body;
  }

}
