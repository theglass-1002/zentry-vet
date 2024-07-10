import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class HospitalHandoverScreen extends StatefulWidget {
  const HospitalHandoverScreen({Key? key}) : super(key: key);
  static const routeName = '/HospitalHandoverScreen';
  @override
  State<HospitalHandoverScreen> createState() => _HospitalHandoverScreenState();
}

class _HospitalHandoverScreenState extends State<HospitalHandoverScreen> {
  final ScrollController _scrollController = ScrollController();
  late ProfileManager _profileManager = ProfileManager();
  late ApiService _apiService = ApiService();
  late List<Vet> vet_list;
  int _page = 1;
  final _limit = 20;
  bool _isLoding = true;
  bool isEndData = false;
  bool isFetchingData = false;

  @override
  void initState() {
    // TODO: implement initState
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    super.initState();
    _scrollController.addListener(() {
      scrollListener();
    });
    getVetList();
  }

  void scrollListener() async {
    if (isFetchingData == false &&
        isEndData == false &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent - 80 &&
        !_scrollController.position.outOfRange) {
      isFetchingData = true;
      _page++;
      await getVetList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return homeContent();
    // return Consumer<ProfileManager>(
    //   builder: (context, user , child) {
    //     _profileManager = user;
    //     return homeContent();
    //   }
    // );
  }

  Widget homeContent() {
    return Scaffold(
      appBar: AppBar(elevation: 1, title: Text("name_Hospital Handover".tr())),
      body: Stack(children: [_isLoding ? const LoadingBar() : mainContent()]),
    );
  }

  Widget mainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: buildListView(),
        )
      ],
    );
  }

  Widget buildListView() {
    return vet_list.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.pets_outlined,
                  size: 200,
                  color: Colors.grey,
                ),
                Text(
                  'No veterinarian list'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            controller: _scrollController,
            itemCount: vet_list.length,
            itemBuilder: (_, index) {
              return buildVeterinarianCard(vet_list[index]);
            });
  }

  Widget buildVeterinarianCard(Vet vet) {
    return Card(
        elevation: 5.0,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${'Name'.tr()} : ',
                          style: TextStyle(
                              color: VetTheme.mainIndigoColor,
                              fontSize: VetTheme.titleTextSize(context),
                              fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            '${vet.name}',
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: VetTheme.textSize(context)),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${'Number'.tr()} : ',
                          style: TextStyle(
                              color: VetTheme.mainIndigoColor,
                              fontSize: VetTheme.titleTextSize(context),
                              fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            '${vet.license}',
                            style:  TextStyle(fontSize: VetTheme.textSize(context)),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${'Position'.tr()} : ',
                          style: TextStyle(
                              color: VetTheme.mainIndigoColor,
                              fontSize: VetTheme.titleTextSize(context),
                              fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            vet.authority == 1
                                ? '수의사'.tr()
                                : vet.authority == 2
                                ? '관리자'.tr()
                                : vet.authority == 4
                                ? '테크니션'.tr()
                                : vet.authority == 3
                                ? '대표원장'.tr()
                                : 'Not Found'.tr(),
                            style:  TextStyle(fontSize: VetTheme.textSize(context)),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${'Date of hire'.tr()} : ',
                          style: TextStyle(
                              color: VetTheme.mainIndigoColor,
                              fontSize: VetTheme.titleTextSize(context),
                              fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            registedate(vet.registeredAt!),
                            style: TextStyle(fontSize: VetTheme.textSize(context),),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        child: ElevatedButton(
                            onPressed: () {
                              UtilityFunction.moveScreen(
                                  context, '/handoverSubmission', vet);
                            },
                            child: Text(
                              '${'대표원장'.tr()}\n${'Authorization'.tr()}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  String registedate(String date) {
    if (date != "") {
      DateTime _last = DateTime.parse(date);
      date = '${_last.year}-${_last.month}-${_last.day}';
    }
    return date;
  }

  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    setLoading(false);
  }
  //유저리스트 가져오기
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
        setLoading(false);
        return;
      }, (success) {
        vet_list = success.vet_list!
            .where((vet) => vet.id.toString() != _profileManager.userData.id && vet.authority!=4)
            .toList();
        setLoading(false);
        return;
      });
    });
  }

  void setLoading(bool isLoding) {
    setState(() {
      _isLoding = isLoding;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
