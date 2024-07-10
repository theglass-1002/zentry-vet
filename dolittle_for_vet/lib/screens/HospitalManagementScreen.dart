import 'dart:convert';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class HospitalManagementScreen extends StatefulWidget {
  const HospitalManagementScreen({Key? key}) : super(key: key);

  @override
  State<HospitalManagementScreen> createState() =>
      _HospitalManagementScreenState();
}

class _HospitalManagementScreenState extends State<HospitalManagementScreen> {
  late ProfileManager _profileManager = ProfileManager();
  late final ApiService _apiService = ApiService();
  TextEditingController hospital_name = TextEditingController();
  TextEditingController hospital_address = TextEditingController();
  TextEditingController hospital_phone = new TextEditingController();

  String selectedIntlCode = "+1";
  final picker = ImagePicker();
  File? file_vet_license;
  File? file_business_license;
  bool _isLoading = false;
  bool _check = false;

  @override
  void initState() {
    // TODO: implement initState
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Contents(context);
  }

  Widget Contents(BuildContext buildContext) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          elevation: 1,
          title: Text(
            "Hospital management".tr(),
          )),
      body:  _isLoading?LoadingBar():Container(
          margin: const EdgeInsetsDirectional.all(10), child: buildInputBox()),
      bottomNavigationBar:_isLoading?null:BottomAppBar(
        child: Container(
          margin: const EdgeInsetsDirectional.all(10),
          child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      _check?VetTheme.mainIndigoColor:Colors.black12
                  )
              ),
              onPressed:
              _check?
                  () => result():null,
              child: _check?Text("Request for change").tr():
              Text("Please click the circle to check").tr()
          ),
        ),
      ),
    );
  }


  Widget buildInputBox() {
    String hospitalAddress = '${_profileManager.hospitalData.address_first??""}${_profileManager.hospitalData.address_second??""}${_profileManager.hospitalData.address_road??""}${_profileManager.hospitalData.address_detail??""}';
    return ListView(
        children: [
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12, width: 2),
                color: Colors.white,
              ),
              margin: const EdgeInsets.fromLTRB(10, 15, 10, 10),
              padding:  EdgeInsets.all(VetTheme.titleTextSize(context)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                        children: [
                          Text(
                            "${"Hospital Name".tr()} : ",
                            style:  TextStyle(fontSize: VetTheme.titleTextSize(context)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                                _profileManager.hospitalData.name ?? "",
                                style:  TextStyle(fontSize: VetTheme.textSize(context))),
                          ),
                        ]),
                    Row(
                        children: [
                          Text(
                            "${"Hospital Location".tr()} : ",
                            style:  TextStyle(fontSize: VetTheme.titleTextSize(context)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                                 hospitalAddress??"",
                                 style:  TextStyle(fontSize: VetTheme.textSize(context))),
                          ),
                        ]),
                    Row(
                        children: [
                          Text(
                            "${"Phone".tr()} : ",
                            style:  TextStyle(fontSize: VetTheme.titleTextSize(context)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                                _profileManager.hospitalData.phoneContact??"",
                                style:  TextStyle(fontSize: VetTheme.textSize(context))),
                          ),
                        ]),
                  ])),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextField(
              controller: hospital_name,
              cursorColor: Colors.black,
              style:  TextStyle(
                fontSize: VetTheme.textSize(context),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: Icon(Icons.local_hospital_outlined,size: VetTheme.logotextSize(context),),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  contentPadding: EdgeInsets.only(top: VetTheme.titleTextSize(context), bottom: 0),   hintText: "ChangeHospitalName".tr(),
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
              style:  TextStyle(
                fontSize: VetTheme.textSize(context),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: Icon(Icons.location_on,size: VetTheme.logotextSize(context),),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  contentPadding: EdgeInsets.only(top: 18, bottom: 0),
                  hintText: "ChangeHospitalLocation".tr(),
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
              margin: EdgeInsets.all(VetTheme.textSize(context)),
              child: TextField(
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
                      child: Icon(Icons.call,size: VetTheme.logotextSize(context),),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    contentPadding: EdgeInsets.only(top: 18, bottom: 0),
                    hintText: "ChangePhone".tr(),
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
                Text('To modify hospital information, you must submit the following documents that can prove the hospital'.tr()),
                Container(
                    margin: EdgeInsets.symmetric(vertical: VetTheme.textSize(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Required information'.tr()),
                        Container(
                          margin: EdgeInsets.only(
                            left: VetTheme.textSize(context),
                            top: VetTheme.textSize(context),
                            bottom: VetTheme.textSize(context)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Updated business registration certificate'.tr()),
                              Text('Updated business card'.tr()),
                              Text('Document or file with the updated hospital name and address'.tr()),

                            ],
                          ),
                        ),
                      ],
                    )),
                Text('You must attach the file in order to change the information'.tr()),
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
                  Text('To modify hospital information, you must submit the following documents that can prove the hospita'.tr()),
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
                                Text('- Updated business registration certificate'.tr()),
                                Text('- Updated business card'.tr()),
                                Text('- Document or file with the updated hospital name and address'.tr()),

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
                    style: TextStyle(fontSize: VetTheme.titleTextSize(context),
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


  void setLoading(bool isLoading) {
    if(mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }

  Future<void> result() async {
    UtilityFunction.log.e('수정바튼 클릭');
    final String defaultLocale = Platform.localeName;
    await UtilityFunction.getCountyCode(defaultLocale.substring(defaultLocale.length-2));


    if(hospital_name.text.trim().isNotEmpty&&
        hospital_address.text.trim().isNotEmpty&&hospital_phone.text.trim().isNotEmpty){
      if(file_business_license!=null){
        var isConfirm = await UtilityComponents.showConfirmationDialog(context,"Would you like to proceed with updating the hospital information with the provided details?".tr())??false;
        UtilityFunction.log.e(isConfirm.toString());
        if(isConfirm&&isConfirm!=null){
           UtilityFunction.log.e('마지막 병원정보 수정 업데이트 일자 ${_profileManager.hospitalData.updatedAt}');


          setLoading(true);
          await Future.delayed(const Duration(milliseconds: 300));
          await apiRequest();
        }
      }else{
        UtilityComponents.showToast("No file attached".tr());
      }
    }else{
      return UtilityComponents.showToast("The input value is empty.".tr());

    }

  }

  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    //setLoading(false);
  }

  Future<void> apiRequest() async {
    UtilityFunction.log.e('전송');
    final fields = <String, String>{};
    final files = <http.MultipartFile>[];
    fields.addAll({
      'vetId': _profileManager.userData.id!,
      'type': '1',
      'hospitalId': _profileManager.hospitalData.id.toString(),
      'hospitalName': hospital_name.text.trim(),
      'hospitalAddress': hospital_address.text.trim(),
    });

    files.add(await http.MultipartFile.fromPath(
      'businessRegistrationImage',
      file_business_license!.path,
    ));


    await _apiService.joinHospital2(fields, files).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? apiRequest()
              : logoutAndPushToHome();
        }
         error.message!.contains("Already")
            ? UtilityComponents.showToast(
                "${"A modification request has already been received".tr()}:${error.message ?? ""}")
            : UtilityComponents.showToast(
                "${"Hospital registration failed".tr()}:${error.message ?? ""}");
        UtilityFunction.log.e('병원정보 변경 실패${error.message.toString()}');
        return UtilityFunction.goBackToPreviousPage(context);
      }, (success) async {
         UtilityFunction.log.e('변경형식 전송 성공');
         await hospitalUpdateInfoMethod(success.licenseUri!,success.businessRegistrationUri!);
      });
    });
  }

  Future<void> hospitalUpdateInfoMethod(String vetNumberUri, String businessNumberUri) async{
    final String defaultLocale = Platform.localeName;
    int countryId = await UtilityFunction.getCountyCode(defaultLocale.substring(defaultLocale.length-2));
    String countryName = await UtilityFunction.getCountryName(defaultLocale.substring(defaultLocale.length-2));

    var body = {
      "name": hospital_name.text.trim(),
      "phoneContact": '$selectedIntlCode${hospital_phone.text}',
      "businessRegistrationNumber": "-",
      "countryId": '$countryId',
      "addressFirst": "$countryName(${countryId.toString()})",
      "addressSecond": "",
      "addressRoad": "",
      "addressDetail": hospital_address.text.trim(),
      "zipCode": '999',
      "reqVetId": _profileManager.userData.id,
      "license": "-",
      "licenseUri": vetNumberUri,
      "businessRegistrationUri": businessNumberUri
    };
      //reqVetId 이거 안넣으면 알람안옴
    var apiResult = await _apiService.executeUpdateHospital(_profileManager.hospitalData.id.toString(),body);
    //수정 들어가는거 봄
    setLoading(false);
    if(apiResult.isSuccess()){
        UtilityFunction.log.e(apiResult.getSuccess()?.result.toString());
    }else{
      if (apiResult.getError()?.re_code == UnauthorizedCode && apiResult.getError()?.code == 101) {
        return await _apiService.refreshToken()
            ? apiRequest()
            : logoutAndPushToHome();
      }
      apiResult.getError()!.message!.contains("Already")?
      UtilityComponents.showToast("${"A modification request has already been received".tr()}:${apiResult.getError()?.message ?? ""}"):
      UtilityComponents.showToast("${"Hospital registration failed".tr()}:${apiResult.getError()?.message ?? ""}");
      return UtilityFunction.goBackToPreviousPage(context);
    }
  }

  Future getImage(String imageTitle) async {
    try {
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      // var image =
      //     await ImagePicker.platform.pickImage(source: ImageSource.gallery);
      File file = File(image!.path);
      UtilityFunction.log.e(file.toString());

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
    } catch(e){
      if (e.toString().contains('photo_access_denied')) {
        UtilityComponents.alertPermission(context, "Permission Setting", "Please allow camera and photo permission\nin [Settings]>[DolittleVet] on your device.");

        // alertPhotoPermission(context);
        UtilityFunction.log.e(e.toString());
      }
    }
  }

}
