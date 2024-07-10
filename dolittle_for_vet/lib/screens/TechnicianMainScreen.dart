import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dolittle_for_vet/screens/screens.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/screens/screens.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:provider/provider.dart';


class TechnicianMainScreen extends StatefulWidget {
  const TechnicianMainScreen({super.key});
  static const routeName = '/TechnicianMainScreen';
  @override
  State<TechnicianMainScreen> createState() => _TechnicianMainScreenState();
}

class _TechnicianMainScreenState extends State<TechnicianMainScreen> {

  ProfileManager _profileManager = ProfileManager();
  MonitoringRoomManager _monitoringRoomManager = MonitoringRoomManager();
  MonitoringDataManager _monitoringDataManager = MonitoringDataManager();
  SocketManager _socketManager = SocketManager();


  @override
  void initState() {
    // TODO: implement initState
    if(mounted){
      _profileManager = Provider.of<ProfileManager>(context, listen: false);
      _socketManager = Provider.of<SocketManager>(context, listen: false);
       socketConnect();
      _monitoringRoomManager =
          Provider.of<MonitoringRoomManager>(context, listen: false);
      _monitoringDataManager =
          Provider.of<MonitoringDataManager>(context, listen: false);
    }
    super.initState();
  }

  Future<void> socketConnect() async {
    bool isSocketConnected = await _socketManager.connectWithExponentialBackoff();
    UtilityFunction.log.e('간호사 소켓연결$isSocketConnected');
    if (isSocketConnected && _socketManager.socket is Socket) {
      final input = Message2101(
          msgSize: 21,
          msgId: 2101,
          reId: 1,
          hospitalId: int.parse(_profileManager.userData.hospitalId!),
          vetId: int.parse(_profileManager.userData.id!),
          isReceivedData: true);
      await sendMsg(input);
      final inputV2 = Message2101(
          msgSize: 21,
          msgId: 4101,
          reId: 1,
          hospitalId: int.parse(_profileManager.userData.hospitalId!),
          vetId: int.parse(_profileManager.userData.id!),
          isReceivedData: true);
      if (_profileManager.userData.id != null) {
        await _socketManager.sendMsg(inputV2.toByteArray());
      }
      _socketManager.setRefreshFlag(false);
    } else {
      //UtilityComponents.showToast(_socketManager.errorMessage ?? "");
      UtilityFunction.log.e('소켓연결 실패 반환받음');
    }
  }

  Future<void> sendMsg(var input) async {
    if (_profileManager.userData.id != null) {
      final bytes = input.toByteArray();
      await _socketManager.sendMsg(bytes);
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
      if (dataList.length < receiveHeader.msgSize) {
        return;
      } else {
        var bodyArr = dataList;
        if (receiveHeader.msgSize == bodyArr.length) {
          if (receiveHeader.msgId == 2205 ||
              receiveHeader.msgId == 2206 ||
              receiveHeader.msgId == 2207) {
           await  _monitoringDataManager.setData(receiveHeader.msgId, bodyArr);
          } else {
            _monitoringRoomManager.setData(receiveHeader.msgId, bodyArr);
          }
          dataList.removeRange(0, receiveHeader.msgSize);
        } else if (bodyArr.length > receiveHeader.msgSize) {
          while (bodyArr.isNotEmpty) {
            ReceiveHeader subReceiveHeader = ReceiveHeader.fromBytes(0, bodyArr);
            if (subReceiveHeader.msgId == 2205 ||
                subReceiveHeader.msgId == 2206 ||
                subReceiveHeader.msgId == 2207) {
              await _monitoringDataManager.setData(
                  subReceiveHeader.msgId, bodyArr);
            } else {
              _monitoringRoomManager.setData(subReceiveHeader.msgId, bodyArr);
            }
            bodyArr.removeRange(0, subReceiveHeader.msgSize);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.zero,
                width: VetTheme.diviceW(context)/2,
                height:60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    color: Colors.black),
                child:
                Center(child: Text('Patient Monitor'.tr(),
                  style: TextStyle(fontSize: VetTheme.titleTextSize(context)),
                  textAlign: TextAlign.center,)),
              ),
              IconButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  iconSize: 35,
                  onPressed: () {
                    UtilityFunction.moveScreen(context, '/setting');
                  },
                  icon:  Icon(Icons.settings,color: Colors.black,))
            ],
          ),
        ),
      ),
      body: Container(
          height: double.infinity,
          child: MonitoringListScreen())
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    UtilityFunction.log.e('tech dispose초기화시켜야합니다');
    _socketManager.disconnectAndCloseSocket();
    _socketManager = SocketManager();
    _monitoringRoomManager = MonitoringRoomManager();
    _monitoringDataManager = MonitoringDataManager();
    super.dispose();
  }
}
