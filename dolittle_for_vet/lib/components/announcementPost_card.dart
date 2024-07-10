import 'package:age_calculator/age_calculator.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';


class AnnouncementPostCard extends StatelessWidget {
  final AnnouncementPost announcementPost;
  const AnnouncementPostCard({super.key, required this.announcementPost});

  @override
  Widget build(BuildContext context) {
    DateTime utcDateObject = DateTime.parse(announcementPost.createdAt!);
    var createdDate = DateFormat('yyyy-MM-dd').format(utcDateObject.toUtc());
    return Card(
        margin: EdgeInsets.all(2),
        elevation: 2.5,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: VetTheme.textSize(context),vertical: VetTheme.textSize(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: VetTheme.mainIndigoColor,
                            width: 1.0,           // 테두리 두께 설정
                          ),
                          borderRadius: BorderRadius.circular(VetTheme.logotextSize(context)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: VetTheme.textSize(context)/2,vertical: VetTheme.textSize(context)/2),
                          child: Text(UtilityComponents.getNoticeType(announcementPost.type!),
                            style: TextStyle(color: VetTheme.mainIndigoColor),),
                        ),
                      ),
                    ],),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: VetTheme.textSize(context)),
                      child:Text(announcementPost.title.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: VetTheme.titleTextSize(context),
                            fontWeight: FontWeight.w600
                        ),),
                    ),
                    Text(
                      createdDate.toString(),
                      style: TextStyle(color: VetTheme.hintColor),
                    )
                  ],
                ),
              ),
              Expanded(child: Container(
                  alignment: Alignment.bottomRight,
                  child: Icon(Icons.arrow_forward_ios,color: VetTheme.hintColor)))
            ],
          ),
        ));
  }
}
