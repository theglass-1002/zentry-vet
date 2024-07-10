import 'dart:io';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/screens/screens.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import '../new_screens/MonitoringListScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const routeName = '/MainScreen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  ProfileManager _profileManager = ProfileManager();
  SocketManager _socketManager = SocketManager();
  ApiService _apiService = ApiService();
  NotificationManager _notificationManager = NotificationManager();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _socketManager =  Provider.of<SocketManager>(context, listen: false);
      _profileManager = Provider.of<ProfileManager>(context, listen: false);
      if(_profileManager.isLoggedIn){
        getUserData();
      }
    }
  }

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    //UtilityFunction.log.e('main didChangeDependencies');
    super.didChangeDependencies();


  }

  @override
  void dispose() {
    UtilityFunction.log.e('Main dispose ');
    super.dispose();
  }


  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _isLoading ? const LoadingBar() : Consumer<ProfileManager>(
        builder: (context, profileManager, child) {
          if (!profileManager.isLoggedIn) {
            _socketManager.disconnectAndCloseSocket();
            Future.delayed(Duration.zero, () {
              UtilityFunction.pushReplacementNamed(context, '/');
            });
          } else if (profileManager.userData.authority == 0) {
            return  GuestMainScreen();
          }else if (profileManager.userData.authority! > 0 && profileManager.userData.hospitalId != null) {
            if(profileManager.userData.authority==4){
              return TechnicianMainScreen();
            }
            return AuthMemberMainscreen();
          }
          return LoadingBar();
        },
      ),
    );
  }


  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    setLoading(false);
  }

  Future<void> getUserData() async {
    await _apiService.getUserData().then((userValue) {
      userValue.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          final refreshToken = await _apiService.refreshToken();
          if (refreshToken) {
            return await getUserData();
          }
          return await logoutAndPushToHome();
        }
        UtilityFunction.log.e(error.message);
        UtilityComponents.showToast(
            "${"Member lookup failed".tr()}:${error.message ?? ""}");
        return await logoutAndPushToHome();
      }, (success) async {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        BaseDeviceInfo deviceInfo;
        String deviceName;
        if (Platform.isAndroid) {
          deviceInfo = await deviceInfoPlugin.androidInfo;
          deviceName = deviceInfo.data['device'];
        } else {
          deviceInfo = await deviceInfoPlugin.iosInfo;
          deviceName = await UtilityFunction.getIosDeviceName(
              deviceInfo.data['utsname']['machine']);
        }
        FirebaseCrashlytics.instance.setCustomKey('server_real', '${ApiUtility.isBuild}');
        FirebaseCrashlytics.instance.setCustomKey('device', deviceName);
        FirebaseCrashlytics.instance.setCustomKey('app_version', packageInfo.version.toString());
        FirebaseCrashlytics.instance.setCustomKey('user_id', '${success.id}');
        //success.authority=0;
        await _profileManager.setUserData2(success);
        if (success.authority! > 0) {
          await _apiService.updateMonitoringNotify(success.id!,
              {"enabled": "${await _apiService.getMonitoringNotice()}"});
          return await getHospitalData();
        }
        return await checkBreedsDate();
      });
    });
  }

  Future<void> getHospitalData() async {
    await _apiService.getHospitalData().then((hospitalValue) {
      hospitalValue.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          final refreshToken = await _apiService.refreshToken();
          if (refreshToken) {
            return getHospitalData();
          }
          return await logoutAndPushToHome();
        }
        UtilityFunction.log. e(error.message.toString());
        UtilityComponents.showToast(
            "${"Hospital inquiry failed".tr()}:${error.message ?? ""}");
        return await logoutAndPushToHome();
      }, (success) async {
        await  _profileManager.setHospitalData2(success);
        return await checkBreedsDate();
      });
    });
  }

  Future<void> checkBreedsDate() async {
    var breedInfo = await _apiService.getAnimalBreedDate();
    var breedList = await _apiService.getAnimalBreedList();
    await _apiService.getBreedsLastUpdate().then((value) {
      value.when((error) {
        UtilityComponents.showToast(error.message!);
        setLoading(false);
      }, (success) async {
        String updateCnt = success.cnt.toString() ?? "";
        String updatedAt = success.updatedAt.toString() ?? "";
        if (breedList.isEmpty || breedInfo!.isEmpty) {
          await _apiService.setAnimalBreedDate([updateCnt, updatedAt]);
          return await getBreedList();
        }
        else if (breedInfo[0] != updateCnt || breedInfo[1] != updatedAt) {
          await _apiService.setAnimalBreedDate([updateCnt, updatedAt]);
          return await getBreedList();
        }
        return setLoading(false);
      });
    });
  }

  Future<void> getBreedList() async {
    await _apiService.getBreedList().then((value) {
      value.when((error) {
        UtilityComponents.showToast(error.message!);
        return setLoading(false);
      }, (success) async {
        UtilityFunction.log.e('불러오기');
        await _apiService.setAnimalBreedList(success);
        return setLoading(false);
      });
    });
  }

  void setLoading(bool isLoading) {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }


}

