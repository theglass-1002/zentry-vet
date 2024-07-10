import 'dart:math';

import 'package:dolittle_for_vet/screens/LineChartPainter.dart';
import 'package:flutter/material.dart';

class LineChartVerticalText extends CustomPainter {

  final bool isDay;
  List<ChartData> dataAll;
  List<ChartData> dataHR;
  List<ChartData> dataRR;
  List<ChartData> dataWeight;

  final double topPadding = 60;
  final double fontSize = 13.0;
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

  LineChartVerticalText({
    required this.isDay, 
    required this.dataAll, 
    required this.dataHR, 
    required this.dataRR, 
    required this.dataWeight, 
  });

  double getYposition(Size size, int type, double value) {

    if (type == 1) {
      double h = size.height / 3 - topPadding;

      double normalizedY = (value - minY_HR ) / (maxY_HR - minY_HR); // 정규화한다. 정규화란 [0 ~ 1] 사이가 나오게 값을 변경하는 것.
      double y = h - (normalizedY * h); 

      y = y + topPadding/2;
      return y;

    }else if (type == 2) {
      double h = size.height / 3 - topPadding;

      double normalizedY = (value - minY_RR ) / (maxY_RR - minY_RR); // 정규화한다. 정규화란 [0 ~ 1] 사이가 나오게 값을 변경하는 것.
      double y = h - (normalizedY * h); 

      y = y + topPadding/2;

      y = y + size.height / 3;  //
      return y;

    }else if (type == 3) {
      double h = size.height / 3 - topPadding;

      double normalizedY = (value - minY_WW ) / (maxY_WW - minY_WW); // 정규화한다. 정규화란 [0 ~ 1] 사이가 나오게 값을 변경하는 것.
      double y = h - (normalizedY * h); 

      y = y + topPadding/2;

      y = y + size.height*2 / 3; //
      return y;

    }else{
      return 0;
    }
    
  }

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
            
      //Y축 Position ----------------------------------------------------------------------------------
      double dHRTopY  = getYposition(size, 1, maxY_HR);
      double dHRDownY = getYposition(size, 1, minY_HR);
      double dRRTopY  = getYposition(size, 2, maxY_RR);
      double dRRDownY = getYposition(size, 2, minY_RR);
      double dWWTopY  = getYposition(size, 3, maxY_WW);
      double dWWDownY = getYposition(size, 3, minY_WW);

      //Y축 기준선 --------------------------------------------------------------------------------------
      drawDashVerticalLine(canvas, Offset(tmpSize.width, dHRTopY) , Colors.grey.shade400);
      drawDashVerticalLine(canvas, Offset(tmpSize.width, dHRDownY), Colors.grey.shade400);
      drawDashVerticalLine(canvas, Offset(tmpSize.width, dRRTopY) , Colors.grey.shade400);
      drawDashVerticalLine(canvas, Offset(tmpSize.width, dRRDownY), Colors.grey.shade400);
      drawDashVerticalLine(canvas, Offset(tmpSize.width, dWWTopY) , Colors.grey.shade400);
      drawDashVerticalLine(canvas, Offset(tmpSize.width, dWWDownY), Colors.grey.shade400);

      //Y축 기준 Text -----------------------------------------------------------------------------------
      //심박
      if (!dHRTopY.isNaN && !dHRDownY.isNaN) {
        drawVerticalTextValue(canvas, maxY_HR.toInt().toString(), Offset(5, dHRTopY) , Colors.black54);
        drawVerticalTextValue(canvas, minY_HR.toInt().toString(), Offset(5, dHRDownY), Colors.black54);
      }

      int hrGap = (maxY_HR - minY_HR) ~/ divisionYUnit;
      if (hrGap > 0) {
        for (var i = minY_HR+hrGap; i < maxY_HR; i = i + hrGap) {
          if (maxY_HR - i >= hrGap) {
            Offset y = Offset(tmpSize.width, getYposition(size, 1, i));
            drawDashVerticalLine(canvas, y, Colors.grey.shade400);
            drawVerticalTextValue(canvas, i.toInt().toString(), Offset(5, y.dy) , Colors.black54);
          }
        }
      }
      
      //호흡
      if (!dRRTopY.isNaN && !dRRDownY.isNaN) {
        drawVerticalTextValue(canvas, maxY_RR.toInt().toString(), Offset(5, dRRTopY) , Colors.black54);
        drawVerticalTextValue(canvas, minY_RR.toInt().toString(), Offset(5, dRRDownY), Colors.black54);
      }

      int rrGap = (maxY_RR - minY_RR) ~/ divisionYUnit;
      if (rrGap > 0) {
        for (var i = minY_RR+rrGap; i < maxY_RR; i = i + rrGap) {
          if (maxY_RR - i >= rrGap) {
            Offset y = Offset(tmpSize.width, getYposition(size, 2, i));
            drawDashVerticalLine(canvas, y, Colors.grey.shade400);
            drawVerticalTextValue(canvas, i.toInt().toString(), Offset(5, y.dy) , Colors.black54);
          }
        }
      }
        
      //몸무게
      if (!dWWTopY.isNaN && !dWWDownY.isNaN) {
        drawVerticalTextValue(canvas, maxY_WW.toInt().toString(), Offset(5, dWWTopY) , Colors.black54);
        drawVerticalTextValue(canvas, minY_WW.toInt().toString(), Offset(5, dWWDownY), Colors.black54);
      }

      int wwGap = (maxY_WW - minY_WW) ~/ divisionYUnit;
      if (wwGap > 0) {
        for (var i = minY_WW+wwGap; i < maxY_WW; i = i + wwGap) {
          if (maxY_WW - i >= wwGap) {
            Offset y = Offset(tmpSize.width, getYposition(size, 3, i));
            drawDashVerticalLine(canvas, y, Colors.grey.shade400);
            drawVerticalTextValue(canvas, i.toInt().toString(), Offset(5, y.dy) , Colors.black54);
          }
        }
      }
      
    }
  }

  double getYaxisMax(List<ChartData> datas) {

    if (datas.isEmpty) return 100.0; //데이터가 없어도 기준선을 그리기 위해 100.0으로 설정
    // if (datas.length == 1) return datas[0].valueA + (datas[0].valueA / 2); //데이터가 1개여도 기준선을 그리기 위해서 값의 반을 더해서 설정
    // if (datas.length == 1 && datas[0].valueA == 0) return 100.0;

    if (isDay && datas.length == 1) {
      if (datas[0].valueA == 0) {
        return 100.0;
      }else{
        return datas[0].valueA + (datas[0].valueA / 2); //데이터가 1개여도 기준선을 그리기 위해서 값의 반을 더해서 설정
      }
    }

    double maxY  = datas.fold(datas[0].valueA, (previousValue, element) => max(previousValue, element.valueA));
    double maxYH = datas.fold(datas[0].valueH, (previousValue, element) => max(previousValue, element.valueH));
    double maxYL = datas.fold(datas[0].valueL, (previousValue, element) => max(previousValue, element.valueL));
    maxY = max(maxY, max(maxYH, maxYL)); 
    return maxY;
  }

  double getYaxisMin(List<ChartData> datas) {

    if (datas.isEmpty) return 0.0;
    // if (datas.length == 1) return datas[0].valueA / 2; //데이터가 1개여도 기준선을 그리기 위해서 값의 반을 설정
    // if (datas.length == 1 && datas[0].valueA == 0) return 0.0;

    if (isDay && datas.length == 1) {
      if (datas[0].valueA == 0) {
        return 0.0;
      }else{
        return datas[0].valueA / 2; //데이터가 1개여도 기준선을 그리기 위해서 값의 반을 설정
      }
    }

    double minY  = datas.fold(datas[0].valueA, (previousValue, element) => min(previousValue, element.valueA));
    double minYH = datas.fold(datas[0].valueH, (previousValue, element) => min(previousValue, element.valueH));
    double minYL = datas.fold(datas[0].valueL, (previousValue, element) => min(previousValue, element.valueL));
    minY = min(minY, min(minYH, minYL)); 
    return minY;
  }

  
  void drawDashVerticalLine(Canvas canvas, Offset offset, Color lineColor) {

    if (offset.dy.isNaN) {
      return;
    }

    Paint paint = Paint()
      ..color       = lineColor
      ..strokeWidth = lineWidth
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.butt;

    int dashUnit = 4;  
    for (var i = 20; i<offset.dx; i = i + dashUnit * 2) {
      canvas.drawLine(Offset(i.toDouble(), offset.dy), Offset((i+dashUnit).toDouble(), offset.dy), paint);
    }
  }

  void drawVerticalTextValue(Canvas canvas, String text, Offset pos, Color textColor) {
    TextSpan maxSpan = TextSpan(style: TextStyle(fontSize: fontSize, color: textColor, fontWeight: FontWeight.bold), text: text); 
    TextPainter tp = TextPainter(text: maxSpan, textDirection: TextDirection.ltr);
    tp.layout();

    double y = -tp.height * 0.5; // 텍스트의 방향을 고려해 y축 값을 보정해줍니다.
    double dx = pos.dx - tp.width / 2; // 텍스트의 위치를 고려해 x축 값을 보정해줍니다.
    double dy = pos.dy + y; 

    Offset offset = Offset(dx, dy);

    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(LineChartVerticalText oldDelegate) {
    return oldDelegate.dataAll != dataAll;
  }

}