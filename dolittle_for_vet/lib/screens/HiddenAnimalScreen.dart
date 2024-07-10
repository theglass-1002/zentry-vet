import 'package:age_calculator/age_calculator.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:provider/provider.dart';

class HiddenAnimalScreen extends StatefulWidget {
  const HiddenAnimalScreen({Key? key}) : super(key: key);
  static const routeName = '/HiddenAnimalScreen';
  @override
  State<HiddenAnimalScreen> createState() => _HiddenAnimalScreenState();
}

class _HiddenAnimalScreenState extends State<HiddenAnimalScreen> {
  ProfileManager _profileManager = ProfileManager();
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  late List<Animal> list = [];
  bool _isLoding = true;
  int _page = 1;
  final _limit = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      scrollListener();
    });
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    getAnimalList();
  }

  void scrollListener() async {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 80 &&
        !_scrollController.position.outOfRange) {
      _page++;
      await getAnimalList();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return homeContent();
    // return _isLoding?const LoadingBar():homeContent();
  }

  Widget homeContent() {
    return Scaffold(
        appBar: AppBar(elevation: 1, title: Text("Hidden animal".tr())),
        body: body());
  }

  Widget body() {
    return _isLoding ? const LoadingBar() : buildListView();
  }

  Widget buildListView() {
    return Stack(
      children: [
        list.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.pets_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    Text(
                      'NoHiddenAnimals'.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                controller: _scrollController,
                itemCount: list.length,
                itemBuilder: (_, index) {
                  return GestureDetector(
                      onTap: () async {
                        if (list[index].id != null) {
                          var value = await showEditDeleteDialog(list[index]);
                          setLoading(true);
                          if (value == null) {
                            return setLoading(false);
                          }
                          if (value == 'popupReturnVisible') {
                            return await hiddenAnimal(list[index].id!);
                            UtilityFunction.log.e('동물숨김');
                          } else if (value == 'popupReturnDelete') {
                            return await deleteAnimalApi(list[index].id!);
                          }
                        }
                        // String? animalId = list[index].id;
                        // if (animalId != null) {
                        //
                        //   // [동물 삭제 및 보임 처리]
                        //   showEditDeleteDialog().then((value) => {
                        //     if( value == popupReturnDelete) {
                        //       deleteAnimal(animalId).then((isSuccess) => {
                        //         if (isSuccess) {
                        //           getAnimalList(isInitList:true) //리스트 재조회
                        //         }
                        //       })
                        //
                        //     }else if( value == popupReturnVisible) {
                        //       visiblenAnimal(animalId).then((isSuccess) => {
                        //         if (isSuccess) {
                        //           getAnimalList(isInitList:true) //리스트 재조회
                        //         }
                        //       })
                        //     }
                        //   });
                        //
                        // }
                      },
                      child: AnimalCard(animal: list[index]));
                }),
      ],
    );
  }

  void setLoading(bool isLoding) {
    setState(() {
      _isLoding = isLoding;
    });
  }

  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    setLoading(false);
  }

  Future<dynamic> hiddenAnimal(String animalId) async {
    Map<String, dynamic> body = {"isVisible": 'true'};
    await _apiService.updateVisibility2(animalId, body).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _profileManager.getRefreshToken()
              ? hiddenAnimal(animalId)
              : logoutAndPushToHome();
        }
        UtilityComponents.showToast(
            "${'Animal hidden failed'.tr()}:${error.message ?? ""}");
        setLoading(false);
      }, (success) async {
        UtilityComponents.showToast('Animal Unhid'.tr());
        return await getAnimalList();
      });
    });
    //  return result;
  }

  Future<void> deleteAnimalApi(String animalId) async {
    await _apiService.deleteAnimal2(animalId).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? getAnimalList()
              : logoutAndPushToHome();
        }
        UtilityComponents.showToast(
            "${"Animal delete failed".tr()}:${error.message ?? ""}");
        setLoading(false);
        return;
      }, (success) async {
        UtilityComponents.showToast("Animal delete Success".tr());
        return await getAnimalList();
      });
    });
  }

  Future<void> getAnimalList() async {
    final offset = (_page - 1) * _limit;
    Map<String, dynamic> queryParameters = {
      'hospitalId': _profileManager.userData.hospitalId,
      'offset': offset.toString(),
      'limit': _limit.toString(),
      'isVisible': 'false',
    };
    await _apiService.getAnimalList2(queryParameters).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? getAnimalList()
              : logoutAndPushToHome();
        }
        UtilityComponents.showToast(
            "${"Animal inquiry failed".tr()}:${error.message ?? ""}");
        UtilityFunction.goBackToPreviousPage(context);
        setLoading(false);
      }, (success) {
        if (_page == 1) {
          list = success.animal_list!;
        } else {
          list.addAll(success.animal_list!);
        }
        setLoading(false);
        return;
      });
    });
  }

  Future<dynamic> showEditDeleteDialog(Animal animal) {
    return showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              title: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    Text(
                      "EditAnimalInfo".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: VetTheme.logotextSize(context)),
                    ),
                    const Padding(padding: EdgeInsets.all(10)),
                    Expanded(
                        child: Text(
                      "Chart Number : ${animal.chart_number!}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: VetTheme.titleTextSize(context)),
                    )),
                    Expanded(
                        child: Text(
                      "Pet Name : ${animal.name!}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: VetTheme.titleTextSize(context)),
                     )),
                  ],
                ),
              ),
              content: Container(
                height: 100,
                width: double.minPositive,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                          onPressed: () {
                            setLoading(true);
                            Navigator.of(context).pop('popupReturnVisible');
                          },
                          child: Text("Show animals".tr())),
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () {
                            setLoading(true);
                            Navigator.of(context).pop('popupReturnDelete');
                          },
                          child: Text("Delete animal_Btn".tr())),
                    ),
                  ],
                ),
              ));
        });
  }

  // Future<bool> visiblenAnimal(String animalId) async {
  //
  //   setFetchLoading(true);
  //
  //   final result = await ApiUtil.fetchHiddenAnimal(
  //     '${ApiUtil.baseUrl}${ApiUtil.ver}/patients/$animalId/visibility',
  //     {'isVisible': "true",},
  //     {'authorization': await Singleton.getAccessToken(),}
  //   );
  //
  //   result.when((exception) {
  //     Utill.showToast("Animal show failed".tr());
  //   }, (resultString) {
  //     Utill.log.e('!@# 동물 보이기 성공: $resultString');
  //   });
  //
  //   setFetchLoading(false);
  //
  //   return result.isSuccess();
  // }
  //
  //   Future<bool> deleteAnimal(String animalId) async {
  //   setFetchLoading(true);
  //
  //   final result = await ApiUtil.fetchDeleteAnimal(
  //     '${ApiUtil.baseUrl}${ApiUtil.ver}/patients/$animalId', {
  //     'authorization': await Singleton.getAccessToken(),
  //   });
  //   result.when((exception) {
  //     Utill.showToast("Animal deletion failed".tr());
  //   }, (resultString) {
  //     Utill.log.e('!@# 동물 삭제 성공: $resultString');
  //   });
  //
  //   setFetchLoading(false);
  //
  //   return result.isSuccess();
  // }

  @override
  void dispose() {
    super.dispose();
  }
}
