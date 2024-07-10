import 'dart:async';
import 'dart:convert';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ProfileManager _profileManager = ProfileManager();
  final _apiService = ApiService();
  bool _isLoading = true;

  @override
  void initState() {
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    await Future.delayed(Duration(seconds: 1));
    await _profileManager.initializeApp();
    await versionCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            _isLoading ? Center(
              child: SizedBox(
                height: VetTheme.mediaHalfSize(context)/2,
                width: VetTheme.mediaHalfSize(context)/2,
                child: const CircularProgressIndicator(
                  color: Color(0xfffffc2934),
                ),
              ),
            ) : Container(),
            Center(
              child: Image.asset(
                'assets/zentry-logo.png',
                fit: BoxFit.fill,
              ),
            ),
          ],
        ));
  }

  /**
   *
   * @앱 버전 체크
   * _isForceAlert => false 강제 업데이트
   * _isRcmdAlert => false 선택 업데이트
   *
   * */

  Future<void> versionCheck() async {
    if(mounted) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      UtilityFunction.log.e('현재버전 ${packageInfo.version}');
       String localVersion = packageInfo.version;
      // String localVersion = "1.2.7";
      _profileManager.setAppVersion(localVersion);
      try {
        await _apiService.versionCheck().then((result) {
          return result.when((error) {
            UtilityFunction.log.e(error.message. toString());
            UtilityComponents.showToast(error.message ?? "");
            setLoading(false);
          }, (success) async {
            UtilityFunction.log.e('강제버전  ${success.forceVersion}');
            UtilityFunction.log.e('권장버전 ${success.recommendVersion}');
            // bool isForceAlert = compareVersion(localVersion,'1.2.7');
            //bool isRcmdAlert = compareVersion(localVersion,'1.2.7');
            bool isForceAlert = compareVersion(
                localVersion, success.forceVersion!);
            bool isRcmdAlert = compareVersion(
                localVersion, success.recommendVersion!);
            if (isForceAlert && isRcmdAlert) {
              return await checkPermission();
            } else {
              String storeUri = _apiService.isAndroid
                  ? 'https://play.google.com/store/apps/details?id=kr.zentry.dolittleforveterinarian'
                  : 'https://apps.apple.com/app/id6443406535';
              // _isForceAlert => false 필수 업데이트
              var resultMsg = isForceAlert
                  ? await versionCheckDialog(0)
                  : await versionCheckDialog(1);
              UtilityFunction.log.e(resultMsg.toString());
              return await resultMsg
                  ? await openUrl(storeUri)
                  : await checkPermission();
            }
          });
        });
      } catch (e) {
        UtilityComponents.showToast('Please check your Network');
        UtilityFunction.log.e(e.toString());
        await versionCheck();
      }
    }
  }

  /**
   * @ 앱 권한 체크
   * true => checkToken()
   * false => move permissionScreen
   * */

  Future<void> checkPermission() async {
    print('checkPermission :${await _apiService.getIsPermission()}');
    return await _apiService.getIsPermission()
        ? await checkToken()
        : UtilityFunction.moveScreenAndPop(context, '/permission');
  }


  /**
   * @ 토큰 체크
   * true => move MainScreen
   * false => move LoginScreen
   * */

  Future<void> checkToken() async {
     if(mounted){
      if(_profileManager.isLoggedIn){
        String userId = _profileManager.userData.id??"";
        if (userId.isEmpty || userId == "") {
          await _profileManager.logout();
          return UtilityFunction.moveScreenAndPop(context, '/login');
        }else{
          bool result = await _apiService.checkToken();
          if(result){
            return UtilityFunction.moveScreenAndPop(context, '/main');
          }else{
            await _apiService.logout();
            await _profileManager.logout();
            return UtilityFunction.moveScreenAndPop(context, '/login');
          }
        }
      }
      return UtilityFunction.moveScreenAndPop(context, '/login');
    }
  }


  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  // //URL 주소를 통해서 웹브라우저 열기
  Future<void> openUrl(String uri) async {
    UtilityFunction.log.e('앱스토어 실행');
    Uri url = Uri.parse(uri);
    try {
      if (_apiService.isAndroid) {
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

  Future<dynamic> versionCheckDialog(
      int state,
      ) {
    String content = state == 0
        ? 'An updated version has been released.\nGo to the App Store.'
        : 'An updated version has been released.';
    return showDialog<bool>(
      context: context,
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

  Future<dynamic> confirmDialog(BuildContext context, String title,
      String content, String buttonContentOk) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext builder) => AlertDialog(
        title: Text(title.tr()),
        content: Text(content.tr()),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                buttonContentOk.tr(),
                textAlign: TextAlign.center,
              ))
        ],
      ),
    );
  }

  //버전비교
  bool compareVersion(String localVersion, String serverVersion) {
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
}

