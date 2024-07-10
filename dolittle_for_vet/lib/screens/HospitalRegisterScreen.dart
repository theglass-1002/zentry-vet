import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:country_picker/country_picker.dart';


class HospitalRegisterScreen extends StatefulWidget {
  const HospitalRegisterScreen({Key? key}) : super(key: key);
  static const routeName = '/HospitalRegisterScreen';
  @override
  State<HospitalRegisterScreen> createState() => _HospitalRegisterScreenState();
}

class _HospitalRegisterScreenState extends State<HospitalRegisterScreen> {
  late ProfileManager _profileManager = ProfileManager();
  late final ApiService _apiservice = ApiService();
  TextEditingController hospital_name = new TextEditingController();
  TextEditingController hospital_address = new TextEditingController();
  TextEditingController hospital_phone = new TextEditingController();
  String selectedIntlCode = "+1";
  final picker = ImagePicker();
  File? file_vet_license;
  File? file_business_license;
  bool _check = false;
  bool _isLoading = false;


  @override
  void initState() {
    // TODO: implement initState
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(elevation: 1, title: Text("Hospital registration".tr())),
      body: _isLoading ? LoadingBar() : Container(
          margin: const EdgeInsetsDirectional.all(10), child: buildInputBox()),
      bottomNavigationBar: _isLoading ? null : BottomAppBar(
        child: Container(
          margin: const EdgeInsetsDirectional.all(10),
          child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      _check ? VetTheme.mainIndigoColor : Colors.black12
                  )
              ),
              onPressed:
              _check ?
                  () => resultBt() : null,
              child: _check ? Text("Hospital registration application").tr() :
              Text("Please click the circle to check").tr()
          ),
        ),
      ),
    );
  }

  Widget buildInputBox() {
    return ListView(
        children: [
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12, width: 2),
                color: Colors.white,
              ),
              margin: const EdgeInsets.fromLTRB(10, 15, 10, 10),
              padding: EdgeInsets.all(VetTheme.titleTextSize(context)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${"Email".tr()} : ",
                            style: TextStyle(
                                fontSize: VetTheme.titleTextSize(context)),
                          ),
                          Expanded(
                            child: Text(
                                _profileManager.userData.email ?? "",
                                style: TextStyle(
                                    fontSize: VetTheme.titleTextSize(context))),
                          ),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${"Name".tr()} : ",
                            style: TextStyle(
                                fontSize: VetTheme.titleTextSize(context)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                                _profileManager.userData.name ?? "",
                                style: TextStyle(
                                    fontSize: VetTheme.titleTextSize(context))),
                          ),
                        ]),
                  ])),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextField(
              controller: hospital_name,
              cursorColor: Colors.black,
              style: TextStyle(
                fontSize: VetTheme.textSize(context),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: Icon(Icons.local_hospital_outlined,
                      size: VetTheme.logotextSize(context),),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  contentPadding: EdgeInsets.only(top: 18, bottom: 0),
                  hintText: "Hospital Name".tr(),
                  helperText: "Required input".tr()
              ),
              maxLength: 70,
              textInputAction: TextInputAction.done,
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: TextField(
              controller: hospital_address,
              cursorColor: Colors.black,
              style: TextStyle(
                fontSize: VetTheme.textSize(context),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: Icon(
                      Icons.location_on, size: VetTheme.logotextSize(context),),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  contentPadding: EdgeInsets.only(top: 18, bottom: 0),
                  hintText: "Hospital Location".tr(),
                  helperText: "Required input".tr()
              ),
              maxLength: 60,
              textInputAction: TextInputAction.done,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.earthAmericas,
                          color: VetTheme.hintColor,),
                        Padding(padding: EdgeInsets.all(10)),
                        Expanded(
                          flex: 1,
                          child: Text('${'Region'.tr()} :', style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: VetTheme.hintColor),),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: VetTheme.hintColor,
                                        width: 2.0
                                    )
                                )
                            ),
                            child: CountryCodePicker(
                              textOverflow: TextOverflow.ellipsis,
                              padding: EdgeInsets.zero,
                              dialogTextStyle: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: VetTheme.textSize(context)),
                              closeIcon: Icon(Icons.close, color: Colors.black,),
                              searchDecoration: InputDecoration(
                                  icon: Icon(FontAwesomeIcons.earthAmericas)
                              ),
                              onChanged: (country) {
                                selectedIntlCode = '(${country.dialCode
                                    .toString()})';
                              },
                              textStyle: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w600,
                                fontSize: VetTheme.textSize(context),
                                color: Colors.black54

                              ),
                              showFlag: false,
                              initialSelection: 'US',
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: true,
                              alignLeft: false,
                            ),
                          ),
                        ),


                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.all(VetTheme.textSize(context)),  child: TextField(
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                controller: hospital_phone,
                cursorColor: Colors.black,
                style: TextStyle(
                  fontSize: VetTheme.textSize(context),
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 0),
                      child: Icon(
                        Icons.call, size: VetTheme.logotextSize(context),),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    contentPadding: EdgeInsets.only(
                        top: VetTheme.titleTextSize(context), bottom: 0),
                    hintText: "Phone".tr(),
                    helperText: "Required input".tr()
                ),
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                },
              )
          ),
          file_business_license == null ? Container(
            margin: EdgeInsets.all(VetTheme.textSize(context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('To complete the registration of your animal hospital with Dolittle Vet'.tr()),
                Container(
                    margin: EdgeInsets.symmetric(vertical: VetTheme.textSize(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Required information'.tr()),
                        Container(
                          margin: EdgeInsets.only(left: VetTheme.textSize(context)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('- Business registration certificate'.tr()),
                              Text('- Business card'.tr()),
                              Text('- Document or photo containing hospital name and address'.tr()),

                            ],
                          ),
                        ),
                      ],
                    )),
                Text('You must attach one of the above three photos to join'.tr()),
              ],
            ),
          ) :
          Container(
            height: VetTheme.diviceH(context) / 2.5,
            alignment: Alignment.center,
            child: file_business_license == null
                ? Container(
              margin: EdgeInsets.all(VetTheme.textSize(context)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('To complete the registration of your animal hospital with Dolittle Vet'.tr()),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: VetTheme.textSize(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Required information'.tr()),
                          Container(
                            margin: EdgeInsets.only(left: VetTheme.textSize(context)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('- Business registration certificate'.tr()),
                                Text('- Business card'.tr()),
                                Text('- Document or photo containing hospital name and address'.tr()),

                              ],
                            ),
                          ),
                        ],
                      )),
                  Text('You must attach one of the above three photos to join'.tr()),
                ],
              ),
            )
                : Image.file(file_business_license!),
          ),
          Container( // 원하는 세로 크기
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                      Colors.pinkAccent)),
              onPressed: () async {
                PermissionStatus permissionStatePhoto =
                await Permission.photos.status;
                if (permissionStatePhoto.isPermanentlyDenied) {
                  UtilityComponents.alertPermission(
                      context, "Permission Setting",
                      "Please allow camera and photo permission\nin [Settings]>[DolittleVet] on your device.");
                } else {
                  getImage('business_license');
                }
              },
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text("Upload File".tr(),
                    style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: VetTheme.titleTextSize(context),
                        color: Colors.white), textAlign: TextAlign.center,)),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: VetTheme.textSize(context)),
            child: Row(
              children: [
                IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      setState(() {
                        _check = !_check;
                      });
                    }, icon: FaIcon(FontAwesomeIcons.circleCheck,
                    color: _check ? VetTheme.mainIndigoColor : Colors.black26
                )),
                Flexible(
                  child: Text(
                      "If false information is provided, the hospital's authorization may be revoked at a later time"
                          .tr()),
                ),
              ],
            ),
          )

        ]);
  }

  Future<void> resultBt() async {
    final String defaultLocale = Platform.localeName;
    await UtilityFunction.getCountyCode(
        defaultLocale.substring(defaultLocale.length - 2));

    if (hospital_name.text
        .trim()
        .isNotEmpty &&
        hospital_address.text
            .trim()
            .isNotEmpty && hospital_phone.text
        .trim()
        .isNotEmpty) {
      if (file_business_license != null) {
        var isConfirm = await UtilityComponents.showConfirmationDialog(context,
            "Would you like to proceed with hospital registration using the provided information?"
                .tr()) ?? false;
        UtilityFunction.log.e(isConfirm.toString());
        if (isConfirm && isConfirm != null) {
          setLoading(true);
          await Future.delayed(const Duration(milliseconds: 300));
          return await createRegistrationRequestHistory();
        }
      } else {
        UtilityComponents.showToast("The hospital file does not exist".tr());
      }
    } else {
      return UtilityComponents.showToast("The input value is empty.".tr());
    }
  }

  Future<void> logoutAndPushToHome() async {
    await _apiservice.logout();
    await _profileManager.logout();
    setLoading(false);
  }

  Future<void> createRegistrationRequestHistory() async {
    final fields = <String, String>{};
    final sendFiles = <http.MultipartFile>[];
    fields.addAll({
      'vetId': _profileManager.userData.id!,
      'type': '0',
      'hospitalName': hospital_name.text.trim(),
      'hospitalAddress': hospital_address.text.trim(),
    });


    if (file_business_license != null) {
      sendFiles.add(await http.MultipartFile.fromPath(
          'businessRegistrationImage', file_business_license!.path));
    }
    if (file_vet_license != null) {
      sendFiles.add(await http.MultipartFile.fromPath(
        'licenseImage',
        file_vet_license!.path,
      ));
    }


    await _apiservice.joinHospital(fields, sendFiles).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiservice.refreshToken()
              ? await createRegistrationRequestHistory()
              : logoutAndPushToHome();
        }
        error.message!.contains("registration")
            ? UtilityComponents.showToast(
            "${"Request already received".tr()}:${error.message ?? ""}")
            : UtilityComponents.showToast(
            "${"Hospital registration failed".tr()}:${error.message ?? ""}");
        return UtilityFunction.goBackToPreviousPage(context);
      }, (success) async {
        /**
         * {{endpoint}}/api/v1/hospitals POST 병원 등록 추가
         * */
        return await hospitalRegistrationMethod(
            success.licenseUri!, success.businessRegistrationUri!);
      });
    });
  }

  /**----------------------------------------------------------------
   *  해외 승인용 임시 코드 로직 수정 예정
   */


  Future<void> hospitalRegistrationMethod(String vetNumberUri,
      String businessNumberUri) async {
    final String defaultLocale = Platform.localeName;
    int countryId = await UtilityFunction.getCountyCode(
        defaultLocale.substring(defaultLocale.length - 2));
    String countryName = await UtilityFunction.getCountryName(
        defaultLocale.substring(defaultLocale.length - 2));
    var phoneNumber = hospital_phone.text
        .trim()
        .isNotEmpty
        ? selectedIntlCode + hospital_phone.text.trim()
        : "000-000-000";


    var body = json.encode({
      "name": hospital_name.text.trim(),
      "phoneContact": phoneNumber,
      "businessRegistrationNumber": "-",
      "countryId": countryId,
      "addressFirst": "$countryName(${countryId.toString()})",
      "addressSecond": "",
      "addressRoad": "",
      "addressDetail": hospital_address.text.trim(),
      "zipCode": "999",
      "reqVetId": _profileManager.userData.id,
      "license": "-",
      "licenseUri": vetNumberUri,
      "businessRegistrationUri": businessNumberUri
    });

    UtilityFunction.log.e('병원가입 정보${body.toString()}');

    await _apiservice.registerHospitalAPI(body).then((value) async {
      if (value) {
        return UtilityFunction.pushReplacementNamed(context, '/');
      } else {
        UtilityComponents.showToast(
            'Hospital registration has failed. Please contact the administrator'
                .tr());
        return UtilityFunction.goBackToMainPage(context);
      }
    });
  }


  /**
   * ---------------------------------------------------------------
   * */


  void setLoading(bool isLoading) {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }
  Future getImage(String imageTitle) async {
    try {
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      File file = File(image!.path);

      switch (imageTitle) {
        case 'vet_license':
          setState(() {
            file_vet_license = file;
          });
          break;
        case 'business_license':
          setState(() {
            file_business_license = file;
          });
          break;
      }
    }catch (e) {
      UtilityFunction.log.e(e.toString());
      if (e.toString().contains('photo_access_denied')) {
        UtilityComponents.alertPermission(context, "Permission Setting", "Please allow camera and photo permission\nin [Settings]>[DolittleVet] on your device.");
      }
    }
  }
}
