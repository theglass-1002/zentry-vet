import 'package:age_calculator/age_calculator.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;

  const AnimalCard({Key? key, required this.animal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: VetTheme.monitorCardSizeByDeviceHeight(context),
      child: Card(
        elevation: 3.0,
        shape: animal.hasQRLink!? RoundedRectangleBorder(
          side: BorderSide(color: VetTheme.mainLightBlueColor),
          borderRadius: BorderRadius.circular(5),
        ):RoundedRectangleBorder(
          side: BorderSide(color: VetTheme.hintColor),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          padding: const EdgeInsetsDirectional.all(10),
          child: Column(
            children: [
              Expanded(
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(children: [
                      Text(
                            animal.chart_number!,
                            style:  TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: VetTheme.textSize(context),
                                fontWeight: FontWeight.bold),
                          ),
                      animal.animal_type == 0
                          ?  Container(
                            padding: EdgeInsets.zero,
                            child: Text('D',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                              fontSize: VetTheme.textSize(context),
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff2e3d80)),
                      ),
                          )
                          :  Container(
                        padding: EdgeInsets.zero,
                            child: Text('C',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: VetTheme.textSize(context),
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffFF5733))),
                          ),
                        Text(animal.breed!,style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: VetTheme.textSize(context),), textAlign: TextAlign.start,),
                        Text(animal.birth!,style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: VetTheme.textSize(context),), textAlign: TextAlign.end,),
                    ]),
                  ],
                ),
              ),
              Expanded(
                child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      4: FlexColumnWidth(2),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: [
                        Text(
                          animal.name!,
                          style: TextStyle(
                              fontSize: VetTheme.textSize(context),
                             overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: UtilityComponents.checkGender(animal.sex.toString())),
                        Icon(
                          Icons.favorite,
                          color: Colors.red.shade400,),
                        Text(
                          UtilityComponents.checkCardiac(animal.cardiac!),
                          textAlign: TextAlign.center,
                          style:  TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: VetTheme.textSize(context),
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          UtilityComponents.checkLastdate(animal.lastdate!),
                          textAlign: TextAlign.end,
                          style:  TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: VetTheme.textSize(context),
                              fontWeight: FontWeight.bold),
                        )
                      ]),
                    ],
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

