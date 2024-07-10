import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:dolittle_for_vet/screens/screens.dart';
import 'package:vibration/vibration.dart';

class AuthMemberMainscreen extends StatefulWidget {
  const AuthMemberMainscreen({Key? key}) : super(key: key);
  static const routeName = '/AuthMemberMainscreen';

  @override
  State<AuthMemberMainscreen> createState() => _AuthMemberMainscreenState();
}

class _AuthMemberMainscreenState extends State<AuthMemberMainscreen>
    with SingleTickerProviderStateMixin {
  ProfileManager _profileManager = ProfileManager();
  MonitoringRoomManager _monitoringRoomManager = MonitoringRoomManager();
  MonitoringDataManager _monitoringDataManager = MonitoringDataManager();
  SocketManager _socketManager = SocketManager();
  TabController? _tabController;
  int _currentIndex = 0;
  bool isFirstConnection = true;

  @override
  void initState() {
    if (mounted) {
      _profileManager = Provider.of<ProfileManager>(context, listen: false);
      _socketManager = Provider.of<SocketManager>(context, listen: false);
       _tabController = TabController(length: 2, vsync: this);
      _tabController?.addListener(_handleTabSelection);
      socketConnect();
      _monitoringRoomManager =
          Provider.of<MonitoringRoomManager>(context, listen: false);
      _monitoringDataManager =
          Provider.of<MonitoringDataManager>(context, listen: false);

      if (_monitoringDataManager.audioPlayer.state == PlayerState.playing) {
        _monitoringRoomManager.audioPlayer.stop();
      }
      Vibration.cancel();
      super.initState();
    }
  }

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    //  UtilityFunction.log.e('auth member? didd');
  }

  Future<void> socketConnect() async {
    bool isSocketConnected =
    await _socketManager.connectWithExponentialBackoff();
     if (isSocketConnected && _socketManager.socket is Socket) {
      if (!_socketManager.refresh) {
        final input = Message2101(
            msgSize: 21,
            msgId: 2101,
            reId: 1,
            hospitalId: int.parse(_profileManager.userData.hospitalId!),
            vetId: int.parse(_profileManager.userData.id!),
            isReceivedData: false);
        final bytes = input.toByteArray();
        await sendMsg(bytes);

        //----------------------------------------------------------------
        final inputV2 = Message4101(
            msgSize: 21,
            msgId: 4101,
            reId: 1,
            hospitalId: int.parse(_profileManager.userData.hospitalId!),
            vetId: int.parse(_profileManager.userData.id!),
            isReceivedData: false);
        final bytesV2 = inputV2.toByteArray();
        await _socketManager.sendMsg(bytesV2);
        //await sendMsg(bytesV2);

      } else {
        final input = Message2101(
            msgSize: 21,
            msgId: 2101,
            reId: 1,
            hospitalId: int.parse(_profileManager.userData.hospitalId!),
            vetId: int.parse(_profileManager.userData.id!),
            isReceivedData: true);
        _socketManager.setRefreshFlag(false);
        final bytes = input.toByteArray();
        await sendMsg(bytes);
        //----------------------------------------------------------------
        final inputV2 = Message4101(
            msgSize: 21,
            msgId: 4101,
            reId: 1,
            hospitalId: int.parse(_profileManager.userData.hospitalId!),
            vetId: int.parse(_profileManager.userData.id!),
            isReceivedData: true);
        _socketManager.setRefreshFlag(false);
        final bytesV2 = inputV2.toByteArray();
        await _socketManager.sendMsg(bytesV2);
        // await sendMsg(bytesV2);
      }
    } else {
      UtilityFunction.log.e('소켓연결 실패 반환받음');
    }
  }

  Future<void> sendMsg(var input) async {
    if (_profileManager.userData.id != null) {
      await _socketManager.sendMsg(input);
      return await socketListen();
    }
  }

  Future<void> socketListen() async {
    _socketManager.socket?.listen((event) async {
      await reciveData(event);
    }, onError: (error) {
      UtilityFunction.log.e('${error.toString()}');
      UtilityFunction.log.e('서버에서 끊으면 여기서 에러뜸 사용자한테 띄워주기 error');
      _socketManager.setSocketErrorMsg(error.toString());
      _socketManager.disconnectAndCloseSocket();
      UtilityFunction.pushReplacementNamed(context, '/');
    }, onDone: () async {
      /**
       * user 가 소켓을 스스로 끊으면 여기로 옴
       * logout : 유저가 아예 끊음
       * 알림 : : 소켓 끊고 재연결
       * 새로고침 : 소켓 끊고 재연결 원함
       * */

      if (_socketManager.refresh) {
        await socketConnect();
      }
      return;
    });
  }


  Future<void> reciveData(Uint8List data) async {
    List<int> dataList = data.toList();
    ReceiveHeader receiveHeader = ReceiveHeader.fromBytes(0, dataList);
    while (dataList.isNotEmpty) {
      //소켓 데이터가 빈값이 될때까지 반복문 돌리기
      if (dataList.length < receiveHeader.msgSize) {
        //받은 데이터가 , 쓰여있는 데이터 사이즈 보다 작으면 뱉어냄
        return;
      } else {
        var bodyArr = dataList;
        if (receiveHeader.msgSize == bodyArr.length) {
          await processData(receiveHeader.msgId, bodyArr);
          dataList.removeRange(0, receiveHeader.msgSize);
        } else if (bodyArr.length > receiveHeader.msgSize) {
          while (bodyArr.isNotEmpty) {
            ReceiveHeader subReceiveHeader = ReceiveHeader.fromBytes(0, bodyArr);
            await processData(subReceiveHeader.msgId, bodyArr);
            bodyArr.removeRange(0, subReceiveHeader.msgSize);
          }
        }
      }
    }
  }


  Future<void> processData(int msgId, List<int> bodyArr) async {

    if (msgId == 2205 || msgId == 2206 || msgId == 2207) {
      await _monitoringDataManager.setData(msgId, bodyArr);
    } else {
      _monitoringRoomManager.setData(msgId, bodyArr);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    width: VetTheme.diviceW(context) < 400 ? 300 : 340,
                    height: 70,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),  // 조절 가능
                        topRight: Radius.circular(0),  // 조절 가능
                      ),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white,
                        indicator: BoxDecoration(
                          borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(30)),
                          color: _currentIndex == 0 || _tabController?.index == 0
                              ? VetTheme.mainIndigoColor
                              : Colors.black,
                        ),
                        tabs: [
                          Text(
                            'Heart Failure'.tr(),
                            style: TextStyle(
                                fontSize: VetTheme.titleTextSize(context)),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Patient Monitor'.tr(),
                            style: TextStyle(
                                fontSize: VetTheme.titleTextSize(context)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )),
              ),
              Builder(builder: (context) {
                if (_currentIndex == 0 || _tabController?.index == 0) {
                  return IconButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      iconSize: 35,
                      onPressed: () {
                        UtilityFunction.moveScreen(context, '/setting');
                      },
                      icon: Icon(
                        Icons.settings,
                        color: Colors.black,
                      ));
                }
                return IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    iconSize: 35,
                    onPressed: () {
                      UtilityFunction.moveScreen(context, '/setting');
                    },
                    icon: Icon(
                      Icons.settings,
                      color: Colors.black,
                    ));
              })
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [HeartFailureScreen(), MonitoringListScreen()],
          ),),
         bottomNavigationBar: Builder(builder: (context){
                      if(_currentIndex==0||_tabController?.index==0){
                                          return BottomAppBar(
                                            child: Container(
                                              margin: EdgeInsets.symmetric(horizontal: VetTheme.textSize(context)),
                                              child: ElevatedButton(onPressed: () async {
                                                var route = await addPatientDialog();
                                                if(route==null){
                                                  return;
                                                }else{
                                                  return UtilityFunction.moveScreen(context, route);
                                                }

                                              }, child: const Text('Pet registration',).tr()),
                                            ),
                                          );
                                    }else{
                                  return BottomAppBar(
                                    height:0,
                                  );
                                }

                }));}



  Future<dynamic> addPatientDialog() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(
          'Add new patient'.tr(),
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff4994ec)),
                      onPressed: () {
                        Navigator.pop(context, '/animalQrScan');
                      },
                      child: Text('Add with QR'.tr()))),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff4994ec)),
                      onPressed: () {
                        Navigator.pop(context, '/addWithQrScreen');
                      },
                      child: Text('Add with Chart'.tr())))
            ],
          ),
        ),
      ),
    );
  }

  void _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController!.index;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _socketManager.disconnectAndCloseSocket();
    _socketManager = SocketManager();
    _monitoringRoomManager = MonitoringRoomManager();
    _monitoringDataManager = MonitoringDataManager();
    super.dispose();
  }
}



// import 'dart:io';
// import 'dart:typed_data';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:dolittle_for_vet/app_theme/app_theme.dart';
// import 'package:dolittle_for_vet/utility_function.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:dolittle_for_vet/utility_function.dart';
// import 'package:dolittle_for_vet/api/api.dart';
// import 'package:dolittle_for_vet/models/models.dart';
// import 'package:dolittle_for_vet/components/components.dart';
// import 'package:dolittle_for_vet/screens/screens.dart';
// import 'package:vibration/vibration.dart';
// //import '../new_screens/MonitoringListScreen.dart';
//
// class AuthMemberMainscreen extends StatefulWidget {
//   const AuthMemberMainscreen({Key? key}) : super(key: key);
//   static const routeName = '/AuthMemberMainscreen';
//
//   @override
//   State<AuthMemberMainscreen> createState() => _AuthMemberMainscreenState();
// }
//
// class _AuthMemberMainscreenState extends State<AuthMemberMainscreen>
//     with SingleTickerProviderStateMixin {
//   ProfileManager _profileManager = ProfileManager();
//   MonitoringRoomManager _monitoringRoomManager = MonitoringRoomManager();
//   MonitoringDataManager _monitoringDataManager = MonitoringDataManager();
//   SocketManager _socketManager = SocketManager();
//   TabController? _tabController;
//   int _currentIndex = 0;
//   bool isFirstConnection = true;
//
//   @override
//    void initState() {
//          if (mounted) {
//             _profileManager = Provider.of<ProfileManager>(context, listen: false);
//                 _socketManager = Provider.of<SocketManager>(context, listen: false);
//                 UtilityFunction.log.e('처음 소켓은 널입니까? ${_socketManager.socket}');
//                 _tabController = TabController(length: 2, vsync: this);
//                 _tabController?.addListener(_handleTabSelection);
//                 socketConnect();
//                 _monitoringRoomManager =
//                     Provider.of<MonitoringRoomManager>(context, listen: false);
//                 _monitoringDataManager =
//                     Provider.of<MonitoringDataManager>(context, listen: false);
//
//                 if (_monitoringDataManager.audioPlayer.state == PlayerState.playing) {
//                   _monitoringRoomManager.audioPlayer.stop();
//                 }
//                 Vibration.cancel();
//                 super.initState();
//               }
//             }
//
//             @override
//       Future<void> didChangeDependencies() async {
//               // TODO: implement didChangeDependencies
//               super.didChangeDependencies();
//             //  UtilityFunction.log.e('auth member? didd');
//             }
//
//       Future<void> socketConnect() async {
//               bool isSocketConnected =
//                   await _socketManager.connectWithExponentialBackoff();
//               if (isSocketConnected && _socketManager.socket is Socket) {
//                 if (!_socketManager.refresh) {
//                   final input = Message2101(
//                       msgSize: 21,
//                       msgId: 2101,
//                       reId: 1,
//                       hospitalId: int.parse(_profileManager.userData.hospitalId!),
//                       vetId: int.parse(_profileManager.userData.id!),
//                       isReceivedData: false);
//                   final bytes = input.toByteArray();
//                   await sendMsg(bytes);
//
//                   //----------------------------------------------------------------
//                   final inputV2 = Message4101(
//                       msgSize: 21,
//                       msgId: 4101,
//                       reId: 1,
//                       hospitalId: int.parse(_profileManager.userData.hospitalId!),
//                       vetId: int.parse(_profileManager.userData.id!),
//                       isReceivedData: false);
//                   final bytesV2 = inputV2.toByteArray();
//                   await _socketManager.sendMsg(bytesV2);
//                   //await sendMsg(bytesV2);
//
//                 } else {
//                   final input = Message2101(
//                       msgSize: 21,
//                       msgId: 2101,
//                       reId: 1,
//                       hospitalId: int.parse(_profileManager.userData.hospitalId!),
//                       vetId: int.parse(_profileManager.userData.id!),
//                       isReceivedData: true);
//                   _socketManager.setRefreshFlag(false);
//                   final bytes = input.toByteArray();
//                   await sendMsg(bytes);
//                 //----------------------------------------------------------------
//                   final inputV2 = Message4101(
//                       msgSize: 21,
//                       msgId: 4101,
//                       reId: 1,
//                       hospitalId: int.parse(_profileManager.userData.hospitalId!),
//                       vetId: int.parse(_profileManager.userData.id!),
//                       isReceivedData: true);
//                   _socketManager.setRefreshFlag(false);
//                   final bytesV2 = inputV2.toByteArray();
//                   await _socketManager.sendMsg(bytesV2);
//                   // await sendMsg(bytesV2);
//                 }
//               } else {
//                 UtilityFunction.log.e('소켓연결 실패 반환받음');
//               }
//             }
//
//    Future<void> sendMsg(var input) async {
//               if (_profileManager.userData.id != null) {
//                 await _socketManager.sendMsg(input);
//                 return await socketListen();
//               }
//   }
//
//    Future<void> socketListen() async {
//     _socketManager.socket?.listen((event) async {
//        await reciveData(event);
//               }, onError: (error) {
//                 UtilityFunction.log.e('${error.toString()}');
//                 UtilityFunction.log.e('서버에서 끊으면 여기서 에러뜸 사용자한테 띄워주기 error');
//                 _socketManager.setSocketErrorMsg(error.toString());
//                 _socketManager.disconnectAndCloseSocket();
//                 UtilityFunction.pushReplacementNamed(context, '/');
//               }, onDone: () async {
//                 /**
//                  * user 가 소켓을 스스로 끊으면 여기로 옴
//                  * logout : 유저가 아예 끊음
//                  * 알림 : : 소켓 끊고 재연결
//                  * 새로고침 : 소켓 끊고 재연결 원함
//                  * */
//
//                 if (_socketManager.refresh) {
//                   await socketConnect();
//                 }
//                 return;
//               });
//             }
//
//
//   Future<void> reciveData(Uint8List data) async {
//     List<int> dataList = data.toList();
//     ReceiveHeader receiveHeader = ReceiveHeader.fromBytes(0, dataList);
//     while (dataList.isNotEmpty) {
//       //소켓 데이터가 빈값이 될때까지 반복문 돌리기
//       if (dataList.length < receiveHeader.msgSize) {
//         //받은 데이터가 , 쓰여있는 데이터 사이즈 보다 작으면 뱉어냄
//         return;
//       } else {
//         var bodyArr = dataList;
//         if (receiveHeader.msgSize == bodyArr.length) {
//             await processData(receiveHeader.msgId, bodyArr);
//             dataList.removeRange(0, receiveHeader.msgSize);
//         } else if (bodyArr.length > receiveHeader.msgSize) {
//           while (bodyArr.isNotEmpty) {
//             ReceiveHeader subReceiveHeader = ReceiveHeader.fromBytes(0, bodyArr);
//              await processData(subReceiveHeader.msgId, bodyArr);
//              bodyArr.removeRange(0, subReceiveHeader.msgSize);
//           }
//         }
//       }
//     }
//   }
//
//
//   Future<void> processData(int msgId, List<int> bodyArr) async {
//
//     if (msgId == 2205 || msgId == 2206 || msgId == 2207) {
//       await _monitoringDataManager.setData(msgId, bodyArr);
//     } else {
//        _monitoringRoomManager.setData(msgId, bodyArr);
//     }
//   }
//
//    Widget build(BuildContext context) {
//           return Scaffold(
//                   appBar: AppBar(
//                   centerTitle: false,
//                   backgroundColor: Colors.transparent,
//                   elevation: 0,
//                   titleSpacing: 0,
//                   title: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Container(
//                             padding: EdgeInsets.zero,
//                             margin: EdgeInsets.zero,
//                             width: VetTheme.diviceW(context) < 400 ? 300 : 340,
//                             height: 70,
//                             decoration: const BoxDecoration(
//                                 borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(30),  // 조절 가능
//                                   topRight: Radius.circular(0),  // 조절 가능
//                                 ),
//                                 ),
//                             child: Container(
//                               decoration: const BoxDecoration(
//                                 color: Colors.grey,
//                                 borderRadius:
//                                     BorderRadius.vertical(top: Radius.circular(30)),
//                               ),
//                               child: TabBar(
//                                controller: _tabController,
//                                 indicatorSize: TabBarIndicatorSize.tab,
//                                 labelColor: Colors.white,
//                                unselectedLabelColor: Colors.white,
//                                indicator: BoxDecoration(
//                                  borderRadius:
//                                      const BorderRadius.vertical(top: Radius.circular(30)),
//                                  color: _currentIndex == 0 || _tabController?.index == 0
//                                      ? VetTheme.mainIndigoColor
//                                      : Colors.black,
//                                ),
//                                tabs: [
//                                  Text(
//                                    'Heart Failure'.tr(),
//                                    style: TextStyle(
//                                        fontSize: VetTheme.titleTextSize(context)),
//                                    textAlign: TextAlign.center,
//                                  ),
//                                  Text(
//                                    'Patient Monitor'.tr(),
//                                    style: TextStyle(
//                                        fontSize: VetTheme.titleTextSize(context)),
//                                    textAlign: TextAlign.center,
//                                  ),
//                                ],
//                               ),
//                             )),
//                       ),
//                       Builder(builder: (context) {
//                         if (_currentIndex == 0 || _tabController?.index == 0) {
//                           return IconButton(
//                               highlightColor: Colors.transparent,
//                               splashColor: Colors.transparent,
//                               iconSize: 35,
//                               onPressed: () {
//                                 UtilityFunction.moveScreen(context, '/setting');
//                               },
//                               icon: Icon(
//                                 Icons.settings,
//                                 color: Colors.black,
//                               ));
//                         }
//                         return IconButton(
//                             highlightColor: Colors.transparent,
//                             splashColor: Colors.transparent,
//                             iconSize: 35,
//                             onPressed: () {
//                               UtilityFunction.moveScreen(context, '/setting');
//                              },
//                             icon: Icon(
//                               Icons.settings,
//                               color: Colors.black,
//                             ));
//                       })
//                     ],
//                   ),
//                 ),
//               body: SafeArea(
//                 child: TabBarView(
//                     physics: const NeverScrollableScrollPhysics(),
//                     controller: _tabController,
//                     children: [HeartFailureScreen(), MonitoringListScreen()],
//                   ),),
//                   bottomNavigationBar: Builder(builder: (context){
//                       if(_currentIndex==0||_tabController?.index==0){
//                                           return BottomAppBar(
//                                             child: Container(
//                                               margin: EdgeInsets.symmetric(horizontal: VetTheme.textSize(context)),
//                                               child: ElevatedButton(onPressed: () async {
//                                                 var route = await addPatientDialog();
//                                                 if(route==null){
//                                                   return;
//                                                 }else{
//                                                   return UtilityFunction.moveScreen(context, route);
//                                                 }
//
//                                               }, child: const Text('Pet registration',).tr()),
//                                             ),
//                                           );
//                                     }else{
//                                   return BottomAppBar(
//                                     height:0,
//                                   );
//                                 }
//
//                 }));}
//
//
//         Future<dynamic> addPatientDialog() {
//                 return showDialog<String>(
//                   context: context,
//                   builder: (BuildContext context) => AlertDialog(
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                     title: Text(
//                       'Add new patient'.tr(),
//                       textAlign: TextAlign.center,
//                     ),
//                     content: SizedBox(
//                       height: 150,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xff4994ec)),
//                                   onPressed: () {
//                                     Navigator.pop(context, '/animalQrScan');
//                                     },
//                                   child: Text('Add with QR'.tr()))),
//                           SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xff4994ec)),
//                                   onPressed: () {
//                                     Navigator.pop(context, '/addWithQrScreen');
//                                   },
//                                   child: Text('Add with Chart'.tr())))
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }
//
//          void _handleTabSelection() {
//            setState(() {
//              _currentIndex = _tabController!.index;
//            });
//               }
//
//           @override
//               void dispose() {
//                 _tabController?.dispose();
//                 _socketManager.disconnectAndCloseSocket();
//                 _socketManager = SocketManager();
//                 _monitoringRoomManager = MonitoringRoomManager();
//                 _monitoringDataManager = MonitoringDataManager();
//                 super.dispose();
//   }
// }
