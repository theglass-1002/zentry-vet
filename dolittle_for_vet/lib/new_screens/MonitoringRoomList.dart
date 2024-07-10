import 'dart:convert';
import 'dart:math';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:dolittle_for_vet/components/monitoring_alarm_card.dart';
import 'package:dolittle_for_vet/components/monitoring_data.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/components/monitoring_defalut_card.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';

import '../components/monitoring_no_data_card.dart';

class MonitoringRoomList extends StatefulWidget {
  final Map? multiAppData;

  const MonitoringRoomList({super.key, required this.multiAppData});

  @override
  State<MonitoringRoomList> createState() => _MonitoringRoomListState();
}

class _MonitoringRoomListState extends State<MonitoringRoomList> {
  late Map? multiAppData;
  ProfileManager _profileManager = ProfileManager();
  ApiService _apiService = ApiService();

  @override
  void initState() {
    // TODO: implement initState
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    multiAppData = widget.multiAppData;
    return Container(
      child: ListView.builder(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: multiAppData!['roomcount'],
        itemBuilder: (BuildContext context, int index) {
          var multiAppUUID = multiAppData!['multiAppUUID'];
          var roomInfo = multiAppData!['RoomInfos'][index];
          Widget cardWidget;
          if (roomInfo['type'] == 3) {
            cardWidget = MonitoringAlarmCard(
                roomInfo: roomInfo, multiAppUUID: multiAppUUID);
          } else if (roomInfo['type'] == 21) {
            cardWidget = MonitoringDefalutCard(
              roomInfo: roomInfo,
              multiAppUUID: multiAppUUID,
            );
          } else {
            cardWidget = MonitoringNoDataCard(roomInfo: roomInfo);
          }

          return GestureDetector(
            onTap: () {
              if (roomInfo['chartApiId'] != null) {
                _dialogBuilder(context, multiAppData!['monitoringType'].toString(),
                    roomInfo['chartApiId']);
              } else {
                UtilityComponents.showToast("Please update to the supported version, whether it's the single or multi-app version.".tr());
              }
            },
            child: cardWidget,
          );
        },
      ),
    );
  }

  Future<void> _dialogBuilder( BuildContext context, String monitoringType, String chartApiId) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          onTap: ()=>{
            Navigator.pop(context)
          },
          child: Center(
              child: Container(
                  margin: EdgeInsets.fromLTRB(VetTheme.logotextSize(context), VetTheme.monitorCardSizeByDeviceHeight(context),VetTheme.logotextSize(context), VetTheme.textSize(context)),
                  width: VetTheme.diviceW(context),
                  height: VetTheme.diviceH(context),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      border: Border.all(
                          color: Colors.white,
                          width: 3
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(VetTheme.textSize(context)))),
                  child: RotatedBox(
                      quarterTurns: 1,
                      child: monitoringDataWidgetBuilder(monitoringType, chartApiId, context)))),
        );
      },
    );
  }

  Future<dynamic> getMonitoringData(
      String monitoringType, String chartApiId, BuildContext context) async {
    final monitoringData =
        await _apiService.getPatientMonitoringData(monitoringType, chartApiId);
    return monitoringData.when(
      (error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          final refreshToken = await _apiService.refreshToken();
          if (refreshToken) {
            return await getMonitoringData(monitoringType, chartApiId, context);
          }
          Navigator.pop(context);
          return await logoutAndPushToHome();
        }
        Navigator.pop(context);
        return UtilityComponents.showToast(
            "${"failed".tr()}:${error.message ?? ""}");
      },
      (success) => success,
    );
  }

  Widget monitoringDataWidgetBuilder(String monitoringType, String chartApiId, BuildContext _context) {
    return FutureBuilder<dynamic>(
        future: getMonitoringData(monitoringType, chartApiId, _context),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingBar();
          } else if (snapshot.hasError) {
            UtilityComponents.showToast('Error');
            UtilityFunction.goBackToPreviousPage(context);
            return Container(
                color: Colors.green,
                child: Text('Error ${snapshot.error}',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: VetTheme.textSize(context))));}
          else {
            if (snapshot.data.runtimeType == PatientMonitoringChart) {
              return buildMonitoringDataWidget(snapshot.data);
            }
            Navigator.pop(_context);
            UtilityComponents.showToast('Error');
            UtilityFunction.goBackToPreviousPage(context);
            return LoadingBar();
          }
        });
  }


  Widget buildMonitoringDataWidget(PatientMonitoringChart data) {
    List<MonitoringRecords>? monitoringRecords = data.monitoringRecords;
    if (monitoringRecords!.isEmpty) {
      return buildChartNoDataWidget(data);
    }
    return buildChartBodyDataWidget(data);
  }

  Widget buildChartNoDataWidget(PatientMonitoringChart data) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          buildChartHeaderWidget(data),
          Expanded(
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              color: Colors.black,
              child: Text(
                'No Chart Data available'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: VetTheme.titleTextSize(context),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChartBodyDataWidget(PatientMonitoringChart data) {
    List<MonitoringRecords> sensorDataList = data.monitoringRecords ?? [];
    String previousText = '';
    DateTime? previousDate;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(VetTheme.textSize(context)))
      ),
      child: Column(
        children: [
          buildChartHeaderWidget(data),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(VetTheme.textSize(context), VetTheme.textSize(context), VetTheme.textSize(context),0),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 200,
                  minX: 0,
                  lineTouchData: const LineTouchData(
                      enabled: false
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: false,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: true,
                          getDotPainter:(spot, percent, barData, index){
                            return FlDotCirclePainter(
                                strokeWidth: 0.1,
                                strokeColor: Colors.green,
                                color: Colors.green
                            );
                          } ),
                      spots: List.generate(sensorDataList.length, (int i) {
                        var intervalSum = 0.0;
                        if (i > 0) {
                          for (int j = 0; j <= i - 1; j++) {
                            intervalSum += sensorDataList[j].interval!.toDouble();
                          }
                        }
                        return FlSpot(
                          intervalSum,
                          sensorDataList[i].hr!.toDouble(),
                        );
                      }),
                      color: Colors.green,
                      barWidth: 0.0,
                    ),
                    LineChartBarData(
                      isCurved: false,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: true,
                      getDotPainter: (spot, percent, barData, index){
                        return FlDotCirclePainter(
                            strokeWidth: 0.1,
                            strokeColor: Colors.blue,
                            color: Colors.blue
                        );
                      }
                      ),
                      spots: List.generate(sensorDataList.length, (int i) {
                        var intervalSum = 0.0;
                        if (i > 0) {
                          for (int j = 0; j <= i - 1; j++) {
                            intervalSum += sensorDataList[j].interval!.toDouble();
                          }
                        }
                        return FlSpot(
                          intervalSum,
                          sensorDataList[i].rr!.toDouble(),
                        );
                      }),
                      color: Colors.blue,
                      barWidth: 0.0,
                    ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        interval: 30,
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '${value.toInt().toString()}',
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        interval: 30,
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '${value.toInt().toString()}',
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta ){
                          //intervalSum 변수는 현재까지의 데이터 간 간격의 합
                          int intervalSum = 0;
                          for (var record in sensorDataList) {
                            intervalSum += record.interval!;
                            if (intervalSum >= value) {
                              //비교하여 해당하는 시간 레이블 찾음.
                              DateTime currentDateTime = UtilityFunction.parseServerTime(record.startedAt!);
                            //  DateTime currentDateTime = DateTime.parse(record.startedAt!).toLocal();
                              Duration difference = currentDateTime.difference(previousDate ?? currentDateTime);
                              //이전날짜 현시와2 분차이 나면 레이블표시
                              if (previousDate == null || difference.inMinutes >= 2) {
                                previousDate = currentDateTime;
                                previousText = '${currentDateTime.hour}:${currentDateTime.minute}';
                                return Text(
                                  previousText,
                                  style: TextStyle(fontSize: 10, color: Colors.white, decoration: TextDecoration.none),
                                );
                              }
                              // 빈 Container를 반환하여 아무것도 표시하지 않음
                              return Container();
                            }
                          }
                          return Container();
                        }
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value){
                      return FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.7
                      );
                    },
                     getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey, // 라인 색상
                          strokeWidth: 0.7, // 라인 두께
                        );
                      }

                  ),
                  borderData: FlBorderData(
                      show: true,
                      border: Border(
                        right: BorderSide(color: Colors.white,width: 0.5),
                        left: BorderSide(color: Colors.white,width: 0.5),
                        bottom: BorderSide(color: Colors.white,
                          width: 2.0
                        ),
                      )
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Start:'
                    '${UtilityFunction.parseServerTime(sensorDataList.first.startedAt!).month}-'
                    '${UtilityFunction.parseServerTime(sensorDataList.first.startedAt!).day} '
                    '${UtilityFunction.parseServerTime(sensorDataList.first.startedAt!).hour}:'
                    '${UtilityFunction.parseServerTime(sensorDataList.first.startedAt!).minute}'
                  ,style: TextStyle(decoration:TextDecoration.none , color:  Colors.grey,fontSize: 10),),
                Text('End:'
                    '${UtilityFunction.parseServerTime(sensorDataList.last.startedAt!).month}-'
                    '${UtilityFunction.parseServerTime(sensorDataList.last.startedAt!).day} '
                    '${UtilityFunction.parseServerTime(sensorDataList.last.startedAt!).hour}:'
                    '${UtilityFunction.parseServerTime(sensorDataList.last.startedAt!).minute}'
                  ,style: TextStyle(decoration:TextDecoration.none, color:  Colors.grey,fontSize: 10),),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildChartHeaderWidget(PatientMonitoringChart data) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(VetTheme.textSize(context)),
              topRight: Radius.circular(VetTheme.textSize(context))
          )
      ),
      padding: EdgeInsets.all(VetTheme.titleTextSize(context)),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(
                textAlign: TextAlign.center,
                DateFormat.yMMMd('en').format(UtilityFunction.parseServerTime(data.createdAt!)),
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: VetTheme.textSize(context)),
              )),
          Expanded(
              child: Text(
                '|',
                textAlign: TextAlign.center,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: VetTheme.textSize(context),
                    color: Colors.black38),
              )),
          Expanded(
              child: Text(
                textAlign: TextAlign.center,
                '${data.chartNumber}',
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: VetTheme.titleTextSize(context)),
              )),
          Expanded(
              child: Text(
                '|',
                textAlign: TextAlign.center,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: VetTheme.textSize(context),
                    color: Colors.black38),
              )),
          Expanded(
              child: Text(
                textAlign: TextAlign.center,
                '${data.name}',
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: VetTheme.titleTextSize(context)),
              )),
          Expanded(
              child: Text(
                '|',
                textAlign: TextAlign.center,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: VetTheme.textSize(context),
                    color: Colors.black38),
              )),
          Expanded(
              flex: 2,
              child: Text(
                textAlign: TextAlign.center,
                '${data.breed}',
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: VetTheme.textSize(context)),
              )),
          Expanded(
              child: Text(
                '|',
                textAlign: TextAlign.center,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: VetTheme.textSize(context),
                    color: Colors.black38),
              )),
          Expanded(
              child: Text(
                '${data.age}y',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: VetTheme.textSize(context)),
              )),
        ],
      ),
    );
  }

  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
  }

}

