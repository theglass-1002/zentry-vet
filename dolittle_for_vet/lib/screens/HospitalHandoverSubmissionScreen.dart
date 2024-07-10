import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class HospitalHandoverSubmissionScreen extends StatefulWidget {
  const HospitalHandoverSubmissionScreen({Key? key}) : super(key: key);
  @override
  State<HospitalHandoverSubmissionScreen> createState() =>
      _HospitalHandoverSubmissionScreenState();
}

class _HospitalHandoverSubmissionScreenState
    extends State<HospitalHandoverSubmissionScreen> {
  late Vet? _vet;
  late ProfileManager _profileManager = ProfileManager();
  late ApiService _apiService = ApiService();
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
    _vet = ModalRoute.of(context)!.settings.arguments as Vet;
    return homeContent();
  }

  Widget homeContent() {
    return Scaffold(
        resizeToAvoidBottomInset:  false,
        appBar: AppBar(
            elevation: 1,
            title: Text(
              "name_Hospital Handover".tr(),style: TextStyle(fontSize: VetTheme.titleTextSize(context)),
            )),
        body: _isLoading ? const LoadingBar() : mainContentBuild(),
        bottomNavigationBar: _isLoading?null:BottomAppBar(
          child: Container(
              margin: const EdgeInsetsDirectional.all(10),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        _check?VetTheme.mainIndigoColor:Colors.black12
                    )
                ),
                onPressed:
                _check?()=>onClickedResultBt():null,
                // _isLoading ? null : onClickedResultBt(),
                  child: _check?Text("Request for change").tr():
                  Text("Please click the circle to check").tr()
              )),
        ));
  }

  Widget mainContentBuild() {
    return ListView(
      children: [
        Container(
            margin:  EdgeInsets.symmetric(vertical: VetTheme.logotextSize(context)),
            alignment: Alignment.center,
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  'H-d-application for transfer'.tr(),
                  textAlign: TextAlign.center,
                  style:  TextStyle(
                      fontSize: VetTheme.titleTextSize(context), fontWeight: FontWeight.bold),
                ),

              ],
            )),
        Container(
          margin:  EdgeInsets.symmetric(vertical: VetTheme.titleTextSize(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'H-d-AS-IS'.tr(),
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: VetTheme.textSize(context)),
              ),
              Text(
                'H-d-TO-BE'.tr(),
                style:
                TextStyle(fontWeight: FontWeight.bold,fontSize: VetTheme.textSize(context)),
              ),
            ],
          ),
        ),
        Container(
          margin:  EdgeInsets.symmetric(horizontal: VetTheme.titleTextSize(context),vertical: VetTheme.titleTextSize(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.account_circle,
                          color: VetTheme.mainIndigoColor),
                      const Padding(padding: EdgeInsets.all(10)),
                      Expanded(
                          child: Text(
                            _profileManager.userData.name!,
                            textAlign: TextAlign.center,
                          )
                        ),
                    ],
                  ),
                ),
              ),
            const Icon(Icons.arrow_right_sharp, size: 50, color: Colors.grey),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.account_circle,
                          color: VetTheme.mainIndigoColor),
                      const Padding(padding: EdgeInsets.all(10)),
                      Expanded(
                          child: Text(
                            _vet!.name!,
                            textAlign: TextAlign.center,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          margin: EdgeInsets.all(VetTheme.textSize(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('To apply for the transfer, the following documents are required'.tr()),
              Container(
                  margin: EdgeInsets.symmetric(vertical: VetTheme.textSize(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Required information'.tr(),style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),),
                      Container(
                        margin: EdgeInsets.only(left: VetTheme.textSize(context)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('- Updated business registration certificate'.tr()),
                            Text('- Business card of the acquiring veterinarian'.tr()),
                            Text('- Document or file with updated hospital name and address'.tr()),

                          ],
                        ),
                      ),
                    ],
                  )),
              Text('You must attach one of the above three photos to join'.tr()),
            ],
          ),
        ),
        file_vet_license == null?Container():Container(
          height: VetTheme.diviceH(context)/2.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Container(
                    margin: const EdgeInsets.all(10),
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: file_vet_license == null
                        ? Container()
                        : Image.file(file_vet_license!)),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  height: double.infinity,
                  alignment: Alignment.center,
                  child: file_business_license == null
                      ? Container() //Text('이미지 첨부')
                      : Image.file(file_business_license!),
                ),
              )
            ],
          ),
        ),
        Container(
          margin:  EdgeInsets.symmetric(horizontal: VetTheme.titleTextSize(context),vertical: VetTheme.titleTextSize(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Text(
                  'Business registration certificate'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: VetTheme.textSize(context)),
                ),
              ),
              Expanded(
                child: Text(
                  'New Business registration certificate'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: VetTheme.textSize(context)),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: VetTheme.titleTextSize(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
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
                      getImage('vet_license');
                    }

                  },
                  child: Text(
                    "Previous file upload".tr(),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: VetTheme.textSize(context)),
                  ),
                ),
              ),
              SizedBox(
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
                    // PermissionStatus permissionStatePhoto =
                    // await Permission.photos.status;
                    // if (permissionStatePhoto.isPermanentlyDenied) {
                    //   UtilityComponents.alertPermission(context, "Permission Setting", "Please allow camera and photo permission\nin [Settings]>[DolittleVet] on your device.");
                    // } else {
                    //   getImage('business_license');
                    // }

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
                  child: Text(
                    "New file upload".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: VetTheme.textSize(context)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
            margin:  EdgeInsets.symmetric(
                horizontal: VetTheme.titleTextSize(context)
            ),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: (){
                      setState(() {
                        _check =!_check;
                      });
                    }, icon: FaIcon(FontAwesomeIcons.circleCheck,
                    color: _check?VetTheme.mainIndigoColor:Colors.black26

                )),
                Expanded(
                  child: Text(
                    'Announcement on Transfer of Hospital Director'.tr(),
                    style:  TextStyle(
                        fontSize:VetTheme.textSize(context), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )),
      ],
    );
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
    } catch(e){
      if (e.toString().contains('photo_access_denied')) {
        UtilityComponents.alertPermission(context, "Permission Setting", "Please allow camera and photo permission\nin [Settings]>[DolittleVet] on your device.");

        // alertPhotoPermission(context);
        UtilityFunction.log.e(e.toString());
      }
    }
  }

  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    setLoading(false);
  }

  Future<void> onClickedResultBt() async {
    if (file_vet_license.toString().isNotEmpty &&
        file_business_license.toString().isNotEmpty) {
      if (file_vet_license?.path != null &&
          file_business_license?.path != null) {
        return await handOverApiRequestV3();
      }
    }
    return UtilityComponents.showToast("No file attached".tr());
  }



  Future<void> handOverApiRequestV3() async {
    setLoading(true);
    final fields = <String, String>{};
    final files = <http.MultipartFile>[];
    files.add(await http.MultipartFile.fromPath(
      'businessRegistrationImage',
      file_business_license!.path,
    ));
    files.add(await http.MultipartFile.fromPath(
        'licenseImage', file_vet_license!.path));

    fields.addAll({
      'vetId': _profileManager.userData.id!,
      'targetVetId': _vet!.id.toString(),
    });
    await _apiService.handOverApiV3(fields, files).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? await handOverApiRequestV3()
              : await logoutAndPushToHome();
        }
        UtilityFunction.log.e('양도 에러 ${error.message}');
        UtilityComponents.showToast("${"handover request  failed".tr()}:${error.message ?? ""}");
        return UtilityFunction.goBackToPreviousPage(context);
      }, (success) async {
        UtilityFunction.log.e('양도 성공 ${success.message}');
        UtilityFunction.log.e('양도 성공 ${success.handoverRequestId}');
        return await onHandoverAuthRequestExecute(success.handoverRequestId.toString());
      });
    });
  }

  Future<void>onHandoverAuthRequestExecute(String handoverRequestId)async{
    var body = {
      "status": '1',
      "comment": "200자 내외 코멘트입니다."
    };

   var resultHandover = await _apiService.executeHandoverAuthRequestV3(handoverRequestId, body);
   if(resultHandover.isError()){
     if(resultHandover.getError()?.re_code == UnauthorizedCode && resultHandover.getError()?.code==101){
       return await _apiService.refreshToken()
           ?await onHandoverAuthRequestExecute(handoverRequestId)
           :await logoutAndPushToHome();
     }
     UtilityFunction.log.e('양도 에러 ${resultHandover.getError()?.message}');
     UtilityComponents.showToast("${"handover request  failed".tr()}:${resultHandover.getError()?.message?? ""}");
     return UtilityFunction.goBackToPreviousPage(context);
   }else{
      UtilityFunction.log.e('병원양도성공');
      UtilityFunction.log.e('병원양도 ${resultHandover.getSuccess()?.result}');
      return UtilityFunction.goBackToPreviousPage(context);
   }
  }




  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

