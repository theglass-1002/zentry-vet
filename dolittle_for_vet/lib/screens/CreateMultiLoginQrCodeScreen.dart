import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:easy_localization/easy_localization.dart';


class CreateMultiLoginQrCodeScreen extends StatelessWidget {
  const CreateMultiLoginQrCodeScreen({super.key});


  String makeAesEncryptLogin(var email, type) {
    DateTime now = DateTime.now();
    DateTime utcNow = now.toUtc();
    String isoTime = utcNow.toIso8601String();
    Map<String, dynamic> map = {
      "timeOut": isoTime,
      "email":email,
      "type": type,
    };
    return  UtilityFunction.aesEncodeMulti(const JsonEncoder().convert(map));
  }


  @override
  Widget build(BuildContext context) {
    var _profileManager = Provider.of<ProfileManager>(context);
    String qrData =makeAesEncryptLogin(_profileManager.userData.email,_profileManager.userData.authType);
    final timeLimit = DateTime.now().add(const Duration(minutes: 9));
    String stLimit = DateFormat('yyyy-MM-dd – kk:mm').format(timeLimit);


    return  Scaffold(
      appBar: AppBar(
        title: Text('Dolittle Multi App Login QR Code'.tr()),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("${"QR validity time".tr()} : ${stLimit.toString()}"),
          Center(
            child: QrImageView(
               version: QrVersions.auto,
               data: qrData,
               size: VetTheme.mediaHalfSize(context),
            ),
          ),
          SizedBox(height: VetTheme.logotextSize(context)),  // 간격 조절
          Container(
            margin: EdgeInsets.all(VetTheme.titleTextSize(context)),
            padding: EdgeInsets.all(VetTheme.titleTextSize(context)),
            color: Colors.black26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dolittle Multi App Login QR Code Scan Method".tr(),
                  style: TextStyle(fontSize:VetTheme.textSize(context),fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),  // 간격 조절
                Text(
                  "1.Step(MultiAppLoginQRscan)".tr(),
                  style: TextStyle(fontSize: VetTheme.textSize(context)),
                ),
                Text(
                  "2.Step(MultiAppLoginQRscan)".tr(),
                  style: TextStyle(fontSize: VetTheme.textSize(context)),
                ),
                Text(
                  "3.Step(MultiAppLoginQRscan)".tr(),
                  style: TextStyle(fontSize: VetTheme.textSize(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
