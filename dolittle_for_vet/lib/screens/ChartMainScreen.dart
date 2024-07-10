import 'dart:convert';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/screens/LineChartOverlay.dart';
import 'package:dolittle_for_vet/screens/LineChartPainter.dart';
import 'package:dolittle_for_vet/screens/LineChartVerticalText.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:easy_localization/easy_localization.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:flutter/gestures.dart';

class ChartPageScreen extends StatefulWidget {
  final Animal animal;

  const ChartPageScreen({super.key, required this.animal});

  @override
  _ChartPageScreenState createState() => _ChartPageScreenState();
}

class _ChartPageScreenState extends State<ChartPageScreen> {
  late ProfileManager _profileManager = ProfileManager();
  late final ApiService _apiService = ApiService();
  final String popupReturnModify = "modify";
  final String popupReturnHidden = "hidden";

  Color mColor = Colors.blue;
  Color mColor0 = Colors.blue;
  final isSelected = <bool>[true, false];

  DateTime dateStart = DateTime.now();
  DateTime dateEnd = DateTime.now();

  bool isLoading = true;
  double chartWidth = 0;
  double touchX = -1;
  String chart_number = "";

  late Chart originAllData;

  List<ChartData> arrAllSample = [];
  List<ChartData> arrHRSample = [];
  List<ChartData> arrRRSample = [];
  List<ChartData> arrWWSample = [];

  List<ChartData> arrAllSampleWeek = [];
  List<ChartData> arrHRSampleWeek = [];
  List<ChartData> arrRRSampleWeek = [];
  List<ChartData> arrWWSampleWeek = [];

  Map<String, String> calDotRR = {};
  Map<String, String> calDotHR = {};
  Map<String, String> calDotWW = {};

  // 차트의 핀치(줌,아웃) 관련 변수
  bool isLongTouch = false;
  final ScrollController _scrollController = ScrollController();

  void setLoading(bool isLoading) {
    if (mounted) {
      setState(() {
        isLoading = isLoading;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _profileManager = Provider.of<ProfileManager>(context, listen: false);
      dateEnd = DateTime.now();
      dateStart = DateTime(dateEnd.year, dateEnd.month, dateEnd.day - 1);
      getChartDate();
      UtilityFunction.log.e(widget.animal.id);
      // chart_number = widget.animal.chart_number!;
      chart_number = widget.animal.chart_number!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // https://devmemory.tistory.com/41
    initializeDateFormatting(Localizations.localeOf(context)
        .languageCode); //언어 초기화를 해주지 않으면 달력 위젯의 locale 한국어 설정 안됨
  }

  void setStartDate(DateTime date) {
    setState(() {
      chartWidth = MediaQuery.of(context).size.width - 32;
      dateStart = date;
    });
    getChartDateFilter();
  }

  void setEndDate(DateTime date) {
    setState(() {
      chartWidth = MediaQuery.of(context).size.width - 32;
      dateEnd = date;
    });
    getChartDateFilter();
  }

  void getChartDateFilter() async {
    UtilityFunction.log.e('getChartDateFilter');
    if (_profileManager.userData.authority == 0) {
      getDataBundle().then((chartInfo) {
        convertChartDataFromAPI2(chartInfo);
      });
    } else {
      UtilityFunction.log.e(widget.animal.hasQRLink);
      convertChartDataFromAPI2(originAllData);
    }
  }

  Future getChartDate() async {
    UtilityFunction.log.e(_profileManager.userData.authority);
    if (_profileManager.userData.authority == 0) {
      getDataBundle().then((chartInfo) {
        setLoading(true);
        convertCalendarDotDataFromAPI(chartInfo);
        convertChartDataFromAPI2(chartInfo);
        UtilityFunction.log.e('샘플데이타');
      });
      return;
    } else {
      UtilityFunction.log.e('getChartDate');
      UtilityFunction.log.e(widget.animal.hasQRLink);
      //큐알링크 잇을때
      if (widget.animal.hasQRLink!) {
        var startDateString =
            DateTime(2022, 1, 1, 00, 00, 00).toUtc().toIso8601String();
        UtilityFunction.log.e(startDateString);
        var endDateString = DateTime(
                dateEnd.year, dateEnd.month, dateEnd.day + 1, 00, 00, 00, -1)
            .toUtc()
            .toIso8601String();
        UtilityFunction.log.e(endDateString);

        return await getPatientData(startDateString, endDateString);
      } else {
        UtilityFunction.log.e('hasQRLink 없음');
        getDataBundle().then((chartInfo) {
          setLoading(true);
          convertCalendarDotDataFromAPI(chartInfo);
          convertChartDataFromAPI2(chartInfo);
        });
      }
    }
  }



  //차트가져옴
  Future<void> getPatientData(String startDateStr, String endDateStr) async {
    setLoading(true);
    return await _apiService.getPatientData2(widget.animal.id!, {
      'startDate': startDateStr,
      'endDate': endDateStr,
    }).then((value) {
          value.when((error) async {
            if (error.re_code == UnauthorizedCode && error.code == 101) {
              return await _apiService.refreshToken()
                  ? await getPatientData(startDateStr, endDateStr)
                  : logoutAndPushToHome();
            }
          }, (success) {
            originAllData = success;
            convertCalendarDotDataFromAPI(originAllData);
            convertChartDataFromAPI2(originAllData);
            return;
          });
        });
  }

  Future<Chart> getDataBundle() async {
    //UtilityFunction.log.e('샘플데이타');
    String jsonString;
    jsonString = await rootBundle.loadString('assets/ChartJson.json');
    return Chart.fromJson(json.decode(jsonString));
  }

  void convertChartDataFromAPI2(Chart chartInfo) {
    var startDateString =
        DateTime(dateStart.year, dateStart.month, dateStart.day, 00, 00, 00)
            .toLocal();
    var endDateString =
        DateTime(dateEnd.year, dateEnd.month, dateEnd.day + 1, 00, 00, 00, -1)
            .toLocal();

    List<ChartRawData> arrAllSampleTemp = [];
    List<ChartRawData> arrHRSampleTemp = [];
    List<ChartRawData> arrRRSampleTemp = [];
    List<ChartRawData> arrWWSampleTemp = [];

    chartInfo.hrRr?.forEach((element) {
      if (element.data != null) {
        DateTime dd = DateTime.parse(element.measuredAt!).toLocal();
        if ((dd.compareTo(startDateString) >= 0) &&
            (dd.compareTo(endDateString) <= 0)) {
          if (element.type == "HR_AUTO_RESERVATION" ||
              element.type == "HR_AUTO" ||
              element.type == "HR_MANUAL") {
            arrHRSampleTemp.add(ChartRawData(
                data: element.data!.toDouble(),
                date: DateTime.parse(element.measuredAt!).toLocal(),
                type: convertChartTypeStringTo(element.type!)));
          } else if (element.type == "RR_AUTO_RESERVATION" ||
              element.type == "RR_AUTO" ||
              element.type == "RR_MANUAL") {
            arrRRSampleTemp.add(ChartRawData(
                data: element.data!.toDouble(),
                date: DateTime.parse(element.measuredAt!).toLocal(),
                type: convertChartTypeStringTo(element.type!)));
          }
        } // date compare
      }
    });

    chartInfo.weights?.forEach((element) {
      if (element.weight != null) {
        DateTime dd = DateTime.parse(element.date!).toLocal();
        if ((dd.compareTo(startDateString) >= 0) &&
            (dd.compareTo(endDateString) <= 0)) {
          Type t = element.weight.runtimeType;
          if (t == int) {
            int nValue = element.weight;
            arrWWSampleTemp.add(ChartRawData(
                data: nValue.toDouble(),
                date: DateTime.parse(element.date!).toLocal(),
                type: ChartDataType.WEIGHT));
          } else if (t == double) {
            arrWWSampleTemp.add(ChartRawData(
                data: element.weight,
                date: DateTime.parse(element.date!).toLocal(),
                type: ChartDataType.WEIGHT));
          }
        } // date compare
      }
    });

    // All
    arrAllSampleTemp.addAll(arrHRSampleTemp); //심박 포함
    arrAllSampleTemp.addAll(arrRRSampleTemp); //호흡 포함
    arrAllSampleTemp.addAll(
        arrWWSampleTemp); //몸무게 포함 (심박, 호흡일자에 포함되는 로직이면 주석 처리 하고 몸무게 데이터에 removeHMS 적용)

    if (mounted) {
      setState(() {
        isLoading = false;

        // false: 일자 단위 날짜
        arrAllSample = convertChartData(arrAllSampleTemp, true);
        arrHRSample = convertChartData(arrHRSampleTemp, true);
        arrRRSample = convertChartData(arrRRSampleTemp, true);
        arrWWSample = convertChartData(arrWWSampleTemp, true);

        // true: 모든 날짜
        arrAllSampleWeek = convertChartData(arrAllSampleTemp, false);
        arrHRSampleWeek = convertChartData(arrHRSampleTemp, false);
        arrRRSampleWeek = convertChartData(arrRRSampleTemp, false);
        arrWWSampleWeek = convertChartData(arrWWSampleTemp, false);
      });
    }
  }

  void convertCalendarDotDataFromAPI(Chart chartInfo) {
    List<ChartRawData> arrHRSampleTemp = [];
    List<ChartRawData> arrRRSampleTemp = [];
    List<ChartRawData> arrWWSampleTemp = [];

    chartInfo.hrRr?.forEach((element) {
      if (element.data != null) {
        if (element.type == "HR_AUTO_RESERVATION" ||
            element.type == "HR_AUTO" ||
            element.type == "HR_MANUAL") {
          arrHRSampleTemp.add(ChartRawData(
              data: element.data!.toDouble(),
              date: DateTime.parse(element.measuredAt!).toLocal(),
              type: convertChartTypeStringTo(element.type!)));
        } else if (element.type == "RR_AUTO_RESERVATION" ||
            element.type == "RR_AUTO" ||
            element.type == "RR_MANUAL") {
          arrRRSampleTemp.add(ChartRawData(
              data: element.data!.toDouble(),
              date: DateTime.parse(element.measuredAt!).toLocal(),
              type: convertChartTypeStringTo(element.type!)));
        }
      }
    });

    chartInfo.weights?.forEach((element) {
      if (element.weight != null) {
        Type t = element.weight.runtimeType;
        if (t == int) {
          int nValue = element.weight;
          arrWWSampleTemp.add(ChartRawData(
              data: nValue.toDouble(),
              date: DateTime.parse(element.date!).toLocal(),
              type: ChartDataType.WEIGHT));
        } else if (t == double) {
          arrWWSampleTemp.add(ChartRawData(
              data: element.weight,
              date: DateTime.parse(element.date!).toLocal(),
              type: ChartDataType.WEIGHT));
        }
      }
    });

    // 달력에 사용 할 Map
    for (var element in convertChartData(arrHRSampleTemp, false)) {
      String timeStr = calDateFormat(element.date);
      calDotHR[timeStr] = 'hr';
    }
    for (var element in convertChartData(arrRRSampleTemp, false)) {
      String timeStr = calDateFormat(element.date);
      calDotRR[timeStr] = 'rr';
    }
    for (var element in convertChartData(arrWWSampleTemp, false)) {
      String timeStr = calDateFormat(element.date);
      calDotWW[timeStr] = 'ww';
    }
  }

  DateTime removeMillisec(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    final String hour = date.hour.toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');
    final String second = date.second.toString().padLeft(2, '0');

    return DateTime.parse("$year-$month-$day $hour:$minute:$second");
  }

  DateTime removeHMS(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');

    return DateTime.parse("$year-$month-$day");
  }

  String calDateFormat(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');

    return "$year.$month.$day";
  }

  List<ChartData> convertChartData(List<ChartRawData> arr, bool isDay) {
    if (arr.isEmpty) {
      return [];
    }

    for (var element in arr) {
      element.date = removeMillisec(element.date);
      element.dateDay = removeHMS(element.date);
    }

    Map<DateTime, List<ChartRawData>> newMap;

    // 3
    if (isDay) {
      newMap = groupBy(arr, (ChartRawData obj) => obj.date);
    } else {
      newMap = groupBy(arr, (ChartRawData obj) => obj.dateDay!);
    }

    // 4
    List<DateTime> keys = newMap.keys.toList().sorted((a, b) => a.compareTo(b));

    // 5
    List<ChartData> arrCals = [];

    for (var i = 0; i < keys.length; i++) {
      var key = keys[i];
      var chartRaw = newMap[key];

      if (chartRaw != null && chartRaw.isNotEmpty) {
        var aValue = chartRaw.fold<double>(
                0, (previousValue, element) => previousValue + element.data) /
            chartRaw.length;
        var lValue = chartRaw.fold<double>(chartRaw[0].data,
            (previousValue, element) => min(previousValue, element.data));
        var hValue = chartRaw.fold<double>(chartRaw[0].data,
            (previousValue, element) => max(previousValue, element.data));

        if (isDay) {
          arrCals.add(ChartData(
              date: key,
              valueH: hValue,
              valueL: lValue,
              valueA: aValue,
              type: chartRaw[0].type));
        } else {
          arrCals.add(ChartData(
              date: key, valueH: hValue, valueL: lValue, valueA: aValue));
        }
      }
    }

    return arrCals;
  }

  var pading = const Padding(padding: EdgeInsets.all(5));
  var pading2 = const Padding(padding: EdgeInsets.all(20));
  var padding3 = const Padding(padding: EdgeInsets.all(4));

  Widget padding(double value) {
    return Padding(padding: EdgeInsets.all(value));
  }

  double getWidth() {
    return chartWidth == 0
        ? (MediaQuery.of(context).size.width - 32)
        : chartWidth;
  }

  Future<void> showCalDialog(bool isStart) async {
    DateTime pocusDate = isStart ? dateStart : dateEnd;
    showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
        child: Stack(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(VetTheme.textSize(context)),
                border: Border.all(color: Colors.black12, width: 1),
                color: Colors.white,
              ),
              child: SizedBox(
                height: VetTheme.diviceH(context)/2,
                width: VetTheme.diviceW(context),
                child: TableCalendar(
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (BuildContext context, date, events) {
                      if (events.isEmpty) return const SizedBox();
                      return ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            var dotColor = Colors.transparent;

                            if (events[index] == 'hr') {
                              dotColor = Colors.red;
                            } else if (events[index] == 'rr') {
                              dotColor = Colors.blue;
                            } else if (events[index] == 'ww') {
                              dotColor = Colors.green;
                            }

                            return Container(
                              margin:  EdgeInsets.only(top: VetTheme.logotextSize(context)),
                              padding: const EdgeInsets.all(1),
                              child: Container(
                                height: 0, // for vertical axis
                                width: 5, // for horizontal axis
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: dotColor,
                                ),
                              ),
                            );
                          });
                    },
                  ),
                  eventLoader: (day) {
                    String dt = calDateFormat(day);
                    List<String> strArr = [];
                    if (calDotHR[dt] != null) {
                      strArr.add(calDotHR[dt]!);
                    }
                    if (calDotRR[dt] != null) {
                      strArr.add(calDotRR[dt]!);
                    }
                    if (calDotWW[dt] != null) {
                      strArr.add(calDotWW[dt]!);
                    }
                    return strArr;
                  },
                  locale: EasyLocalization.of(context)!.locale.toString(),
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 10, 16),
                  focusedDay: pocusDate,
                  currentDay: pocusDate,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: Icon(
                      Icons.arrow_left,
                      color: Colors.grey,
                    ),
                    rightChevronIcon: Icon(
                      Icons.arrow_right,
                      color: Colors.grey,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (isStart) {
                      setStartDate(selectedDay);
                    } else {
                      setEndDate(selectedDay);
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget calendarBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(children: [
        Expanded(
          child: Container(
              padding: const EdgeInsets.fromLTRB(2, 6, 2, 6),
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12, width: 1),
                color: Colors.white,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  child: Row(children: [
                    const Icon(Icons.date_range, size: 30, color: Colors.grey),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
                    Text(calDateFormat(dateStart).toString(),
                        style:  TextStyle(fontSize: VetTheme.textSize(context))),
                  ]),
                  onTap: () {
                    showCalDialog(true);
                  },
                ),
              )),
        ),
        const Text('~'),
        Expanded(
          child: Container(
              padding: const EdgeInsets.fromLTRB(2, 6, 2, 6),
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12, width: 1),
                color: Colors.white,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  child: Row(children: [
                    const Icon(Icons.date_range, size: 30, color: Colors.grey),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
                    Text(calDateFormat(dateEnd).toString(),
                        style: TextStyle(fontSize: VetTheme.textSize(context))),
                  ]),
                  onTap: () {
                    showCalDialog(false);
                  },
                ),
              )),
        ),
      ]),
    );
  }

  Widget dayWeekToggleBtn() {
    return ToggleButtons(
      color: Colors.black.withOpacity(0.60),
      selectedColor: Colors.blue,
      selectedBorderColor: Colors.blue,
      fillColor: mColor0.withOpacity(0.08),
      splashColor: Colors.grey.withOpacity(0.12),
      hoverColor: const Color(0xFF6200EE).withOpacity(0.04),
      borderRadius: BorderRadius.circular(9.0),
      constraints: const BoxConstraints(minHeight: 36.0),
      isSelected: isSelected,
      onPressed: (index) {
        //Day
        if (index == 0) {
          setState(() {
            isLoading = true;
          });
          isSelected[0] = true;
          isSelected[1] = false;
          setStartDate(DateTime(dateEnd.year, dateEnd.month, dateEnd.day - 1));

          //Week
        } else {
          setState(() {
            isLoading = true;
          });
          isSelected[0] = false;
          isSelected[1] = true;
          setStartDate(DateTime(dateEnd.year, dateEnd.month, dateEnd.day - 21));
        }
      },
      children: [
        SizedBox(
            width: MediaQuery.of(context).size.width * 1 / 2 - 10,
            child: Text('Day'.tr(),
                style: TextStyle(fontSize: 20), textAlign: TextAlign.center)),
        SizedBox(
            width: MediaQuery.of(context).size.width * 1 / 2 - 10,
            child: Text('Week'.tr(),
                style: TextStyle(fontSize: 20), textAlign: TextAlign.center)),
      ],
    );
  }

  Widget chartAll() {
    if (_profileManager.userData.authority!=0&&_profileManager.userData.hospitalId != 'null' ) {
      if (widget.animal.hasQRLink == false) {
        return appendQrIcon();
      }
    }
    Widget topText(String sText, Color color) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sText,
            style: TextStyle(color: color, fontSize: 18), //alignment
            textAlign: TextAlign.start,
          ),
        ],
      );
    }

    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        calendarBar(),
        padding(4),
        dayWeekToggleBtn(),
        pading,
        Expanded(
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: const Color.fromARGB(255, 76, 152, 175).withAlpha(10),
              child: Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 32,
                    child: CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: LineChartVerticalText(
                        isDay: isSelected.first,
                        dataAll:
                            isSelected.first ? arrAllSample : arrAllSampleWeek,
                        dataHR:
                            isSelected.first ? arrHRSample : arrHRSampleWeek,
                        dataRR:
                            isSelected.first ? arrRRSample : arrRRSampleWeek,
                        dataWeight:
                            isSelected.first ? arrWWSample : arrWWSampleWeek,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                    //왼쪽 12 마진은 좌측 기준 TEXT와 겹치지 않도록 하기 위해 사용
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      //스크롤 바운스 없애기
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: getWidth(),
                        child: RawGestureDetector(
                          gestures: {
                            _HorizontalDragRecognizer:
                                GestureRecognizerFactoryWithHandlers<
                                    _HorizontalDragRecognizer>(
                              () => _HorizontalDragRecognizer(),
                              (_HorizontalDragRecognizer instance) {
                                instance.onUpdate = (details) {
                                  var totalWidth =
                                      MediaQuery.of(context).size.width - 32;
                                  if (getWidth() > totalWidth &&
                                      isLongTouch == false) {
                                    var scrollOffset =
                                        _scrollController.offset -
                                            details.delta.dx;
                                    var isRight = totalWidth + scrollOffset;
                                    if (0 < scrollOffset &&
                                        isRight < getWidth()) {
                                      _scrollController.jumpTo(scrollOffset);
                                    }
                                  }
                                };
                              },
                            ),
                            _ScaleRecognizer:
                                GestureRecognizerFactoryWithHandlers<
                                    _ScaleRecognizer>(
                              () => _ScaleRecognizer(),
                              (_ScaleRecognizer instance) {
                                instance
                                  ..onStart = (details) {}
                                  ..onUpdate = (details) {
                                    var totalWidth =
                                        MediaQuery.of(context).size.width - 32;
                                    setState(() {
                                      if (chartWidth == 0) {
                                        chartWidth = totalWidth;
                                      }
                                      setState(() {
                                        if (details.horizontalScale < 1.0) {
                                          var tmpWidth = chartWidth - 5;
                                          if (tmpWidth < totalWidth) {
                                            chartWidth = totalWidth;
                                          } else {
                                            chartWidth = tmpWidth;
                                            _scrollController.jumpTo(
                                                _scrollController.offset - 2.5);
                                          }
                                        } else if (details.horizontalScale >
                                            1.0) {
                                          chartWidth = chartWidth + 7;
                                          _scrollController.jumpTo(
                                              _scrollController.offset + 3.5);
                                        }
                                      });
                                    });
                                  }
                                  ..onEnd = (details) {};
                              },
                            ),
                          },
                          child: GestureDetector(
                            onLongPressStart: (details) {
                              var x = details.localPosition.dx;

                              setState(() {
                                isLongTouch = true;
                                touchX = x;
                              });
                            },
                            onLongPressMoveUpdate: (details) {
                              var x = details.localPosition.dx;

                              setState(() {
                                isLongTouch = true;
                                touchX = x;
                              });
                            },
                            onLongPressEnd: (details) {
                              setState(() {
                                isLongTouch = false;
                                touchX = -1;
                              });
                            },
                            onDoubleTap: () {
                              setState(() {
                                chartWidth =
                                    MediaQuery.of(context).size.width - 32;
                              });
                            },
                            child: CustomPaint(
                              size:
                                  const Size(double.infinity, double.infinity),
                              painter: LineChart(
                                isDay: isSelected.first,
                                dataAll: isSelected.first
                                    ? arrAllSample
                                    : arrAllSampleWeek,
                                dataHR: isSelected.first
                                    ? arrHRSample
                                    : arrHRSampleWeek,
                                dataRR: isSelected.first
                                    ? arrRRSample
                                    : arrRRSampleWeek,
                                dataWeight: isSelected.first
                                    ? arrWWSample
                                    : arrWWSampleWeek,
                              ),
                              foregroundPainter: LineChartOverlay(
                                touchX: touchX,
                                isDay: isSelected.first,
                                dataAll: isSelected.first
                                    ? arrAllSample
                                    : arrAllSampleWeek,
                                dataHR: isSelected.first
                                    ? arrHRSample
                                    : arrHRSampleWeek,
                                dataRR: isSelected.first
                                    ? arrRRSample
                                    : arrRRSampleWeek,
                                dataWeight: isSelected.first
                                    ? arrWWSample
                                    : arrWWSampleWeek,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  arrAllSample.isNotEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: topText(
                                "HR".tr(),
                                Colors.red,
                              ),
                            ),
                            Expanded(
                              child: topText("RR".tr(),
                                  const Color.fromARGB(255, 52, 19, 237)),
                            ),
                            Expanded(
                              child: topText("Weight".tr(),
                                  const Color.fromARGB(255, 19, 103, 10)),
                            ),
                          ],
                        )
                      : Stack(),
                  (isLoading == false && arrAllSample.isEmpty)
                      ? Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.insert_chart_outlined_outlined,
                                    size: 80, color: Colors.grey),
                                Text("The data does not exist.".tr()),
                              ]),
                        )
                      : Stack(),
                ],
              )),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //키패드 올라갈 때 Chart UI 밀리지 않도록 설정
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _profileManager.animalListRefresh(true);
            UtilityFunction.goBackToMainPage(context);
           },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text("HR/RR Graph".tr()),
        actions: [
          _profileManager.userData.authority == 0
              ? Container()
              : IconButton(
                  onPressed: () async {
                    final result = await UtilityComponents.buildDialog(
                        context, widget.animal);
                    if (result == null) {
                      return;
                    }
                    return dialogResult(result, widget.animal);
                  },
                  icon: Icon(Icons.edit_note_sharp))
        ],
      ),
      body: Column(
        children: [
          AnimalCard(animal: widget.animal),
          padding(4),
          isLoading ? const LoadingBar() : chartAll()
        ],
      ),
    );
  }

  Widget appendQrIcon() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: const Color.fromARGB(255, 76, 152, 175).withAlpha(10),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    var a = await UtilityComponents.notiyDialog(context);
                    UtilityFunction.log.e(a);
                    if (a != null) {
                      if (a) {
                          return UtilityFunction.moveScreen(
                            context, '/animalQrScan', widget.animal.id);
                      }
                    }
                    return;
                  },
                  child: Icon(Icons.qr_code, size: 80, color: Colors.black),
                ),
                padding(3),
                Text("QR link is required to monitor data".tr()),
              ]),
        ),
      ),
    );
  }

  Future<void> dialogResult(var result, Animal animal) async {
    UtilityFunction.log.e(animal.toJson());
    final type = result['type'];
    final fun = result['fun'];
    final screen = result['screen'];
    if (type == 'move') {
      if (screen == '/changeQr' || screen == '/attachQr') {
        // return UtilityFunction.moveScreen(context, '/animalQrScan',widget.animal.id);
        UtilityFunction.log.e('큐알 업데이트');
        return UtilityFunction.moveScreen(context, '/animalQrScan', animal.id);
      } else if (screen == '/modifyChart') {
        final _animal = animal.toJson();
        _animal['modifyChart'] = true;
        UtilityFunction.log.e(_animal);
        UtilityFunction.log.e(animal.breedCode);
        UtilityFunction.moveScreen(context, '/animalDataModify', _animal);
        UtilityFunction.log.e('차트 변경');
        // 차트 변경 로직 추가
      }
    } else if (type == 'fun') {
      if (fun == 'setHidePatient') {
        return await hiddenAnimal(animal.id!);
        //동물숨기기
      }
    }
  }

  Future<dynamic> hiddenAnimal(String animalId) async {
    setLoading(true);
    Map<String, dynamic> body = {"isVisible": 'false'};
    await _apiService.updateVisibility2(animalId, body).then((value) {
      value.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? hiddenAnimal(animalId)
              : await logoutAndPushToHome();
        }
        UtilityComponents.showToast(
            "${'Animal hidden failed'.tr()}:${error.message ?? ""}");
        return;
      }, (success) {
        UtilityComponents.showToast('Animal hidden success'.tr());
        _profileManager.animalListRefresh(true);

        //_profileManager.refreshAnimalList();
        UtilityFunction.goBackToMainPage(context);
      });
    });
    return;
  }

  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    setLoading(false);
  }


}

class _HorizontalDragRecognizer extends HorizontalDragGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}

class _ScaleRecognizer extends ScaleGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
