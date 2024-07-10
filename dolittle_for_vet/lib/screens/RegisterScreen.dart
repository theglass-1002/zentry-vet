import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  static const routeName = '/RegisterScreen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late LoginArguments? arguments;
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final api_Service = ApiService();
  bool isAllChecksCompleted = false;
  bool isOver14 = false;
  bool isTermsOfServiceAllowed = false;
  bool isPrivacyConsentAllowed = false;
  bool isPrivacyPolicyAllowed = false;
  bool isUpdateInfoAllowed = false;
  int completedConsents = 0;

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as LoginArguments;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                UtilityFunction.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text("Join membership".tr())),
        body: _isLoading ? const LoadingBar() : Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Theme(
                data: ThemeData(
                    iconTheme: const IconThemeData(color: Colors.grey),
                    primaryColor: Colors.grey),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          height: MediaQuery.of(context).size.width / 10,
                          child: Row(
                            children: [
                               Icon(
                                Icons.email_sharp,
                                size: VetTheme.logotextSize(context),
                              ),
                              Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    arguments!.email,
                                    style:  TextStyle(
                                        height: 1,
                                        fontSize: VetTheme.logotextSize(context),
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                    buildNameField(),
                    personalDataConsentWidget()
                  ],
                ),
              ),
            ),


        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: completedConsents == 4
                    ? MaterialStateProperty.all(VetTheme.mainIndigoColor)
                    : MaterialStateProperty.all(Colors.grey),

              ),
              onPressed: () async {
                if (completedConsents != 4) {
                  return;
                }
                if (nullCheck()) {
                  await onJoinBtnClicked();
                  UtilityFunction.log.e('회원가입전송');
                } else {
                return UtilityComponents.showToast("Please enter your name".tr());
                }

              },
              child: Text(
                completedConsents == 4
                    ? "Join membership".tr()
                    : "Your consent is required for the essential items".tr(),
              ),
            ),
          ),
        ));
  }

  Future<void> onJoinBtnClicked() async {
    setLoadingView(true);
    String name = _nameController.text.toString().trim();
    String pwJoin =
        UtilityFunction.getSha256Hash(arguments!.userId + arguments!.email);
    String loginType = arguments!.loginType.name == "KAKAO"
        ? 'kakao'
        : arguments!.loginType.name == "APPLE"
            ? 'apple'
            : 'google';
    String pwLogin =
        UtilityFunction.aesEncodeLogin('${arguments!.email};$loginType'); //v2
    bool apiResult = await api_Service.join(
        name, arguments!.email, pwJoin, loginType, arguments!.userId);

    if (apiResult) {
      setLoadingView(false);
      UtilityComponents.showToast("Sign up is complete".tr());
      UtilityFunction.moveScreenAndPop(context, '/login');
    } else {
      setLoadingView(false);
      UtilityComponents.showToast("Member registration failed".tr());
      UtilityFunction.moveScreenAndPop(context, '/login');
    }

  }


  Widget buildNameField() {
    return TextField(
      style: const TextStyle(fontSize: 20),
      maxLength: 30,
      controller: _nameController,
      cursorColor: Colors.grey,
      decoration: InputDecoration(
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          labelStyle: const TextStyle(color: Colors.grey),
          hintText: arguments!.name ?? "Name",
          helperText: 'Please enter your real name'.tr()),
    );
  }

  Widget personalDataConsentWidget() {
    return Container(
      margin:  const EdgeInsets.fromLTRB(0, 40, 0, 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start, // 가로 방향 정렬
            crossAxisAlignment: CrossAxisAlignment.center, // 세로 방향 정렬
            children: [
          IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              setState(() {
                isAllChecksCompleted = !isAllChecksCompleted;
                isOver14 = isAllChecksCompleted;
                isTermsOfServiceAllowed = isAllChecksCompleted;
                isPrivacyConsentAllowed = isAllChecksCompleted;
                isPrivacyPolicyAllowed = isAllChecksCompleted;
                isUpdateInfoAllowed = isAllChecksCompleted;
                isAllChecksCompleted
                    ? completedConsents = 4
                    : completedConsents = 0;
              });
            },
            icon: FaIcon(
              FontAwesomeIcons.circleCheck,
              size: VetTheme.titleTextSize(context) * 2,
              color: isAllChecksCompleted
                  ? VetTheme.mainIndigoColor
                  : Colors.black26,
            ),
          ),
          Text(
            "I consent to all".tr(),
            style: TextStyle(
                fontSize: VetTheme.titleTextSize(context),
                fontWeight: FontWeight.w600,
                color: VetTheme.mainIndigoColor),
          ),
            ],
          ),
          Container(
            color: Colors.grey.shade300,
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Container(
                  child: Row(
                    children: [
                      IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              isOver14 = !isOver14;
                              isOver14 ? "" : isAllChecksCompleted = false;
                              isOver14
                                  ? completedConsents++
                                  : completedConsents--;
                            });
                          },
                          icon: FaIcon(FontAwesomeIcons.circleCheck,
                              color: isOver14
                                  ? VetTheme.mainIndigoColor
                                  : Colors.black26)),
                      Flexible(
                        child: Text("I am 14 years or older (Required)".tr()),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              isTermsOfServiceAllowed = !isTermsOfServiceAllowed;
                              isTermsOfServiceAllowed
                                  ? ""
                                  : isAllChecksCompleted = false;
                              isTermsOfServiceAllowed
                                  ? completedConsents++
                                  : completedConsents--;
                            });
                          },
                          icon: FaIcon(FontAwesomeIcons.circleCheck,
                              color: isTermsOfServiceAllowed
                                  ? VetTheme.mainIndigoColor
                                  : Colors.black26)),
                      Flexible(
                        child: InkWell(
                            onTap: (){
                              UtilityFunction.moveScreen(context, '/webView',"Terms of Service (Required)");
                              },
                            child: Text("Terms of Service (Required)".tr(),)),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              isPrivacyConsentAllowed = !isPrivacyConsentAllowed;
                              isPrivacyConsentAllowed
                                  ? ""
                                  : isAllChecksCompleted = false;
                              isPrivacyConsentAllowed
                                  ? completedConsents++
                                  : completedConsents--;
                            });
                          },
                          icon: FaIcon(FontAwesomeIcons.circleCheck,
                              color: isPrivacyConsentAllowed
                                  ? VetTheme.mainIndigoColor
                                  : Colors.black26)),
                      Flexible(
                        child: InkWell(
                            onTap: (){
                              UtilityFunction.moveScreen(context, '/webView',"Privacy Consent (Required) ");
                            },
                            child: Text(
                                "Privacy Consent (Required)".tr())),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              isPrivacyPolicyAllowed = !isPrivacyPolicyAllowed;
                              isPrivacyPolicyAllowed
                                  ? ""
                                  : isAllChecksCompleted = false;
                              isPrivacyPolicyAllowed
                                  ? completedConsents++
                                  : completedConsents--;
                            });
                          },
                          icon: FaIcon(FontAwesomeIcons.circleCheck,
                              color: isPrivacyPolicyAllowed
                                  ? VetTheme.mainIndigoColor
                                  : Colors.black26)),
                      Flexible(
                        child: InkWell(
                            onTap: (){
                              UtilityFunction.moveScreen(context, '/webView',"Privacy Policy");
                            },
                            child: Text("Privacy Policy (Required)".tr())),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void setLoadingView(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  bool nullCheck() {
    if (_nameController.text.toString().trim().isEmpty) {
      _nameController.text = arguments!.name ?? "";
      return !_nameController.text.toString().trim().isEmpty;
    }
    return true;
  }
}

