import 'package:dolittle_for_vet/screens/LineChartPainter.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/material.dart';

class LineChartOverlay extends CustomPainter {
  double touchX;
  final bool isDay;
  List<ChartData> dataAll;
  List<ChartData> dataHR;
  List<ChartData> dataRR;
  List<ChartData> dataWeight;
  UtilityFunction utilityFunction = UtilityFunction();

  final double topPadding = 60;
  final double lineWidth = 1.0;
  final double margin = 30.0;
  double spacing = 0.0;
  LineChartOverlay({
    required this.touchX,
    required this.isDay,
    required this.dataAll,
    required this.dataHR,
    required this.dataRR,
    required this.dataWeight,
  });

  void paintRect(Canvas canvas, Size screenSize, Size boxSize, double dx) {
    final paint = Paint();
    paint.color = Colors.white;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.fill;

    final Path path1 = Path()
      ..addRRect(
        RRect.fromLTRBR(
            dx - boxSize.width,
            screenSize.height / 2 - boxSize.height,
            dx + boxSize.width,
            screenSize.height / 2 + boxSize.height,
            const Radius.elliptical(10, 10)),
      );

    canvas.drawPath(path1, paint);

    final paint2 = Paint();
    paint2.color = Colors.grey;
    paint2.strokeWidth = 1;
    paint2.style = PaintingStyle.stroke;

    final Path path2 = Path()
      ..addRRect(
        RRect.fromLTRBR(
            dx - boxSize.width,
            screenSize.height / 2 - boxSize.height,
            dx + boxSize.width,
            screenSize.height / 2 + boxSize.height,
            const Radius.elliptical(10, 10)),
      );

    canvas.drawPath(path2, paint2);
  }

  void drawText(Canvas canvas, String value, Offset offset, Color textColor,
      double fontSize) {
    if (value.isNotEmpty) {
      drawTextValue22(canvas, value, offset, textColor, fontSize);
    }
  }

  void drawTextValue22(Canvas canvas, String text, Offset pos, Color textColor,
      double fontSize) {
    TextSpan maxSpan = TextSpan(
        style: TextStyle(
            fontSize: fontSize, color: textColor, fontWeight: FontWeight.bold),
        text: text);
    TextPainter tp =
        TextPainter(text: maxSpan, textDirection: TextDirection.ltr);
    tp.layout();

    double y = -tp.height; // 텍스트의 방향을 고려해 y축 값을 보정해줍니다.
    double dx = pos.dx - tp.width / 2; // 텍스트의 위치를 고려해 x축 값을 보정해줍니다.
    double dy = pos.dy + y;

    Offset offset = Offset(dx, dy);

    tp.paint(canvas, offset);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (touchX < 0) {
      return;
    }

    if (dataAll.isNotEmpty) {
      var tmpSize = size;

      // -----------------------------------------------------------------------------------------------
      // All -------------------------------------------------------------------------------------------
      spacing = (size.width - margin * 2) /
          (dataAll.length - 1); // 좌표를 일정 간격으로 벌리지 위한 값을 구합니다.
      if (spacing.isNaN || spacing.isInfinite) {
        spacing = 60.0;
      }

      getCoordinatesAll();

      double ddd = 0;
      String dateString = "";

      for (var i = 0; i < dataAll.length; i++) {
        var dx = dataAll[i].valueAPoint?.dx;
        var sDate = dataAll[i].getDateString(isDay, true);

        if (dx != null) {
          var s = spacing / 2;
          var rangeL = dx - s;
          var rangeR = dx + s;

          if (rangeL <= touchX && touchX <= rangeR) {
            ddd = dx;
            dateString = sDate;
            break;
          }
        }
      }

      double? hrValue;
      List<DotData> dotDataHR = getCoordinates2(dataHR, tmpSize, 1);
      for (var i = 0; i < dotDataHR.length; i++) {
        var dx = dotDataHR[i].point.dx;
        var value = dotDataHR[i].data;

        var s = spacing / 2;
        var rangeL = dx - s;
        var rangeR = dx + s;

        if (rangeL <= touchX && touchX <= rangeR) {
          hrValue = value;
          break;
        }
      }

      double? rrValue;
      List<DotData> dotDatasRR = getCoordinates2(dataRR, tmpSize, 2);
      for (var i = 0; i < dotDatasRR.length; i++) {
        var dx = dotDatasRR[i].point.dx;
        var value = dotDatasRR[i].data;

        var s = spacing / 2;
        var rangeL = dx - s;
        var rangeR = dx + s;

        if (rangeL <= touchX && touchX <= rangeR) {
          rrValue = value;
          break;
        }
      }

      double? wwValue;
      List<DotData> dotDatasWeight = getCoordinatesWeight2(dataWeight, tmpSize);
      for (var i = 0; i < dotDatasWeight.length; i++) {
        var dx = dotDatasWeight[i].point.dx;
        var value = dotDatasWeight[i].data;

        var s = spacing / 2;
        var rangeL = dx - s;
        var rangeR = dx + s;

        if (rangeL <= touchX && touchX <= rangeR) {
          wwValue = value;
          break;
        }
      }

      if (hrValue != null || rrValue != null || wwValue != null) {
        //세로 기준선 --------------------------------------------------------------------
        drawDashVerticalLine(canvas, Offset(ddd, 0), Colors.grey,
            size.height - 25); // -25는 하단 일자 Text 높이
      }

      //TEXT Size 계산 --------------------------------------------------------------------
      String sHR = "";
      String sRR = "";
      String sWW = "";

      Size oHR = const Size(0, 0);
      Size oRR = const Size(0, 0);
      Size oWW = const Size(0, 0);

      Size oBoxSize = const Size(0, 0);

      if (hrValue != null) {
        sHR = utilityFunction.getTranslationString('HR') + hrValue.toInt().toString();
        
      }
      if (rrValue != null) {
        sRR = utilityFunction.getTranslationString('RR') + rrValue.toInt().toString();
      }
      if (wwValue != null) {
        var wwString = wwValue.toStringAsFixed(1).toString();
        if (wwString.substring(wwString.length - 1) == '0') {
          sWW = utilityFunction.getTranslationString('Weight') + wwString.substring(0, wwString.length - 2);
        }else{
          sWW = utilityFunction.getTranslationString('Weight') + wwString;
        }
      }

      // 라운드 박스, Text --------------------------------------------------------------------

      //다 있음
      if (sHR.isNotEmpty && sRR.isNotEmpty && sWW.isNotEmpty) {
        oBoxSize = Size(46, 18 * 2 + 4);

        paintRect(canvas, size, oBoxSize, ddd);
        drawText(canvas, dateString, Offset(ddd, size.height / 2 - 18),
            Colors.grey.shade700, 12);
        drawText(canvas, sHR, Offset(ddd, size.height / 2 + 2), Colors.red, 16);
        drawText(canvas, sRR, Offset(ddd, size.height / 2 + 18.0 + 2),
            Colors.blue, 16);
        drawText(canvas, sWW, Offset(ddd, size.height / 2 + 36.0 + 2),
            Colors.green, 16);

        //심박만 있음
      } else if (sHR.isNotEmpty && sRR.isEmpty && sWW.isEmpty) {
        oBoxSize = Size(46, 18 * 1 + 4);

        paintRect(canvas, size, oBoxSize, ddd);
        drawText(canvas, dateString, Offset(ddd, size.height / 2),
            Colors.grey.shade700, 12);
        drawText(
            canvas, sHR, Offset(ddd, size.height / 2 + 18), Colors.red, 16);

        //호흡만 있음
      } else if (sHR.isEmpty && sRR.isNotEmpty && sWW.isEmpty) {
        oBoxSize = Size(46, 18 * 1 + 4);

        paintRect(canvas, size, oBoxSize, ddd);
        drawText(canvas, dateString, Offset(ddd, size.height / 2),
            Colors.grey.shade700, 12);
        drawText(
            canvas, sRR, Offset(ddd, size.height / 2 + 18), Colors.blue, 16);

        //몸무게만 있음
      } else if (sHR.isEmpty && sRR.isEmpty && sWW.isNotEmpty) {
        oBoxSize = Size(46, 18 * 1 + 4);

        paintRect(canvas, size, oBoxSize, ddd);
        drawText(canvas, dateString, Offset(ddd, size.height / 2),
            Colors.grey.shade700, 12);
        drawText(
            canvas, sWW, Offset(ddd, size.height / 2 + 18), Colors.green, 16);

        //심박, 호흡 있음
      } else if (sHR.isNotEmpty && sRR.isNotEmpty && sWW.isEmpty) {
        oBoxSize = Size(46, 18 * 2 + 4);

        paintRect(canvas, size, oBoxSize, ddd);
        drawText(canvas, dateString, Offset(ddd, size.height / 2 - 18.0 + 2),
            Colors.grey.shade700, 12);
        drawText(canvas, sHR, Offset(ddd, size.height / 2 + 4), Colors.red, 16);
        drawText(canvas, sRR, Offset(ddd, size.height / 2 + 18.0 + 6),
            Colors.blue, 16);

        //호흡, 몸무게 있음
      } else if (sHR.isEmpty && sRR.isNotEmpty && sWW.isNotEmpty) {
        oBoxSize = Size(46, 18 * 2 + 4);

        paintRect(canvas, size, oBoxSize, ddd);
        drawText(canvas, dateString, Offset(ddd, size.height / 2 - 18.0 + 2),
            Colors.grey.shade700, 12);
        drawText(
            canvas, sRR, Offset(ddd, size.height / 2 + 4), Colors.blue, 16);
        drawText(canvas, sWW, Offset(ddd, size.height / 2 + 18.0 + 6),
            Colors.green, 16);

        //심박, 몸무게 있음
      } else if (sHR.isNotEmpty && sRR.isEmpty && sWW.isNotEmpty) {
        oBoxSize = Size(46, 18 * 2 + 4);

        paintRect(canvas, size, oBoxSize, ddd);
        drawText(canvas, dateString, Offset(ddd, size.height / 2 - 18.0 + 2),
            Colors.grey.shade700, 12);
        drawText(canvas, sHR, Offset(ddd, size.height / 2 + 4), Colors.red, 16);
        drawText(canvas, sWW, Offset(ddd, size.height / 2 + 18.0 + 6),
            Colors.green, 16);
      } else {
        oBoxSize = Size(0, 0);
      }
    }
  }

  Size getTextSize({String text = '', double fontSize = 15.0}) {
    if (text.isNotEmpty) {
      TextSpan maxSpan =
          TextSpan(style: TextStyle(fontSize: fontSize), text: text);
      TextPainter tp =
          TextPainter(text: maxSpan, textDirection: TextDirection.ltr);
      tp.layout();
      return Size(tp.width, tp.height);
    } else {
      return const Size(0, 0);
    }
  }

  void drawDashVerticalLine(
      Canvas canvas, Offset offset, Color lineColor, double height) {
    if (offset.dy.isNaN) {
      return;
    }

    Paint paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    int dashUnit = 4;
    for (var i = 0; i < height; i = i + dashUnit * 2) {
      canvas.drawLine(Offset(offset.dx, i.toDouble()),
          Offset(offset.dx, (i + dashUnit).toDouble()), paint);
    }
  }

  void getCoordinatesAll() {
    for (int i = 0; i < dataAll.length; i++) {
      double x = spacing * i + margin;
      Offset coord = Offset(x, 0);
      dataAll[i].valueAPoint = coord;
    }
  }

  List<DotData> getCoordinates2(
      List<ChartData> datas, Size size, int nHPosition) {
    Map<DateTime, ChartData> test01 = <DateTime, ChartData>{};
    for (var element in datas) {
      test01[element.date] = element;
    }

    List<DotData> coordinates = [];

    for (int i = 0; i < dataAll.length; i++) {
      double x = spacing * i + margin; // x축 좌표를 구합니다.

      var ppp = test01[dataAll[i].date];
      if (ppp != null) {
        DotData coord =
            DotData(data: ppp.valueA, type: ppp.type, point: Offset(x, 0));
        ppp.valueAPoint = coord.point;

        coordinates.add(coord);
      }
    }

    return coordinates;
  }

  //몸무게 좌표 구하기
  List<DotData> getCoordinatesWeight2(List<ChartData> datas, Size size) {
    Map<DateTime, ChartData> test01 = <DateTime, ChartData>{};
    for (var element in datas) {
      test01[element.date] = element;
    }

    List<DotData> coordinates = [];

    for (int i = 0; i < dataAll.length; i++) {
      double x = spacing * i + margin; // x축 좌표를 구합니다.

      // DateTime tmpDate = removeHMS(dataAll[i].date);
      // var ppp = test01[tmpDate];
      
      var ppp = test01[dataAll[i].date];
      if (ppp != null) {
        DotData coord =
            DotData(data: ppp.valueA, type: ppp.type, point: Offset(x, 0));
        coordinates.add(coord);
      }
    }
    return coordinates;
  }

  @override
  bool shouldRepaint(LineChartOverlay oldDelegate) {
    return oldDelegate.touchX != touchX;
  }
}
