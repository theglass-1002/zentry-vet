import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class VeterinarianManagementScreen extends StatefulWidget {
  const VeterinarianManagementScreen({Key? key}) : super(key: key);

  @override
  State<VeterinarianManagementScreen> createState() =>
      _VeterinarianManagementScreenState();
}

class _VeterinarianManagementScreenState
    extends State<VeterinarianManagementScreen> {
  late ProfileManager _profileManager = ProfileManager();
  late ApiService _apiService = ApiService();
  bool _isLoding = true;
  late List<Vet> vet_list;

  @override
  void initState() {
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    getVetList();
    super.initState();
  }


  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    setLoading(false);
  }

  Future<void> getVetList() async {
    await _apiService.getVetList().then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? getVetList()
              : logoutAndPushToHome();
        }
        UtilityComponents.showToast(
            "${"Failed to load vet list".tr()}:${error.message ?? ""}");
        UtilityFunction.goBackToPreviousPage(context);
        //UtilityFunction.pushReplacementNamed(context, '/');
        return;
      }, (success) {
       // int authority = _profileManager.userData.authority!;
        vet_list = success.vet_list!;
        setLoading(false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1, title: Text("Staff care".tr())),
      body: _isLoding ? const LoadingBar() : mainBuild(),
      bottomNavigationBar: BottomAppBar(
          child: Container(
           margin: EdgeInsets.symmetric(horizontal: VetTheme.textSize(context)),
           child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(const Color(0xff2e3d80))),
          onPressed: () =>
              UtilityFunction.moveScreenAndPop(context, '/vetQrScan'),
          child: Text("Registering as a hospital staff".tr()),
        ),
      )),
    );
  }

  Widget mainBuild() {
    return ListView.builder(
        itemCount: vet_list.length,
        itemBuilder: (BuildContext context, int index) {
          return vetCard(vet_list[index]);
     });
  }

  Widget vetCard(Vet vet) {
    return Card(
        elevation: 5.0,
        child: Container(
          margin: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                            Text('${'Name'.tr()} : ',
                              style: TextStyle(color: VetTheme.mainIndigoColor,
                                        fontSize: VetTheme.titleTextSize(context),
                                        fontWeight: FontWeight.bold),
                                  ),
                          Expanded(
                             child: Text(
                             '${vet.name}',
                               textAlign: TextAlign.start,
                              style: TextStyle(fontSize: VetTheme.textSize(context))),
                           )
                        ],
                      ),
                      Row(
                        children: [
                          Text('${'Number'.tr()} : ',
                            style: TextStyle(
                                color: VetTheme.mainIndigoColor,
                                fontSize: VetTheme.titleTextSize(context),
                                fontWeight: FontWeight.bold),),
                          Expanded(child:
                          Text('${vet.license}',
                            style: TextStyle(
                                fontSize: VetTheme.textSize(context)),),),
                        ],
                      ),
                      Row(
                        children: [
                          Text('${'Position'.tr()} : ',
                            style: TextStyle(
                            color: VetTheme.mainIndigoColor,
                            fontSize: VetTheme.titleTextSize(context),
                            fontWeight: FontWeight.bold),),
                          Expanded(
                            child: Text(
                              vet.authority == 1 ? '수의사'.tr() :
                              vet.authority == 2 ? '관리자'.tr() :
                              vet.authority == 4 ? '테크니션'.tr() :
                              vet.authority == 3 ? '대표원장'.tr() :
                              'Not Found'.tr(), style:  TextStyle(fontSize: VetTheme.textSize(context))))
                        ],
                      ),
                      Row(
                        children: [
                          Text('${'Date of hire'.tr()} : ',
                            style: TextStyle(
                            color: VetTheme.mainIndigoColor,
                            fontSize: VetTheme.titleTextSize(context),
                            fontWeight: FontWeight.bold),),
                          Expanded(
                            child: Text(
                            registedate(vet.registeredAt!),
                            style: TextStyle(fontSize: VetTheme.textSize(context)))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: vet.authority==3?Container():_profileManager.userData.id==vet.id.toString()?Container():Container(
                  child: Column(
                    children: [
                      setPermissionStatusBtnWidget(vet),
                      ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color(0xffDD5E56))),
                          onPressed: (){
                            deregisterVet(vet);
                          }, child: Text('Terminate'.tr()))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget setPermissionStatusBtnWidget(Vet vet) {
    Widget widget;
    if (vet.authority == 1) {
      widget = ElevatedButton(
        onPressed: () => updateVetauthority(vet),
        child: Text(
          'Promote to manager'.tr(),
          style: TextStyle(fontSize: VetTheme.textSize(context)),
          textAlign: TextAlign.center,
        ).tr(),
      );
    } else if (vet.authority == 2) {
      widget = ElevatedButton(
          onPressed: () => updateVetauthority(vet),
          child: Text(
            'Demote to vet'.tr(),
            style: TextStyle(fontSize: VetTheme.textSize(context)),
            textAlign: TextAlign.center,
          ).tr());
    } else {
      widget = ElevatedButton(
          onPressed: null,
          child: Text(
            'Promote to manager'.tr(),
            style: TextStyle(fontSize: VetTheme.textSize(context)),
            textAlign: TextAlign.center,
          ).tr());
    }
    return widget;
  }

  Future<void> updateVetauthority(Vet vet) async {
    setLoading(true);
    UtilityFunction.log.e('권한변경');
    int authority = vet.authority == 1 ? 2 : 1;
    await _apiService.updateVetauthority(
        vet.id.toString(), {"authority": '$authority'}).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? updateVetauthority(vet)
              : logoutAndPushToHome();
        }
        UtilityComponents.showToast(
            "${"Vet Authorization Failed".tr()}:${error.message ?? ""}");
        UtilityFunction.goBackToPreviousPage(context);
        return;
      }, (success) async {
        UtilityComponents.showToast(authority == 2
            ? '${vet.name} ${"Authorization complete".tr()}'
            : '${vet.name} ${"Permissions revoked".tr()}');
        return await getVetList();
      });
    });
  }

  Future<void> deregisterVet(Vet vet) async {
    setLoading(true);
    UtilityFunction.log.e('수의사 삭제');
    await _apiService.deregisterVet(vet.id.toString()).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? deregisterVet(vet)
              : logoutAndPushToHome();
        }
        UtilityComponents.showToast(
            "${"Veterinarian delete failed".tr()}:${error.message ?? ""}");
        UtilityFunction.goBackToPreviousPage(context);
        return;
      }, (success) async {
        UtilityComponents.showToast("Veterinarian deleted".tr());
        return await getVetList();
      });
    });
  }

  String registedate(String date) {
    if (date != "") {
      DateTime _last = DateTime.parse(date);
      date = '${_last.year}-${_last.month}-${_last.day}';
    }
    return date;
  }

  void setLoading(bool isLoding) {
    setState(() {
      _isLoding = isLoding;
    });
  }
}
