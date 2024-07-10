import 'package:age_calculator/age_calculator.dart';
import 'package:dolittle_for_vet/screens/ChartMainScreen.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  static const routeName = '/SearchScreen';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ScrollController _scrollController = ScrollController();
  late ProfileManager _profileManager = ProfileManager();
  late ApiService _apiService = ApiService();

  List<Animal> search_list = [];
  TextEditingController search_value = TextEditingController();
  String keyword = "";
  int _page = 1;
  final _limit = 15;
  bool _isLoding = false;
  bool isEndData = false;
  bool isFetchingData = false;

  @override
  void initState() {
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    _scrollController.addListener(() {
      scrollListener();
    });
    super.initState();
  }

  void scrollListener() async {
    if (isFetchingData == false &&
        isEndData == false &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent - 80 &&
        !_scrollController.position.outOfRange) {
      isFetchingData = true;
      _page++;
      UtilityFunction.log.e(keyword);
      await searchApiRequest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return homeContent();
    // return Consumer<ProfileManager>(
    //   builder: (context,user,child) {
    //     _profileManager =user;
    //     return homeContent();
    //   }
    // );
  }

  Widget homeContent() {
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
        backgroundColor: VetTheme.mainIndigoColor,
        elevation: 1,
        title: TextField(
          decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: const TextStyle(color: Colors.white),
              hintText: "Please enter name or chart number".tr(),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: IconButton(
                  onPressed: () => search_value.clear(),
                  icon:
                      const Icon(Icons.clear, size: 30, color: Colors.white))),
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: Colors.white),
          controller: search_value,
          textAlign: TextAlign.start,
          onSubmitted: (value) {
            keyword = value;
            _isLoding = false;
            isEndData = false;
            search_value.clear();
            search_list.clear();
            if (_profileManager.userData.authority != 0) {
              searchResult();
            }
          },
        ),
      ),
      body: _isLoding ? const LoadingBar() : buildBody(),
    );
  }

  Widget buildBody() {
    return search_list.isEmpty
        ? Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets_outlined,
                  color: Colors.grey,
                  size: VetTheme.mediaHalfSize(context),
                ),
                Text(
                  'No animals found'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: search_list.length,
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onTap: () async {
                          final authority = _profileManager.userData.authority;
                          if (authority == 4) {
                            UtilityComponents.showToast(
                                'You cannot access the page with your permission level'
                                    .tr());
                            return;
                          }
                          if (authority == 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChartPageScreen(
                                        animal: search_list[index],
                                      )),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChartPageScreen(
                                    animal: search_list[index])),
                          );
                        },
                        child: AnimalCard(animal: search_list[index]),
                      );
                    }),
              ),
            ],
          );
  }

  Future<void> dialogResult(var result, Animal animal) async {
    UtilityFunction.log.e(animal);
    // UtilityFunction.log.e(result);
    final type = result['type'];
    final fun = result['fun'];
    final screen = result['screen'];
    if (type == 'move') {
      if (screen == '/graph') {
        UtilityFunction.log.e('그래프로 가기');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChartPageScreen(animal: animal)),
        );
      } else if (screen == '/changeQr' || screen == '/attachQr') {
        UtilityFunction.log.e('큐알 업데이트');
        return UtilityFunction.moveScreen(context, '/animalQrScan', animal.id);
      } else if (screen == '/modifyChart') {
        final _animal = animal.toJson();
        _animal['modifyChart'] = true;
        UtilityFunction.log.e(_animal);
        UtilityFunction.log.e(animal.breedCode);
        UtilityFunction.moveScreen(context, '/addWithQrScreen', _animal);
        UtilityFunction.log.e('차트 변경');
        // 차트 변경 로직 추가
      }
    } else if (type == 'fun') {
      if (fun == 'setHidePatient') {
        return await hiddenAnimal(animal.id!);
        //동물숨기기
      }
    }
  }

  void searchResult() {
    keyword.trim().isEmpty
        ? UtilityComponents.showToast(
            "Please enter your name or chart number".tr())
        : searchApiRequest();
    return;
  }

  Future<void> searchApiRequest() async {
    final offset = (_page - 1) * _limit;
    Map<String, String> queryParameters = {
      'hospitalId': _profileManager.userData.hospitalId.toString(),
      'offset': offset.toString(),
      'limit': _limit.toString(),
      'keyword': keyword.trim().toString() ?? "",
    };
    UtilityFunction.log.e(queryParameters);
    await _apiService.getSearchAnimalList2(queryParameters).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? searchApiRequest()
              : logoutAndPushToHome();
        }
        UtilityComponents.showToast(
            "${"Animal inquiry failed".tr()}:${error.message ?? ""}");
        setLoading(false);
      }, (success) {
        search_list.addAll(success.Searchlist as Iterable<Animal>);
        UtilityFunction.log.e(success.Searchlist!.length);
        setLoading(false);
      });
    });
  }

  Future<dynamic> hiddenAnimal(String animalId) async {
    setLoading(true);
    Map<String, dynamic> body = {"isVisible": 'false'};
    await _apiService.updateVisibility2(animalId, body).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? hiddenAnimal(animalId)
              : await logoutAndPushToHome();
        }
        UtilityComponents.showToast(
            "${'Animal hidden failed'.tr()}:${error.message ?? ""}");
        return;
      }, (success) async {
        UtilityComponents.showToast('Animal hidden success'.tr());
        _profileManager.animalListRefresh(true);
        //_profileManager.refreshAnimalList();
        UtilityFunction.goBackToMainPage(context);
      });
    });
    return;
  }

  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    setLoading(false);
  }

  void setLoading(bool isLoding) {
    setState(() {
      _isLoding = isLoding;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}


//----------------------------------------------------------------


// import 'package:age_calculator/age_calculator.dart';
// import 'package:dolittle_for_vet/ApiModel/ResponseEntity.dart';
// import 'package:dolittle_for_vet/Utill.dart';
// import 'package:dolittle_for_vet/screens/ChartMainScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:dolittle_for_vet/ApiUtil.dart';
//
// import 'package:dolittle_for_vet/singleton/Singleton.dart';
// import 'package:easy_localization/easy_localization.dart';
//
// class SearchScreen extends StatefulWidget {
//   const SearchScreen({Key? key}) : super(key: key);
//   static const routeName = '/SearchScreen';
//
//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   final ScrollController _scrollController = ScrollController();
//   List<Animal> search_list = [];
//   TextEditingController search_value = TextEditingController();
//   String keyword = "";
//   bool _isLoding = false;
//   int _page = 1;
//   final _limit = 13;
//   int cntretry = 0;
//
//   @override
//   void initState() {
//     _scrollController.addListener(() {
//       scrollListener();
//     });
//     super.initState();
//   }
//
//   void scrollListener() async {
//     Utill.log_e('serach init state scrollListener');
//     if (_scrollController.offset ==
//             _scrollController.position.maxScrollExtent &&
//         !_scrollController.position.outOfRange) {
//       Utill.log_e('스크롤하단 닿음');
//       _page++;
//       Utill.log_e('페이징 실행${_page}');
//       searchApiRequest();
//     } else if (_scrollController.offset ==
//         _scrollController.position.minScrollExtent) {
//       Utill.log_e('스크롤이 맨 위에 위치해 있습니다');
//     }
//   }
//
//   void setLoading(bool isLoding) {
//     setState(() {
//       _isLoding = isLoding;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // return MaterialApp(
//     //     theme:
//     //         ThemeData(appBarTheme: const AppBarTheme(color: Color(0xffffffff))),
//     //     home: homeContent());
//     return homeContent();
//   }
//
//   Widget homeContent() {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         leading: IconButton(
//           visualDensity: VisualDensity(horizontal: -4, vertical: 4),
//           padding: EdgeInsets.zero,
//           onPressed: () {
//             print('뒤로가기');
//             Navigator.pop(context);
//           },
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: Color(0xf0000000),
//           ),
//         ),
//         title: TextField(
//           decoration: InputDecoration(
//               border: InputBorder.none,
//               hintText: "Please enter your name or chart number".tr(),
//               floatingLabelBehavior: FloatingLabelBehavior.always,
//               suffixIcon: IconButton(
//                   onPressed: () {
//                     search_value.clear();
//                   },
//                   icon: Icon(
//                     Icons.clear,
//                     size: 30,
//                     color: Color(0xf0000000),
//                   ))),
//           textInputAction: TextInputAction.search,
//           controller: search_value,
//           textAlign: TextAlign.start,
//           onSubmitted: (value) {
//             //검색 api에 보내기
//             Utill.log.e('엥엥엥....${value}');
//             searchResult();
//             search_value.clear();
//           },
//         ),
//       ),
//       body: _isLoding ? loadingBar() : buildBody(),
//     );
//   }
//
//   Widget buildBody() {
//     return Container(
//         child: Column(
//       children: [
//         // buildRadioList(),
//         Expanded(
//           child: ListView.builder(
//               controller: _scrollController,
//               itemCount: search_list.length,
//               itemBuilder: (_, index) {
//                 return GestureDetector(
//                   onTap: () {
//                     Utill.log.e('클릭');
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (context) =>
//                             ChartPageScreen(animal: search_list[index])));
//                   },
//                   child: Utill.getAnimalCard(search_list[index]),
//                 );
//               }),
//         ),
//       ],
//     ));
//   }
//
//   Widget buildListView() {
//     return ListView.builder(
//         itemCount: search_list.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               Utill.log.e('클릭');
//             },
//             child: Utill.getAnimalCard(search_list[index])
//           );
//         });
//   }
//
//   Widget loadingBar() {
//     return Container(
//       child: Center(
//         child: SizedBox(
//           child: CircularProgressIndicator(),
//           height: 30.0,
//           width: 30.0,
//         ),
//       ),
//     );
//   }
//
//   void searchResult() async {
//     search_list.clear();
//     setLoading(true);
//     keyword = search_value.text;
//     if (keyword == null || keyword == "") {
//       Utill.showToast('이름 또는 차트번호를 입력해주세요');
//       setLoading(false);
//     } else {
//       _page = 1;
//       Utill.log_e('재 검색실행${_page}');
//       searchApiRequest();
//       // cntretry = 0;
//       // Response response = await searchApiRequest();
//       // print(response);
//       // Utill.log_e(response.body);
//       // setLoading(false);
//       // addSearchList(response.body);
//       // search_list.isEmpty ? Utill.showToast('검색결과 없음') : false;
//     }
//   }
//
//   Future<void> searchApiRequest() async {
//     final offset = (_page - 1) * _limit;
//     Map<String, dynamic> queryParameters = {
//       'hospitalId': await Singleton.getHospitalId(),
//       'offset': offset.toString(),
//       'limit': _limit.toString(),
//       'keyword': keyword,
//     };
//     Utill.log_e(queryParameters.toString());
//     final search_result = await ApiUtil.fetchSearchAnimalList(
//         '${ApiUtil.dolittleVetApiUri('/patients', queryParameters)}', {
//       'authorization': await Singleton.getAccessToken(),
//     });
//     search_result.when((error) async {
//       // await ApiUtil.errorStatusCodeCheck(
//       //         context, error.re_code, '동물검색 실패', error.code)
//       //     ? searchApiRequest()
//       //     : false;
//       /***
//        * 400 일때 메인페이지로
//        * 401-101 일때만 갱신 호출 -> api 재호출
//        * 그외 로그인 페이지로
//        *
//        * */
//
//       if (error.re_code == BadRequestCode) {
//         Utill.showToast('동물검색 실패');
//         //return Utill.showToast('동물검색 실패');
//       } else if (error.re_code == 401 && error.code == 101) {
//         return await ApiUtil.refreshToken()
//             ? searchApiRequest()
//             : Utill.moveScreenAndRemovePages(context, '/loginScreen');
//       } else {
//         return Utill.moveScreenAndRemovePages(context, '/loginScreen');
//       }
//       return setLoading(false);
//     }, (objet) {
//       Utill.log_e('message');
//       Utill.log.e('동물목록 불러오기 성공');
//       var re = objet.Searchlist;
//       search_list.addAll(re!);
//       setLoading(false);
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
// }
