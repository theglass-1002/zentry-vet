import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:provider/provider.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({Key? key}) : super(key: key);

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  bool _isLoading = true;
  late ApiService _apiService = ApiService();
  List<PushMessages>? pushMessages;
  ProfileManager _profileManager = ProfileManager();

  @override
  void initState() {
    // TODO: implement initState
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    getNotifyList();
    super.initState();
  }

  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    setLoading(false);
  }

  Future<void> getNotifyList() async {
    return await _apiService.getNotifyList().then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? getNotifyList()
              : logoutAndPushToHome();
        }

        UtilityComponents.showToast(
            "${"Failed to retrieve notification history".tr()}:${error.message ?? ""}");
        _profileManager.animalListRefresh(true);

        //_profileManager.refreshAnimalList();
        UtilityFunction.goBackToMainPage(context);
        return;
      }, (success) {
        pushMessages = success.pushMessages;
        setLoading(false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                _profileManager.animalListRefresh(true);
                // _profileManager.refreshAnimalList();
                UtilityFunction.goBackToMainPage(context);
              },
              icon: const Icon(Icons.arrow_back),
            ),
            elevation: 1,
            title: Text('Notifications'.tr(),
                style: const TextStyle(color: Colors.white))),
        body: _isLoading ? const LoadingBar() : buildBody());
  }

  Widget buildBody() {
    return Stack(
      children: [
        pushMessages!.isEmpty
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications,
                          color: Colors.black, size: 80),
                      Text('The data does not exist.'.tr()),
                    ]),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: pushMessages!.length,
                itemBuilder: (context, index) {
                  return NotiyCard(pushMessages: pushMessages![index],user:_profileManager.userData);
                })
      ],
    );
  }

  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }
}
