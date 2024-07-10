import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class CreatVeteQrCodeScreen extends StatelessWidget {

  const CreatVeteQrCodeScreen({Key? key})
      : super(key: key);
  //static const routeName = '/CreatVeteQrCodeScreen';

  String makeAesEncrypt(var id, name,authority,number,time) {
    DateTime now = DateTime.now();
    print(now.isBefore(time));
    // //현재시간은 제한시간보다 작은가? -> 네
    Map<String, dynamic> map = {
      "timeOut": time.toString(),
      "id": id.toString(),
      "name": name,
      "authority":authority,
      "number": number,
    };
    UtilityFunction.log.e(map.toString());
    return UtilityFunction.aesEncodeVet(const JsonEncoder().convert(map));
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> arguments = Map<String, dynamic>.from(ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>);
    final timeLimit = DateTime.now().add(const Duration(minutes: 30));
    String stLimit = DateFormat('yyyy-MM-dd – kk:mm').format(timeLimit);
    String data = makeAesEncrypt(arguments['id'], arguments['name'], arguments['authority'],arguments['number'], timeLimit);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));


      return Scaffold(
        appBar: AppBar(
            elevation: 1,
            title: AutoSizeText(
                      "Issuance of QR code for registration".tr(),
                      maxLines: 1,
                    ),
        ),
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${"QR validity time".tr()} : ${stLimit.toString()}"),
                QrImageView(
                  version: QrVersions.auto,
                  data: data,
                  size: VetTheme.mediaHalfSize(context),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: VetTheme.logotextSize(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Please present the issued QR code for the hospital administrator or manager to scan".tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: VetTheme.titleTextSize(context), fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: VetTheme.logotextSize(context)),  // 간격 조절
                      Container(
                        padding: EdgeInsets.all(VetTheme.titleTextSize(context)),
                        color: Colors.black26,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hospital Administrator or Manager QR Code Scan Method".tr(),
                              style: TextStyle(fontSize:VetTheme.textSize(context),fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),  // 간격 조절
                            Text(
                              "1.scanStep".tr(),
                              style: TextStyle(fontSize: VetTheme.textSize(context)),
                            ),
                            Text(
                              "2.scanStep".tr(),
                              style: TextStyle(fontSize: VetTheme.textSize(context)),
                            ),
                            Text(
                              "3.scanStep".tr(),
                              style: TextStyle(fontSize: VetTheme.textSize(context)),
                            ),
                            Text(
                              "4.scanStep".tr(),
                              style: TextStyle(fontSize: VetTheme.textSize(context)),
                            ),
                            Text(
                              "5.scanStep".tr(),
                              style: TextStyle(fontSize: VetTheme.textSize(context)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )


              ],
            ),
          ),
        ),
      );

  }
}
