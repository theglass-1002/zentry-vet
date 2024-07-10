// import 'package:dolittle_for_vet/utility_function.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MultiProvider(
//           providers: [
//              ChangeNotifierProvider<CountProvider>(
//                  create: (_)=>CountProvider()),
//              ChangeNotifierProvider<Pri>(create: (_)=>Pri()),
//         ],
//         child: Home(),
//         )
//     );
//   }
// }
//
//
// class Home extends StatelessWidget {
//
//   @override
//   Widget build(BuildContext context) {
//     UtilityFunction.log.e('rebuild');
//     return Center(
//       child: Consumer<CountProvider>(
//         builder: (context, provider, child){
//           return Row(
//             children: [
//               Text(provider.count.toString()),
//               ElevatedButton(onPressed: ()=>provider.add(), child: Text('12313'))
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
//
// class CountProvider extends ChangeNotifier{
//   int _count = 0;
//   int get count => _count;
//
//   add(){
//     _count++;
//     notifyListeners();
//   }
//
//
// }
// class Pri extends ChangeNotifier{
//   int _count = 0;
//   int get count => _count;
//
//   add(){
//     _count++;
//     notifyListeners();
//   }
//
//
// }


