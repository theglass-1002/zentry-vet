
import 'dart:convert';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/components/announcementPost_card.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/dom.dart' as dom;


class AnnouncementPostScreen extends StatefulWidget {
  const AnnouncementPostScreen({super.key});

  @override
  State<AnnouncementPostScreen> createState() => _AnnouncementPostScreenState();
}

class _AnnouncementPostScreenState extends State<AnnouncementPostScreen> {
  late ProfileManager _profileManager = ProfileManager();
  late ApiService _apiService = ApiService();
  late WebViewController _controller;
  bool _isLoading = true; // 추가
  var postId = null;
  AnnouncementDetail announcementDetail = AnnouncementDetail();


  @override
  void initState() {
    // TODO: implement initState
    //getData();
    super.initState();
  }


  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    postId = ModalRoute.of(context)?.settings.arguments.toString();
    await getPostDetail(postId);
    super.didChangeDependencies();
  }


  Future<void> getPostDetail(postId)  async {
    await _apiService.connectGetAnnouncementDetail(postId).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? await getPostDetail(postId)
            : await logoutAndPushToHome();
        }
        UtilityComponents.showToast(
        "${"Failed to load announcement list".tr()}:${error.message ?? ""}");
        UtilityFunction.goBackToPreviousPage(context);
      },
      (success) {
        announcementDetail = success;
        setLoading(false);
        return;
      });
    });
  }


  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    setLoading(false);
  }

  void setLoading(bool isLoding) {
    setState(() {
      _isLoading = isLoding;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Announcement".tr()),
      ),
      body: _isLoading?LoadingBar():
      InteractiveViewer(
        minScale: 0.1,
        maxScale: 1.6,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: VetTheme.textSize(context)),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: VetTheme.logotextSize(context)),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: VetTheme.mainIndigoColor,
                            width: 1.0,           // 테두리 두께 설정
                          ),
                          borderRadius: BorderRadius.circular(VetTheme.logotextSize(context)),
                        ),
                        margin: EdgeInsets.only(right: VetTheme.textSize(context)),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: VetTheme.textSize(context)/2,vertical: VetTheme.textSize(context)/2),
                          child: Text(UtilityComponents.getNoticeType(announcementDetail.type!),
                            style: TextStyle(color: VetTheme.mainIndigoColor),),
                        ),
                      ),
                      Expanded(
                        child: Container(
                            child: Text(announcementDetail.title.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: VetTheme.logotextSize(context)),)),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text('Zentry'),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: VetTheme.textSize(context)),
                        child: Text('|')),
                    Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(announcementDetail.createdAt!))),
                  ],
                ),
                Container(
                    margin: EdgeInsets.symmetric(vertical: VetTheme.textSize(context)),
                    child: Divider()), // Divider 추가
                Container(
                  child: Html(
                    data: announcementDetail.content,
                  ),
                )
            ],
          ),
        ),
      )

    );
  }
}

//----------------------------------------------------------------

// import 'dart:convert';
//
// import 'package:dolittle_for_vet/app_theme/app_theme.dart';
// import 'package:dolittle_for_vet/components/announcementPost_card.dart';
// import 'package:dolittle_for_vet/utility_function.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:dolittle_for_vet/utility_function.dart';
// import 'package:dolittle_for_vet/api/api.dart';
// import 'package:dolittle_for_vet/models/models.dart';
// import 'package:dolittle_for_vet/components/components.dart';
// import 'package:flutter/services.dart';
// import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
//
//
// class AnnouncementPostScreen extends StatefulWidget {
//   const AnnouncementPostScreen({super.key});
//
//   @override
//   State<AnnouncementPostScreen> createState() => _AnnouncementPostScreenState();
// }
//
// class _AnnouncementPostScreenState extends State<AnnouncementPostScreen> {
//   late ProfileManager _profileManager = ProfileManager();
//   late ApiService _apiService = ApiService();
//   late WebViewController _controller;
//   bool isLoading = true; // 추가
//   var postId = null;
//
//
//   @override
//   Widget build(BuildContext context) {
//     postId = ModalRoute.of(context)?.settings.arguments;
//     UtilityFunction.log.e('is logding ${isLoading}');
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text("Announcement".tr()),
//       ),
//       body: Container(
//         height:isLoading?0.5:double.infinity,
//         child: WebView(
//           backgroundColor: Colors.white,
//            //initialUrl:'http://10.1.1.113:3000',
//          // / initialUrl:'https://admin.zentry.kr',
//           initialUrl:'https://admin.zentry.kr',
//           javascriptMode: JavascriptMode.unrestricted,
//           onWebViewCreated: (WebViewController webViewController) {
//             UtilityFunction.log.e('webViewCreated webViewController');
//             setState(()  {
//               _controller = webViewController;
//             });
//           },
//           onPageStarted: (String url)async{
//           },
//           onPageFinished: (String url) async {
//             await _controller.runJavascript('localStorage.setItem("type","vet")');
//             await _controller.runJavascript('localStorage.setItem("isServer","true")');
//             Future.delayed(Duration(seconds: 1), () async {
//               var a = await _controller.runJavascriptReturningResult('localStorage.getItem("type")');
//               UtilityFunction.log.e(a);
//               if(a.contains('vet')) {
//                 UtilityFunction.log.e('값들어감${a}');
//                 var values = {
//                   "appType":"vet",
//                   "utility":"0",
//                   "method":"AnnouncementDetail",
//                   "postId":"$postId"
//                 };
//                 var jsonString = jsonEncode(values);
//                 await _controller.runJavascript('window.checkAppContentType($jsonString)');
//                 setState(() {
//                   isLoading = false;
//                 });
//               } else {
//                 UtilityFunction.log.e('값안들어감 ${a}');
//               }
//             });
//
//            //  await _controller.runJavascript(
//            //      'localStorage.setItem("type","vet")');
//            //  await _controller.runJavascript(
//            //      'localStorage.setItem("isServer","true")');
//            // var a = await _controller.runJavascriptReturningResult('localStorage.getItem("type")');
//            // UtilityFunction.log.e(a);
//            // if(a.contains('vet')){
//            //   UtilityFunction.log.e('값들어감${a}');
//            //   var values = {
//            //     "appType":"vet",
//            //     "utility":"0",
//            //     "method":"AnnouncementDetail",
//            //     "postId":"$postId"
//            //   };
//            //   var jsonString = jsonEncode(values);
//            //   await _controller.runJavascript(
//            //       'window.checkAppContentType($jsonString)');
//            //   setState(() {
//            //     isLoading = false;
//            //   });
//            // }else{
//            //   UtilityFunction.log.e('값안들어감 ${a}');
//            //  }
//            },
//           onWebResourceError: (WebResourceError error){
//             UtilityFunction.log.e('에러발생${error.description}');
//           },
//         ),
//       ),
//     );
//   }
// }
