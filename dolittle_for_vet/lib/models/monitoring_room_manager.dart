import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:vibration/vibration.dart';
import 'ResponseEntity.dart';

class MonitoringRoomManager extends ChangeNotifier{
  int headerSize =12;
  static Map data = {
  };
  List<MultiAppData>? _multiAppDatas;
  AudioPlayer audioPlayer = AudioPlayer();
  Message2201 _message2201 = Message2201();
  Message4201 _message4201 = Message4201();
  Message2203 _message2203 = Message2203();
  Message2204 _message2204 = Message2204();
  Message4204 _message4204 = Message4204();
  Message2208 _message2208 = Message2208();
  List<MultiAppData>? get multiAppDatas => _multiAppDatas;

  void setData(int msgId, var bodyArr){
    //UtilityFunction.log.e('${msgId}');
    switch (msgId){
      case 2201:
        _message2201 = Message2201.fromBytes(headerSize, bodyArr);
        setMultiAppDatas(_message2201.multiAppDatas??[]);
        notifyListeners();
        break;
      case 4201:
        _message4201 = Message4201.fromBytes(headerSize, bodyArr);
        setMultiAppDatasV2(_message4201.multiAppDatasV2??[]);
        notifyListeners();
        break;
      case 2202:
        var multiApp = MultiAppData.fromBytes(headerSize, bodyArr);
        _multiAppDatas?.add(multiApp);
        data['connectedMultiAppCount']=_multiAppDatas?.length;
        data['multiAppDatas']=List.from(data['multiAppDatas'])..add(multiApp.toJson());
        notifyListeners();
        break;
      case 4202:
        var multiAppV2 = MultiAppDataV2.fromBytes(headerSize, bodyArr);
        _multiAppDatas?.add(multiAppV2);
        data['connectedMultiAppCount']=_multiAppDatas?.length;
        data['multiAppDatas']=List.from(data['multiAppDatas'])..add(multiAppV2.toJson());
        notifyListeners();
        break;
      case 2203:
      case 4203:
        _message2203 = Message2203.fromBytes(headerSize, bodyArr);
        for(var i = _multiAppDatas!.length - 1; i >= 0; i--){
          if(_multiAppDatas?[i].multiAppUUID==_message2203.multiAppUUID){
                     _multiAppDatas?.removeAt(i);
          }
        }
        var _multiAppList = List<Map<String, dynamic>>.from(data['multiAppDatas']);
        _multiAppList.removeWhere((value) => value['multiAppUUID'] == _message2203.multiAppUUID);
        data['multiAppDatas'] = _multiAppList;
        data['connectedMultiAppCount'] = _multiAppDatas?.length;
        notifyListeners();
        break;

      case 2204:
        _message2204 = Message2204.fromBytes(headerSize, bodyArr);
        roomUpdate(_message2204);
        break;
      case 4204:
        _message4204 = Message4204.fromBytes(headerSize, bodyArr);
        roomUpdateV2(_message4204);
        break;
      case 2208:
        _message2208 = Message2208.fromBytes(headerSize, bodyArr);
        _multiAppDatas?.where((multiAppData) => multiAppData.multiAppUUID == _message2208.multiAppUUID)
            .forEach((multiAppData) {
          multiAppData.multiAppName = _message2208.multiAppName;
          multiAppData.multiAppNameLength = _message2208.multiAppNameLength;
            });
        notifyListeners();
        break;
    }
  }



  void setMultiAppDatas(List<MultiAppData> multiAppDatas) {
    _multiAppDatas = []; // 초기화 추가
    _multiAppDatas?.addAll(multiAppDatas);
    data["connectedMultiAppCount"]=_multiAppDatas!.length;
    data["multiAppDatas"]=_multiAppDatas?.map((multiAppData) => multiAppData.toJson()).toList();
  }
  void setMultiAppDatasV2(List<MultiAppDataV2> multiAppDatas) {
    _multiAppDatas ??= []; // 초기화 추가
    _multiAppDatas?.addAll(multiAppDatas);
    data["connectedMultiAppCount"]=_multiAppDatas!.length;
    data["multiAppDatas"]=_multiAppDatas?.map((multiAppData) => multiAppData.toJson()).toList();

  }


  void roomUpdate(Message2204 message2204){
    var uuid =  message2204.multiAppUUID;
    var roomInfoData = message2204.roominfo;
    switch(message2204.actionType){
      case 0:
        multiAppDatas!
            .where((multiAppData) => multiAppData.multiAppUUID == uuid).forEach((multiAppData) {
          final updatedRoomInfos = multiAppData.RoomInfos?.where((roomInfo) => roomInfo.roomId != roomInfoData?.roomId).toList();
          final updatedRoomCount = updatedRoomInfos?.length ?? 0;
          multiAppData.RoomInfos = updatedRoomInfos;
          multiAppData.roomCount = updatedRoomCount;
          data['multiAppDatas'].forEach((multiAppData){
            if(multiAppData['multiAppUUID']==uuid){
              multiAppData['RoomInfos'].removeWhere((roomInfo) => roomInfo['roomId'] == roomInfoData?.roomId);
              multiAppData['roomcount'] = multiAppData['RoomInfos'].length;
            }
          });
        });
        notifyListeners();
        break;
      case 1:
        multiAppDatas!.where((multiAppData) => multiAppData.multiAppUUID == uuid)
            .forEach((multiAppData) {
          multiAppData.RoomInfos?.add(roomInfoData!);
          multiAppData.roomCount = multiAppData.RoomInfos?.length;
          if(multiAppDatas != null && multiAppDatas!.isNotEmpty && data['connectedMultiAppCount'] > 0) {
            data['multiAppDatas'].forEach((multiAppData){
              if(multiAppData['multiAppUUID']==uuid){
                multiAppData['RoomInfos'].add(roomInfoData?.toJson());
                multiAppData['roomcount'] = multiAppData['RoomInfos'].length;
              }
            });
          }

        });
        notifyListeners();
        break;
      case 2:
        if (multiAppDatas != null && multiAppDatas!.isNotEmpty && data['connectedMultiAppCount'] > 0) {
          for (var i = 0; i < data['connectedMultiAppCount']; i++) {
            var multiAppUUID = multiAppDatas?[i].multiAppUUID;
            var dataAppUUID = data['multiAppDatas'][i]['multiAppUUID'];
            if (multiAppUUID == dataAppUUID) {
              var roomcount = data['multiAppDatas'][i]['roomcount'];
              for (var j = 0; j < roomcount; j++) {
                if (multiAppDatas![i].RoomInfos != null && multiAppDatas![i].RoomInfos!.isNotEmpty) {
                  multiAppDatas![i].RoomInfos![j].dataType0 = data['multiAppDatas'][i]['RoomInfos'][j]['dataType0'];
                  multiAppDatas![i].RoomInfos![j].dataType1 = data['multiAppDatas'][i]['RoomInfos'][j]['dataType1'];
                  if (multiAppUUID == uuid) {
                    if (data['multiAppDatas'][i]['RoomInfos'][j]['roomId'] == roomInfoData?.roomId) {
                      data['multiAppDatas'][i]['RoomInfos'][j]['type'] = roomInfoData?.type;
                      data['multiAppDatas'][i]['RoomInfos'][j]['roomName'] = roomInfoData?.roomName;
                      data['multiAppDatas'][i]['RoomInfos'][j]['patientName'] = roomInfoData?.patientName;
                      data['multiAppDatas'][i]['RoomInfos'][j]['chartNumber'] = roomInfoData?.chartNumber;
                      break;
                    }
                  }
                }
              }
            }
          }
        }
        multiAppDatas!
            .where((multiAppData) => multiAppData.multiAppUUID == uuid)
            .forEach((multiAppData) {
          multiAppData.RoomInfos?.forEach((roomInfo) {
                if(roomInfo.roomId==roomInfoData?.roomId){
                  roomInfo.type=roomInfoData?.type;
                  roomInfo.roomName =roomInfoData?.roomName;
                  roomInfo.patientName =roomInfoData?.patientName;
                  roomInfo.chartNumber =roomInfoData?.chartNumber;
                }
             });
         });
        notifyListeners();
        break;
    }
  }


  void roomUpdateV2(Message4204 message){
    var uuid =  message.multiAppUUID;
    var roomInfoData = message.roomInfoV2;
    switch(message.actionType){
      case 0:
        multiAppDatas!
            .where((multiAppData) => multiAppData.multiAppUUID == uuid)
            .whereType<MultiAppDataV2>()
            .forEach((multiAppDataV2) {
          final updatedRoomInfos = multiAppDataV2.RoomInfosV2?.where((roomInfoV2) => roomInfoV2.roomId != roomInfoData?.roomId).toList();
          final updatedRoomCount = updatedRoomInfos?.length ?? 0;
          multiAppDataV2.RoomInfosV2 = updatedRoomInfos;
          multiAppDataV2.roomCount = updatedRoomCount;
          data['multiAppDatas'].forEach((multiAppData){
            if(multiAppData['multiAppUUID']==uuid){
              multiAppData['RoomInfos'].removeWhere((roomInfo) => roomInfo['roomId'] == roomInfoData?.roomId);
              multiAppData['roomcount'] = multiAppData['RoomInfos'].length;
            }
         });
        });
        notifyListeners();
        break;
      case 1:
        multiAppDatas!
            .where((multiAppData) => multiAppData.multiAppUUID == uuid)
            .whereType<MultiAppDataV2>()
            .forEach((multiAppDataV2) {
          multiAppDataV2.RoomInfosV2?.add(roomInfoData!);
          multiAppDataV2.roomCount = multiAppDataV2.RoomInfosV2?.length;
          if(multiAppDatas != null && multiAppDatas!.isNotEmpty && data['connectedMultiAppCount'] > 0) {
            data['multiAppDatas'].forEach((multiAppData){
              if(multiAppData['multiAppUUID']==uuid){
                multiAppData['RoomInfos'].add(roomInfoData?.toJson());
                multiAppData['roomcount'] = multiAppData['RoomInfos'].length;
              }
            });
          }
        });
        notifyListeners();
        break;
      case 2:
       if(multiAppDatas != null && multiAppDatas!.isNotEmpty && data['connectedMultiAppCount'] > 0) {
         for (var i = 0; i < data['connectedMultiAppCount']; i++) {
           var multiAppUUID = multiAppDatas?[i].multiAppUUID;
           var dataAppUUID = data['multiAppDatas'][i]['multiAppUUID'];
           if (multiAppUUID == dataAppUUID && multiAppDatas?[i] is MultiAppDataV2) {
             var roomcount = data['multiAppDatas'][i]['roomcount'];
             MultiAppDataV2? currentMultiAppDataV2 = multiAppDatas?[i] as MultiAppDataV2?;
             if (currentMultiAppDataV2?.RoomInfosV2 != null) {
               for (var j = 0; j < roomcount; j++) {
                 if (currentMultiAppDataV2!.RoomInfosV2!.length > j) {
                   currentMultiAppDataV2.RoomInfosV2![j].dataType0 = data['multiAppDatas'][i]['RoomInfos'][j]['dataType0'];
                   currentMultiAppDataV2.RoomInfosV2![j].dataType1 = data['multiAppDatas'][i]['RoomInfos'][j]['dataType1'];

                   if (multiAppUUID == uuid) {
                      if (data['multiAppDatas'][i]['RoomInfos'][j]['roomId'] == roomInfoData?.roomId) {
                        data['multiAppDatas'][i]['RoomInfos'][j]['type'] = roomInfoData?.type;
                        data['multiAppDatas'][i]['RoomInfos'][j]['roomName'] = roomInfoData?.roomName;
                        data['multiAppDatas'][i]['RoomInfos'][j]['patientName'] = roomInfoData?.patientName;
                        data['multiAppDatas'][i]['RoomInfos'][j]['chartNumber'] = roomInfoData?.chartNumber;
                        data['multiAppDatas'][i]['RoomInfos'][j]['chartApiId'] = roomInfoData?.chartApiId;
                       break;
                     }
                   }
                 }
               }
             }
           }
         }
       }
        multiAppDatas!
            .where((multiAppData) => multiAppData.multiAppUUID == uuid)
            .whereType<MultiAppDataV2>()
            .forEach((multiAppDataV2) {
          multiAppDataV2.RoomInfosV2?.forEach((roomInfoV2) {
            if(roomInfoV2.roomId == roomInfoData?.roomId){
              roomInfoV2.type = roomInfoData?.type;
              roomInfoV2.roomName = roomInfoData?.roomName;
              roomInfoV2.patientName = roomInfoData?.patientName;
              roomInfoV2.chartNumber = roomInfoData?.chartNumber;
              roomInfoV2.chartApiId = roomInfoData?.chartApiId;
            }
          });
        });
        notifyListeners();
        break;
    }
  }



}
