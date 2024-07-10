import 'dart:io';
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:provider/provider.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

import 'ChartMainScreen.dart';




class HeartFailureScreen extends StatefulWidget {
  const HeartFailureScreen({super.key});

  @override
  State<HeartFailureScreen> createState() => _HeartFailureScreenState();
}

class _HeartFailureScreenState extends State<HeartFailureScreen> {
  late ProfileManager _profileManager = ProfileManager();
  SocketManager _socketManager = SocketManager();
  late final ApiService _apiService = ApiService();
  late List<String> filterList = ['Reg. Date', 'Name', 'Meas. Date', 'Chart Number'];
  String dropdownValue ='Reg. Date';
  bool _isDesc =true;
  bool _isLoading = true;
  List<Animal> animalList = [];
  //---------------
  final ScrollController _scrollController = ScrollController();
  TextEditingController search_value = TextEditingController();
  Map<String, dynamic> queryParameters = {
    'sort':'createdAt',
    'keyword':'',
    'sortOrder':'DESC',
    'isVisible': 'true',
  };
  int _page = 1;
  int _offset = 0;
  int _limit = 15;
  bool isEndData = false;
  bool isFetchingData = false;



  @override
  void initState() {
    // TODO: implement initState
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    _socketManager =  Provider.of<SocketManager>(context, listen: false);
    queryParameters['hospitalId']=_profileManager.userData.hospitalId;
    getAnimalList();
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
      isEndData = true;
      _page++;
      _offset = (_page - 1) * _limit;
      queryParameters['hospitalId']=_profileManager.userData.hospitalId;
      queryParameters['offset']=_offset.toString();
     await addAnimalList(queryParameters);
     }
  }


  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    final input = Message2101(msgSize: 21, msgId: 2101, reId: 1, hospitalId: int.parse(_profileManager.userData.hospitalId!), vetId: int.parse(_profileManager.userData.id!), isReceivedData: false);
    await sendMsg(input);
    final inputV2 = Message2101(msgSize: 21, msgId: 4101, reId: 1, hospitalId: int.parse(_profileManager.userData.hospitalId!), vetId: int.parse(_profileManager.userData.id!), isReceivedData: false);
    await _socketManager.sendMsg(inputV2.toByteArray());
    super.didChangeDependencies();
  }

  Future<void> sendMsg(var input) async {
    if (_socketManager.socket is Socket) {
      final bytes = input.toByteArray();
      await _socketManager.sendMsg(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  Widget buildBody() {
    String local = EasyLocalization.of(context)!.locale.toString();
    String today = DateFormat('yMMMd', local).format(DateTime.now());
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: VetTheme.mainIndigoColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ImageIcon(AssetImage('assets/icon_vet.png'), size: 50),
                Text(today,style: const TextStyle(color: Colors.white),),
                Row(
                  children: [
                    IconButton(
                        iconSize: 40,
                        onPressed: () {
                          UtilityFunction.moveScreen(context, '/notify');
                        },
                        icon: const Icon(Icons.notifications)),

                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              _profileManager.hospitalData.name!=null?Container(
                  margin: EdgeInsets.only(left: VetTheme.textSize(context)),
                  child: Text('${_profileManager.hospitalData.name}',style: TextStyle(
                      fontWeight: FontWeight.bold,fontSize: VetTheme.titleTextSize(context)
                  ),)):Container(),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: (){
                  getAnimalList();
                }, icon: Icon(Icons.refresh),color: Colors.black,),
            ],
          ),
          _isLoading?LoadingBar():animalSearchFilterListWidget()
        ]);}

  Widget animalSearchBarWidget(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: VetTheme.textSize(context)),
      child: Row(
        children: [
          Expanded(child: TextField(
            textInputAction: TextInputAction.search,
            controller: search_value,
            decoration: InputDecoration(
                hintText: "Please enter your name or chart number".tr(),
                suffixIcon: IconButton(
                    onPressed: () => {
                      if(search_value.value.text.toString().trim().isNotEmpty){
                        getAnimalList()
                      }else{
                        search_value.clear(),
                      }
                    },
                    icon:
                    const Icon(Icons.clear, size: 30, color: Colors.black))
            ),
            onSubmitted: (value){
              if(value.toString().trim().isEmpty){
                UtilityComponents.showToast('The input field is empty'.tr());
              }else{
                getAnimalListBySearch(value.trim());
              }
            },
          )),
        ],
      ),
    );
  }
  Widget animalListFilterWidget(){
    return Container(
     // color: Colors.pink,
      margin: EdgeInsets.symmetric(horizontal: VetTheme.textSize(context)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
              //  color: Colors.blue,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.black12,
                  width: 1.5
                )
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  customButton:Container(
                    padding: EdgeInsets.symmetric(horizontal: VetTheme.textSize(context)),
                    child: Row(

                      children: [
                        Container(
                          padding: EdgeInsets.only(right: VetTheme.textSize(context)),
                          child: Icon(
                              Icons.list,
                              size: VetTheme.smallIconSize(context),
                              color: VetTheme.hintColor
                          ),
                        ),
                        Text('${'Sort by'.tr()} ${dropdownValue.tr()}',style: TextStyle(
                          fontSize: VetTheme.textSize(context)
                        ),)
                      ],
                    ),
                  ) ,
                  items: filterList.map((String item) => DropdownMenuItem<String>(
                      value: item.tr(),
                      child: Text(
                        item.tr(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: VetTheme.textSize(context)),))).toList(),
                  onChanged: (String? value) {
                    getAnimalListBySort(value!);
                  },
                  dropdownStyleData: DropdownStyleData(
                    padding: EdgeInsets.symmetric(horizontal: VetTheme.textSize(context)),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: Colors.white,
                        )
                    )
                  ),
                ),
              ),
            ),
          ),
          
          IconButton(
            padding: EdgeInsets.all(VetTheme.textSize(context)),
            onPressed: (){
            getAnimalListBySortOrder();
          },
            icon: Icon(_isDesc?Icons.arrow_downward_outlined:Icons.arrow_upward_outlined,
              color: VetTheme.hintColor,
              weight: VetTheme.logotextSize(context),

            ),
          )]
      ),
    );
  }


  Widget animalListViewWidget(){
    return  Expanded(child: buildAnimalList());
  }

  Widget animalSearchFilterListWidget(){
    return Consumer<ProfileManager>(
        builder: (context, profileManager, child) {
          if(profileManager.isReload){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              profileManager.animalListRefresh(false);
            });
            return FutureBuilder<dynamic>(
                future: getAnimalList(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return const LoadingBar();
                }
            );
          }else{
             return Expanded(
                child: Column(
                  children: [
                    animalSearchBarWidget(),
                    animalListFilterWidget(),
                    animalListViewWidget(),
                  ],
                )
              );
          }
        }
    );
  }






  Widget buildAnimalList(){
     return ListView.builder(
      controller: _scrollController,
      itemCount: animalList.length, // 리스트의 항목 개수를 설정합니다.
      itemBuilder: (context, index) {
        final _animal = animalList[index];
        return GestureDetector(
            onTap: (){
              final authority = _profileManager.userData.authority;
              if (authority == 4) {
                UtilityComponents.showToast('You cannot access the page with your permission level'.tr());
                return;
              }else{
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChartPageScreen(
                      animal:_animal
                  )),
                );
                return;
              }
            },
            child: AnimalCard(animal: animalList[index]));
      });
  }


  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
  }

  Future<void> getAnimalList() async {
    queryParameters['hospitalId']=_profileManager.userData.hospitalId;
    queryParameters['sort']='createdAt';
    queryParameters['sortOrder']='DESC';
    queryParameters['keyword']='';
    queryParameters['offset']='0';
    queryParameters['limit']='15';
    final animalListValue = await _apiService.getAnimalList3(queryParameters);
    return animalListValue.when((error) async {
      if(error.re_code == UnauthorizedCode &&error.code == 101){
        final refreshToken = await _apiService.refreshToken();
        if(refreshToken){
          return await getAnimalList();
        }
        await logoutAndPushToHome();
      }
      UtilityFunction.log.e(error.message);
      UtilityComponents.showToast(
          "${"error".tr()}:${error.message ?? ""}");
      await logoutAndPushToHome();
    },(success){
      setState(() {
         search_value.clear();
        _page = 1;
        _offset = 0;
        isEndData = false;
        isFetchingData = false;
        _isDesc =true;
        dropdownValue = filterList[0];
        animalList = success.animal_list??[];
        UtilityComponents.scrollToTop(_scrollController);
         _isLoading = false;
      });
    });

  }

  Future<void> getAnimalListBySort(String sort) async {
    UtilityFunction.log.e(sort);
    queryParameters['sort']=getSort(sort);
    queryParameters['hospitalId']=_profileManager.userData.hospitalId;
    queryParameters['offset']='0';
    queryParameters['limit']='15';
    UtilityFunction.log.e(queryParameters.toString());
    final animalListValue = await _apiService.getAnimalList3(queryParameters);
    return animalListValue.when((error) async {
      if(error.re_code == UnauthorizedCode &&error.code == 101){
        final refreshToken = await _apiService.refreshToken();
        if(refreshToken){
          return await getAnimalListBySort(sort);
        }
        await logoutAndPushToHome();
      }
      UtilityFunction.log.e(error.message);
      UtilityComponents.showToast(
          "${"error".tr()}:${error.message ?? ""}");
      await logoutAndPushToHome();
    },(success){
      setState(() {
        _page = 1;
        _offset = 0;
        isEndData = false;
        isFetchingData = false;
        dropdownValue = sort;
        animalList = success.animal_list??[];
        UtilityComponents.scrollToTop(_scrollController);
      });
    });

  }

  Future<void> getAnimalListBySortOrder() async {
    _isDesc = !_isDesc;
    queryParameters['sortOrder']=_isDesc?'DESC':'ASC';
    queryParameters['hospitalId']=_profileManager.userData.hospitalId;
    queryParameters['offset']='0';
    queryParameters['limit']='15';
    final animalListValue = await _apiService.getAnimalList3(queryParameters);
    return animalListValue.when((error) async {
      if(error.re_code == UnauthorizedCode &&error.code == 101){
        final refreshToken = await _apiService.refreshToken();
        if(refreshToken){
          return await getAnimalListBySortOrder();
        }
        await logoutAndPushToHome();
      }
      UtilityFunction.log.e(error.message);
      UtilityComponents.showToast(
          "${"error".tr()}:${error.message ?? ""}");
      await logoutAndPushToHome();
    },(success){
      setState(() {
        _page = 1;
        _offset = 0;
        isEndData = false;
        isFetchingData = false;
        animalList = success.animal_list??[];

        UtilityComponents.scrollToTop(_scrollController);
      });
    });

  }

  Future<void> getAnimalListBySearch(String value) async {
    queryParameters['hospitalId']=_profileManager.userData.hospitalId;
    queryParameters['keyword']=value;
    queryParameters['offset']='0';
    queryParameters['limit']='15';
    UtilityFunction.log.e(queryParameters.toString());
    final animalListValue = await _apiService.getAnimalList3(queryParameters);
    return animalListValue.when((error) async {
      if(error.re_code == UnauthorizedCode &&error.code == 101){
        final refreshToken = await _apiService.refreshToken();
        if(refreshToken){
          return await getAnimalListBySearch(value);
        }
        await logoutAndPushToHome();
      }
      UtilityFunction.log.e(error.message);
      UtilityComponents.showToast(
          "${"error".tr()}:${error.message ?? ""}");
      await logoutAndPushToHome();
    },(success){
      setState(() {
        _page = 1;
        _offset = 0;
        isEndData = false;
        isFetchingData = false;
        animalList = success.animal_list??[];
        UtilityComponents.scrollToTop(_scrollController);
      });
    });

  }

  Future<void> addAnimalList(var queryParameters) async {
    final animalListValue = await _apiService.getAnimalList3(queryParameters);
    return animalListValue.when((error) async {
      if(error.re_code == UnauthorizedCode &&error.code == 101){
        final refreshToken = await _apiService.refreshToken();
        if(refreshToken){
          return await addAnimalList(queryParameters);
        }
        await logoutAndPushToHome();
      }
      UtilityFunction.log.e(error.message);
      UtilityComponents.showToast(
          "${"error".tr()}:${error.message ?? ""}");
      await logoutAndPushToHome();
    }, (success) {
      UtilityFunction.log.e(queryParameters.toString());
      if(success.animal_list!.isEmpty){
      }else{
        setState(() {
          isEndData = false;
          isFetchingData = false;
          animalList.addAll(success.animal_list as Iterable<Animal>);
        });
      }
    });
  }





  void setLoading(bool isLoading) {
    if(mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }}

  String getSort(String sortType) {
   String sort = 'createdAt';
    if (sortType.contains('Reg')||sortType.contains('등록')||sortType.contains('registro')) {
      sort = 'createdAt';
    } else if (sortType.contains('Name')||sortType.contains('이름')||sortType.contains('Nombre')) {
      sort = 'name';
  } else if (sortType.contains('Meas')||sortType.contains('측정')||sortType.contains('medición')) {
      sort = 'updatedAt';
  } else if(sortType.contains('Chart')||sortType.contains('차트')||sortType.contains('Cuadro')) {
      sort = 'chartNumber';
  }
    return sort;
}


