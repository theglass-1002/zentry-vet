import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  //  ProfileScreen({Key? key}) : super(key: key);
  late ProfileManager _profileManager;
  static const routeName = '/ProfileScreen';

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileManager>(builder: (context, user, child) {
      _profileManager = user;
      return Contents(context);
    });
  }


  String hospitalAddress() {
    String? addressFirst = _profileManager.hospitalData.address_first;
    String? addressSecond = _profileManager.hospitalData.address_second;
    String? addressRoad = _profileManager.hospitalData.address_road;
    String? addressDetail = _profileManager.hospitalData.address_detail;
    return "${addressFirst!} ${addressSecond!} ${addressRoad!} ${addressDetail!}";
  }

  String userAuthority() {
    String authority = "";
    switch (_profileManager.userData.authority) {
      case 0:
        return authority = 'none';
      case 1:
        return authority = '수의사'.tr();
      case 2:
        return authority = '관리자'.tr();
      case 3:
        return authority = '대표원장'.tr();
      case 4:
        return authority = '테크니션'.tr();
    }
    return authority;
  }

  Widget Contents(BuildContext context) {
    UtilityFunction.log.e(_profileManager.hospitalData.name);
    UtilityFunction.log.e(_profileManager.hospitalData.address_first);

    List listProfile = [
      {'name': _profileManager.userData.email, 'group': 'Email'.tr()},
      {'name': _profileManager.userData.name, 'group': 'Name'.tr()},
      {
        'name': _profileManager.userData.license == "none"||_profileManager.userData.authority==4
            ? ''
            : _profileManager.userData.license,
        'group': 'License number'.tr()
      },
      {
        'name': _profileManager.hospitalData.name ?? '',
        'group': 'Hospital Name'.tr()
      },
      {
        'name': _profileManager.hospitalData.address_first == null
            ? ''
            : hospitalAddress(),
        'group': 'Hospital Location'.tr()
      },
      {'name': userAuthority(), 'group': 'Authority'},
    ];

    return Scaffold(
      appBar: AppBar(
          elevation: 1,
          title: Text("Profile".tr(),
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Color(0xffffffff)))),
      body: GroupedListView<dynamic, String>(
        sort: false,
        elements: listProfile,
        groupBy: (element) {
          String groupName = element['group'];
          return groupName.tr();
        },
        groupSeparatorBuilder: (String value) => Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            value,
            textAlign: TextAlign.start,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff2e3d80)),
          ),
        ),
        itemBuilder: (c, element) {
          return buildSetValueCard(element);
        },
      ),
    );
  }

  Widget buildSetValueCard(dynamic settingMenu) {
    return Card(
      elevation: 5.0,
      child: SizedBox(
        child: ListTile(
          title: Text(
            getText(settingMenu['name']).tr(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String getText(String name) {
    return name.tr();
  }
}
