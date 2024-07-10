import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class VeterinarianRegisterScreen extends StatefulWidget {
  const VeterinarianRegisterScreen({Key? key}) : super(key: key);
  static const routeName = '/VeterinarianRegisterScreen';

  @override
  State<VeterinarianRegisterScreen> createState() =>
      _VeterinarianRegisterScreenState();
}

class _VeterinarianRegisterScreenState
    extends State<VeterinarianRegisterScreen> {
  TextEditingController number = new TextEditingController();
  late ProfileManager user_profile = ProfileManager();

  @override
  void initState() {
    user_profile = Provider.of<ProfileManager>(context, listen: false);
    // TODO: implement initState
    super.initState();
  }

  void resultBt() {
    UtilityFunction.log.e(number.text.tr());
    number.text.trim().isEmpty
        ? UtilityComponents.showToast('The input value is empty.'.tr())
        : Navigator.pushNamed(context, '/createVetQr', arguments: {
            'id': user_profile.userData.id!,
            'name': user_profile.userData.name!,
            'authority': '1',
            'number': number.text.trim()
          });

    // UtilityFunction.log.e(number.text.tr());
    //   number.text.trim().isEmpty?UtilityComponents.showToast('The input value is empty.'.tr()):
    //       UtilityFunction.moveScreen(context, 'createVetQr',{
    //         'id':user_profile.userData.id!,
    //         'name':user_profile.userData.name!,
    //         'number':number.text.trim()
    //       });
  }

  @override
  Widget build(BuildContext context) {
    return Contents(context);
    // return Consumer<ProfileManager>(
    //   builder: (context, user, child) {
    //     user_profile = user;
    //     return Contents(context);
    //   }
    // );
  }

  Widget Contents(BuildContext buildContext) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          elevation: 1,
          title: Text(
            "Veterinary registration".tr(),
          )),
      body: Container(child: buildInputBox()),
      bottomNavigationBar: BottomAppBar(
          child: Container(
        margin: const EdgeInsetsDirectional.all(10),
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(VetTheme.mainIndigoColor)),
          onPressed: () => resultBt(),
          child: Text("QR issuance".tr()),
        ),
      )),
    );
  }

  Widget buildInputBox() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.all(20)),
        Container(
          color: Colors.black12,
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 50),
          padding: const EdgeInsets.all(20),
          child: Text(
            '${"Name".tr()} : ${user_profile.userData.name}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 50),
          child: TextField(
            controller: number,
            cursorColor: Colors.black,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
              hintText: "Veterinarian license number".tr(),
            ),
            textInputAction: TextInputAction.done,
          ),
        ),
      ],
    );
  }
}
