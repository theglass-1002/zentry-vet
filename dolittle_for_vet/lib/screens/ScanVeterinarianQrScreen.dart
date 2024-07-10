import 'dart:convert';
import 'dart:io' show File, Platform;
import 'dart:math';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:scan/scan.dart';

class ScanVeterinarianQrScreen extends StatefulWidget {
  const ScanVeterinarianQrScreen({Key? key}) : super(key: key);
  @override
  State<ScanVeterinarianQrScreen> createState() => _ScanVeterinarianQrState();
}

class _ScanVeterinarianQrState extends State<ScanVeterinarianQrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  late ProfileManager _profileManager = ProfileManager();
  late final ApiService _apiService = ApiService();
  QRViewController? controller;
  late Map<dynamic, dynamic> userData;
  bool _qr_scan = false;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    super.initState();
  }

  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    UtilityFunction.log.e('빌드');
    return _buildQrView(context);
  }

  //qr스캔 화면
  Widget _buildQrView(BuildContext context) {
    var scanArea = min(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height) *
        0.8;
    return Scaffold(
      appBar: AppBar(elevation: 1,
          actions: [
            IconButton(
              onPressed: () async {
                await getImageIncludeQrCode();
              },
              icon: const Icon(Icons.image),
            )
          ],
          title: Text("Veterinary registration".tr())
      ),

      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          QRView(
            cameraFacing: CameraFacing.back,
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            // overlayMargin: const EdgeInsets.only(bottom: 190),
            overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 15,
              borderLength: 80,
              borderWidth: 30,
              cutOutBottomOffset: 115,
              cutOutHeight: 270,
              cutOutWidth: 250,
            ),
            onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          ),
          Column(
            children: [
              const Spacer(),
              Container(
                  // margin: EdgeInsets.only(top: 400),
                  // height: 200,
                  color: Colors.black.withAlpha(125))
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
                      UtilityFunction.log.e('카메라실행');
                      await controller!.resumeCamera();
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
                    'The QR image in your gallery can be used, too.'.tr(),
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ],
      ),
    );
  }

  Future<void> stopCamera(QRViewController controller) async {
    await controller.stopCamera();
    setState(() {});
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      String data = UtilityFunction.decodeVetQr(scanData.code!);
      if (data == 'none') {
        UtilityFunction.log.e('잘못 된 큐알');
        UtilityComponents.showToast('Invalid QR code'.tr());
        await controller.pauseCamera();
        return;
      } else {
        userData = json.decode(data);
        if (qrTimeOut(userData['timeOut'])) {
          UtilityFunction.log.e(userData.toString());
          UtilityFunction.moveScreenAndPop(
              context, '/addVeterinarianScreen', userData);
          await controller.stopCamera();
          return;
        } else {
          UtilityComponents.showToast('QR code validity timeout'.tr());
          await controller.pauseCamera();
        }
        return;
      }
    });
  }

  Future<void> getImageIncludeQrCode() async {
    UtilityFunction.log.e('사진가져오기');
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    UtilityFunction.log.e('이미지가져옴 ${image.toString()}');
    if (image != null) {
      File file = File(image.path);
      String? qrCodeString = await Scan.parse(file.path);
      if(qrCodeString!=null){
        String data = UtilityFunction.decodeVetQr(qrCodeString);
        UtilityFunction.log.e('qr 암호 해독 ${data.toString()}');
        if(data=='none'){
          UtilityFunction.log.e('잘못 된 큐알');
          UtilityComponents.showToast('Invalid QR code'.tr());
          return await controller!.pauseCamera();
        }else{
          userData = json.decode(data);
          if (qrTimeOut(userData['timeOut'])) {
            UtilityFunction.log.e(userData.toString());
            UtilityFunction.moveScreenAndPop(
                context, '/addVeterinarianScreen', userData);
            await controller!.stopCamera();
            return;
          } else {
            UtilityComponents.showToast('QR code validity timeout'.tr());
            await controller!.pauseCamera();
          }
          return;
        }
      }else{
        UtilityComponents.showToast("Unregistered QR code".tr());
        return await controller!.pauseCamera();
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    UtilityFunction.log.e('dispose');
    if (mounted) {
      controller!.stopCamera();
      super.dispose();
    }
  }

  bool qrTimeOut(var time) {
    DateTime now = DateTime.now();
    DateTime timeOut = DateTime.parse(time);
    //현재시간은 제한시간보다 이전인가
    return now.isBefore(timeOut);
  }
  // Future<void> addVet() async {
  //   UtilityFunction.log.e(_profileManager.hospitalData.name);
  //   UtilityFunction.log.e(_profileManager.hospitalData.id);
  //  await _apiService.addVet(vetData['vet_id'], {
  //    "hospitalId": _profileManager.hospitalData.id.toString(),
  //    "authority": '1',
  //    "license": vetData['vet_number']
  //  }).then((value) {
  //    value.when((error) async {
  //      if(error.re_code==UnauthorizedCode&&error.code==101){
  //        return await _apiService.refreshToken()?addVet():UtilityFunction.pushReplacementNamed(context, '/login');
  //      }
  //      UtilityComponents.showToast(("Failed to register as a veterinarian".tr()));
  //      return  UtilityFunction.pushReplacementNamed(context, '/');
  //    }, (success) {
  //      return UtilityFunction.moveScreenAndPop(context, '/veterinarianManagement');
  //    });
  //  });
  // }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Please allow camera permission in your phone settings".tr())),
      );
    }
  }
}
