import 'dart:convert';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dropdown_button2/dropdown_button2.dart' as drop2;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:provider/provider.dart';

class AnimalDataModifyScreen extends StatefulWidget {
  const AnimalDataModifyScreen({Key? key}) : super(key: key);
  State<AnimalDataModifyScreen> createState() => _AnimalDataModifyScreenState();
}

final List<String> modifySpeciesItems = [
  'Dog',
  'Cat',
];

final List<String> modifySexItems = [
  'Female',
  'Female(neutered)',
  'Male',
  'Male(neutered)',
];



List<DropdownMenuItem<String>> _addDividersAfterItems(List<String> items) {
  List<DropdownMenuItem<String>> menuItems = [];
  for (var item in items) {
    menuItems.addAll(
      [
        DropdownMenuItem<String>(
          value: item,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                item,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        //If it's last item, we will not add Divider after it.
        if (item != items.last)
          const DropdownMenuItem<String>(
            enabled: false,
            child: Divider(thickness: 1, color: Color(0xff2e3d80)),
          ),
      ],
    );
  }
  return menuItems;
}

List<double> _getCustomItemsHeights(var items) {
  List<double> itemsHeights = [];
  for (var i = 0; i < (items.length * 2) - 1; i++) {
    if (i.isEven) {
      itemsHeights.add(40);
    }
    //Dividers indexes will be the odd indexes
    if (i.isOdd) {
      itemsHeights.add(4);
    }
  }
  return itemsHeights;
}

class _AnimalDataModifyScreenState extends State<AnimalDataModifyScreen> {
  ProfileManager _profileManager = ProfileManager();
  ApiService _apiService = ApiService();
  List<dynamic> _breedList = [];
  Map<dynamic, dynamic> _animalData = {};
  var breedInfo = {};
  String _userLanguage = 'en';
  String modifyselectedSexValue = "";
  String modifyselectedSpeciesValue = "";
  bool _isBreedInput = false;
  bool _isLoading = true;
  String breedName = 'Select the breed'.tr();
  String birth = 'Select date of birth'.tr();
  TextEditingController chartNum = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController inputBreed = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if(_animalData.isEmpty){
      await checkBreedsDate();
      _userLanguage = await _profileManager.getUserTranslation();
      _animalData = Map<dynamic, dynamic>.from(ModalRoute.of(context)!.settings.arguments as Map);
      chartNum.text = _animalData['chart_no'];
      name.text = _animalData['name'];
      birth = _animalData['birth'];
      modifyselectedSpeciesValue = _animalData['animal_type'] == 0 ? 'Dog' : 'Cat';
      var index = _breedList.indexWhere(
            (element) => element['code'] == int.parse(_animalData['breedCode']),
      );
      breedInfo = _breedList[index];
      breedName = _animalData['breed'];
      modifyselectedSexValue = _animalData['gender'].toString();
      UtilityFunction.log.e(_animalData.toString());
    }
    setLoading(false);
  }



  void onDropdownChanged(int? state,String? value) {
    setState(() {
      if(state==0){
        modifyselectedSpeciesValue = value!;
      }else{
        modifyselectedSexValue = value!;
        UtilityFunction.log.e(modifyselectedSexValue.toString());
      }
    });

  }



  @override
  Widget build(BuildContext context) {
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
                title: Text('Modify Chart'.tr())),
            body:  _isLoading
                ? Container(color: Colors.white, child: const LoadingBar())
                :Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 30, 0, 10),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: buildTitle('Chart_No')),
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: 250,
                            height: 50,
                            child: buildInput('Enter chart number.', chartNum),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: buildTitle('Name')),
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: 250,
                            height: 50,
                            child: buildInput('Enter patient’s name', name),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: buildTitle('Species')),
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: 250,
                            height: 50,
                            child: Listener(
                              behavior: HitTestBehavior.opaque,
                              onPointerDown: (_) {
                                setState(() {
                                  breedName = 'Select the breed'.tr();
                                  breedInfo = {};
                                });
                              },
                              child: DropDownBtn(
                                  state: 0,
                                  hint: modifySpeciesItems[
                                      (_animalData['animal_type'])],
                                  modifySelectedValue:
                                      modifyselectedSpeciesValue,
                                  onChanged: onDropdownChanged,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: buildTitle('Breed')),
                        Expanded(flex: 3, child: buildBreed())
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: buildTitle('Sex')),
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: 250,
                            height: 50,
                            child: DropDownBtn(
                                state: 1,
                                hint: modifySexItems[(_animalData['gender'])],
                                modifySelectedValue: modifyselectedSexValue,
                                onChanged: onDropdownChanged,
                            ),
                            // child: DropdownButton('Select the sex.',1,selectedSexValue),
                            // child: DropdownButton('Select the sex.', 1 ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: buildTitle('Date of birth')),
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: 250,
                            height: 50,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xff9e9e9e)),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextButton(
                                onPressed: () async {
                                  var nowDate = DateTime.now();
                                  String local = EasyLocalization.of(context)!
                                      .locale
                                      .toString();
                                  var birthDate =
                                      await UtilityComponents.dialogDate(
                                          context,
                                          local,
                                          'Date of birth',
                                          nowDate);
                                  // UtilityFunction.log.e(birthDate);
                                  // UtilityFunction.log.e(birthDate.toString().trim().isNotEmpty);
                                  if (birthDate != null &&
                                      birthDate.toString().trim().isNotEmpty) {
                                    setState(() {
                                      birth = DateFormat('yyyy-MM-dd', local)
                                          .format(birthDate);
                                    });
                                  }
                                  return;
                                },
                                child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      birth,
                                      style: const TextStyle(
                                          color: Colors.black45),
                                    ))),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: buildBottom(),
          );
  }

  Widget buildBreed() {
    return _isBreedInput
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: 250,
            height: 50,
            child: TextField(
              style: const TextStyle(fontSize: 15),
              controller: inputBreed,
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff9e9e9e))),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(width: 2, color: VetTheme.mainIndigoColor)),
                hintText: 'Enter patient’s breed'.tr(),
                hintStyle: const TextStyle(color: Color(0xff9e9e9e)),
                suffixIcon: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      breedName = 'Select the breed'.tr();
                      breedInfo = {};
                      _isBreedInput = false;
                    });
                  },
                  icon: const Icon(CupertinoIcons.pencil),
                  color: VetTheme.mainIndigoColor,
                ),
                isDense: true,
              ),
            ),
          )
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff9e9e9e)),
              borderRadius: BorderRadius.circular(5),
            ),
            width: 250,
            height: 50,
            padding: EdgeInsets.zero,
            child: TextButton(
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        breedName,
                        style: const TextStyle(color: Colors.black45),
                      ),
                    ),
                    IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            inputBreed.clear();
                            _isBreedInput = true;
                          });
                        },
                        icon: Icon(
                          CupertinoIcons.pencil,
                          color: VetTheme.hintColor,
                        ))
                  ],
                ),
              ),
              onPressed: () async {
               // UtilityFunction.log.e(modifyselectedSpeciesValue.toString());
                UtilityFunction.log.e('클릭');
                if (_breedList.isEmpty) {
                  return await checkBreedsDate();
                }
                if (modifyselectedSpeciesValue.toString().isEmpty) {
                  return UtilityComponents.showToast(
                      'Please select the species'.tr());
                } else {
                  //UtilityFunction.log.e('breed list dialog 띄우기');
                  var list = modifyselectedSpeciesValue.toString() == 'Cat'
                      ? _breedList
                          .where((element) => element['code'] >= 20000)
                          .toList()
                      : _breedList
                          .where((element) => element['code'] < 20000)
                          .toList();
                  var getBreedInfo = await UtilityComponents.breedListDialog(
                      context,
                      modifyselectedSpeciesValue.toString(),
                      list,
                      _userLanguage);
                 // UtilityFunction.log.e(getBreedInfo.toString());
                  if (getBreedInfo != null) {
                    breedInfo = getBreedInfo;
                    if (breedInfo['code'] == 10000 ||
                        breedInfo['code'] == 20000) {
                      setState(() {
                        _isBreedInput = true;
                      });
                      return;
                    } else {
                      setState(() {
                        breedName = UtilityFunction.getBreedName(
                            breedInfo, _userLanguage);
                      });
                    }
                  }
                  return;
                }
              },
            ));
  }

  Widget buildInput(String hint, TextEditingController textEditingController) {
    return TextField(
      style: const TextStyle(fontSize: 15),
      controller: textEditingController,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff9e9e9e))),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: VetTheme.mainIndigoColor)),
        hintText: hint.tr(),
        hintStyle: const TextStyle(color: Color(0xff9e9e9e)),
        isDense: true,
      ),
    );
  }

  Widget buildTitle(
    String title,
  ) {
    return Text(
      title.tr(),
      textAlign: TextAlign.center,
      style: TextStyle(
          color: VetTheme.mainIndigoColor,
          fontSize: 20,
          fontWeight: FontWeight.bold),
    );
  }

  Widget buildBottom() {
    return BottomAppBar(
      child: Container(
          margin: const EdgeInsets.all(10),
          child: ElevatedButton(
              onPressed: () async {
                UtilityFunction.log.e('확인');
                onConfirmClicked();
              },
              child: Text('Confirm'.tr()))),
    );
  }

  void setLoading(bool isLoading) {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }

  /**
   * @ 동물종체크
   * */

  Future<void> checkBreedsDate() async {
    var breedInfo = await _apiService.getAnimalBreedDate();
    var breedList = await _apiService.getAnimalBreedList();
    await _apiService.getBreedsLastUpdate().then((value) {
      value.when((error) {
        UtilityComponents.showToast(error.message!);
      }, (success) async {
        String updateCnt = success.cnt.toString() ?? "";
        String updatedAt = success.updatedAt.toString() ?? "";
        if (breedList.isEmpty || breedInfo!.isEmpty) {
          _apiService.setAnimalBreedDate([updateCnt, updatedAt]);
          return await getBreedList();
        } else if (breedInfo[0] != updateCnt || breedInfo[1] != updatedAt) {
          await _apiService.setAnimalBreedDate([updateCnt, updatedAt]);
          return await getBreedList();
        }
        _breedList =
            json.decode(breedList).cast<Map<String, dynamic>>().toList();
        return;
      });
    });
  }

  Future<void> getBreedList() async {
    await _apiService.getBreedList().then((value) {
      value.when((error) {
        UtilityComponents.showToast(error.message!);
      }, (success) async {
        UtilityFunction.log.e('불러오기');
        await _apiService.setAnimalBreedList(success);
        var breed = await _apiService.getAnimalBreedList();
        _breedList = json.decode(breed).cast<Map<String, dynamic>>().toList();
      });
    });
  }

  Future<void> onConfirmClicked() async {
    if (!nullCheck()) {
      return;
    }
    await updatePatient();
    return;
  }

  bool nullCheck() {
    _animalData['animal'] = _animalData['animal'] ?? '';
    if (chartNum.text.trim().isEmpty) {
      UtilityComponents.showToast('Please enter your chart number'.tr());
      return false;
    } else if (name.text.trim().isEmpty) {
      UtilityComponents.showToast('Please enter your name'.tr());
      return false;
    } else if (modifyselectedSpeciesValue.isEmpty) {
      UtilityComponents.showToast('Please select the species'.tr());
      return false;
    } else if (modifyselectedSexValue.isEmpty) {
      UtilityComponents.showToast('Please select the gender'.tr());
      return false;
    } else if (birth.contains('Select date')) {
      UtilityComponents.showToast('Please select a date'.tr());
      return false;
    } else {
      _animalData['animal_type'] =
          modifyselectedSpeciesValue.contains('Dog') ? 0 : 1;
      _animalData['gender'] = checkAnimalSex(modifyselectedSexValue);
      UtilityFunction.log.e(_animalData['gender']);
      if (_isBreedInput) {
        if (inputBreed.text.trim().isEmpty) {
          UtilityComponents.showToast('Please enter patient’s breed'.tr());
          return false;
        }
        _animalData['breedCode'] =
            _animalData['animal_type'] == 0 ? 10000 : 20000;
        _animalData['breed'] = inputBreed.text.trim();
      } else {
        if (breedInfo.isEmpty) {
          UtilityComponents.showToast('Please select breed'.tr());
          return false;
        }

        _animalData['breedCode'] = breedInfo['code'];
        _animalData['breed'] =
            UtilityFunction.getBreedName(breedInfo, _userLanguage);
      }

      _animalData['chart_no'] = chartNum.text.trim();
      _animalData['name'] = name.text.trim();
      _animalData['birth'] = birth;
    }
    return true;
  }


  Future<void> updatePatient() async {
    Map<String, String> request = {
      "name": _animalData['name'],
      "birth": birth,
      "animalType": _animalData['animal_type'].toString(),
      "sex": _animalData['gender'].toString(),
      "breedCode": _animalData['breedCode'].toString(),
      "breed": _animalData['breed'],
      "chartNumber": _animalData['chart_no'].toString(),
    };
    await _apiService
        .updatePatientsData(_animalData['id'], request)
        .then((value) {
      value.when((error) async {
        UtilityFunction.log.e(error);
        UtilityFunction.log.e(error.re_code);
        UtilityFunction.log.e(error.code);
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? await updatePatient()
              : logoutAndPushToHome();
        } else if (error.re_code == 400 && error.code == 501) {
          UtilityComponents.showToast("Chart number is duplicated".tr());
          setLoading(false);
          return;
        }
        setLoading(false);
        UtilityComponents.showToast(
            "${"Animal Modify failed".tr()}:${error.message ?? ""}");
        _profileManager.animalListRefresh(true);
        UtilityFunction.goBackToMainPage(context);
        return;
      }, (success) {
         UtilityComponents.showToast("Animal Modify complete".tr());
        _profileManager.animalListRefresh(true);
         UtilityFunction.goBackToMainPage(context);
        return;
      });
    });
  }

  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    setLoading(false);
  }

  int checkAnimalSex(String sex) {
    int animalSex = 0;
    switch (sex) {
      case "Female":
      case "암컷":
      case "0":
        animalSex = 0;
        break;
      case "Female(neutered)":
      case "암컷(중성화)":
      case "1":
        animalSex = 1;
        break;
      case "Male":
      case "수컷":
      case "2":
        animalSex = 2;
        break;
      case "Male(neutered)":
      case "수컷(중성화)":
      case "3":
        animalSex = 3;
        break;
    }

    return animalSex;
  }
}

class DropDownBtn extends StatefulWidget {
  int? state;
  String? hint;
  String? modifySelectedValue;
  final Function(int?, String?)? onChanged; // 수정: 함수 타입 명시

  DropDownBtn({super.key, this.hint, this.state, this.modifySelectedValue, this.onChanged});

  @override
  State<DropDownBtn> createState() => _DropDownBtnState();
}

class _DropDownBtnState extends State<DropDownBtn> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Color(0xff9e9e9e)),
          borderRadius: BorderRadius.circular(5)),
      height: 50,
      padding: EdgeInsets.zero,
      child: DropdownButtonHideUnderline(
        child: drop2.DropdownButton2(
          isExpanded: true,
          hint: Container(
            margin: const EdgeInsets.all(10),
            child: Text(
              widget.hint!.tr(),
              style: const TextStyle(
                color: Color(0xff9e9e9e),
                fontSize: 16,
              ),
            ),
          ),
          iconStyleData: const drop2.IconStyleData(icon: SizedBox.shrink()),
          items: _addDividersAfterItems(
              widget.state == 0 ? modifySpeciesItems : modifySexItems),
          value: _selectedValue,
          onChanged: (value) {
            setState(() {

              if(widget.state==0){
                widget.onChanged?.call(0,value as String);
              }else{
                widget.onChanged?.call(1,value as String);
              }
              _selectedValue = value as String;
              // UtilityFunction.log.e(value);
              // UtilityFunction.log.e(widget.state.toString());
              // widget.state == 0
              //     ? modifyselectedSpeciesValue = value as String
              //     : modifyselectedSexValue = value as String;
              // if (widget.state == 0) {
              //   _selectedValue = value;
              //   modifyselectedSpeciesValue = value;
              // } else {
              //   _selectedValue = value;
              //   modifyselectedSexValue = value;
              // }
            });
          },
          buttonStyleData: const drop2.ButtonStyleData(height: 40, width: 140),
          dropdownStyleData: drop2.DropdownStyleData(
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: VetTheme.mainIndigoColor),
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            ),
            maxHeight: 200,
          ),
          menuItemStyleData: drop2.MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            customHeights: _getCustomItemsHeights(
                widget.state == 0 ? modifySpeciesItems : modifySexItems),
          ),
        ),
      ),
    );
  }
}
