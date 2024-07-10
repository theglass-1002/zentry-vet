import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'animal_card.dart';
import 'package:dolittle_for_vet/screens/ChartMainScreen.dart';
import 'package:flutter/material.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/screens/screens.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class MainAnimalList extends StatefulWidget {
  final List<Animal>? animalList;
  const MainAnimalList({
    super.key,
    this.animalList,
  });

  @override
  State<MainAnimalList> createState() => _MainAnimalListState();
}

enum AnimalType { A, B, C, D }

class _MainAnimalListState extends State<MainAnimalList> {
  final ScrollController _scrollController = ScrollController();
  late ProfileManager _profileManager = ProfileManager();
  late final ApiService _apiService = ApiService();
  late List<Animal>? _animalList = widget.animalList;
  AnimalType _animalType = AnimalType.A;
  int _page = 1;
  int _offset = 0;
  final _limit = 15;
  bool isEndData = false;
  bool isFetchingData = false;
  bool _isLoading = false;

  @override
  void initState() {
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    _scrollController.addListener(() {
      scrollListener();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void scrollListener() async {
    if (isFetchingData == false &&
        isEndData == false &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent - 80 &&
        !_scrollController.position.outOfRange) {
      isFetchingData = true;
      _page++;
      _offset = (_page - 1) * _limit;
      Map<String, dynamic> queryParameters = {
        'hospitalId': _profileManager.userData.hospitalId,
        'offset': _offset.toString(),
        'limit': '15',
        'isVisible': 'true',
      };
      UtilityFunction.log.e('하단닿음');
      _animalType == AnimalType.B
          ? queryParameters['animalType'] = '0'
          : _animalType == AnimalType.C
          ? queryParameters['animalType'] = '1'
          : null;
      await addAnimalList(queryParameters);
    }
  }

  @override
  Widget build(BuildContext context) {
     return Column(
       children: [
         _profileManager.hospitalData.name!=null?Container(
             padding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
             child: Text('${_profileManager.hospitalData.name}',style: TextStyle(
                 fontWeight: FontWeight.bold,fontSize: VetTheme.titleTextSize(context)
             ),)):Container(),
         Row(
           children: [
             Expanded(child: TextField()),
             IconButton(onPressed: (){}, icon: Icon(Icons.clear,color: Colors.black,))
           ],
         )

         ],
     );
  }

  Widget buildAnimalList() {
    return _animalList!.isEmpty
        ? Expanded(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            //  buildRadioList(),
            Icon(
              Icons.pets_outlined,
              color: Colors.grey,
              size: VetTheme.mediaHalfSize(context),
            ),
            Text(
              'NoAnimals'.tr(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    ) : Expanded(
      child: Container(
        child: Column(
          children: [
            // buildRadioList(),
            Expanded(
              child: Container(
                child: Scrollbar(
                  controller: _scrollController,
                  thickness: 4,
                  radius: Radius.circular(8),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _animalList!.length,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      final animal = _animalList![index];
                      return GestureDetector(
                          onTap: () async {
                            final authority = _profileManager.userData.authority;
                            if (authority == 4) {
                              UtilityComponents.showToast('You cannot access the page with your permission level'.tr());
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChartPageScreen(
                                  animal:_animalList![index]
                              )),
                            );
                            return;
                          },
                          child: AnimalCard(animal: animal));
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Widget buildAnimalList() {
  //   return _animalList!.isEmpty
  //       ? Expanded(
  //         child: SizedBox(
  //           width: double.infinity,
  //           child: Column(
  //             children: [
  //             //  buildRadioList(),
  //               Icon(
  //                 Icons.pets_outlined,
  //                 color: Colors.grey,
  //                 size: VetTheme.mediaHalfSize(context),
  //               ),
  //               Text(
  //                 'NoAnimals'.tr(),
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       ) : Expanded(
  //     child: Container(
  //       child: Column(
  //         children: [
  //          // buildRadioList(),
  //           Expanded(
  //             child: Container(
  //               child: Scrollbar(
  //                 controller: _scrollController,
  //                 thickness: 4,
  //                 radius: Radius.circular(8),
  //                 child: ListView.builder(
  //                   shrinkWrap: true,
  //                   itemCount: _animalList!.length,
  //                   controller: _scrollController,
  //                   itemBuilder: (context, index) {
  //                     final animal = _animalList![index];
  //                     return GestureDetector(
  //                         onTap: () async {
  //                           final authority = _profileManager.userData.authority;
  //                           if (authority == 4) {
  //                             UtilityComponents.showToast('You cannot access the page with your permission level'.tr());
  //                             return;
  //                           }
  //                           Navigator.push(
  //                             context,
  //                             MaterialPageRoute(builder: (context) => ChartPageScreen(
  //                                 animal:_animalList![index]
  //                             )),
  //                           );
  //                           return;
  //                         },
  //                         child: AnimalCard(animal: animal));
  //                   },
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }



  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    setLoading(false);
  }



  Future<void> addAnimalList([Map<String, dynamic>? queryParameters]) async {
    await _apiService.getAnimalList2(queryParameters).then((animalListValue) {
      animalListValue.when((error) async {
        if(error.re_code == UnauthorizedCode &&error.code == 101){
          final refreshToken = await _apiService.refreshToken();
          if(refreshToken){
            return await addAnimalList(queryParameters);
          }
          return await logoutAndPushToHome();
        }
        UtilityFunction.log.e(error.message);
        UtilityComponents.showToast(
            "${"error".tr()}:${error.message ?? ""}");
        return await logoutAndPushToHome();
      },(success){

        if(success.animal_list!.isNotEmpty){
          setState(() {
            isFetchingData =false;
            isEndData = false;
            _animalList?.addAll(success.animal_list as Iterable<Animal>);
          });
        }
      });
    });
  }



  Future<void> getAnimalList() async {
    Map<String, dynamic> queryParameters = {
      'hospitalId': _profileManager.userData.hospitalId,
      'offset': '0',
      'limit': '15',
      'isVisible': 'true',
    };
    _animalType == AnimalType.B
        ? queryParameters['animalType'] = '0'
        : _animalType == AnimalType.C
        ? queryParameters['animalType'] = '1'
        : null;

    UtilityFunction.log.e(queryParameters.toString());
    await _apiService.getAnimalList2(queryParameters).then((animalListValue) {
      animalListValue.when((error) async {
        if(error.re_code == UnauthorizedCode &&error.code == 101){
          final refreshToken = await _apiService.refreshToken();
          if(refreshToken){
            return await getAnimalList();
          }
          return await logoutAndPushToHome();
        }
        UtilityFunction.log.e(error.message);
        UtilityComponents.showToast(
            "${"error".tr()}:${error.message ?? ""}");
        return await logoutAndPushToHome();
      },(success){
        setState(() {
          isFetchingData =false;
          isEndData = false;
          _profileManager.setAnimalData2(success);
          _animalList = success.animal_list;
          if(_scrollController.hasClients){
            _scrollController.jumpTo(_scrollController.position.minScrollExtent);
          }
        });
      });
    });
  }


  void setLoading(bool isLoading) {
    if(mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }

}


