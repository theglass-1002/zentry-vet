import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class ProfileManager extends ChangeNotifier {
  bool _loggedIn = false;
  User _userData = User();
  Hospital _hospital = Hospital();
  ResponseError _responseError = ResponseError();
  AnimalList _animalList = AnimalList();
  final app_cache = AppCache();
  final api_service = ApiService();
  int _count = 0;
  int get count => _count;
  User get userData => _userData;
  ResponseError get responseError => _responseError;
  Hospital get hospitalData => _hospital;
  AnimalList get AnimalListData => _animalList;
  String _version = "";
  String get version => _version;
  bool _disposed = false;
  bool get isLoggedIn => _loggedIn;

  bool _isReload = false;
  bool get isReload  => _isReload;



  // Initializes the app
  Future<void> initializeApp( ) async {
    _loggedIn = await app_cache.getIsUserLogin();
    _userData.id = await app_cache.getUserId();
    _userData.name = await app_cache.getUserName();
    _userData.email = await app_cache.getUserEmail();
    _userData.license =await app_cache.getUserLicense();
    _userData.authority =await app_cache.getAuthority();
    _userData.hospitalId = await app_cache.getHospitalId();

  }
  
  Future<void> login() async {
    _loggedIn = true;
    await app_cache.setIsUserLogin(true);
    notifyListeners();
  }

  Future <void>  logout()async {
    _userData = User();
    _hospital = Hospital();
    _animalList = AnimalList();
    _loggedIn = false;
    await app_cache.setCacheUserData(_userData);
    await app_cache.setCacheHospitalData(hospitalData);
    await api_service.setInvaliDate();
    notifyListeners();
  }
  

  void setAppVersion(String version){
    _version = version;
  }


  Future<void> refreshUserDataFromServer(BuildContext context) async {
    bool versionCheck = await getVersion(context);
    if (versionCheck){
      await getUserData().then((userValue) {
        userValue.when((error) async {
          if (error.re_code == UnauthorizedCode && error.code == 101) {
            return await getRefreshToken()
                ? getUserData()
                : logout();
          }
          logout();
          UtilityComponents.showToast(error.message ?? "");
        //  UtilityFunction.pushReplacementNamed(context, '/login');

        }, (success) {

        });
      });
    }
  }

  Future<bool> getVersion(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;
    return await api_service.versionCheck().then((value) async {
      return await value.when((error) {
        UtilityFunction.log.e(error.message.toString());
        UtilityComponents.showToast(error.message ?? "");
        return false;
      }, (success) async {
        bool isForceAlert = UtilityFunction.compareVersion(
            localVersion, success.forceVersion!);
        bool isRcmdAlert = UtilityFunction.compareVersion(
            localVersion, success.recommendVersion!);
        if(isForceAlert && isRcmdAlert){
          return true;
        }
        String storeUri = api_service.isAndroid
            ? 'https://play.google.com/store/apps/details?id=kr.zentry.dolittleforveterinarian'
            : 'https://apps.apple.com/app/id6443406535';
        // _isForceAlert => false 필수 업데이트
        var resultMsg = isForceAlert
            ? await UtilityComponents.versionCheckDialog(0,context)
            : await UtilityComponents.versionCheckDialog(1,context);
        if(resultMsg){
          await UtilityComponents.openUrl(api_service.isAndroid,storeUri);
        }
        return true;
      });
    });
  }


  Future<void> setHospitalData2(Hospital hospital) async {
    _hospital = hospital;
   await app_cache.setCacheHospitalData(hospital);
    // UtilityFunction.log.e('_hospital 울려라');
   // notifyListeners();
  }
  Future<void> setUserData2(User user)  async {
    _userData = user;
    if(_userData.authority!>0){
      await app_cache.setIsHospitalJoinPopup(true);
    }
    await app_cache.setCacheUserData(_userData);
    //notifyListeners();
  }


  void setAnimalData2(AnimalList animalList)  {
    _animalList = animalList;
  }

  void addAnimalData2(AnimalList animalList)  {
    _animalList.animal_list!.addAll(animalList.animal_list as Iterable<Animal>);

  }

  void notifytest(){
    _userData.authority=0;
    notifyListeners();
  }

  Future <Result<ResponseError,User>> getUserData() async {
    return await api_service.getUserData().then((user) {
      return user.when((error) async {
       return Error(error);
      }, (success) async {
        await api_service.setCacheUserData(success);
        _userData = success;
        UtilityFunction.log.e('profile noty 울림');
        notifyListeners();
       return Success(success);
      });
    });
  }

  Future <Result<ResponseError,Hospital>> getHospitalData() async {
    return await api_service.getHospitalData().then((value) {
      return value.when((error) async {
        UtilityFunction.log.e(error.message);
        return Error(error);
      }, (success) async {
        await api_service.setCacheHospitalData(success);
        _hospital = success;
        UtilityFunction.log.e('${success.id.toString()}');
        notifyListeners();
        return Success(success);
      });
    });
  }

  Future  <Result<ResponseError, AnimalList>>  getAnimalData([Map<String, dynamic>? queryParameters]) async {
    if (userData.authority == 0) {
      final dataString = await _loadAsset(
        'assets/sample_data/sample_animals.json',
      );
      final Map<String, dynamic> json = jsonDecode(dataString);
      _animalList = AnimalList.fromJson(json);
      //notifyListeners();
      return Success(_animalList);
    } else {
     return await api_service.getAnimalList2(queryParameters).then((value) {
        return value.when((error) async {
          UtilityFunction.log.e(error.message);
         return Error(error);
        }, (success) {
          String offser = queryParameters!['offset'];
          if(offser=='0'){
            _animalList = success;
          //  notifyListeners();
          }else{
            _animalList.animal_list!.addAll(success.animal_list as Iterable<Animal>);
          }
          return Success(_animalList);
        });
      });
    }
  }



  Future<bool> getRefreshToken() async => await api_service.refreshToken();


  Future<bool> getUserEventNotice() async => await api_service.getEventNotice();
  Future<bool> setUserEventNotice(bool value) async => await api_service.setEventNotice(value);
  Future<bool> getUserDiseaseNotice() async => await api_service.getDiseaseNotice();
  Future<bool> setUserDiseaseNotice(bool value) async => await api_service.setDiseaseNotice(value);
  Future<bool> setUserTranslation(String value) async => await api_service.setTranslation(value);
  Future<String> getUserTranslation() async => await api_service.getTranslation();

  //-------모니터링---------------------------------------------------------
  Future<bool> getMonitoringNotice() async => await api_service.getMonitoringNotice();
  Future<bool> setMonitoringNotice(bool value) async => await api_service.setMonitoringNotice(value);

  Future<String> _loadAsset(String path) async {
    return rootBundle.loadString(path);
  }


  void animalListRefresh(bool reload) {
    _isReload = reload;
    notifyListeners();
  }

  // void animalListRefresh() {
  //   _isReload = false;
  //   notifyListeners();
  // }

  // void refreshAnimalList() {
  //   // 동물 목록을 새로고침하는 로직을 여기에 추가
  //   notifyListeners();
  // }


  // add() {
  //   UtilityFunction.log.e('notifyListeners 울리기');
  //   notifyListeners();
  // }

  @override
  void dispose(){
    _disposed = true;
    super.dispose();
  }


}
