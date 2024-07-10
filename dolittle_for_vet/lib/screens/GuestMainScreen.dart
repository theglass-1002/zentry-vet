import 'dart:convert';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/screens/ChartMainScreen.dart';
import 'package:dolittle_for_vet/screens/HeartFailureScreen.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

import '../new_screens/MonitoringListScreen.dart';

class GuestMainScreen extends StatefulWidget {
  const GuestMainScreen({Key? key}) : super(key: key);
  static const routeName = '/GuestMainScreen';
  @override
  State<GuestMainScreen> createState() => _GuestMainScreenState();
}

class _GuestMainScreenState extends State<GuestMainScreen> with SingleTickerProviderStateMixin{
  late ProfileManager _profileManager = ProfileManager();
  late OverlayEntry overlayEntry;
  List<Animal> animalList = [];

  @override

  void initState() {
    // TODO: implement initState
    if (mounted) {
      _profileManager = Provider.of<ProfileManager>(context, listen: false);
      super.initState();
    }
  }
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
  }



  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          title: Container(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.zero,
                  width: VetTheme.diviceW(context)/2,
                  height:60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                      color: VetTheme.mainIndigoColor),
                  child:
                  Center(child: Text('Heart Failure'.tr(),
                    style: TextStyle(fontSize: VetTheme.titleTextSize(context)),
                    textAlign: TextAlign.center,)),
                ),
                IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    iconSize: 35,
                    onPressed: () {
                      UtilityFunction.moveScreen(context, '/setting');
                    },
                    icon:  Icon(Icons.settings,color: Colors.black,))
              ],
            ),
          ),
        ),
        body: buildGuestBody(),
        floatingActionButton: Container(
          margin: EdgeInsets.symmetric(
              vertical: VetTheme.textSize(context),
              horizontal: VetTheme.textSize(context)),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: VetTheme.logotextSize(context)),
                child: Text(
                  'Register'.tr(),
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: VetTheme.logotextSize(context)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildCircularContainer('OWNER',VetTheme.mainIndigoColor),
                  _buildCircularContainer('NORMAL',VetTheme.mainLightBlueColor),
                  _buildCircularContainer('TECHNICIAN',VetTheme.hintColor),
                ],
              ),
            ],
          ),
        ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCircularContainer(String auth,Color color) {
    DateTime now = DateTime.now();
    var dialogContent = "AuthorizationRequest".tr(namedArgs: {'auth': auth.tr()});
    double fixedSize = VetTheme.mediaHalfSize(context)/2;
    return Container(
        width: fixedSize,
        height: fixedSize,
        margin: EdgeInsets.only(bottom: VetTheme.textSize(context)),
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 7)
              )
            ]
        ),
      child: ElevatedButton(
          onPressed: () async {
            var dialogResult = await UtilityComponents.showConfirmationDialog(context,dialogContent,confirmText: "Notification");
            if(dialogResult!=null&&dialogResult){
              UtilityFunction.log.e('dialogContent${dialogResult}');
              if(auth=="OWNER"){
                UtilityFunction.moveScreen(context, "/hospitalRegister");
              }else if(auth=="NORMAL"){
                UtilityFunction.moveScreen(context, "/veterinarianRegister");
              }else if(auth=="TECHNICIAN"){
                UtilityFunction.moveScreen(context, "/createVetQr",{
                  'id': _profileManager.userData.id!,
                  'name': _profileManager.userData.name!,
                  'authority': '4',
                  'number': DateFormat('yyyyMMdd').format(now),
                });
              }
            }
          },child:Text(
        auth.tr(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: VetTheme.textSize(context)),),
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: CircleBorder()),
      ),
    );

  }
  Widget buildGuestBody() {
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
        Expanded(child: buildAnimalList())
      ]

    );
  }

  Widget buildAnimalList(){
   return FutureBuilder(
        future: getSampleAnimalList(),
        builder: (context,snapshot) {
          if(snapshot.connectionState ==ConnectionState.done){
            return ListView.builder(
              itemCount: animalList.length,
              itemBuilder: (context, index){
                return GestureDetector(
                    onTap: (){
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context)=>
                      ChartPageScreen(animal: animalList[index]))
                      );
                    },
                    child: AnimalCard(animal: animalList[index]));
              }
            );
          }
          return const LoadingBar();
        }
    );
  }

  Future<bool> getSampleAnimalList() async {
    final dataString = await _loadAsset(
      'assets/sample_data/sample_animals.json',
    );
    final Map<String, dynamic> animalJson = jsonDecode(dataString);
    animalList = AnimalList.fromJson(animalJson).animal_list!;
     return true;
  }
  Future<String> _loadAsset(String path) async {
    return rootBundle.loadString(path);
  }

}




