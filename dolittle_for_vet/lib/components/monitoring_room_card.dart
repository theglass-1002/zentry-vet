// import 'package:dolittle_for_vet/utility_function.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../app_theme/app_theme.dart';
// import 'components.dart';
// import 'package:dolittle_for_vet/models/models.dart';
// class MonitoringRoomCard extends StatefulWidget {
//   final Map? roominfo;
//   final String multiAppUUID;
//
//
//   MonitoringRoomCard({Key? key,required this.roominfo,required this.multiAppUUID}) : super(key: key);
//
//   @override
//   State<MonitoringRoomCard> createState() => _MonitoringRoomCardState();
// }
//
// class _MonitoringRoomCardState extends State<MonitoringRoomCard> with SingleTickerProviderStateMixin{
//   late  AnimationController _controller;
//   late  Animation<Color?> _colorAnimation;
//
//   //입원장 상태에 따른 색상 진동변경
//   Map? roominfo;
//   String? multiAppUUID;
//
//   @override
//    void initState() {
//     _controller=AnimationController(
//       duration: Duration(seconds: 1),
//       vsync: this,
//     )..repeat(reverse: true);
//     _colorAnimation =ColorTween(begin: Colors.red[400], end: Colors.transparent)
//         .animate(_controller);
//     roominfo = widget.roominfo;
//     multiAppUUID = widget.multiAppUUID;
//     // TODO: implement initState
//
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     if(mounted) {
//       _controller.dispose();
//     }
//     super.dispose();
//   }
//
//   BorderSide getCustomBorderSide({required Color color, required String type}) {
//     switch (type) {
//       case 'all':
//         return BorderSide(color: Colors.grey.withOpacity(0.3), width: 1);
//       case 'top':
//         return BorderSide(color: Colors.grey.withOpacity(0.3), width: 1);
//       case 'bottom':
//         return BorderSide(color: Colors.grey.withOpacity(0.3), width: 1);
//       case 'left':
//         return BorderSide(color: Colors.grey.withOpacity(0.3), width: 1);
//       case 'right':
//         return BorderSide(color: Colors.grey.withOpacity(0.3), width: 1);
//       default:
//         return BorderSide(color: Colors.grey.withOpacity(0.3), width: 1);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     multiAppUUID = widget.multiAppUUID;
//     roominfo= widget.roominfo;
//     return roomType0CardWidget();
//     //
//     // if(roominfo!['type']==3){
//     //   //심호흡 이상함 겉에 깜빡임
//     //   return roomType3CardWidget();
//     // }else {
//     //   //안깜빡임
//     //   return roomType0CardWidget();
//     // }
//   }
//
//
//   Widget roomType3CardWidget(){
//     return AnimatedBuilder(
//         animation: _colorAnimation,
//         builder: (context, child){
//           return Container(
//               height: VetTheme.diviceH(context)<800?75:90,
//               child: Card(
//                   margin: EdgeInsets.all(4),
//                   elevation: 1,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),
//                       side: BorderSide(color: _colorAnimation.value ?? Colors.redAccent,width: 5)),
//                   //   side: BorderSide(color: _colorAnimation.value ?? Colors.redAccent, width: 5),),
//                   child: MonitoringDataCard(
//                     roomInfo: roominfo, multiAppUUID: multiAppUUID!,)),
//               decoration: BoxDecoration(
//                   color: _colorAnimation.value ?? Colors.redAccent,
//                   borderRadius: BorderRadius.circular(5))
//           );
//         }
//     );
//   }
//
//   Widget roomType0CardWidget(){
//     return Container(
//       height: VetTheme.diviceH(context)<740?75:90,
//       child: Card(
//
//           elevation: 1,
//           margin: EdgeInsets.all(VetTheme.diviceH(context)<800?5:4),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(5),
//             side: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),),
//           child: MonitoringDataCard(
//             roominfo: roominfo, multiAppUUID: multiAppUUID!,)),
//     );
//   }
//
//
//   // @override
//   // Widget build(BuildContext context) {
//   //   multiAppUUID = widget.multiAppUUID;
//   //   roominfo= widget.roominfo;
//   //
//   //   if(roominfo!['type']==3){
//   //     //심호흡 이상함 겉에 깜빡임
//   //     return roomType3CardWidget();
//   //   }else {
//   //     //안깜빡임
//   //     return roomType0CardWidget();
//   //   }
//   // }
//   //
//   //
//   // Widget roomType3CardWidget(){
//   //   return AnimatedBuilder(
//   //       animation: _colorAnimation,
//   //       builder: (context, child){
//   //         return Container(
//   //           height: VetTheme.diviceH(context)<800?75:90,
//   //           child: Card(
//   //             margin: EdgeInsets.all(4),
//   //             elevation: 1,
//   //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),
//   //              side: BorderSide(color: _colorAnimation.value ?? Colors.redAccent,width: 5)),
//   //            //   side: BorderSide(color: _colorAnimation.value ?? Colors.redAccent, width: 5),),
//   //               child: MonitoringDataCard(
//   //             roominfo: roominfo, multiAppUUID: multiAppUUID!,)),
//   //           decoration: BoxDecoration(
//   //               color: _colorAnimation.value ?? Colors.redAccent,
//   //               borderRadius: BorderRadius.circular(5))
//   //         );
//   //       }
//   //   );
//   // }
//   //
//   // Widget roomType0CardWidget(){
//   //   return Container(
//   //     height: VetTheme.diviceH(context)<740?75:90,
//   //     child: Card(
//   //
//   //         elevation: 1,
//   //          margin: EdgeInsets.all(VetTheme.diviceH(context)<800?5:4),
//   //          shape: RoundedRectangleBorder(
//   //                 borderRadius: BorderRadius.circular(5),
//   //                 side: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),),
//   //                 child: MonitoringDataCard(
//   //                 roominfo: roominfo, multiAppUUID: multiAppUUID!,)),
//   //   );
//   // }
//
// }
