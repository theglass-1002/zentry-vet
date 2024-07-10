import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  late String? webViewTitle = "";
  late String? webUri = "";
  final ApiService _apiService = ApiService();
  bool _isLoding = true;
  final key = UniqueKey();

  void setLoading(bool isLoding) {
    setState(() {
      _isLoding = isLoding;
    });
  }

  @override
  void initState() {
    super.initState();
    getPrivacyPolicyUri();
  }

  @override
  Widget build(BuildContext context) {
    webViewTitle = ModalRoute.of(context)!.settings.arguments.toString().trim();
    UtilityFunction.log.e(webViewTitle);
    return Scaffold(
        resizeToAvoidBottomInset: false, //키패드 올라갈 때 Chart UI 밀리지 않도록 설정
        appBar: AppBar(
            elevation: 1,
            title: Text(webViewTitle!.tr(),
                style: const TextStyle(color: Colors.white))),
        body: Stack(
          children: [
            getWebView(),
            _isLoding ? const LoadingBar() : getWebView()
          ],
        ));
  }

  Widget getWebView() {
    if (webViewTitle!.isNotEmpty) {
      return WebView(
        initialUrl: webUri,
        backgroundColor: Colors.white,
        onPageFinished: (finish) {
          setState(() {
            _isLoding = false;
          });
        },
      );
    } else {
      return Stack();
    }
  }

  Future<void> getPrivacyPolicyUri() async {
    await _apiService.getTranslation().then((langCode) {
      UtilityFunction.log.e(langCode.toString());
      if (webViewTitle == "Terms of Service (Required)") {
        webUri = langCode.contains('ko')
            ? ApiUtility.termsOfService
            : langCode.contains('es')
                ? ApiUtility.termsOfService_es
                : ApiUtility.termsOfService_en;
      } else if (webViewTitle == "Privacy Consent (Required)") {
        webUri = langCode.contains('ko')
            ? ApiUtility.personalInfoConsent
            : langCode.contains('es')
                ? ApiUtility.personalInfoConsent_es
                : ApiUtility.personalInfoConsent_en;
      } else {
        webUri = langCode.contains('ko')
            ? ApiUtility.privacyPolicy
            : langCode.contains('es')
                ? ApiUtility.privacyPolicy_es
                : ApiUtility.privacyPolicy_en;
      }
    });
    setLoading(false);
  }
}
