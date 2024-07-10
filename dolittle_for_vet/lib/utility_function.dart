import 'dart:convert';
import 'package:age_calculator/age_calculator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:crypto/crypto.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as en;
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:webview_flutter/webview_flutter.dart';




class UtilityFunction{

  final bool _isAndroid = Platform.isAndroid;
  bool get isAndroid => _isAndroid;
  static var log = Logger();
  final app_cache = AppCache();
  static String keyAnimalAES = 'FEE2B2A39AE31A79';
  static String keyVetAES = 'FEE3B2A39AE51A19';
  static String keyMultiAES = 'FEE3B2A39AE51A24';






  //안드로이드 좌로막기
  void horizontalModeBlocking ()=>_isAndroid?SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]):null;

  static String aesEncodeVet(String params) {
    final key = en.Key.fromUtf8(keyVetAES);
    final iv = en.IV.fromUtf8(keyVetAES.substring(0, 16));
    final encrypter = en.Encrypter(en.AES(key));
    final encrypted = encrypter.encrypt(params, iv: iv).base64;
    UtilityFunction.log.e(encrypted);
    return encrypted;
  }


  static String aesEncodeMulti(String params) {
    final key = en.Key.fromUtf8(keyMultiAES);
    final iv = en.IV.fromUtf8(keyMultiAES.substring(0, 16));
    final encrypter = en.Encrypter(en.AES(key));
    final encrypted = encrypter.encrypt(params, iv: iv).base64;
    return encrypted;
  }

  static String decodeVetQr(String params) {
    String decrypteds = 'none';
    try {
      final key = en.Key.fromUtf8(keyVetAES);
      final iv = en.IV.fromUtf8(keyVetAES.substring(0, 16));
      final encrypter = en.Encrypter(en.AES(key));
      decrypteds = encrypter.decrypt(
          en.Encrypted.fromBase64(params), iv: iv);
      return decrypteds;
    }catch(e){
      return decrypteds;
    }
  }

  static String decodeAnimalQr(String params) {
    String decrypteds = "none";
    try {
      final key = en.Key.fromUtf8(keyAnimalAES);
      final iv = en.IV.fromUtf8(keyAnimalAES.substring(0, 16));
      final encrypter = en.Encrypter(en.AES(key));
      decrypteds = encrypter.decrypt(en.Encrypted.fromBase64(params), iv: iv);
      // UtilityFunction.log.e(decrypteds);
      return decrypteds;
    } catch (e) {
      return decrypteds;
    }
  }


  //페이지 이동 <이전 페이지 있음 >
  static void moveScreen(BuildContext context, String route,
      [var argument]) async {
    Navigator.of(context).pushNamed(route, arguments: argument);
    return;
  }

  //페이지 이동 <이전 페이지 삭제 됨>
  static void moveScreenAndPop(BuildContext context, String route,
      [var argument]) async {
    Navigator.of(context).popAndPushNamed(route, arguments: argument);
  }

  // 이전 페이지로 이동하고 현재 페이지를 pop합니다.
  static void goBackToPreviousPage(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void goBackToMainPage(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }


  String getTranslationString(String str) {
    return str.tr();
  }

  //스택전부제거 이동
  static void pushReplacementNamed(
      BuildContext context,
      String route, [Map<String,String>? params,Map<String,String>? queryParams ,Object? extra]){
    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
    return;
  }

  //로그인 시 pw 생성에 사용
  static String getSha256Hash(String str) {
    var bytes1 = utf8.encode(str); // data being hashed
    var digest1 = sha256.convert(bytes1); // Hashing Process
    return digest1.toString();
  }

  static int getUserIdJwt(String token) {
    Map<String, dynamic> payload = Jwt.parseJwt(token);
    int nUserId = payload['id'];
    return nUserId;
  }

  static String getLocalTime(){
    DateTime now = DateTime.now();
    String formattedTime = DateFormat.yMMMMd().add_jms().format(now);
    return formattedTime;
  }

  static DateTime parseServerTime(String serverTimeStr ){
    final serverTimeFormat = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ");
    DateTime serverTime = serverTimeFormat.parseUtc(serverTimeStr).toLocal();
    return serverTime ;
  }

  static String getUserAppleEmailJwt(String token) {
    Map<String, dynamic> payload = Jwt.parseJwt(token);
    if (payload['email'] != null) {
      String email = payload['email'];
      log.e('getUserAppleEmailJwt $email');
      return email;
    } else {
      return "";
    }
  }

  static String aesEncodeLogin(String params) {
    final key = en.Key.fromUtf8(AppCache.keyVetLoginAES);
    final iv = en.IV.fromUtf8(AppCache.keyVetLoginAES.substring(0, 16));
    final encrypter = en.Encrypter(en.AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(params, iv: iv).base64;
    return encrypted;
  }

  static Future getIosDeviceName(String id) async {
    String iosList = await rootBundle.loadString('assets/ios/Devios.json');
    Map iosJson = json.decode(iosList);
    String device = iosJson[id];
    return device;
  }

  static Future getCountyCode(String name) async {
    int numericCode = 999;
    var countryCodeList = await rootBundle.loadString('assets/country_code/country_code.json');
    Map countryCodesMap = json.decode(countryCodeList);
    final List<dynamic> countryList = countryCodesMap['countryList'];
    for (Map<String, dynamic> country in countryList) {
      if (country['tld'].toString().trim().contains(name)) {
        return numericCode = int.parse(country['numericCode'].toString().trim());
      }
    }

    return numericCode;

  }


  static Future getCountryName(String name) async {
    UtilityFunction.log.e('name: $name');
    String countryName = "";
    var countryCodeList = await rootBundle.loadString('assets/country_code/country_code.json');
    Map countryCodesMap = json.decode(countryCodeList);
    final List<dynamic> countryList = countryCodesMap['countryList'];
    for (Map<String, dynamic> country in countryList) {
      if (country['tld'].toString().trim().contains(name)) {
        return countryName = country['countryName'].toString().trim();
      }
    }

    return countryName;

  }

  static int readIntFromBytesBigEndian(List<int> bytes, int index) {
    return ((bytes[index++] << 24) |
    (bytes[index++] << 16) |
    (bytes[index++] << 8) |
    bytes[index++]);
  }

  static String bytesToHex(List<int> bytes) {
    var hexArray = '0123456789ABCDEF'.split('');

    var hexChars = List.filled(bytes.length * 2, '');
    for (var j = 0; j < bytes.length; j++) {
      var v = bytes[j] & 0xFF;

      hexChars[j * 2] = hexArray[v >> 4];
      hexChars[j * 2 + 1] = hexArray[v & 0x0F];
    }
    return hexChars.join();
  }

  static String notifiBodyMsg(RemoteNotification remoteNotification){
    String userName = '';
    UtilityFunction.log.e('msg ${remoteNotification.bodyLocArgs.toString()}');
    UtilityFunction.log.e('msg ${remoteNotification.bodyLocArgs.isEmpty}');
    if(remoteNotification.bodyLocArgs.isNotEmpty){
      userName = remoteNotification.bodyLocArgs[0];
    }
    String msg = '';
    switch(remoteNotification.bodyLocKey.toString()){
        case 'HOSPITAL_USER_REGISTRATION_NORMAL':
        case 'HOSPITAL_USER_REGISTRATION_MANAGER':
        case 'HOSPITAL_USER_REGISTRATION_OWNER':
        case 'HOSPITAL_USER_REGISTRATION_TECHNICIAN':
          msg = '$userName${'HOSPITAL_USER_REGISTRATION'.tr()}';
          break;
       case 'HOSPITAL_USER_DEREGISTRATION':
         msg = '$userName${'HOSPITAL_USER_DEREGISTRATION'.tr()}';
         break;
      case 'HOSPITAL_USER_AUTHORITY_CHANGED_NORMAL':
          msg = '${'HOSPITAL_USER_AUTHORITY_CHANGED'.tr()} ⌜${'NORMAL'.tr()}⌟';
          break;
      case 'HOSPITAL_USER_AUTHORITY_CHANGED_MANAGER':
        msg = '${'HOSPITAL_USER_AUTHORITY_CHANGED'.tr()} ⌜${'MANAGER'.tr()}⌟';
        break;
      case 'HOSPITAL_USER_AUTHORITY_CHANGED_OWNER':
        msg = '${'HOSPITAL_USER_AUTHORITY_CHANGED'.tr()} ⌜${'OWNER'.tr()}⌟';
        break;
      case 'HOSPITAL_USER_AUTHORITY_CHANGED_TECHNICIAN':
        msg = '${'HOSPITAL_USER_AUTHORITY_CHANGED'.tr()} ⌜${'TECHNICIAN'.tr()}⌟';
        break;
        case 'HOSPITAL_REGISTRATION_ACCEPTED':
          msg ='HOSPITAL_REGISTRATION_ACCEPTED'.tr();
          break;
      case 'HOSPITAL_REGISTRATION_REJECTED':
        msg ='HOSPITAL_REGISTRATION_REJECTED'.tr();
        break;
      case 'HOSPITAL_UPDATE_ACCEPTED':
        msg ='HOSPITAL_UPDATE_ACCEPTED'.tr();
        break;
      case 'HOSPITAL_UPDATE_REJECTED':
        msg ='HOSPITAL_UPDATE_REJECTED'.tr();
        break;
        case 'HOSPITAL_HANDOVER_ACCEPTED':
          msg ='HOSPITAL_HANDOVER_ACCEPTED'.tr();
          break;
      case 'HOSPITAL_HANDOVER_REJECTED':
        msg ='HOSPITAL_HANDOVER_REJECTED'.tr();
        break;

    }
    UtilityFunction.log.e(msg);
    return msg;
  }


  static String alarmBodyMsg(var dataType){
    String msg = '';
    switch(dataType['alarmType']){
      case 'HR_RR':
        msg = 'Multi-Alarm'.tr();
        break;
      default :
        msg = '${dataType['alarmType']}';
        break;


    }
    return msg;
  }

  static String getBreedName(var breedInfo, String userLanguage) {
    if(userLanguage.contains('en')){
      return breedInfo['enName'];
    }else if(userLanguage.contains('ko')){
      return breedInfo['koName'];
    }else if(userLanguage.contains('es')){
      return breedInfo['esName'];
    }
    return breedInfo['enName'];
  }


  static List<dynamic> filterBreedList(List<dynamic> breedList, String language, String search) {
    List<dynamic> _searchList = [];
    _searchList = breedList.where((element) => element['enName'].toString().toLowerCase().contains(search)).toList();
    if (language.contains('en')) {
      _searchList = breedList.where((element) => element['enName'].toString().toLowerCase().contains(search)).toList();
    } else if(language.contains('ko')) {
      _searchList = breedList.where((element) => element['koName'].toString().toLowerCase().contains(search)).toList();
    }  else if(language.contains('es')) {
      _searchList = breedList.where((element) => element['esName'].toString().toLowerCase().contains(search)).toList();
    }
    return _searchList;
  }


  static String getBreedNameAtIndex(List<dynamic> searchList, int index, String language) {
    String breedName =searchList[index]['enName'];
    if (language.contains('en')) {
       breedName =searchList[index]['enName'];
    } else if(language.contains('ko')) {
      breedName =searchList[index]['koName'];
    }  else if(language.contains('es')) {
      breedName =searchList[index]['esName'];
      // _searchList = breedList.where((element) => element['esName'].toString().toLowerCase().contains(search)).toList();
    }
    // String breedName = language == 0 ? searchList[index]['enName'] : searchList[index]['koName'];
    return breedName;
  }

  //버전비교
  static bool compareVersion(String localVersion, String serverVersion) {
    final List<String> arrLocal = localVersion.split(".");
    final List<String> arrForce = serverVersion.split(".");
    if (arrLocal.isEmpty || arrForce.isEmpty) {
      return true;
    }
    var cntMin =
    (arrLocal.length > arrForce.length) ? arrLocal.length : arrForce.length;
    for (int i = 0; i < cntMin; i++) {
      if (int.parse(arrLocal[i]) > int.parse(arrForce[i])) {
        return true;
      } else if (int.parse(arrLocal[i]) < int.parse(arrForce[i])) {
        return false;
      }
    }
    return (arrLocal.length >= arrForce.length) ? true : false;
  }

  static String getTimeZoneLiveMeeting(String abbreviation) {
    var timeZoneMap = {
      'ET': 'America/New_York',
      'CT': 'America/Chicago',
      'MT': 'America/Denver',
      'PT': 'America/Los_Angeles',
      'AK': 'America/Anchorage',
      'HAST': 'Pacific/Honolulu',
      'MST': 'America/Phoenix',
      'AST': 'America/Aruba',
      'MOST': 'Africa/Casablanca',
      'UTC': 'Etc/GMT+0',
      'GMT': 'Europe/London',
      'GST': 'Africa/Casablanca',
      'WET': 'Europe/Amsterdam',
      'CET': 'Europe/Belgrade',
      'RST': 'Europe/Copenhagen',
      'CEST': 'Europe/Sarajevo',
      'ECT': 'Africa/Douala',
      'JST': 'Europe/Bucharest',
      'GTBST': 'Europe/Bucharest',
      'MEST': 'Africa/Cairo',
      'EGST': 'Africa/Cairo',
      'SST': 'Africa/Cairo',
      'SAST': 'Africa/Harare',
      'EET': 'Europe/Helsinki',
      'ISST': 'Asia/Jerusalem',
      'EEST': 'Asia/Jerusalem',
      'NMST': 'Asia/Jerusalem',
      'ARST': 'Asia/Baghdad',
      'ABST': 'Asia/Kuwait',
      'MSK': 'Europe/Moscow',
      'EAT': 'Asia/Kuwait',
      'IRST': 'Asia/Tehran',
      'ARBST': 'Asia/Muscat',
      'AZT': 'Asia/Baku',
      'MUT': 'Asia/Baku',
      'GET': 'Asia/Baku',
      'AMT': 'Asia/Baku',
      'AFT': 'Asia/Baku',
      'YEKT': 'Asia/Yekaterinburg',
      'PKT': 'Asia/Karachi',
      'WAST': 'Asia/Yekaterinburg',
      'IST': 'Asia/Calcutta',
      'SLT': 'Asia/Calcutta',
      'NPT': 'Asia/Katmandu',
      'BTT': 'Asia/Dhaka',
      'BST': 'Asia/Dhaka',
      'NCAST': 'Asia/Dhaka',
      'MYST': 'Asia/Rangoon',
      'THA': 'Asia/Bangkok',
      'KRAT': 'Asia/Bangkok',
      'HKT': 'Asia/Hong_Kong',
      'IRKT': 'Asia/Irkutsk',
      'SNST': 'Asia/Taipei',
      'AWST': 'Australia/Perth',
      'TIST': 'Asia/Taipei',
      'UST': 'Asia/Taipei',
      'TST': 'Asia/Tokyo',
      'KST': 'Asia/Seoul',
      'YAKT': 'Asia/Yakutsk',
      'CAUST': 'Australia/Adelaide',
      'ACST': 'Australia/Darwin',
      'EAST': 'Australia/Brisbane',
      'AEST': 'Australia/Sydney',
      'WPST': 'Pacific/Guam',
      'TAST': 'Australia/Hobart',
      'VLAT': 'Asia/Vladivostok',
      'SBT': 'Pacific/Guadalcanal',
      'NZST': 'Pacific/Auckland',
      'UTC12': 'Etc/GMT-12',
      'FJT': 'Pacific/Fiji',
      'PETT': 'Etc/GMT+12',
      'PHOT': 'Pacific/Tongatapu',
      'AZOST': 'Atlantic/Azores',
      'CVT': 'Atlantic/Cape_Verde',
      'ESAST': 'America/Sao_Paulo',
      'ART': 'America/Buenos_Aires',
      'SAEST': 'SA_Eastern_Standard_Time',
      'GNST': 'America/Godthab',
      'MVST': 'America/Montevideo',
      'NST': 'Canada/Newfoundland',
      'PRST': 'America/Aruba',
      'CBST': 'America/Aruba',
      'SAWST': 'America/Santiago',
      'PSAST': 'America/Santiago',
      'VST': 'America/Caracas',
      'SAPST': 'America/Bogota',
      'EST': 'America/Halifax',
      'CAST': 'America/Mexico_City',
      'CST': 'America/Mexico_City',
      'CCST': 'Canada/Saskatchewan',
      'MSTM': 'America/Mazatlan',
      'PST': 'America/Los_Angeles',
      'SMST': 'Pacific/Midway',
      'BIT': 'Etc/GMT+12',
    };

    return timeZoneMap[abbreviation] ?? abbreviation;
  }


  static String announcementLanguage(String value) {
    if (value.contains('ko')) {
      return '100';
    } else if (value.contains('en')) {
      return '101';
    } else if (value.contains('es')) {
      return '102';
    } else {
      return '101.';
    }
  }


  static Future getSampleJsonData(var assetsUri) async {
    String jsonString;
    jsonString = await rootBundle.loadString(assetsUri);
    //return Chart.fromJson(json.decode(jsonString));
    return jsonString;
  }



}