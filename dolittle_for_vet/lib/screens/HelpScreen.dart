import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dolittle_for_vet/components/utility_components.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);
  static const routeName = '/HelpScreen';
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  late ProfileManager _profileManager = ProfileManager();
  late ApiService _apiService = ApiService();
  final email = TextEditingController();
  final anytitle = TextEditingController();
  final contents = TextEditingController();
  final picker = ImagePicker();
  bool _check = false;
  File? first_attachment;
  File? second_attachment;
  List<File> files = [];

  @override
  void initState() {
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return homeContent();
    // return Consumer<ProfileManager>(
    //   builder: (context, user, child) {
    //     _profileManager = user;
    //     return homeContent();
    //   }
    // );
  }

  Widget homeContent() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Help'.tr()),
      ),
      body: body(),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  _check ? const Color(0xff2e3d80) : Colors.black12)),
          onPressed: _check ? () => resultBt() : null,
          child: _check
              ? Text('SEND'.tr())
              : Text(
                  'Please check your consent to collecting and using personal information'
                      .tr()),
        ),
      ),
    );
  }

  Widget body() {
    return Scrollbar(
      thickness: 5,
      radius: const Radius.circular(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: const EdgeInsets.all(15),
          color: Colors.white38,
          child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    color: Colors.black12,
                    child: Text(
                      _profileManager.userData.name!,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black54),
                    )),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Email to receive reply (optional)'.tr(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: TextField(
                    controller: email,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'email@example.com'.tr()),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Contact title'.tr(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: TextField(
                    controller: anytitle,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Contact title'.tr(),
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Contact details'.tr(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: TextField(
                    controller: contents,
                    maxLines: 10,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText:
                            'Contact Us Tips - Please attach a screenshot of the problem for faster verification.'
                                .tr()),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.only(bottom: 10),
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        border:
                            Border(bottom: BorderSide(color: Colors.black54))),
                    child: Text(
                      'File'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.black54))),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.center,
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 0.1),
                              ),
                              child: first_attachment == null
                                  ? const FaIcon(
                                      FontAwesomeIcons.plus,
                                      color: Colors.black54,
                                    )
                                  : Image.file(first_attachment!)),
                          onTap: () async {
                            PermissionStatus permissionStatePhoto =
                                await Permission.photos.status;
                            if (permissionStatePhoto.isPermanentlyDenied) {
                              alertPhotoPermission(context);
                            } else {
                              getImage('first_attachment');
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.center,
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 0.1),
                              ),
                              child: second_attachment == null
                                  ? const FaIcon(
                                      FontAwesomeIcons.plus,
                                      color: Colors.black54,
                                    )
                                  : Image.file(second_attachment!)),
                          onTap: () async {
                            PermissionStatus permissionStatePhoto =
                                await Permission.photos.status;
                            if (permissionStatePhoto.isPermanentlyDenied) {
                              alertPhotoPermission(context);
                            } else {
                              getImage('second_attachment');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black54)),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onPressed: () {
                                setState(() {
                                  _check = !_check;
                                });
                              },
                              icon: FaIcon(FontAwesomeIcons.circleCheck,
                                  color: _check
                                      ? VetTheme.mainIndigoColor
                                      : Colors.black26 //트루면 Color(0xff2e3d80),
                                  )),
                          Flexible(
                            child: Text(
                                'Consent to collect and use personal information (required)'
                                    .tr()),
                          ),
                          // Text('버튼'),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(15, 0, 0, 15),
                        width: double.infinity,
                        child: DefaultTextStyle(
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('1. Purpose of collecting/using personal'
                                  .tr()),
                              Text('Receiving inquiries'.tr()),
                              Text('2. Personal information collection items'
                                  .tr()),
                              Text('Member Name, Email'.tr()),
                              Text(
                                  '3. Period of personal information use'.tr()),
                              Text(
                                  ' Until the purpose of collection is achieved or the user requests deletion'
                                      .tr()),
                              Text(
                                  ' * Users may disagree with the collection/use of personal information.'
                                      .tr()),
                              Text(
                                  ' However, if you refuse to consent, the use of the service will be restricted.'
                                      .tr()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  void resultBt() {
    textNullCheck()
        ? apiRequest()
        : UtilityComponents.showToast(
            'Please fill in the title and content'.tr());
  }

  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
  }
  Future<void> apiRequest() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final fields = <String, String>{};
    final sendFiles = <http.MultipartFile>[];
    BaseDeviceInfo deviceInfo;
    String deviceName;
    if (Platform.isAndroid) {
      deviceInfo = await deviceInfoPlugin.androidInfo;
      deviceName = deviceInfo.data['device'];
    } else {
      deviceInfo = await deviceInfoPlugin.iosInfo;
      deviceName = await UtilityFunction.getIosDeviceName(
          deviceInfo.data['utsname']['machine']);
    }
    String platform = Platform.isAndroid ? '2001' : '2002';
    fields.addAll({
      'userId': _profileManager.userData.id.toString(),
      'email': email.text.trim().isEmpty
          ? '${_profileManager.userData.email}-(회신 불필요)'
          : '${email.text.trim()}-(회신 원함)',
      'phone': '',
      'title': anytitle.text.trim(),
      'content': contents.text.trim(),
      'type': '0',
      'appCode': platform,
      'appVersion': packageInfo.version.toString(),
      'systemVersion': deviceName,
      'status': '0'
    });
    if (fileNullCheck()) {
      for (int i = 0; i < files.length; i++) {
        sendFiles.add(await http.MultipartFile.fromPath(
          'images',
          files[i].path,
        ));
        UtilityFunction.log.e(sendFiles[i]);
      }
    }
    await _apiService.sendReport(fields, sendFiles).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? apiRequest()
              : logoutAndPushToHome();
        }
        UtilityComponents.showToast(
            "${"registration failed".tr()}:${error.message ?? ""}");
        //UtilityFunction.pushReplacementNamed(context, '/');
        return;
      }, (success) {
        UtilityComponents.showToast("Send completed".tr());
        UtilityFunction.goBackToPreviousPage(context);
      });
    });
  }

  bool textNullCheck() {
    if (anytitle.text.trim().isNotEmpty && contents.text.trim().isNotEmpty) {
      return true;
    }
    return false;
  }

  bool fileNullCheck() {
    if (first_attachment != null) {
      files.add(first_attachment!);
    }
    if (second_attachment != null) {
      files.add(second_attachment!);
    }
    if (files.isNotEmpty) {
      UtilityFunction.log.e(files.isNotEmpty.toString());
      return true;
    }
    return false;
  }

  Future getImage(String c) async {
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    File file = File(image!.path);
    switch (c) {
      case 'first_attachment':
        setState(() {
          first_attachment = file;
        });
        break;
      case 'second_attachment':
        setState(() {
          second_attachment = file;
        });
        break;
    }
  }

  void alertPhotoPermission(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Notifications setting".tr()),
        content: Text(
            "Please allow photo permission\nin [Settings]>[DolittleVet]>[Notifications] on your device."
                .tr()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel".tr()),
          ),
          TextButton(
            onPressed: () {
              AppSettings.openAppSettings();
              Navigator.pop(context);
            },
            child: Text(
              "Setting".tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
