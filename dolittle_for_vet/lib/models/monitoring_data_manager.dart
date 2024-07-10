import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:dolittle_for_vet/models/app_cache.dart';
import 'package:dolittle_for_vet/models/monitoring_room_manager.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'ResponseEntity.dart';

class MonitoringDataManager extends ChangeNotifier{
  int headerSize =12;
  AppCache appCache = AppCache();
  AudioPlayer audioPlayer = AudioPlayer();
  Message2205? _message2205 = Message2205();
  Message2206? _message2206 = Message2206();
  Message2205? get message2205 => _message2205;
  static int _bellState = 2;
  bool _monitoringNotice = true;

  Future<void> setData(int msgId, var bodyArr) async {
   var data = MonitoringRoomManager.data;
    switch (msgId){
      case 2205:
        _message2205 = Message2205.fromBytes(headerSize, bodyArr);
        if(data['connectedMultiAppCount'] > 0){
          data['multiAppDatas'].forEach((multiAppData){
            if(multiAppData['multiAppUUID']==message2205?.MultiAppUUID){
              multiAppData['RoomInfos'].forEach((room){
                if (_message2205?.Data == '0') {
                  _message2205?.Data = '--';
                }
                if(room['roomId']==message2205?.RoomID){
                  room['dataType${message2205?.DataType}'] = message2205?.Data;
                }
              });
            }
          });
        }
        notifyListeners();
        break;
      case 2206:
        _message2206 = Message2206.fromBytes(headerSize, bodyArr);
        playBell();
        break;
      case 2207:
        _message2206 = Message2206.fromBytes(headerSize, bodyArr);
        stopBell();
        break;
    }
  }

  void update(){
    _message2205 = Message2205();
    notifyListeners();
  }

  Future<void> playBell() async{
    _bellState = await appCache.getMonitoringAlarmState();
    _monitoringNotice =  await appCache.getMonitoringNotice();
    if(_bellState == 0 || !_monitoringNotice){
      UtilityFunction.log.e('벨 안울림 bellstate${_bellState}이고Notice${_monitoringNotice}') ;
      await audioPlayer.stop();
      await Vibration.cancel();
    }else if(_bellState==2){
      await playSound();
    }else {
      await playVibrate();
    }
  }

  Future<void> playSound() async {
    await Vibration.cancel();
    if(audioPlayer.state!=PlayerState.playing) {
      try{
      await audioPlayer.play(AssetSource('audio/bpm_alarm.mp3'));
      await Future.delayed(const Duration(seconds: 1));}
          catch(e){
        UtilityFunction.log.e(e);
          }
      }
  }

  Future<void> playVibrate() async {
    UtilityFunction.log.e('진동 실행');
    await audioPlayer.stop();
    if(Platform.isAndroid){
      await Vibration.vibrate(duration: 2500);
    }else{
      await Vibration.vibrate();
    }
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> stopBell() async {
    await audioPlayer.stop();
    await Vibration.cancel();
  }





  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioPlayer = AudioPlayer();
      audioPlayer.stop();
      Vibration.cancel();
    });
    super.dispose();
  }
}
