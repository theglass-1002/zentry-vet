import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});
  static const routeName = '/PermissionScreen';

  @override
  Widget build(BuildContext context) {
    var padd = const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0));
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Information on using DolittleVet".tr())),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              children: [
                padd,
                Center(
                    child: Text(
                  "Guide to optional app access rights".tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 17, color: Color.fromARGB(255, 0, 0, 0)),
                )),
                padd,
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications, color: Colors.grey),
                      Text("PUSH notifications".tr(),
                          style: TextStyle(fontSize: VetTheme.titleTextSize(context))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
                  child: Text(
                    "PUSH message".tr(),
                      style: TextStyle(fontSize: VetTheme.titleTextSize(context))
                  ),
                ),
                padd,
                // Container(
                //   padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                //   child: Row(
                //     children: [
                //       const Icon(
                //         Icons.photo_camera,
                //         color: Colors.grey,
                //       ),
                //       Text("Camera and Microphone".tr(),
                //           style: const TextStyle(fontSize: 19)),
                //     ],
                //   ),
                // ),
                // Container(
                //   padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
                //   child: Text("It is used for QR code recognition.".tr(),
                //       style: const TextStyle(fontSize: 16)),
                // ),
                // padd,
                // Container(
                //   padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                //   child: Row(
                //     children: [
                //       const Icon(
                //         Icons.image,
                //         color: Colors.grey,
                //       ),
                //       Text("Photo".tr(), style: const TextStyle(fontSize: 19)),
                //     ],
                //   ),
                // ),
                // Container(
                //   padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
                //   child: Text("Used for uploading photos.".tr(),
                //       style: const TextStyle(fontSize: 16)),
                // ),
                padd,
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: const Divider(
                    thickness: 1,
                    color: Color.fromARGB(132, 96, 94, 94),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
                  child: Text(
                      "*Optional consent can be changed at any time on the System Settings screen > DolittleVet app."
                          .tr(),
                      style: TextStyle(fontSize: VetTheme.textSize(context))),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () async {
                    UtilityFunction.log.e('퍼미션 허용클릭');
                    await ApiService().setIsPermission(true);
                    Phoenix.rebirth(context);
                  },
                  child: Text("Confirm".tr(),
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
