import 'package:dolittle_for_vet/utility_function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:provider/provider.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);
  static const routeName = '/SettingScreen';

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

enum ItemTrans { A, B, C }

enum ItemAuth { A, B, C,D}


class _SettingScreenState extends State<SettingScreen> {
  ProfileManager _profileManager = ProfileManager();
  SocketManager _socketManager = SocketManager();
  ApiService _apiService = ApiService();
  ApiUtility _apiUtility = ApiUtility();
  final businessLicenseController = TextEditingController();
  final vetLicenseController = TextEditingController();
  final confirmationCodeController = TextEditingController();
  late List _listSettingCategory = [];
  // bool? _isEventNotificationEnabled;
  // bool? _isDiseaseNotification;
  bool? monitorNotice;
  bool _isLoading = true;
  bool _isServer = false;
  int _serverRoute = 0;

  ItemTrans _itemTran = ItemTrans.A;
  ItemAuth _itemAuth = ItemAuth.A;

  @override
  void initState() {
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    _socketManager = Provider.of<SocketManager>(context, listen: false);
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    UtilityFunction.log.e('setting didchange');
    await retrieveDeviceAndUserSettings();
    super.didChangeDependencies();
  }

  Future<void> retrieveDeviceAndUserSettings() async {
    _serverRoute = _apiUtility.getServerRoute();
    _isServer = _apiUtility.getIsRealServerState();
    monitorNotice = await _profileManager.getMonitoringNotice();
    _itemTran = setLanguage(await _profileManager.getUserTranslation());
    int userAuth = _profileManager.userData.authority!;
    switch (userAuth) {
      case 1:
      case 4:
        _itemAuth = ItemAuth.A;
        break;
      case 2:
        _itemAuth = ItemAuth.B;
        break;
      case 3:
        _itemAuth = ItemAuth.C;
        break;
      default:
        _itemAuth = ItemAuth.D;
        break;
    }
    createSettingCategory();
    setLoading(false);
  }


  ItemTrans setLanguage(String language) {
    if (language.contains('en')){
      return ItemTrans.B;
    }else if (language.contains('ko')){
      return ItemTrans.A;
    }else if(language.contains('es')){
      return ItemTrans.C;
    }
    return ItemTrans.A;
  }


  List createSettingCategory() {
    switch (_profileManager.userData.authority) {
      case 0:
        _listSettingCategory = ListSettingCategory.where((category) =>
        category['authority'] == 'none' || category['authority'] == 0)
            .toList();
        break;
      case 1:
        _listSettingCategory = ListSettingCategory.where((category) =>
        category['authority'] == 'none' ||
            category['authority'] == 9 ||
            category['authority'] == 1 )
            .toList();

        break;
      case 2:
        _listSettingCategory = ListSettingCategory.where((category) =>
        category['authority'] == "none" ||
            category['authority'] ==9 ||
            category['authority'] >= 1 && category['authority'] < 3).toList();
        break;
      case 3:
        _listSettingCategory = ListSettingCategory.where((category) =>
        category['authority'] == "none" || category['authority'] >= 1)
            .toList();
        break;
      case 4:
        UtilityFunction.log.e('간호사 권한 카테고리 만들기');
        _listSettingCategory = ListSettingCategory.where((category) =>
        category['authority'] == 'none' || category['authority'] == 1)
            .toList();
        break;

    }

    if (!_apiUtility.getIsRealServerState()) {
      if (SettingCategory.test_auth != null) {
        _listSettingCategory
            .add(Map<String, dynamic>.from(SettingCategory.test_auth));
      }
    }

    return _listSettingCategory;
  }


  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Container(color: Colors.white, child: const LoadingBar())
        : mainContent();
  }

  Widget mainContent() {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              _profileManager.animalListRefresh(true);

              //_profileManager.refreshAnimalList();
              UtilityFunction.goBackToMainPage(context);

            },
            icon: const Icon(Icons.arrow_back),
          ),
          elevation: 1,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(_profileManager.hospitalData.name ?? "",style: TextStyle(fontSize: VetTheme.titleTextSize(context)),)),
              Text('Setting'.tr())
            ],
          )),
      body: Stack(
        children: [
          buildListView(),
        ],
      ),
    );
  }

  Widget buildListView() {
    return GroupedListView<dynamic, String>(
      elements: _listSettingCategory,
      groupBy: (element) => element['group'],
      itemComparator: (item1, item2) => item1['name'].compareTo(item2['name']),
      sort: false,
      shrinkWrap: false,
      groupSeparatorBuilder: (String groupTitle) => Container(
        padding: const EdgeInsets.all(3),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Text(
          groupTitle.tr(),
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: VetTheme.titleTextSize(context),
              fontWeight: FontWeight.bold,
              color: VetTheme.mainIndigoColor),
        ),
      ),
      itemBuilder: (c, element) {
        return GestureDetector(
            onTap: () => onMenuClicked(element), child: mainBuild(element));
      },
    );
  }

  Widget mainBuild(settingMenu) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2.0),
      child: SizedBox(
        child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            title: titleBuild(settingMenu),
            trailing: trailingBuild(settingMenu)),
      ),
    );
  }

  Widget trailingBuild(dynamic settingMenu) {
    Widget widget = Text('');
    switch (settingMenu['trailing']) {
      case 'icon':
        return widget = const Icon(Icons.arrow_forward_ios);
      case 'switch':
        return widget = switchBuild(settingMenu);
    }
    return widget;
  }

  Widget titleBuild(dynamic settingMenu) {
    Widget widget = Container();
    switch (settingMenu['type']) {
      case 'link':
      case 'dialog':
        return widget = Text(settingMenu['name'],style: TextStyle(fontSize: VetTheme.titleTextSize(context)),).tr();
      case 'radio':
        return settingMenu['group'] == 'Language'
            ? radioLanguageBuild()
            : radioBuild(settingMenu);
      case 'dialog':
      //    return widget = buttonBuild(settingMenu);
      case 'none':
        return widget = noneBuild(settingMenu);
      default:
        return widget = Text(settingMenu['name'],style: TextStyle(fontSize: VetTheme.titleTextSize(context)),).tr();
    }
  }

  Widget switchBuild(dynamic settingMenu) {
    Widget widget = Container();
    switch (settingMenu['name']) {
      case 'name_Monitoring notification':
        widget = Switch(
          value: monitorNotice!,
          onChanged: (bool value) {
            setState(() {
              _profileManager.setMonitoringNotice(value);
              monitorNotice = value;
              updateMonitoringNotice(value);
            });
          },
          activeColor: VetTheme.mainIndigoColor,
        );
        break;
    }

    return widget;
  }


  Widget noneBuild(dynamic settingMenu) {
    Widget widget = Container();
    if (settingMenu['name'] == 'name_Version') {
      return widget = Text(
          '${_profileManager.version} (${_isServer ? 'R' : 'T'} - ${_serverRoute == 0 ? 'K' : _serverRoute == 1 ? 'F' : 'None'})');
    }
    return widget;
  }

  Widget radioLanguageBuild() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile(
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              contentPadding: EdgeInsets.zero,
              title: Text('Korean'.tr(),style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: VetTheme.textSize(context)),),
              value: ItemTrans.A,
              groupValue: _itemTran,
              onChanged: (ItemTrans? value) {
                _profileManager.setUserTranslation('ko');

                EasyLocalization.of(context)!
                    .setLocale(const Locale('ko', 'KR'));
                setState(() {
                  _itemTran = ItemTrans.A;
                });
              }),
        ),
        Expanded(
          child: RadioListTile(
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              contentPadding: EdgeInsets.zero,
              title: Text('English'.tr(),style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: VetTheme.textSize(context)),),
              value: ItemTrans.B,
              groupValue: _itemTran,
              onChanged: (ItemTrans? value) {
                _profileManager.setUserTranslation('en');
                EasyLocalization.of(context)!
                    .setLocale(const Locale('en', 'US'));
                setState(() {
                  _itemTran = ItemTrans.B;
                });
              }),
        ),
        Expanded(
          child: RadioListTile(
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              contentPadding: EdgeInsets.zero,
              title: Text('Spanish'.tr(),style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: VetTheme.textSize(context)),),
              value: ItemTrans.C,
              groupValue: _itemTran,
              onChanged: (ItemTrans? value) {
                _profileManager.setUserTranslation('es');
                EasyLocalization.of(context)!
                    .setLocale(const Locale('es', 'ES'));
                setState(() {
                  _itemTran = ItemTrans.C;
                });
              }),
        ),
      ],
    );
  }

  Widget radioBuild(dynamic settingMenu) {
    Widget widget = Container();
    if (settingMenu['group'] == 'testAuthChange') {
      if (_apiUtility.getIsRealServerState()) {
        UtilityFunction.log.e('여기진입');
        return Container();
      } else {
        return widget = radioAuthorityBuild();
      }
    }
    return widget;
  }


  Widget radioAuthorityBuild() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile(
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              contentPadding: EdgeInsets.zero,
              title: Text('TECHNICIAN'.tr()),
              value: ItemAuth.A,
              groupValue: _itemAuth,
              onChanged: (ItemAuth? value) async {
                await changeAuth(
                    _profileManager.userData.id.toString(), {"authority": '4'});
              }),
        ),
        Expanded(
          child: RadioListTile(
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              contentPadding: EdgeInsets.zero,
              title: Text('NORMAL'.tr()),
              value: ItemAuth.A,
              groupValue: _itemAuth,
              onChanged: (ItemAuth? value) async {
                await changeAuth(
                    _profileManager.userData.id.toString(), {"authority": '1'});
              }),
        ),
        Expanded(
          child: RadioListTile(
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              contentPadding: EdgeInsets.zero,
              title: Text('관리자'.tr()),
              value: ItemAuth.B,
              groupValue: _itemAuth,
              onChanged: (ItemAuth? value) async {
                await changeAuth(
                    _profileManager.userData.id.toString(), {"authority": '2'});
              }),
        ),
        Expanded(
          child: RadioListTile(
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              contentPadding: EdgeInsets.zero,
              title: Text('OWNER'.tr()),
              value: ItemAuth.C,
              groupValue: _itemAuth,
              onChanged: (ItemAuth? value) async {
                await changeAuth(
                    _profileManager.userData.id.toString(), {"authority": '3'});
              }),
        ),
      ],
    );
  }

  Future<void> updateMonitoringNotice(bool MonitoringNotic)async {
    await _apiService.updateMonitoringNotify(_profileManager.userData.id!,
        {"enabled":"$MonitoringNotic"}).then((value){
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          bool result = await _apiService.refreshToken();
          if(result){
            return await updateMonitoringNotice(MonitoringNotic);
          }else{
            return await logoutAndPushToHome();
          }
        }
        UtilityComponents.showToast(
            "${"MonitoringNotice Setting Failed ".tr()}:${error.message ?? ""}");
        UtilityFunction.goBackToPreviousPage(context);

      },(success){
        UtilityFunction.log.e('알림끄기 ${success.toString()}');
        return;
      });
    });
  }



  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    setLoading(false);
  }

  Future<void> onMenuClicked(dynamic settingMenu) async {
    DateTime now = DateTime.now();
    switch (settingMenu['type']) {
      case 'link':
        if(settingMenu['name'].toString().contains('name_Technician registration')){
          UtilityFunction.moveScreen(context, "/createVetQr",{
            'id': _profileManager.userData.id!,
            'name': _profileManager.userData.name!,
            'authority': '4',
            'number': DateFormat('yyyyMMdd').format(now),
          });
          break;
        }
        UtilityFunction.moveScreen(context, settingMenu['route']);
        break;
      case 'dialog':
        if (settingMenu['name'] == 'name_Logout') {
          var result = await alertLogoutDialog(
            context,
            'Logout'.tr(),
            'Are you really going to log out?'.tr(),
            'Cancel'.tr(),
            'Logout'.tr(),
          );
          if (result) {
            setLoading(true);
            await logoutAndPushToHome();
          }
          break;
        } else {
          var result = await alertWithdrawal(context);
          if (result) {
            setLoading(true);
            if(_profileManager.userData.authority==3){
             return await closeHospital();
            }else{
            return await withdrawMembership();
            }
          }
          businessLicenseController.text = '';
          vetLicenseController.text = '';
          confirmationCodeController.text = '';
        }
        break;
    }
  }

  Future<dynamic> alertWithdrawal(BuildContext context) {
    Widget widget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: confirmationCodeController,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            helperText: "Please input the text 'CONFIRM'".tr(),
            hintText: 'CONFIRM',
          ),
        ),
      ],
      //  Confirm
    );
    return showDialog<bool>(
      context: context,
      builder: (BuildContext _) => AlertDialog(
        title: Text('Delete Account'.tr()),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "All personal information usage records will be deleted.\nDeleted accounts cannot be recovered."
                    .tr()),
            _profileManager.userData.authority! == 3 ? widget : Container()
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              return Navigator.pop(_, false);
            },
            child: Text("Cancel".tr()),
          ),
          TextButton(
            onPressed: () {
              if (_profileManager.userData.authority == 3) {
                if (confirmationCodeController.text.trim().isEmpty) {
                  UtilityComponents.showToast('A blank exists.'.tr());
                  Navigator.pop(_, false);
                } else if (confirmationCodeController.text.trim().toUpperCase() == "CONFIRM") {
                  Navigator.pop(_, true);
                } else {
                  UtilityFunction.log.e('일치하지않음');
                  UtilityComponents.showToast('input text is incorrect'.tr());
                  Navigator.pop(_, false);
                }
              } else {
                Navigator.pop(_, true);
              }
            },

            child: Text(
              "OK".tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> alertLogoutDialog(BuildContext context, String title,
      String content, String buttonContentCancel, String buttonContentOk) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(buttonContentCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              buttonContentOk,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> closeHospital() async {
    UtilityFunction.log.e('병원폐업 실행');
    var apiResult = await _apiService.executeUpdateHospital(_profileManager.hospitalData.id.toString(),{'isShutdown':'true'});
    if(apiResult.isSuccess()){
    return await withdrawMembership();
    }else{
      if(apiResult.getError()?.code==101){
       return await _apiService.refreshToken()? await closeHospital():
       logoutAndPushToHome();
      }else{
       UtilityComponents.showToast('${'Membership withdrawal failed'.tr()}${apiResult.getError()?.message}');
       return UtilityFunction.goBackToMainPage(context);
      }
    }
  }


  Future<void> withdrawMembership() async {
    UtilityFunction.log.e('회원탈퇴 실행');
    await _apiService.setWithdrawalUser().then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? withdrawMembership()
              : logoutAndPushToHome();
        }
        UtilityComponents.showToast(
            "${"Membership withdrawal failed.".tr()}:${error.message ?? ""}");
        return UtilityFunction.goBackToMainPage(context);
      }, (success) async {
        UtilityComponents.showToast(
            "Membership withdrawal complete".tr());
        return logoutAndPushToHome();
      });
    });
  }


  Future<void> changeAuth(String vetId, Map<String, String> body) async {
    setLoading(true);
    await _apiService.updateVetauthority(vetId, body).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? changeAuth(vetId, body)
              : UtilityFunction.pushReplacementNamed(context, '/login');
        }
        UtilityComponents.showToast(
            "${"Vet Authorization Failed".tr()}:${error.message ?? ""}");
        UtilityFunction.pushReplacementNamed(context, '/');
        return;
      }, (success) async {
        UtilityComponents.showToast('success changeAuth');
        UtilityFunction.pushReplacementNamed(context, '/');
      });
    });
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
