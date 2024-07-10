
import 'package:dolittle_for_vet/models/app_cache.dart';
import 'package:dolittle_for_vet/screens/RegisterScreen.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/components/loading_bar.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/api/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:timezone/standalone.dart';
import '../models/ResponseEntity.dart' as Response;
import '../models/notification_manager.dart';
import '../models/profile_manager.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/loginScreen';
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

const List<Widget> countryList = <Widget>[
  Text('Korea'),
  Text('FrankFurt'),
];

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();
  final ApiUtility _apiUtility = ApiUtility();
  NotificationManager _notificationManager = NotificationManager();
  ProfileManager _profileManager = ProfileManager();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final List<bool> _countryList = <bool>[true, false];
  bool _isLoading = false;
  int  _serverRouteInfo = 0;
  bool vertical = false;


  @override
  void initState() {
    // TODO: implement initState
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    _notificationManager = Provider.of<NotificationManager>(context, listen: false);
    UtilityFunction.log.e('실제 빌드 ? ${ApiUtility.isBuild}');
    super.initState();
  }


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    }

  @override
  void dispose() {
    // TODO: implement dispose
    googleSignIn.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    KakaoSdk.init(nativeAppKey: '8a50d0112182a3fb70353a621956e9ff');
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ApiUtility.isBuild?Container(): buildServerSettingsWidget(),
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(bottom: VetTheme.diviceH(context)/3),
                      child: Image.asset(
                        'assets/zentry-logo.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              signGoogle(),
                              _apiService.isAndroid? Container():
                              signApple(),
                              signKakao(),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      //const LoadingBar(),
    );
  }

  Widget signKakao() {
    return Container(
      margin: EdgeInsets.fromLTRB(0,5,0,20),
      width: VetTheme.logoWidth(context),
      height: VetTheme.logoHeight(context),
      child: GestureDetector(
          onTap: () async {
             ApiUtility.isBuild?await loginWithKakao():showKakaoLoginMethodDialog();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(10.0),

            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: Icon(
                      CupertinoIcons.chat_bubble_fill,
                      color: Colors.black87,size: VetTheme.mediaHalfSize(context)/7,),
                  ),
                ),
                Expanded(
                    flex: 4,
                    child: Container(
                      margin: EdgeInsets.only(left: VetTheme.diviceW(context)/15),
                      child: Text('Login with Kakao',
                        style: TextStyle(fontSize: VetTheme.logotextSize(context),fontWeight: FontWeight.w400,color: Colors.black87),),
                    ))
              ],
            ),
          )
      ),
    );
  }

  Widget buildServerSettingsWidget() {
    return Column(
      children: [
        SwitchListTile(
          title: Text(_apiUtility.getIsRealServerState()?'RealServer':'TestServer'), // 스위치 버튼의 이름을 표시하는 텍스트 위젯
          value: _apiUtility.getIsRealServerState(), // 스위치의 현재 상태
          onChanged: (bool value) {
            setState(() {
              _apiUtility.setIsRealServerState(value);
              _apiUtility.setServerRoute(_serverRouteInfo);
            });
          },
          activeColor: Colors.red,
          inactiveTrackColor: VetTheme.hintColor,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text('Select-ServerRoute'),
            Container(margin: EdgeInsets.only(right: 5),),
            ToggleButtons(
              direction: vertical ? Axis.vertical : Axis.horizontal,
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < countryList.length; i++) {
                    _countryList[i] = i == index;
                  }
                  _serverRouteInfo = index;
                });
                _apiUtility.setServerRoute(_serverRouteInfo);
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              selectedColor: Colors.white,
              fillColor: Colors.red,
              color: Colors.red,
              constraints: const BoxConstraints(
                minHeight: 40.0,
                minWidth: 80.0,
              ),
              isSelected: _countryList,
              children: countryList,
            ),
          ],
        ),
      ],
    );
  }


  Widget signGoogle(){
    return Container(
      margin: const EdgeInsets.only(top: 5),
      width: VetTheme.logoWidth(context),
      height: VetTheme.logoHeight(context),
      child:
      GestureDetector(
        onTap: () async {
          await onGoogleLoginClicked();
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                  width: 0.5,
                  color: Colors.black
              )
          ),
          child: Row(
            children:  [
              Expanded(
                  child: SvgPicture.asset('assets/google/v-google-logo.svg',height: VetTheme.mediaHalfSize(context)/7 )),
              Expanded(
                flex: 4,
                child: Container(
                  margin: EdgeInsets.only(left: VetTheme.diviceW(context)/15),
                  child: Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: VetTheme.logotextSize(context),
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
  Widget signApple(){
    return Container(
      margin: const EdgeInsets.only(top: 5),
      width: VetTheme.logoWidth(context),
      height: VetTheme.logoHeight(context),
      child:
      GestureDetector(
        onTap: () async {
          await onAppleLoginClicked();
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                  width: 0.5,
                  color: Colors.black
              )
          ),
          child: Row(
            children:  [
              Expanded(

                  child: Icon(Icons.apple,color: Colors.black87,size: VetTheme.mediaHalfSize(context)/6,)),
              Expanded(
                flex: 4,
                child: Container(
                  margin: EdgeInsets.only(left: VetTheme.diviceW(context)/15),
                  child: Text(
                    'Sign in with Apple ',
                    style: TextStyle(
                      fontSize: VetTheme.logotextSize(context),
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }




  Future<void> loginWithKakao() async{
    var keyhash =await KakaoSdk.origin;

    try {
      if (await isKakaoTalkInstalled()) {
        UtilityFunction.log.e('카카오톡 자동 로그인 클릭');
        await UserApi.instance.loginWithKakaoTalk();
        await getKaKaoUserInfo();
      } else {
        UtilityFunction.log.e('카카오톡 선택 로그인 클릭');
        await UserApi.instance.loginWithKakaoAccount();
        await getKaKaoUserInfo();
      }
    }catch(e){
      UtilityFunction.log.e('${e.toString()}');
      if (e is PlatformException && e.code =="NotSupportError") {
        await UserApi.instance.loginWithKakaoAccount();
        await getKaKaoUserInfo();
        return;
      }
    }
  }

  Future<void> loginWithAnotherKakaoAccount() async{
    UtilityFunction.log.e('다른아이디로 로그인 클릭');
    try {
      await UserApi.instance.loginWithKakaoAccount();
      await getKaKaoUserInfo();
    }catch(e){
      print(e);
      if (e is PlatformException && e.code =="NotSupportError") {
        await UserApi.instance.loginWithKakaoAccount();
        await getKaKaoUserInfo();
        return;
      }
    }
  }

  Widget createContainerWithText(int state,String text, BuildContext dialogBuild) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          Navigator.pop(dialogBuild);
          state==0?await loginWithKakao():await loginWithAnotherKakaoAccount();
        },
        child: Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.fromLTRB(30, 0, 30,10),
          padding: EdgeInsets.all(VetTheme.textSize(context)),
          decoration: BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              decoration: TextDecoration.none,
              fontSize: VetTheme.textSize(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void showKakaoLoginMethodDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87,
      pageBuilder: (BuildContext dialogBuild, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Center(
          child: Container(
            height: VetTheme.diviceW(context) / 2,
            child: Column(
              children: [
                createContainerWithText(0,'Login with Kakao', dialogBuild),
                createContainerWithText(1,'Login with another Kakao account', dialogBuild),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 20),
                    child:Container(
                      width: 50, // 동그라미의 너비 설정
                      height: 50, // 동그라미의 높이 설정 (동일한 값으로)
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // 동그라미 모양 설정
                        border: Border.all(
                          color: Colors.white, // 테두리 색상 설정
                          width: 0.5, // 테두리 두께 설정
                        ),
                      ),
                      child: GestureDetector(
                          onTap: (){
                             Navigator.pop(dialogBuild);
                          },
                          child: Icon(Icons.clear,color: Colors.white,)), // 아이콘 색상 설정
                    )),
                )
              ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 100),
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.0, 0.9),
            end: Offset(0.0, 0.3),
          ).animate(animation),
          child: child,
        );
      },
    );
  }


  /**
   * @ google login api
   *
   * */

  Future<void> onGoogleLoginClicked() async{
    try {
      final GoogleSignInAccount? user = await googleSignIn.signIn();
      if (user != null) {
        String email = user.email.toString();
        String username = user.displayName.toString() ?? '';
        String userid = user.email.toString();
        String pw = UtilityFunction.aesEncodeLogin('$email;google');
        var loginArg = Response.LoginArguments(
            loginType: Response.eLoginType.GOOGLE,
            userId: userid,
            email: email,
            name: '',
            nickName: username,
            authorizationCode: '',
            identityToken: ''
        );
         //유저 정보 가져온걸로 로그인 api
         return await fetchLogin3(pw, loginArg);
        // return await fetchLoginV2(pw,loginArg);
      }
      return setLoading(false);
    }catch(e){
      setLoading(false);
      UtilityFunction.log.e(e.toString());
    }
  }


  /**
   * @ apple login api
   *
   * */
  Future<void> onAppleLoginClicked() async{
    //setLoading(true);
    try{
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      if(credential.identityToken!=null){
        String name = "";
        String nickName = "";
        if (credential.familyName != null &&
            credential.familyName != null) {
          name =
          "${credential.givenName.toString()}${credential.familyName.toString()}";
          nickName =
          "${credential.givenName.toString()}${getMinSec(DateTime.now())}";
        }
        //UtilityFunction.log.e(credential.authorizationCode);
        UtilityFunction.log.e(credential.identityToken!);
        String email = UtilityFunction.getUserAppleEmailJwt(credential.identityToken!);
        UtilityFunction.log.e(email);
        UtilityFunction.log.e(credential.toString());
        UtilityFunction.log.e(credential.givenName.toString());
        UtilityFunction.log.e(credential.familyName.toString());

        var loginArg = Response.LoginArguments(
            loginType: Response.eLoginType.APPLE,
            userId: credential.userIdentifier.toString(),
            email: email,
            name: name,
            nickName: nickName,
            authorizationCode: credential.authorizationCode,
            identityToken: credential.identityToken!
        );
        //return await fetchAppleLogin(credential.authorizationCode,credential.identityToken!,loginArg);
         return await fetchAppleLogin2(credential.authorizationCode,credential.identityToken!,loginArg);

      }
    }catch (error) {
      print(error);
      UtilityFunction.log.e(error.toString());
      setLoading(false);
    }
  }

  Future<void> getKaKaoUserInfo() async {
    User user = await UserApi.instance.me();
    Account? account = user.kakaoAccount;
    //UtilityFunction.log.e(user.toString());
    if (account != null) {
      String email = account.email.toString() ?? "";
      String pw = UtilityFunction.aesEncodeLogin('$email;kakao');

      var loginArg = Response.LoginArguments(
        loginType: Response.eLoginType.KAKAO,
        userId: user.id.toString(),
        email: account.email.toString(),
        name: "",
        nickName: account.profile != null ?
        account.profile!.nickname != null
            ? account.profile!.nickname.toString() : "" : "",
        authorizationCode: "",
        identityToken: "",
      );

      //유저 정보 가져온걸로 로그인 api
      return await fetchLogin3(pw,
          loginArg);

    //return await fetchLoginV2(pw, loginArg);
    } else {
      //app_cache.setIsKakaoLogin(false);
      // Singleton.setIsKakaoLogin(false);
    }
  }



  /**
   * @  (apple)login api true => MainScreen : registerScrren
   * */
  Future<void>fetchAppleLogin2(String authorizationCode, String identityToken ,Response.LoginArguments loginArguments) async{
    UtilityFunction.log.e('AppleLogin 로그인실행v2');
    await _notificationManager.getFcmToken();
    final String defaultLocale = Platform.localeName;
    String currentTimeZone = DateTime.now().timeZoneName;
    final isAppleLogin = await _apiService.appleLoginV2(
        {
          'appVersion':_profileManager.version,
          'appOS':"iOS",
          'regionCode':defaultLocale.substring(defaultLocale.length-2),
          'languageCode':defaultLocale.substring(0,2),
          'timeZone': UtilityFunction.getTimeZoneLiveMeeting(currentTimeZone)
        }, {
          "identityToken":identityToken,
          "authorizationCode":authorizationCode,
          "pushMessageToken":await AppCache().getFcmToken()
    });
    if(isAppleLogin.isSuccess()){
      int nUserID = UtilityFunction.getUserIdJwt(isAppleLogin.getSuccess()!.accessToken);
      await _apiService.setUserId(nUserID.toString());
      await _apiService.setAccessToken(isAppleLogin.getSuccess()!.accessToken);
      await _apiService.setRefreshToken(isAppleLogin.getSuccess()!.refreshToken);
      Provider.of<ProfileManager>(context,listen: false).login();
      return UtilityFunction.moveScreenAndPop(context,'/main');
    }else{
      if(isAppleLogin.getError()?.code==301){
        return UtilityFunction.moveScreenAndPop(context, '/register',loginArguments);
      }else{
        return UtilityComponents.showToast('error : ${isAppleLogin.getError()?.message??""}');
      }
    }
  }

  // /**
  //  * @  (apple)login api true => MainScreen : registerScrren
  //  * */
  // Future<void>fetchAppleLogin(String authorizationCode, String identityToken ,Response.LoginArguments loginArguments) async{
  //   await _notificationManager.getFcmToken();
  //   final isAppleLogin = await _apiService.appleLogin(authorizationCode, identityToken);
  //   if(isAppleLogin){
  //     Provider.of<ProfileManager>(context,listen: false).login();
  //     return UtilityFunction.moveScreenAndPop(context,'/main');
  //   }else{
  //     return UtilityFunction.moveScreenAndPop(context, '/register',loginArguments);
  //   }
  // }



  Future<void>fetchLogin3(String pw ,Response.LoginArguments loginArguments) async{
    //UtilityFunction.log.e('로그인실행v3');
    await _notificationManager.getFcmToken();
    final String defaultLocale = Platform.localeName;
    String currentTimeZone = DateTime.now().timeZoneName;
    final isLogin = await _apiService.loginV3({
      'appVersion':_profileManager.version,
      'appOS':_apiService.isAndroid?"Android":"iOS",
      'regionCode':defaultLocale.substring(defaultLocale.length-2),
      'languageCode':defaultLocale.substring(0,2),
      'timeZone': UtilityFunction.getTimeZoneLiveMeeting(currentTimeZone)
    },{'password': pw,
      'pushMessageToken': await AppCache().getFcmToken()});

    if(isLogin.isSuccess()){
      int nUserID = UtilityFunction.getUserIdJwt(isLogin.getSuccess()!.refreshToken);
      await _apiService.setUserId(nUserID.toString());
      await _apiService.setAccessToken(isLogin.getSuccess()!.accessToken);
      await _apiService.setRefreshToken(isLogin.getSuccess()!.refreshToken);
      Provider.of<ProfileManager>(context,listen: false).login();
        return UtilityFunction.moveScreenAndPop(context,'/main');
    }else{
      if(isLogin.getError()?.code==301){
       return UtilityFunction.moveScreenAndPop(context, '/register',loginArguments);
      }else{
        return UtilityComponents.showToast('error : ${isLogin.getError()?.message??""}');
      }
    }
  }

  // Future<void>fetchLoginV2(String pw ,Response.LoginArguments loginArguments) async{
  //   await _notificationManager.getFcmToken();
  //   final String defaultLocale = Platform.localeName;
  //   final isLogin = await _apiService.login(pw);
  //   if(isLogin.isSuccess()){
  //     int nUserID = UtilityFunction.getUserIdJwt(isLogin.getSuccess()!.refreshToken);
  //     await _apiService.setUserId(nUserID.toString());
  //     await _apiService.setAccessToken(isLogin.getSuccess()!.accessToken);
  //     await _apiService.setRefreshToken(isLogin.getSuccess()!.refreshToken);
  //     Provider.of<ProfileManager>(context,listen: false).login();
  //     return UtilityFunction.moveScreenAndPop(context,'/main');
  //   }else{
  //     if(isLogin.getError()?.code==301){
  //       return UtilityFunction.moveScreenAndPop(context, '/register',loginArguments);
  //     }else{
  //       return UtilityComponents.showToast('error : ${isLogin.getError()?.message??""}');
  //     }
  //   }
  // }


  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  String getMinSec(DateTime date) {
    final String minute = date.minute.toString().padLeft(2, '0');
    final String second = date.second.toString().padLeft(2, '0');

    return "$minute$second";
  }



}
