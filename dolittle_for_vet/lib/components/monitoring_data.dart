import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/components/monitoring_defalut_card.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class MonitoringDataCard extends StatelessWidget {
  final Map? roomInfo;
  MonitoringDataCard({Key? key,required this.roomInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween,
        children: [
          Expanded(
            child: Text('${roomInfo?['dataType0'] ?? '-'}',
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: VetTheme.diviceH(context) < 800 ? 30 : 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27C32B)),),
          ),
          Expanded(
            child: Text('${roomInfo?['dataType1'] ?? '-'}',
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: VetTheme.diviceH(context) < 800 ? 30 : 35,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF45A1FF))),
          ),
        ],),);
  }



}
