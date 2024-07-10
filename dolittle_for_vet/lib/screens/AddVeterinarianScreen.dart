import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class AddVeterinarianScreen extends StatefulWidget {
  const AddVeterinarianScreen({Key? key}) : super(key: key);

  @override
  State<AddVeterinarianScreen> createState() => _AddVeterinarianScreenState();
}

class _AddVeterinarianScreenState extends State<AddVeterinarianScreen> {
  late final Map<dynamic, dynamic> _userData = Map<dynamic, dynamic>.from(
      ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>);
  late ProfileManager _profileManager = ProfileManager();
  late final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    // UtilityFunction.log.e(_vetData.toString());
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
    return _isLoading ? const LoadingBar() : _setQrdata(context);
  }

  Widget _setQrdata(BuildContext context) {
  UtilityFunction.log.e(_userData.toString());
  String staffName = _userData.containsKey('vet_name')?_userData['vet_name'].toString().trim():_userData['name'].toString().trim();
  String staffNumber = _userData.containsKey('vet_number')?_userData['vet_number'].toString().trim():_userData['number'].toString().trim();
  String staffAuth = _userData.containsKey('authority')?_userData['authority'].toString().trim():_userData['authority'].toString().trim();

    //  String vet = _userData['']
    return Scaffold(
      appBar: AppBar(
          elevation: 1,
          title: Text(
            "Register new staff".tr(),
          ),centerTitle: false,),
      body: Center(
        child: Container(
          margin:  EdgeInsets.all(VetTheme.titleTextSize(context)),
          padding:  EdgeInsets.all(VetTheme.titleTextSize(context)),
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          height: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text("Position".tr(),
                    style: TextStyle(
                      color: VetTheme.mainIndigoColor,
                      fontSize: VetTheme.logotextSize(context),

                    )),
              ),
              Expanded(
                child: Text(
                  staffAuth == '1'
                      ? '수의사'.tr()
                      : staffAuth == '2'
                      ? '관리자'.tr()
                      : staffAuth == '4'
                      ? '테크니션'.tr()
                      : staffAuth == '3'
                      ? '병원장'.tr()
                      : 'Not Found'.tr(),
                  style:  TextStyle(fontSize: VetTheme.titleTextSize(context),
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Expanded(
                child: Text("Name".tr(),
                    style: TextStyle(
                        color: VetTheme.mainIndigoColor,
                        fontSize: VetTheme.logotextSize(context),

                    )),
              ),
              Expanded(
                child: Text(
                    staffName,
                    style:  TextStyle(
                      fontSize: VetTheme.titleTextSize(context), fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text("License number".tr(),
                    style: TextStyle(
                        color: VetTheme.mainIndigoColor,
                        fontSize: VetTheme.logotextSize(context),
                    )),
              ),
              Expanded(
                child: Text(
                    staffNumber,
                    style: TextStyle(
                        fontSize: VetTheme.titleTextSize(context),
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Container(
        margin: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () => resultBt(),
          child: Text("Register".tr()),
        ),
      )),
    );
  }
  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    setLoading(false);
  }
  void resultBt() {
    setLoading(true);
    var user_id = _userData.containsKey('vet_id')?_userData['vet_id'].toString().trim():_userData['id'].toString().trim();
    _apiService.getUserData(user_id).then((value) {
      value.when((error) async {
        UtilityFunction.log.e('서버연결안됨');
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? resultBt()
              : logoutAndPushToHome();
        }
        UtilityComponents.showToast(error.message ?? "");
        return UtilityFunction.goBackToPreviousPage(context);
      }, (success) {
        UtilityFunction.log.e(success.toJson());
        _userData['id'] =success.id;
        addVet();
      });
    });
  }

  Future<void> addVet() async {
    UtilityFunction.log.e(_profileManager.hospitalData.name);
    UtilityFunction.log.e(_profileManager.hospitalData.id);

    await _apiService.addVet(_userData['id'], {
      "hospitalId": _profileManager.hospitalData.id.toString(),
      "authority": _userData ['authority']??'1',
      "license": _userData.containsKey('vet_number')?_userData['vet_number'].toString().trim():_userData['number'].toString().trim()
    }).then((value) {
      value.when((error) async {
        setLoading(false);
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? addVet()
              : logoutAndPushToHome();
        }

        UtilityComponents.showToast(
            ("${"Failed to register as a veterinarian".tr()}:${error.message ?? ""}"));
        return UtilityFunction.goBackToPreviousPage(context);
      }, (success) {
        return UtilityFunction.moveScreenAndPop(
            context, '/veterinarianManagement');
      });
    });
  }
}
