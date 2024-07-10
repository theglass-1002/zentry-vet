import 'dart:math';

import 'package:flutter/material.dart';

class LineChart extends CustomPainter {

  final bool isDay;
  List<ChartData> dataAll;
  List<ChartData> dataHR;
  List<ChartData> dataRR;
  List<ChartData> dataWeight;

  final double topPadding = 60;
  final double fontSize = 11.0;
  final double lineWidth = 1.0;
  final double margin = 30.0;
  final int divisionYUnit = 5;

  double spacing = 0.0;

  double maxY_HR = 0;
  double maxY_RR = 0;
  double maxY_WW = 0;

  double minY_HR = 0;
  double minY_RR = 0;
  double minY_WW = 0;

  LineChart({
    required this.isDay, 
    required this.dataAll, 
    required this.dataHR, 
    required this.dataRR, 
    required this.dataWeight, 
  });

  @override
  void paint(Canvas canvas, Size size) {

    if ( dataAll.isNotEmpty ) {
      var tmpSize = size;

      // -----------------------------------------------------------------------------------------------
      // All -------------------------------------------------------------------------------------------
      spacing = (size.width - margin*2) / (dataAll.length - 1); // 좌표를 일정 간격으로 벌리지 위한 값을 구합니다.
      if (spacing.isNaN || spacing.isInfinite) {
        spacing = 60.0;
      }

      maxY_HR     = getYaxisMax(dataHR);
      maxY_RR     = getYaxisMax(dataRR);
      maxY_WW     = getYaxisMax(dataWeight);

      minY_HR     = getYaxisMin(dataHR);
      minY_RR     = getYaxisMin(dataRR);
      minY_WW     = getYaxisMin(dataWeight);
      
      // print("maxY_HR = $maxY_HR, minY_HR = $minY_HR");
      // print("maxY_RR = $maxY_RR, minY_RR = $minY_RR");
      // print("maxY_WW = $maxY_WW, minY_WW = $minY_WW");

    
      // 심박 -------------------------------------------------------------------------------------------
      //상하 고저 offset 배열
      if (isDay == false) {
        List<List<Offset>> offsetsHR = getCoordinatesHL2(dataHR, tmpSize, 1);
        for (var offsets in offsetsHR) {
          drawLines(canvas,  tmpSize, offsets, Colors.red); // 구한 좌표를 바탕으로 선을 그립니다.
        }
      }
    
      // 점들이 그려질 좌표를 구합니다.   
      List<DotData> dotDataHR = getCoordinates2(dataHR, tmpSize, 1);

      if (spacing > 20) {
        drawText2(canvas, dotDataHR, Colors.red); // 점 위의 Text 값을 그립니다.
        drawLines2(canvas, dotDataHR, Colors.red); // 구한 좌표를 바탕으로 선을 그립니다.
      }
      drawPoints2(canvas, dotDataHR, Colors.red); // 좌표에 따라 점을 그립니다. 


      // 호흡 -------------------------------------------------------------------------------------------
      //상하 고저 offset 배열
      if (isDay == false) {
        List<List<Offset>> offsetsRR = getCoordinatesHL2(dataRR, tmpSize, 2); 
        for (var offsets in offsetsRR) {
          drawLines(canvas,  tmpSize, offsets, Colors.blue); // 구한 좌표를 바탕으로 선을 그립니다.
        }
      }

      // 점들이 그려질 좌표를 구합니다.
      List<DotData> dotDatasRR = getCoordinates2(dataRR, tmpSize, 2);

      if (spacing > 20) {
        drawText2(canvas, dotDatasRR, Colors.blue); // 점 위의 Text 값을 그립니다.
        drawLines2(canvas, dotDatasRR, Colors.blue); // 구한 좌표를 바탕으로 선을 그립니다.
      }

      drawPoints2(canvas, dotDatasRR, Colors.blue); // 좌표에 따라 점을 그립니다. 


      // 몸무게 -------------------------------------------------------------------------------------------
      //상하 고저 offset 배열
      if (isDay == false) {
        List<List<Offset>> offsetsWeight = getCoordinatesHLWeight(dataWeight, tmpSize); 
        for (var offsets in offsetsWeight) {
          drawLines(canvas,  tmpSize, offsets, const Color.fromARGB(255, 14, 128, 29)); // 구한 좌표를 바탕으로 선을 그립니다.
        }
      }

      // 점들이 그려질 좌표를 구합니다.
      List<DotData> dotDatasWeight = getCoordinatesWeight2(dataWeight, tmpSize); 


      if (spacing > 20) {
        drawText2(canvas, dotDatasWeight, const Color.fromARGB(255, 14, 128, 29)); // 점 위의 Text 값을 그립니다.
        drawLines2(canvas, dotDatasWeight, const Color.fromARGB(255, 14, 128, 29) ); // 구한 좌표를 바탕으로 선을 그립니다.
      }

      drawPoints2(canvas, dotDatasWeight, const Color.fromARGB(255, 14, 128, 29)); // 좌표에 따라 점을 그립니다. 
      //------------------------------------------------------------------------------------------------
      //------------------------------------------------------------------------------------------------

      List<Offset> dateOffsets = getCoordinatesAll(dataAll, tmpSize);
      drawDateText(canvas, dateOffsets, dataAll, tmpSize); // 하단의 일자를 그립니다. //임시 주석 처리
    }
  }

double getYaxisMax(List<ChartData> datas) {

  if (datas.isEmpty) return 0.0;

  double maxY  = datas.fold(datas[0].valueA, (previousValue, element) => max(previousValue, element.valueA));
  double maxYH = datas.fold(datas[0].valueH, (previousValue, element) => max(previousValue, element.valueH));
  double maxYL = datas.fold(datas[0].valueL, (previousValue, element) => max(previousValue, element.valueL));
  maxY = max(maxY, max(maxYH, maxYL)); 
  return maxY;
}

double getYaxisMin(List<ChartData> datas) {

  if (datas.isEmpty) return 0.0;

  double minY  = datas.fold(datas[0].valueA, (previousValue, element) => min(previousValue, element.valueA));
  double minYH = datas.fold(datas[0].valueH, (previousValue, element) => min(previousValue, element.valueH));
  double minYL = datas.fold(datas[0].valueL, (previousValue, element) => min(previousValue, element.valueL));
  minY = min(minY, min(minYH, minYL)); 
  return minY;
}

List<Offset> getCoordinatesAll(List<ChartData> datas, Size size) {

  List<Offset> coordinates = [];

  for (int i = 0; i < datas.length; i++) {
  
    double x = spacing * i + margin; // x축 좌표를 구합니다. 

    Offset coord = Offset(x, 0);
    dataAll[i].valueAPoint = coord;

    coordinates.add(coord); 
  }

  return coordinates;
}

  List<DotData> getCoordinates2(List<ChartData> datas, Size size, int nHPosition) {

    Map<DateTime, ChartData> test01 = <DateTime, ChartData>{};
    for (var element in datas) {
      test01[element.date] = element;
    }

    List<DotData> coordinates = [];

    double h = size.height / 3 - topPadding;
    double maxY = 0;
    double minY = 0;

    if (nHPosition == 1) {
      maxY = maxY_HR;
      minY = minY_HR; 
      
    }else if (nHPosition == 2) {
      maxY = maxY_RR;
      minY = minY_RR; 
    }
    
    for (int i = 0; i < dataAll.length; i++) {

      double x = spacing * i + margin; // x축 좌표를 구합니다. 

      var ppp = test01[dataAll[i].date];
      if ( ppp != null) {
        double normalizedY = (ppp.valueA - minY ) / (maxY - minY); // 정규화한다. 정규화란 [0 ~ 1] 사이가 나오게 값을 변경하는 것.
        if (normalizedY.isNaN) {
          if (ppp.valueA == 0) { 
            normalizedY = 0.0; // 0데이터 1개만 있는 경우 Y 하단 라인에 맞추기
          }else{
            normalizedY = 0.5; // 1개의 데이터만 있고 데이터 값이 0보다 큰 경우 Y축 중간 위치에 배치
          }
        }
        double y = h - (normalizedY * h);
        y = y + topPadding/2;

        if (nHPosition == 2) {
          y = y + size.height / 3;
        }
        
        DotData coord = DotData(data: ppp.valueA, type: ppp.type, point: Offset(x, y));
        ppp.valueAPoint = coord.point;

        coordinates.add(coord);
      }      
    }

    return coordinates;
  }

  List<List<Offset>> getCoordinatesHL2(List<ChartData> datas, Size size, int nHPosition) {

    Map<DateTime, ChartData> test01 = <DateTime, ChartData>{};
    for (var element in datas) {
      test01[element.date] = element;
    }

    List<List<Offset>> coordinates = [];

    double h = 0;
    double maxY = 0;
    double minY = 0;

    if (nHPosition == 1) {
      h = size.height / 3 - topPadding;
      maxY = maxY_HR;
      minY = minY_HR; 
      
    }else if (nHPosition == 2) {
      h = size.height / 3 - topPadding;
      maxY = maxY_RR;
      minY = minY_RR; 
    }
    

    for (int i = 0; i < dataAll.length; i++) {

      double x = spacing * i + margin; // x축 좌표를 구합니다. 
      
      var ppp = test01[dataAll[i].date];
      if ( ppp != null) {
        //max
        double normalizedY2 = (ppp.valueH - minY ) / (maxY - minY); // 정규화한다. 정규화란 [0 ~ 1] 사이가 나오게 값을 변경하는 것.
        double y2 = h - (normalizedY2 * h); 
        y2 = y2 + topPadding/2;

        if (nHPosition == 2) {
          y2 = y2 + size.height / 3;
        }

        Offset coord2 = Offset(x, y2);
        ppp.valueHPoint = coord2;

        //min
        double normalizedY3 = (ppp.valueL - minY ) / (maxY - minY); // 정규화한다. 정규화란 [0 ~ 1] 사이가 나오게 값을 변경하는 것.
        double y3 = h - (normalizedY3 * h); 
        y3 = y3 + topPadding/2;

        if (nHPosition == 2) {
          y3 = y3 + size.height / 3;
        }

        Offset coord3 = Offset(x, y3);
        ppp.valueLPoint = coord3;
        
        coordinates.add([coord2, coord3]);
      }      
    }

    return coordinates;
  }

  //몸무게 좌표 구하기
  List<DotData> getCoordinatesWeight2(List<ChartData> datas, Size size) {

    if (datas.isEmpty) {
      return [];
    }

    Map<DateTime, ChartData> test01 = <DateTime, ChartData>{};
    for (var element in datas) {
      test01[element.date] = element;
    }
    
    List<DotData> coordinates = [];

    double h = size.height/3 - topPadding; // 패딩을 제외한 화면의 높이를 구합니다. 
    double maxY = maxY_WW;
    double minY = minY_WW;

    for (int i = 0; i < dataAll.length; i++) {

      double x = spacing * i + margin; // x축 좌표를 구합니다. 

      // DateTime tmpDate = removeHMS(dataAll[i].date);
      // var ppp = test01[tmpDate];
      
      var ppp = test01[dataAll[i].date];
      if ( ppp != null) {
        double normalizedY = (ppp.valueA - minY ) / (maxY - minY); // 정규화한다. 정규화란 [0 ~ 1] 사이가 나오게 값을 변경하는 것.
        if (normalizedY.isNaN) {
          if (ppp.valueA == 0) { 
            normalizedY = 0.0; // 0데이터 1개만 있는 경우 Y 하단 라인에 맞추기
          }else{
            normalizedY = 0.5; // 1개의 데이터만 있고 데이터 값이 0보다 큰 경우 Y축 중간 위치에 배치
          }
        }
        double y = h - (normalizedY * h);

        y = y + topPadding/2;
        y = y + (size.height*2 / 3);

        DotData coord = DotData(data: ppp.valueA, type: ppp.type, point: Offset(x, y));

        coordinates.add(coord);
      }
    }
    return coordinates;
  }

  //몸무게 상하 좌표 구하기
  List<List<Offset>> getCoordinatesHLWeight(List<ChartData> datas, Size size) {

    Map<DateTime, ChartData> test01 = <DateTime, ChartData>{};
    for (var element in datas) {
      test01[element.date] = element;
    }

    List<List<Offset>> coordinates = [];

    double h = 0;
    double maxY = 0;
    double minY = 0;

    h = size.height / 3 - topPadding;
    maxY = maxY_WW;
    minY = minY_WW; 

    for (int i = 0; i < dataAll.length; i++) {

      double x = spacing * i + margin; // x축 좌표를 구합니다. 

      // DateTime tmpDate = removeHMS(dataAll[i].date);
      // var ppp = test01[tmpDate];

      var ppp = test01[dataAll[i].date];
      if ( ppp != null ) {
        //max
        double normalizedY2 = (ppp.valueH - minY ) / (maxY - minY); // 정규화한다. 정규화란 [0 ~ 1] 사이가 나오게 값을 변경하는 것.
        double y2 = h - (normalizedY2 * h); 
        y2 = y2 + topPadding/2;
        y2 = y2 + size.height*2 / 3;

        Offset coord2 = Offset(x, y2);
        ppp.valueHPoint = coord2;

        //min
        double normalizedY3 = (ppp.valueL - minY ) / (maxY - minY); // 정규화한다. 정규화란 [0 ~ 1] 사이가 나오게 값을 변경하는 것.
        double y3 = h - (normalizedY3 * h); 
        y3 = y3 + topPadding/2;
        y3 = y3 + size.height*2 / 3;

        Offset coord3 = Offset(x, y3);
        ppp.valueLPoint = coord3;
        
        coordinates.add([coord2, coord3]);
      }     
    }

    return coordinates;
  }

  void drawLines(Canvas canvas, Size size, List<Offset> offsets, Color lineColor) {
    Paint paint = Paint()
      ..color       = lineColor
      ..strokeWidth = lineWidth
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    Path path = Path(); 

    double dx = offsets[0].dx;
    double dy = offsets[0].dy;

    path.moveTo(dx, dy);
    offsets.map((offset) => path.lineTo(offset.dx , offset.dy)).toList();

    canvas.drawPath(path, paint);
  }

  void drawLines2(Canvas canvas, List<DotData> dotDatas, Color lineColor) {

    if (dotDatas.isEmpty) {
      return;
    }

    Paint paint = Paint()
      ..color       = lineColor
      ..strokeWidth = lineWidth
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    Path path = Path(); 

    double dx = dotDatas[0].point.dx;
    double dy = dotDatas[0].point.dy;

    path.moveTo(dx, dy);
    dotDatas.map((dotData) => path.lineTo(dotData.point.dx , dotData.point.dy)).toList();

    canvas.drawPath(path, paint);
  }

  void drawPoints2(Canvas canvas, List<DotData> datas, Color dotColor) {
    
    for (var i = 0; i < datas.length; i++) {

      if (datas[i].type == ChartDataType.HR_MANUAL || datas[i].type == ChartDataType.RR_MANUAL) {
        Paint paint = Paint()
        ..color = dotColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

        canvas.drawCircle(datas[i].point, 3, paint);

      }else{
        Paint paint = Paint()
        ..color = dotColor
        ..style = PaintingStyle.fill;

        canvas.drawCircle(datas[i].point, 4, paint);
      }
    }
  }

  void drawText2(Canvas canvas, List<DotData> dotDatas, Color textColor) {
    for (var i = 0; i < dotDatas.length; i++) {

      String value = dotDatas[i].data.toStringAsFixed(1).toString();
      if (value.substring(value.length - 1) == '0') {
        value = value.substring(0, value.length - 2);
      }
      drawTextValue(canvas, value, dotDatas[i].point, true, textColor); 
    }
  }

  void drawTextValue(Canvas canvas, String text, Offset pos, bool textUpward, Color textColor) {
    TextSpan maxSpan = TextSpan(style: TextStyle(fontSize: fontSize, color: textColor, fontWeight: FontWeight.bold), text: text); 
    TextPainter tp = TextPainter(text: maxSpan, textDirection: TextDirection.ltr);
    tp.layout();

    double y = textUpward ? -tp.height * 1.2  : tp.height * 0.5; // 텍스트의 방향을 고려해 y축 값을 보정해줍니다.
    double dx = pos.dx - tp.width / 2; // 텍스트의 위치를 고려해 x축 값을 보정해줍니다.
    double dy = pos.dy + y; 

    Offset offset = Offset(dx, dy);

    tp.paint(canvas, offset);
  }

  void drawDateText(Canvas canvas, List<Offset> offsets, List<ChartData> datas, Size size) {
      
    var mod = offsets.length ~/ (size.width / 60);
    if (mod < 1) {
      mod = 1;
    }

    for (var i = 0; i < datas.length; i++) {
      if (i%mod == 0) {
        String value = datas[i].getDateString(isDay, false);
        drawDateTextValue(canvas, value, offsets[i], true, size); 
      }
    }
  }
  
  void drawDateTextValue(Canvas canvas, String text, Offset pos, bool textUpward, Size size) {
    TextSpan maxSpan = TextSpan(style: const TextStyle(fontSize: 10, color: Color.fromARGB(255, 26, 182, 159), fontWeight: FontWeight.bold), text: text); 
    TextPainter tp = TextPainter(text: maxSpan, textDirection: TextDirection.ltr);
    tp.layout();

    double dx = pos.dx - tp.width / 2; // 텍스트의 위치를 고려해 x축 값을 보정해줍니다.
    double dy = size.height - tp.height;

    Offset offset = Offset(dx, dy);

    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(LineChart oldDelegate) {
    return oldDelegate.dataAll != dataAll;
  }

}





ChartDataType convertChartTypeStringTo(String str) {

  if (str == "HR_AUTO_RESERVATION") {
    return ChartDataType.HR_AUTO_RESERVATION;
  }else if (str == "HR_AUTO") {
    return ChartDataType.HR_AUTO;
  }else if (str == "HR_MANUAL") {
    return ChartDataType.HR_MANUAL;

  }else if (str == "RR_AUTO_RESERVATION") {
    return ChartDataType.RR_AUTO_RESERVATION;
  }else if (str == "RR_AUTO") {
    return ChartDataType.RR_AUTO;
  }else if (str == "RR_MANUAL") {
    return ChartDataType.RR_MANUAL;

  }else{
    return ChartDataType.NONE;
  }
}

enum ChartDataType {
  HR_AUTO_RESERVATION,
  HR_AUTO,
  HR_MANUAL,

  RR_AUTO_RESERVATION,
  RR_AUTO,
  RR_MANUAL,

  WEIGHT,
  NONE,
}

class DotData {
  final Offset point;
  final ChartDataType? type;
  final double data;

  DotData({
    required this.data,
    required this.point,
    required this.type,
  });
}

class ChartRawData {
  DateTime date;
  DateTime? dateDay;
  double data;
  ChartDataType type;

  ChartRawData({
    required this.date,
    required this.data,
    required this.type,
  });
}

class ChartData {
  DateTime date;
  ChartDataType? type;

  final double valueH;
  final double valueL;
  final double valueA;

  Offset? valueHPoint;
  Offset? valueLPoint;
  Offset? valueAPoint;

  ChartData({
    required this.date,
    required this.valueH,
    required this.valueL,
    required this.valueA,
    this.type,
  });
  
  String getDateString(bool isDay, bool isOverlaypupup) {
    if (isDay) {
      return dateToStringMMddHHmm(date, !isOverlaypupup);
    }else{ //week
      return dateToStringMMdd(date);
    }
  }

  String dateToStringMMddHHmm(DateTime date, bool isNewLine) { 
    final String month  = date.month.toString().padLeft(2, '0');
    final String day    = date.day.toString().padLeft(2, '0');
    final String hour   = date.hour.toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');
    
    if (isNewLine) {
      return "$month.$day\n$hour:$minute";  
    }else{
      return "$month.$day $hour:$minute";
    }
  }

  String dateToStringMMdd(DateTime date) { 
    final String month  = date.month.toString().padLeft(2, '0');
    final String day    = date.day.toString().padLeft(2, '0');

    return "$month.$day";
  }

}


DateTime removeHMS(DateTime date) {
  final String year  = date.year.toString().padLeft(4, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String day   = date.day.toString().padLeft(2, '0');

  return DateTime.parse("$year-$month-$day");
}

