import 'dart:math';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:scan/scan.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';


class ScanAnimalQrScreen extends StatefulWidget {
  const ScanAnimalQrScreen({Key? key}) : super(key: key);

  @override
  State<ScanAnimalQrScreen> createState() => _ScanAnimalQrScreenState();
}

class _ScanAnimalQrScreenState extends State<ScanAnimalQrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late ProfileManager _profileManager = ProfileManager();
  late final ApiService _apiService = ApiService();
  QRViewController? controller;
  late Map<dynamic, dynamic> _animalData;
  String animalId = "";
  bool _isPermission = true;


  @override
  void initState() {
    // TODO: implement initState
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String) {
      UtilityFunction.log.e('qr 첨부');
      animalId = arg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildQrView(context);
  }

  //Qr 코드 스캔화면
  Widget _buildQrView(BuildContext context) {
    var scanArea = min(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height) *
        0.8;
    return Scaffold(
      appBar: AppBar(
          elevation: 1,
          actions: [
            IconButton(
              onPressed: () {
                 getImageIncludeQrCode();
              },
              icon: const Icon(Icons.image),
            )
          ],
          leading: IconButton(
            onPressed: () {
              _profileManager.animalListRefresh(true);
              UtilityFunction.goBackToMainPage(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            "Pet registration".tr(),
          )),
      body: _isPermission
          ?Stack(
        alignment: AlignmentDirectional.center,
        children: [
          QRView(
              cameraFacing: CameraFacing.back,
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 15,
                borderLength: 80,
                borderWidth: 30,
                cutOutBottomOffset: 115,
                cutOutHeight: 270,
                cutOutWidth: 250,
              ),
              onPermissionSet: (ctrl, p) {
                if (!p) {
                  setState(() {
                    _isPermission = false;
                  });
                }
              }),
          Column(
            children: [
              const Spacer(),
              Container(color: Colors.black.withAlpha(125))
            ],
          ),
          Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 2),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            backgroundColor: Colors.white,
                            fixedSize: const Size(100, 100)),
                        onPressed: () async {
                          UtilityFunction.log.e('재시작');
                          await controller?.resumeCamera();
                          setState(() {});
                        },
                        child: const FaIcon(
                          FontAwesomeIcons.camera,
                          color: Colors.black,
                          size: 50,
                        )),
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 30),
                      child: Text(
                        'The QR image in your gallery can be used, too.'
                            .tr(),
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ),
            ],
          ):
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      margin: EdgeInsets.symmetric(
                          vertical: VetTheme.textSize(context)),
                      child: Text(
                        'Permission granted'.tr(),
                        style: TextStyle(
                            fontSize: VetTheme.logotextSize(context)),
                      )),
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: VetTheme.textSize(context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt,
                            color: VetTheme.hintColor,
                            size: VetTheme.logoHeight(context)),
                        Container(
                          margin: EdgeInsets.all(VetTheme.textSize(context)),
                        ),
                        Icon(Icons.folder,
                            color: VetTheme.hintColor,
                            size: VetTheme.logoHeight(context)),
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(
                          vertical: VetTheme.textSize(context),
                          horizontal: VetTheme.textSize(context)),
                      child: Text(
                        'Please allow camera and photo permission\nin [Settings]>[DolittleVet] on your device.'
                            .tr(),
                        style: TextStyle(
                            fontSize: VetTheme.titleTextSize(context)),
                      )),
                  Container(
                      margin: EdgeInsets.symmetric(
                          vertical: VetTheme.textSize(context)),
                      child: ElevatedButton(
                          onPressed: () {
                            AppSettings.openAppSettings(
                                type: AppSettingsType.settings);
                            UtilityFunction.goBackToMainPage(context);
                          },
                          child: Text(
                            'Settings'.tr(),
                            style: TextStyle(
                                fontSize: VetTheme.titleTextSize(context)),
                          )))
                ],
              ),
            ));
  }
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    String animalQr = "";
    // 스캔 이벤트를 한 번만 처리하도록 변수를 추가
    bool scanned = false;
    controller.scannedDataStream.listen((scanData) async {
      if (scanned) {
        UtilityFunction.log.e('중복스캔 무시');
        return; // 이미 스캔된 경우, 무시
      } else {
        scanned = true;
        animalQr = UtilityFunction.decodeAnimalQr(scanData.code.toString());
        if (animalQr == "none") {
          UtilityComponents.showToast("Unregistered QR code".tr());
          await controller.pauseCamera();
          scanned = false;
          return;
        } else {
          UtilityFunction.log.e('스캔으로 animal 데이터 가져오기 ${animalQr}');
          await getAnimalData(animalQr);
          await controller.stopCamera();
          scanned = false;
          return;
        }
      }
    });
  }


  Future<void> getImageIncludeQrCode() async {
    try {
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        File file = File(image.path);
        String? qrCodeString = await Scan.parse(file.path);
        UtilityFunction.log.e(qrCodeString);
        if (qrCodeString != null) {
          String data = UtilityFunction.decodeAnimalQr(qrCodeString);
          if (data == "none") {
            UtilityComponents.showToast("Unregistered QR code".tr());
            await controller!.pauseCamera();
            return;
          } else {
            UtilityFunction.log.e('애니멀정보가져오기');
            return await getAnimalData(data);
          }
        } else {
          UtilityComponents.showToast("Unregistered QR code".tr());
          await controller!.pauseCamera();
          return;
        }
      }
    }catch (e) {
      if (e.toString().contains('photo_access_denied')) {
        setState(() {
          _isPermission = false;
        });
      }
    }
  }

  //동물정보 가져오기
  Future<void> getAnimalData(var scanData) async {
    UtilityFunction.log.e('여기까지 들어옴 ');
    await _apiService.getAnimalData({'animal': '$scanData'}).then((value) {
      value.when((error) async {
        UtilityComponents.showToast(
            "${"Animal inquiry failed".tr()}:${error.message ?? ""}");
        return UtilityFunction.goBackToPreviousPage(context);
      }, (success) async {
        if (success.owner!.isEmpty ||
            success.owner == null ||
            success.owner == "") {
          UtilityComponents.showToast(
              'You are a member who has withdrawn.'.tr());
          return UtilityFunction.pushReplacementNamed(context, '/');
        } else {
          if (animalId.isNotEmpty) {
            return await updateAnimalQr(success.animal!);
          } else {
            _animalData = success.toJson();
            UtilityFunction.moveScreenAndPop(
                context, '/addWithQrScreen', _animalData);
            return;
          }
        }
      });
    });
  }

  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();

  }


  Future<void> updateAnimalQr(String animal) async {
    UtilityFunction.log.e('동물 qr 업데이트');
    String animalQr = animal;
    await _apiService
        .updateAnimalQr(animalId, {"animal": animalQr}).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? await updateAnimalQr(animalQr)
              : await logoutAndPushToHome();
        }
        UtilityFunction.log.e('동물 qr세팅 실패${error.message}');
        _profileManager.animalListRefresh(true);
        UtilityComponents.showToast(
            "${'Animal QR setting failed'.tr()}:${error.message ?? ""}");
        UtilityFunction.goBackToPreviousPage(context);
        return;
      }, (success) {
        _profileManager.animalListRefresh(true);
        UtilityComponents.showToast('Animal QR setting success'.tr());
        UtilityFunction.goBackToMainPage(context);
        return;
      });
    });
  }

  Future<void> stopCamera(QRViewController controller) async {
    await controller.stopCamera();
    setState(() {});
  }


}
