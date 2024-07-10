import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dolittle_for_vet/models/ResponseEntity.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class AppCache {


  static const String keyIsUserLogin='key_user';
  static const String keyIsPermission = 'key_permission';
  static const String keyIsHospitalJoinPopup = 'key_hospitalJoinPopup';
  static const String keyLocalVersion = 'key_localVersion';
  static const String keyAccessToken = 'key_accessToken';
  static const String keyRefreshToken = 'key_refreshToken';
  static const String keyUserId = 'key_userId';
  static const String keyUserName = 'key_userName';
  static const String keyUserEmail = 'key_userEmail';
  static const String keyHospitalId = 'key_hospitalId';
  static const String keyHospitalName = 'key_hospitalName';
  static const String keyHospitalLicense = 'key_hospitalLicense';
  static const String keyHospitalAddress = 'key_hospitalAddress';
  static const String keyAuthority = 'key_authority';
  static const String keyUserLicense = 'key_userLicense';
  static const String keyEventNotice = 'key_userEventNotice';
  static const String keyDiseaseNotice = 'key_userDiseaseNotice';
  static const String keyFcmToken = 'key_fcmToken';
  static const String keyVetLoginAES = 'vdmflskvmwekwlefkvmwlekvm!abdejk';



  static const String keyAnimalBreedDate = 'key_breedDate';
  static const String keyAnimalBreedList = 'key_breedList';
  static const String keyAnimalAES = 'FEE2B2A39AE31A79';
  static const String keyVetAES = 'FEE3B2A39AE51A19';
  static final String AnimalKeyIv = keyAnimalAES.substring(0, 16);
  static final String VetKeyIv = keyVetAES.substring(0, 16);
  static const String keyIsKakaoLogin = 'key_kakaoLogin';
  static const String keyTranslation = 'key_translation';



  //----------------------------------------------------------------
  static const String keyMonitoringAlarmState = 'key_monitoringAlarm';
  static const String keyMonitoringNotice = 'key_monitoringNotice';


  //----------------------------------------------------------------


  Future<bool> getIsUserLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsUserLogin) ?? false;
  }


  Future<bool> setIsUserLogin(bool isUserLogin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(keyIsUserLogin, isUserLogin);
  }


  Future<void> setCacheUserData(User userData) async {
    await setUserId(userData.id??"");
    await setUserName(userData.name??"");
    await setUserEmail(userData.email??"");
    await setUserLicense(userData.license??"");
    await setAuthority(userData.authority??0);
    await setHospitalId(userData.hospitalId??"");
    /**
     * 병원 iD가 null 인경우 예외처리 해서 화면을 띄워야 함
     *
     * */
  }

  //
  // /**
  //  * 토큰+쉐어드 무효화
  //  * */
  // Future<void> setInvaliDate() async {
  //   await setAccessToken("");
  //   await setRefreshToken("");
  //   await setUserId("");
  //   await setIsKakaoLogin(false);
  //   await setIsUserLogin(false);
  // }






  Future<void> setCacheHospitalData(Hospital hospitalData) async {
    String addresss = hospitalData.address_first??"${hospitalData.address_second??""}${hospitalData.address_road??""}${hospitalData.address_detail??""}";
    await setHospitalName(hospitalData.name??"");
    await setHospitalAddress(addresss);
    await setHospitalLicense(hospitalData.business_registration_number??"");
  }

   Future<bool> getIsKakaoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsKakaoLogin) ?? false;
  }


   Future<bool> setIsKakaoLogin(bool isKakaoLogin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(keyIsKakaoLogin, isKakaoLogin);
  }

  Future<List<String>?> getAnimalBreedDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(keyAnimalBreedDate)?? [];
  }
  Future<bool> setAnimalBreedDate(List<String> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(keyAnimalBreedDate,data);
  }

  Future<String> getAnimalBreedList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyAnimalBreedList)??"";
  }
  Future<bool> setAnimalBreedList(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyAnimalBreedList,data);
  }






  /****
   * 유저, 언어
   * 권한 알림허가
   * 토큰
   * 아이디
   *
   *
   *
   * */


  Future<String> getLocalVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLocalVersion) ?? "";
  }

  Future<bool> setLocalVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String _localVersion = packageInfo.version;
    return prefs.setString(keyLocalVersion, _localVersion);
  }

   Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserId) ?? "";

  }

   Future<bool> setUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyUserId, userId);
  }

   Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserName) ?? "";
  }

   Future<bool> setUserName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyUserName, name);
  }

   Future<String> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserEmail) ?? "";
  }

   Future<bool> setUserEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyUserEmail, email);
  }

   Future<String> getUserLicense() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserLicense) ?? "";
  }

   Future<bool> setUserLicense(String userLicense) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyUserLicense, userLicense);
  }

  Future<int> getAuthority() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyAuthority) ?? 0;
  }

  Future<bool> setAuthority(int authority) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(keyAuthority, authority);
  }

  Future<String> getHospitalId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyHospitalId) ?? "";
  }

  Future<bool> setHospitalId(String hospitalId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyHospitalId, hospitalId);
  }


  Future<String> getTranslation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyTranslation) ?? "en";
  }

   Future<bool> setTranslation(String translation) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyTranslation, translation);
  }

   Future<bool> getIsPermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsPermission) ?? false;
  }

   Future<bool> setIsPermission(bool isPermission) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(keyIsPermission, isPermission);
  }


  Future<bool> getIsHospitalJoinPopup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsHospitalJoinPopup) ?? false;
  }

  Future<bool> setIsHospitalJoinPopup(bool IsHospitalJoinPopup) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(keyIsHospitalJoinPopup, IsHospitalJoinPopup);
  }

   Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyAccessToken) ?? "";
  }

   Future<bool> setAccessToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyAccessToken, accessToken);
  }

   Future<String> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyRefreshToken) ?? "";
  }

   Future<bool> setRefreshToken(String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyRefreshToken, refreshToken);
  }

   Future<bool> getEventNotice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyEventNotice) ?? true;
  }

   Future<bool> setEventNotice(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(keyEventNotice, value);
  }

   Future<bool> getDiseaseNotice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyDiseaseNotice) ?? true;
  }

   Future<bool> setDiseaseNotice(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(keyDiseaseNotice, value);
  }



  /****
   * 병원
   * 병원이름
   * 병원사업자번호 =
   * 아이디

   * */


   Future<String> getHospitalName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyHospitalName) ?? "";
  }

   Future<bool> setHospitalName(String HospitalName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyHospitalName, HospitalName);
  }

   Future<String> getHospitalLicense() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyHospitalLicense) ?? "";
  }

   Future<bool> setHospitalLicense(String HospitalLicense) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyHospitalLicense, HospitalLicense);
  }

  Future<String> getHospitalAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyHospitalAddress) ?? "";
  }

  Future<bool> setHospitalAddress(String hospitalAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyHospitalAddress, hospitalAddress);
  }

   Future<String> getFcmToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyFcmToken) ?? "";
  }

   Future<bool> setFcmToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyFcmToken, token);
  }



  /**
   * 토큰+사용자 내용무효화
   * */
   Future<void> setInvaliDate() async {
   await setAccessToken("");
   await setRefreshToken("");
   await setIsHospitalJoinPopup(false);
   await setIsKakaoLogin(false);
   await setIsUserLogin(false);
  }



//=======================모니터링화면=========================================
//keyMonitoringAlarmState
  Future<int> getMonitoringAlarmState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyMonitoringAlarmState) ?? 2;
  }

  Future<bool> setMonitoringAlarmState(int state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(keyMonitoringAlarmState, state);
  }

  Future<bool> getMonitoringNotice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyMonitoringNotice) ?? true;
  }

  Future<bool> setMonitoringNotice(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(keyMonitoringNotice, value);
  }

}
