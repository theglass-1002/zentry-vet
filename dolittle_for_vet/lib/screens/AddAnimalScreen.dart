import 'dart:math';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:scan/scan.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({Key? key}) : super(key: key);

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  late final Map<dynamic, dynamic> _animalData = Map<dynamic, dynamic>.from(
      ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>);
  late ProfileManager _profileManager = ProfileManager();
  late final ApiService _apiService = ApiService();
  late TextEditingController number = TextEditingController();
  bool _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    super.initState();
  }

  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? const LoadingBar() : _setQrdata(context);
  }

  Widget _setQrdata(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          elevation: 1,
          title: Text(
            "Pet registration".tr(),
          )),
      body: Center(child: setVetInfo()),
      bottomNavigationBar: BottomAppBar(
          child: Container(
        margin: const EdgeInsetsDirectional.all(10),
        child: ElevatedButton(
          onPressed: () {
            resultBt();
          },
          child: Text("Pet registration".tr()),
        ),
      )),
    );
  }

  Widget setVetInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12, width: 2),
              color: Colors.white,
            ),
            margin: const EdgeInsets.fromLTRB(15, 30, 15, 10),
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                          width: 83,
                          child: AutoSizeText(
                            "${"Animal name".tr()}:",
                            maxLines: 1,
                            style: const TextStyle(fontSize: 20),
                          )),
                      Expanded(
                          child: AutoSizeText(_animalData['name'],
                              maxLines: 1,
                              style: const TextStyle(fontSize: 25))),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                          width: 83,
                          child: AutoSizeText(
                            "${"Species".tr()}:",
                            maxLines: 1,
                            style: const TextStyle(fontSize: 20),
                          )),
                      Expanded(
                          child: AutoSizeText(
                              _animalData['animal_type'] == "0" ? "DOG" : "CAT",
                              maxLines: 1,
                              style: const TextStyle(fontSize: 25))),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                          width: 83,
                          child: AutoSizeText(
                            "${"Breed".tr()}:",
                            maxLines: 1,
                            style: const TextStyle(fontSize: 20),
                          )),
                      Expanded(
                          child: AutoSizeText(
                              UtilityComponents.spliteBreed(
                                  _animalData['breed']),
                              maxLines: 1,
                              style: const TextStyle(fontSize: 25))),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                          width: 83,
                          child: AutoSizeText(
                            "${"Date of birth".tr()}:",
                            maxLines: 1,
                            style: const TextStyle(fontSize: 20),
                          )),
                      Expanded(
                          child: AutoSizeText(
                              UtilityComponents.countBirth(
                                  _animalData['birth']),
                              maxLines: 1,
                              style: const TextStyle(fontSize: 25))),
                    ]),
              ],
            )),
        Container(
            margin: const EdgeInsets.fromLTRB(15, 10, 15, 20),
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: number,
              cursorColor: Colors.black,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                hintText: "Enter chart number".tr(),
              ),
            )),
      ],
    );
  }

  Future<void> resultBt() async {
    number.text.trim().isEmpty
        ? UtilityComponents.showToast(
            ("The chart number input value is empty.".tr()))
        : await addPatients();
    return;
  }

  Future<void> addPatients() async {
    setLoading(true);
    // await _apiService.addPatient({
    //   "hospitalId": _profileManager.userData.hospitalId!,
    //   "chartNumber": number.text.trim(),
    //   "animal": _animalData['animal'],
    //   "animalId": _animalData['_id'],
    // }).then((value) {
    //   value.when((error) async {
    //     if (error.re_code == UnauthorizedCode && error.code == 101) {
    //       return await _apiService.refreshToken()
    //           ? addPatients()
    //           : UtilityFunction.pushReplacementNamed(context, '/login');
    //     }else if(error.code==501){
    //       UtilityComponents.showToast(
    //           "Chart number is duplicated".tr());
    //       setLoading(false);
    //       return;
    //     }
    //     UtilityComponents.showToast(
    //         "${"Animal registration failed".tr()}:${error.message ?? ""}");
    //      UtilityFunction.pushReplacementNamed(context, '/');
    //     return;
    //   }, (success) {
    //     UtilityComponents.showToast("Animal registration complete".tr());
    //      UtilityFunction.pushReplacementNamed(context, '/');
    //     return;
    //   });
    // });
  }

  Future<void> stopCamera(QRViewController controller) async {
    await controller.stopCamera();
    setState(() {});
  }
}
