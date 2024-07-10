import 'package:dolittle_for_vet/utility_function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:provider/provider.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class MonitoringSettingScreen extends StatefulWidget {
  const MonitoringSettingScreen({Key? key}) : super(key: key);
  static const routeName = '/MonitoringSettingScreen';

  @override
  State<MonitoringSettingScreen> createState() => _MonitoringSettingScreenState();
}


class _MonitoringSettingScreenState extends State<MonitoringSettingScreen> {
  ProfileManager _profileManager = ProfileManager();
  ApiService _apiService = ApiService();
  ApiUtility _apiUtility = ApiUtility();
  final business_license = TextEditingController();
  final vet_license = TextEditingController();
  late List _MonitoringlistSettingCategory = [];
  bool? monitorNotice;
  bool _isLoading = true;
  bool _isServer = false;
  int _serverRoute = 0;


  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    await getNotice();
    super.didChangeDependencies();
  }

  Future<void> getNotice() async {
    _serverRoute = _apiUtility.getServerRoute();
    _isServer = _apiUtility.getIsRealServerState();
    monitorNotice = await _profileManager.getMonitoringNotice();
    UtilityFunction.log.e('멀티알람 설정${monitorNotice}');
    makeCategory();
    setLoading(false);
  }




  List makeCategory() {
    switch (_profileManager.userData.authority) {
      case 0:
        _MonitoringlistSettingCategory = MonitoringListSettingCategory.where((category) =>
        category['authority'] == 'none' || category['authority'] == 0)
            .toList();
        break;
      case 1:
        _MonitoringlistSettingCategory = MonitoringListSettingCategory.where((category) =>
        category['authority'] == 'none' || category['authority'] == 1)
            .toList();
        break;

      case 2:
        _MonitoringlistSettingCategory = MonitoringListSettingCategory.where((category) =>
        category['authority'] == "none" ||
            category['authority'] >= 1 && category['authority'] < 3).toList();
        break;
      case 3:
        _MonitoringlistSettingCategory = MonitoringListSettingCategory.where((category) =>
        category['authority'] == "none" || category['authority'] >= 1)
            .toList();

        break;
      case 4:
        _MonitoringlistSettingCategory = MonitoringListSettingCategory.where((category) =>
        category['authority'] == 'none' || category['authority'] == 1)
            .toList();
        break;
    }


    return _MonitoringlistSettingCategory;
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
              UtilityFunction.log.e('설정에서 뒤로가기 누름');
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          elevation: 1,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Patient Monitoring'.tr(),style: TextStyle(fontSize: VetTheme.titleTextSize(context)),),
              Text('Setting'.tr(),style: TextStyle(fontSize: VetTheme.titleTextSize(context)))
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
      elements: _MonitoringlistSettingCategory,
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

  Widget titleBuild(dynamic settingMenu) {
    Widget widget = Container();
    switch (settingMenu['type']) {
      case 'link':
        return widget = Text(settingMenu['name'],style: TextStyle(fontSize: VetTheme.titleTextSize(context)),).tr();
      case 'none':
        return widget = noneBuild(settingMenu);
      default:
        return widget = Text(settingMenu['name'],style: TextStyle(fontSize: VetTheme.titleTextSize(context)),).tr();
    }
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



  Widget switchBuild(dynamic settingMenu) {
    Widget widget = Text('data');
    switch (settingMenu['name']) {
      case 'name_Monitoring notification':
        widget = Switch(
          value: monitorNotice!,
          onChanged: (bool value) {
            setState(()  {
              updateMonitoringNotice(value);
              _profileManager.setMonitoringNotice(value);
              monitorNotice = value;
              UtilityFunction.log.e('멀티 알람 설정 ${monitorNotice}');
            });
          },
          activeColor: VetTheme.mainIndigoColor,
        );
        break;
    }

    return widget;
  }



  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
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



  Widget noneBuild(dynamic settingMenu) {
    Widget widget = Container();
    if (settingMenu['name'] == 'name_Version') {
      return widget = Text(
        '${_profileManager.version} (${_isServer ? 'R' : 'T'} - ${_serverRoute == 0 ? 'K' : _serverRoute == 1 ? 'F' : 'None'})',style: TextStyle(fontSize: VetTheme.titleTextSize(context)),);
    }
    return widget;
  }



  Future<void> onMenuClicked(dynamic settingMenu) async {
    switch (settingMenu['type']) {
      case 'link':
        UtilityFunction.moveScreen(context, settingMenu['route']);
        break;
    }
  }


  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  void dispose() {
    UtilityFunction.log.e('monitoring setting dispose');
    super.dispose();
  }
}