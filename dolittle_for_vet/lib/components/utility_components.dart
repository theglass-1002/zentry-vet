import 'dart:convert';

import 'package:age_calculator/age_calculator.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class UtilityComponents {
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 4,  // iOS 및 웹에서의 표시 시간
      backgroundColor: VetTheme.mainIndigoColor,
      textColor: Colors.white,
      fontSize: 20.0,

    );
  }



  static void alertPermission(BuildContext _,String title, String content ) {
    showDialog<String>(
      context: _,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title.tr()),
        content: Text(content.tr()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel".tr()),
          ),
          TextButton(
            onPressed: () {
              AppSettings.openAppSettings(type: AppSettingsType.settings);
              Navigator.pop(context);
            },
            child: Text(
              "Setting".tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

 static Future<dynamic> dialogDate(BuildContext _,String local,String title,DateTime nowDate){
   // String newDate = '';
    DateTime newDate = DateTime.now();

    return showDialog<dynamic>(context: _, builder: (BuildContext context){
      return AlertDialog(
        shape: const RoundedRectangleBorder(
         borderRadius: BorderRadius.all(Radius.circular(32.0))),
          contentPadding: const EdgeInsets.only(top: 10.0),
        title: Text(title.tr(),textAlign: TextAlign.center,),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                initialDateTime: nowDate,
                mode: CupertinoDatePickerMode.date,
                minimumDate: DateTime.parse('2010-01-01'),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (DateTime _newDate) {
                    newDate = _newDate;
                },
              ),
            ),
            Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(32.0),
                              )),
                          child: Text(
                            'Cancel'.tr(),
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context,newDate);
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          decoration: BoxDecoration(
                              color: VetTheme.mainLightBlueColor,
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(32.0),
                              )),
                          child: Text(
                            'Confirm'.tr(),
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]
            ),
          );
        });
  }
  static Future<dynamic> buildDialog(BuildContext _ ,Animal animal) {
    var dialogResult = <String, String>{};
    return showDialog<Map<String, String>>(
      context: _,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(
         '${'Chart Number'.tr()} : ${animal.chart_number}',
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          width: double.minPositive,
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              animal.hasQRLink!?Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ElevatedButton(
                  //     style:ElevatedButton.styleFrom(backgroundColor: Color(0xff4994ec)),
                  //     onPressed: (){
                  //       dialogResult['type'] = 'move';
                  //       dialogResult['screen'] = '/graph';
                  //       Navigator.pop(context, dialogResult);
                  //     },child: SizedBox(
                  //     width: double.infinity,
                  //     child: Text('Hr/Rr records'.tr(),textAlign: TextAlign.center,))),
                  ElevatedButton(
                      style:ElevatedButton.styleFrom(backgroundColor: Color(0xff4994ec)),
                      onPressed: (){
                        //환자 만성 심부전앱 측정 데이터 연동(v2)
                        dialogResult['type'] = 'move';
                        dialogResult['screen'] = '/changeQr';
                        Navigator.pop(context, dialogResult);
                      },child: SizedBox(
                      width: double.infinity,
                      child: Text('Change QR'.tr(),textAlign: TextAlign.center,))),
                ],
              ): ElevatedButton(
                  style:ElevatedButton.styleFrom(backgroundColor: Color(0xff4994ec)),
                  onPressed: (){
                    //환자 만성 심부전앱 측정 데이터 연동(v2)
                    dialogResult['type'] = 'move';
                    dialogResult['screen'] = '/attachQr';
                    Navigator.pop(context, dialogResult);
                  },child: SizedBox(
                  width: double.infinity,
                  child: Text('Attach QR'.tr(),textAlign: TextAlign.center,))),
              ElevatedButton(
                  style:ElevatedButton.styleFrom(backgroundColor: Color(0xff4994ec)),
                  onPressed: (){
                    // PATCH 환자 정보 수정(v2)
                    dialogResult['type'] = 'move';
                    dialogResult['screen'] = '/modifyChart';
                    Navigator.pop(context, dialogResult);
                  },child: SizedBox(
                  width: double.infinity,
                  child: Text('Modify chart'.tr(),textAlign: TextAlign.center,))),
              ElevatedButton(
                  style:ElevatedButton.styleFrom(backgroundColor: Color(0xff4994ec)),
                  onPressed: (){
                    dialogResult['type'] = 'fun';
                    dialogResult ['fun'] = 'setHidePatient';
                    Navigator.pop(context, dialogResult);
                  },child: SizedBox(
                  width: double.infinity,
                  child: Text('Hide patient'.tr(),textAlign: TextAlign.center,))),
            ],
          ),
        ),
        // content: const Text('AlertDialog description'),
        // actions: <Widget>[
        //
        // ],
      ),
    );
  }



  static Future<dynamic> showCountryCodeListBottomSheet(BuildContext context) async {
    int a = 0;
    final countryNameSearchController = TextEditingController();
    var countryCodeJson = await rootBundle.loadString('assets/country_code/country_code.json');
    var countryData = CountryList.fromJson(json.decode(countryCodeJson));
    List<CountryInfoItem>? countryInfoList = countryData.countryInfoList;
    countryInfoList?.sort((a, b) => a.countryName!.compareTo(b.tld!));
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // 국가 코드 목록을 표시하는 BottomSheet 위젯을 반환
        return Container(
          height: VetTheme.diviceH(context), // Adjust the height as needed
          child: Column(
            children: [
              TextField(
                controller: countryNameSearchController,
                onChanged: (value){
                     UtilityFunction.log.e('나라이름${value}');
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: countryInfoList?.length,
                  itemBuilder: (BuildContext context, int index) {
                    String? number = countryInfoList![index]?.countryNumberCode!.replaceAll(RegExp(r'[^0-9]'), '');
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${countryInfoList![index]?.countryName}', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('+${number}', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  // //URL 주소를 통해서 웹브라우저 열기
  static Future<void> openUrl(bool isAndroid, String uri) async {
    UtilityFunction.log.e('앱스토어 실행');
    Uri url = Uri.parse(uri);
    try {
      if (isAndroid) {
        AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data: uri,

        );
        await intent.launch();
      } else {
        if (!await launchUrl(url)) {
          throw 'Could not launch $url';
        }
      }
    }catch(e){
      UtilityFunction.log.e(e);
      UtilityComponents.showToast('The market URL address is incorrect. \n please open the appStore And download the app again from the market');
    }
  }

 static Future<dynamic> versionCheckDialog(
      int state,BuildContext _
      ) {
    String content = state == 0
        ? 'An updated version has been released.\nGo to the App Store.'
        : 'An updated version has been released.';
    return showDialog<bool>(
      context: _,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Notification'.tr()),
        content: Text(content.tr()),
        actions: <Widget>[
          state == 0
              ? ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Later'),
          )
              : Container(),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }


  static void scrollToTop(ScrollController _scrollController) {
    if(_scrollController.hasClients){
      _scrollController.jumpTo(0);
    }
  }
  static Future<dynamic> breedListDialog(BuildContext _,var species,List breedList,String language) async {
     final searchBreed = TextEditingController();
    return showDialog<dynamic>(
        context: _,
        builder: (BuildContext context) {
          String search = "";
          var _searchList = breedList;
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            title: Text(
              'Breed list'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Container(
              width: 300.0,
              child: SingleChildScrollView(
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                            margin: const EdgeInsets.all(10),
                            child: TextField(
                                controller: searchBreed,
                                onChanged: (value){
                                  setState((){
                                    search = value.toLowerCase();
                                    _searchList = UtilityFunction.filterBreedList(breedList,language,search);
                                    // language==0?_searchList=breedList.where((element) =>element['enName'].toString().toLowerCase().contains(search)).toList():
                                    // _searchList=breedList.where((element) =>element['koName'].toString().toLowerCase().contains(search)).toList();
                                  });
                                },
                                decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: VetTheme.mainIndigoColor),
                                    ),
                                    prefixIcon: Icon(Icons
                                        .search,color: VetTheme.mainIndigoColor,), //you can use prefixIcon property too.
                                    labelText: 'Type to search'.tr(),
                                    labelStyle: const TextStyle(color:Colors.grey),
                                    suffixIcon:
                                    IconButton(onPressed: (){
                                      searchBreed.clear();
                                    }, icon:Icon(Icons.close,color: VetTheme.mainIndigoColor,))//icon at tail of input
                                ))),
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          height: 300,
                          child: Scrollbar(
                              thickness: 5,
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: _searchList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Container(
                                        margin: const EdgeInsets.all(10),
                                        child: GestureDetector(
                                            onTap: (){
                                              // UtilityFunction.log.e(_searchList[index]);
                                              // UtilityFunction.log.e('클릭');
                                              Navigator.pop(context,_searchList[index]);
                                            },
                                            child: Text(UtilityFunction.getBreedNameAtIndex(_searchList, index, language)))
                                      //이름 영어로? 한글로?
                                    );
                                  }
                              )
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),
            ),
          );
        });
  }


  static Future<dynamic>  showConfirmationDialog(BuildContext _,String content,{String? confirmText}){
    return showDialog<bool>(
        context: _,
        builder: (BuildContext context){
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            contentPadding: const EdgeInsets.only(top: 10.0),
            title: confirmText==null?null:Text(
              confirmText.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      margin: EdgeInsets.all(10),
                      child: Text(content,style: TextStyle(
                          fontSize: VetTheme.textSize(_)
                      ),).tr()),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context,false);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                            decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(25.0),
                                )),
                            child: Text(
                              'Cancel'.tr(),
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context,true);
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                            decoration: BoxDecoration(
                                color: VetTheme.mainLightBlueColor,
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(25.0),
                                )),
                            child: Text(
                              'Confirm'.tr(),
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]
            ),
          );
    });
  }

  static Future<dynamic> notiyDialog(BuildContext _) async {
    return showDialog<bool>(
        context: _,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            title: Text(
              'Notification'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Container(
              width: 300.0,
              child: SingleChildScrollView(
                child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Do you want to attach QR \n for the patient?'.tr(),textAlign: TextAlign.center,),
                          Padding(padding: EdgeInsets.all(10)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context,false);
                                  },
                                  child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32)),
                                        color: VetTheme.hintColor
                                        // 다른 스타일 속성들을 추가할 수 있습니다.
                                      ),
                                      child: Text('No',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                        ),
                                        textAlign: TextAlign.center,)),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context,true);
                                  },
                                  child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(32)),
                                        color: VetTheme.mainLightBlueColor,
                                        // 다른 스타일 속성들을 추가할 수 있습니다.
                                      ),
                                      child: Text('Yes',style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                      ),
                                        textAlign: TextAlign.center,)),
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                    }
                ),
              ),
            ),
          );
        });
  }


 static Widget listBuild(var breedList , int language ){
    UtilityFunction.log.e(breedList.toString());
    return   Container(
      margin: EdgeInsets.only(left: 20),
      height: 300,
      child: Scrollbar(
          thickness: 5,
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: breedList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    margin: EdgeInsets.all(10),
                    child: GestureDetector(
                        onTap: (){
                          UtilityFunction.log.e(breedList[index]);
                          UtilityFunction.log.e(breedList[index]['enName']);
                          UtilityFunction.log.e('클릭');
                          Navigator.pop(context,breedList[index]);
                        },
                        child: Text(language==0?breedList[index]['enName']:breedList[index]['koName']))
                  //이름 영어로? 한글로?
                );
              }
          )
      ),
    );

  }

  static String countBirth(String birth) {
    DateTime birthday = DateTime.parse(birth);
    DateDuration duration = AgeCalculator.age(birthday);
    birth = '${duration.years}y${duration.months}m';
    return birth;
  }

  static String checkLastdate(String lastdate) {
    if (lastdate.trim().isNotEmpty) {
      DateTime last = DateTime.parse(lastdate);
      lastdate = '${last.year}-${last.month}-${last.day}';
      return lastdate;
    } else {
      return "".tr();
    }
  }

  static String checkCardiac(String cardiac) {
    return cardiac = cardiac == "" || cardiac == "NONE"
        ? "None".tr()
        : cardiac == "UNKNOWN"
            ? "Unknown".tr()
            : cardiac;
  }

  static String spliteBreed(String breed) {
    return breed = breed.length > 5 ? breed.substring(0, 5) : breed;
  }

  static Widget checkGender(String gender) {
    Widget widget = Container();
    switch (gender) {
      case "0":
        widget = Image.asset('assets/animal_gender_data/female.png', width: 20);
        break;
      case "1":
        widget =
            Image.asset('assets/animal_gender_data/none_female.png', width: 20);
        break;
      case "2":
        widget = Image.asset('assets/animal_gender_data/male.png', width: 20);
        break;
      case "3":
        widget =
            Image.asset('assets/animal_gender_data/none_male.png', width: 20);
        break;
    }
    return widget;
  }


  static String formatServerDate(String serverDateTime) {
    DateTime utcDateObject = DateTime.parse(serverDateTime);

    // 원하는 형식으로 UTC 날짜 및 시간 추출
    int utcYear = utcDateObject.toUtc().year;
    String utcMonth = DateFormat('MM').format(utcDateObject.toUtc());
    String utcDay = DateFormat('dd').format(utcDateObject.toUtc());
    String utcHours = DateFormat('HH').format(utcDateObject.toUtc());
    String utcMinutes = DateFormat('mm').format(utcDateObject.toUtc());

    // 'yyyy-mm-dd (hh:mm)' 형식으로 UTC 시간 반환
    return '$utcYear-$utcMonth-$utcDay ($utcHours:$utcMinutes)';
  }


  static String getNoticeType(int code) {
    String type = "";

    switch (code) {
      case 0:
        type = "General".tr();
        break;
      case 1:
        type = "Feature".tr();
        break;
      case 2:
        type = "Advertisement".tr();
        break;
      case 3:
        type = "Instructions".tr();
        break;
      default:
        type = "etc".tr();
        break;
    }

    return type;
  }

}

// static Future<dynamic> BreedListDialog(BuildContext _, List breedList,int language) async {
//   return showDialog<dynamic>(
//       context: _,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(32.0))),
//           contentPadding: EdgeInsets.only(top: 10.0),
//           title: Text(
//             'Breed list'.tr(),
//             textAlign: TextAlign.center,
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           content: Container(
//             width: 300.0,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 Container(
//                     margin: const EdgeInsets.all(10),
//                     child: TextField(
//                         decoration: InputDecoration(
//                             focusedBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(
//                                   color: VetTheme.mainIndigoColor),
//                             ),
//                             prefixIcon: Icon(Icons
//                                 .search,color: VetTheme.mainIndigoColor,), //you can use prefixIcon property too.
//                             labelText: 'Type to search'.tr(),
//                             labelStyle: const TextStyle(color:Colors.grey),
//                             suffixIcon:
//                                 Icon(Icons.close,color: VetTheme.mainIndigoColor,) //icon at tail of input
//                             ))),
//                 Container(
//                   margin: EdgeInsets.only(left: 20),
//                   height: 200,
//                   child: Scrollbar(
//                     thickness: 5,
//                     child: ListView.builder(
//                         itemCount: breedList.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           return Container(
//                             margin: EdgeInsets.all(10),
//                             child: Text(language==0?breedList[index]['enName']:breedList[index]['koName'])
//                                 //이름 영어로? 한글로?
//                           );
//                         }
//                     )
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.pop(context, false);
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.only(top: 10),
//                           padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
//                           decoration: const BoxDecoration(
//                               color: Colors.grey,
//                               borderRadius: BorderRadius.only(
//                                 bottomLeft: Radius.circular(32.0),
//                               )),
//                           child: Text(
//                             'Cancel'.tr(),
//                             style: TextStyle(color: Colors.white),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.pop(context, '클릭1d입니다');
//                         },
//                         child: Container(
//                           margin: EdgeInsets.only(top: 10),
//                           padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
//                           decoration: BoxDecoration(
//                               color: VetTheme.mainLightBlueColor,
//                               borderRadius: BorderRadius.only(
//                                 bottomRight: Radius.circular(32.0),
//                               )),
//                           child: Text(
//                             'Confirm'.tr(),
//                             style: TextStyle(color: Colors.white),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       });
// }

