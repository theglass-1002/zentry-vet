import 'dart:io';
import 'dart:typed_data';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/models/monitoring_room_manager.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/material.dart';
import 'ResponseEntity.dart';

class SocketManager extends ChangeNotifier{
  final ApiUtility _apiUtility = ApiUtility();
  final maxRetryCount = 5; // 최대 재시도 횟수
  final initialDelay = Duration(seconds: 1); // 초기 대기 시간
  Socket? _socket = null;
  String _errorMessage = "";
  String get errorMessage => _errorMessage;
  Socket? get socket => _socket;
  int _count = 0;
  int get count => _count;
  bool _refresh = false;
  bool get refresh => _refresh;

  void setsocket(Socket socket){
    _socket = socket;
  }

  void setSocketErrorMsg(String errorMessage){
    _errorMessage = errorMessage ;
  }

  void setRefreshFlag(bool shouldRefresh) {
    _refresh = shouldRefresh;
  }


  Future<bool> connectWithExponentialBackoff() async{
    const initialDelay = Duration(seconds: 1); // 초기 대기 시간
    int retryCount = 0;
    Duration delay = initialDelay;
    return await connect(retryCount,delay);
  }

  Future<bool> connect(int retryCount, Duration delay) async {
    try {

      var newSocket = await Socket.connect(
        _apiUtility.getSocketHost(), _apiUtility.SocketPort,
      );
      // var newSocket = await Socket.connect(
      //  '31231232', _apiUtility.SocketPort,
      // );
      UtilityFunction.log.e('소켓연결 성공');
      setSocketErrorMsg("");
      setsocket(newSocket);
      return true; // 소켓 연결 성공 시 true 반환
    } catch (error) {
      if (retryCount < maxRetryCount) {
        await Future.delayed(delay);
        retryCount++;
        delay *= 2; // 대기 시간 2배로 증가
        UtilityFunction.log.e('연결 시도 ${retryCount} 회차');
        return connect(retryCount, delay); // 재시도
      } else {
        //에러 메세지 보기
        setSocketErrorMsg(error.toString());
        UtilityFunction.log.e(error.hashCode.toString());
        UtilityFunction.log.e('소켓 재시도 해도 안됨 ${error.toString()}');
        return false; // 재시도 횟수를 초과하면 false 반환
      }
    }
  }

  Future<void> sendMsg(var bytes) async {
    if (_socket is Socket) {
      _socket!.add(bytes);
      await _socket!.flush();
    }
  }



  void resetAndRefreshSocket(){
    setRefreshFlag(true);
    disconnectAndCloseSocket();
  }

  // void disconnectAndCloseSocket() {
  //   _socket?.close();
  //   _socket = null;
  // }
  void disconnectAndCloseSocket() {
    UtilityFunction.log.e(_socket);
    if(_socket!=null){
      _socket!.destroy();
      _socket = null;
      UtilityFunction.log.e('소켓 파키${_socket}');
      return;
    }else{
      UtilityFunction.log.e('소켓없음');
    }
    // if (_socket != null) {
    //   _socket!.close();
    //   _socket = null;
    // }
  }
}