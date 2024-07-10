import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:vibration/vibration.dart';

import 'MonitoringRoomList.dart';

class MonitoringListScreen extends StatefulWidget {
  const MonitoringListScreen({Key? key}) : super(key: key);

  @override
  State<MonitoringListScreen> createState() => _MonitoringListScreenState();
}

enum Bell { Ring, Vibration }

class _MonitoringListScreenState extends State<MonitoringListScreen> {
  MonitoringDataManager? _monitoringDataManager = MonitoringDataManager();
  MonitoringRoomManager? _monitoringRoomManager = MonitoringRoomManager();
  ProfileManager _profileManager = ProfileManager();
  SocketManager? _socketManager = SocketManager();
  AppCache appCache = AppCache();
  bool _isTimerStart = true;
  int _bellState = 2;
  Timer? _timer;
  //Bell? _bell = Bell.Vibration;

  @override
  initState() {
    _profileManager = Provider.of<ProfileManager>(context, listen: false);
    _socketManager = Provider.of<SocketManager>(context, listen: false);
    _monitoringRoomManager =
        Provider.of<MonitoringRoomManager>(context, listen: false);
    super.initState();
  }

  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies

    final input = Message2101(
      msgSize: 21,
      msgId: 2101,
      reId: 1,
      hospitalId: int.parse(_profileManager.userData.hospitalId!),
      vetId: int.parse(_profileManager.userData.id!),
      isReceivedData: true,
    );
    await sendMsg(input);
    final inputV2 = Message4101(
      msgSize: 21,
      msgId: 4101,
      reId: 1,
      hospitalId: int.parse(_profileManager.userData.hospitalId!),
      vetId: int.parse(_profileManager.userData.id!),
      isReceivedData: true,
    );
    await sendMsg(inputV2);
    _bellState = await appCache.getMonitoringAlarmState();
    super.didChangeDependencies();
  }

  Future<void> sendMsg(var input) async {
    /**
     * 소켓에 방정보 요청 true 보냄
     * */
    if (_socketManager?.socket is Socket) {
      final bytes = input.toByteArray();
      await _socketManager?.sendMsg(bytes);
    }
  }


  void _startTimer() {
    if (mounted) {
      _timer = Timer(Duration(seconds: 15), () {
        setState(() {
          _isTimerStart = false;
        });
        _stopTimer();
      });
    }
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }
  @override
  Widget build(BuildContext context) {
    /**
     * 1. 방정보가 null 이면 타이머 + 로딩바 돌리기
     * 2. 방정보가 0 이면 텍스트띄우기
     * 3. 방정보가 1 이상이면 방띄우기
     * */
    return Container(
        color: Colors.black,
        child: SingleChildScrollView(
          child: Consumer<MonitoringRoomManager>(builder: (context, data, child) {
            _monitoringRoomManager = data;
            if (_monitoringRoomManager?.multiAppDatas==null) {
              return awaitResultWidget();
            }
            else if (_monitoringRoomManager?.multiAppDatas?.length==0) {
              _stopTimer();
              return Column(
                children: [
                  topWidget(),
                  Container(
                    margin: EdgeInsets.all(10),
                  ),
                  Text(
                    'Please connect your Patient Monitor device'.tr(),
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        _socketManager?.resetAndRefreshSocket();
                        setState(() {
                          _isTimerStart = true;
                        });
                        UtilityFunction.log.e('멀티 모니터링 새로고침 누름 ');
                      },
                      child: Text(
                        'Refresh'.tr(),
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              );
            } else if (_monitoringRoomManager!.multiAppDatas!.isNotEmpty) {
              _stopTimer();
              return Column(
                children: [
                  topWidget(),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _monitoringRoomManager!.multiAppDatas!.length,
                      itemBuilder: (BuildContext context, int index) {
                        var multiAppData = _monitoringRoomManager!.multiAppDatas![index];
                        return Container(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        '${multiAppData.multiAppName}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.start,
                                      ),
                                      margin: EdgeInsets.only(left: 20),
                                    ),
                                  ),
                                ],
                              ),
                              MonitoringRoomList(multiAppData: multiAppData.toJson()),
                            ],
                          ),
                        );
                      }),
                ],
              );
            }
            return LoadingBar();
          }),
        ));
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget awaitResultWidget() {
    /**
     * 타이머시작
     * 로딩바 돌리기 -> 타이머 시작될동안
     * 버튼+ 텍스트 글자 -> 타이머 종료시 까지 룸 값없으면
     * */
    if (!_isTimerStart) {
      return Column(children: [
        Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: VetTheme.mediaHalfSize(context),
            ),
            Container(
              margin: EdgeInsets.all(5),
            ),
            Text(
              'I apologize, there was an error connecting to the server'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white),
            ),
            Container(
              margin: EdgeInsets.all(5),
            ),
            Text(
              'Please check your network connection or contact the application Developer for assistance'
                  .tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white),
            ),
            Container(
              margin: EdgeInsets.all(5),
            ),
            Text(
              'Do you like to try reconnecting the server?'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            Container(
              margin: EdgeInsets.all(5),
            ),
            ElevatedButton(
                onPressed: () {
                  _socketManager?.resetAndRefreshSocket();
                  setState(() {
                    _isTimerStart = true;
                  });
                  UtilityFunction.pushReplacementNamed(context, '/');
                  UtilityFunction.log.e('멀티모니터링 새로고침 누름 ${_isTimerStart}');
                },
                child: Text('Try reconnecting the server'.tr())),
          ],
        ),
      ]);
    } else {
      _startTimer();
      return LoadingBar();
    }
  }

  Widget topWidget() {
    String local = EasyLocalization.of(context)!.locale.toString();
    String today = DateFormat('yMMMd', local).format(DateTime.now());
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Container(
            height: VetTheme.monitorCardSizeByDeviceHeight(context),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Expanded(
                      flex: 1,
                      child: SvgPicture.asset(
                        'assets/icons/logo_multi.svg',
                        height: VetTheme.logoHeight(context),
                      )
                    ),

                  Expanded(
                    flex: 2,
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        today,
                        style: TextStyle(color: Colors.white,
                            fontSize: VetTheme.titleTextSize(context)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB
                       (0,5, 0, 5),
                      child: setAlertModeWidget(),
                    ),
                  ),
                ],
              ),
          ),

          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
            padding: EdgeInsets.symmetric(horizontal: 5),
            //  margin: EdgeInsets.symmetric(vertical: 0,horizontal: 0),
            child: Card(
              color: Colors.black,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    // Container(
                    //   margin: EdgeInsets.symmetric(vertical: 7),
                    //   child: IconButton(
                    //       onPressed: () {
                    //         UtilityFunction.log
                    //             .e('새로고침 누름 여기가 로딩창 뜨게 해야함${_isTimerStart}');
                    //         _socketManager?.resetAndRefreshSocket();
                    //         setState(() {
                    //           _isTimerStart = true;
                    //         });
                    //       },
                    //       icon: Icon(
                    //         Icons.refresh,
                    //         size: VetTheme.monitorCardSizeByDeviceHeight(context)/2,
                    //       )
                    //   ),
                    // ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      VetTheme.diviceH(context) < 800 ? 15 : 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            child: Text(' |  ',
                                style: TextStyle(
                                    fontSize: VetTheme.logotextSize(context), color: Colors.black)))),
                    Expanded(
                        flex: 3,
                        child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 5),
                                  height: 50,
                                  width: 50,
                                  child: SvgPicture.asset(
                                    'assets/icons/heart.svg',
                                  ),
                                ),
                                Container(
                                    height: 50,
                                    width: 50,
                                    margin: EdgeInsets.only(right: 2),
                                    child: Image.asset(
                                      'assets/icons/lung.png',
                                    )),
                              ],
                            )))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget setAlertModeWidget() {
    if (_bellState == 2) {
      return InkWell(
        child: Image.asset(
        'assets/icons/sound.png',

        ),
        onTap: () {
          UtilityFunction.log.e('모니터링 진동 켬');
          setState(() {
            _bellState = 1;
            appCache.setMonitoringAlarmState(1);
          });
        },
      );
    } else if (_bellState == 1) {
      return InkWell(
       child: Image.asset(
          'assets/icons/vibration.png',
        ),
        onTap: () {
          UtilityFunction.log.e('모니터링 소리 끔');
          setState(() {
            _bellState = 0;
            appCache.setMonitoringAlarmState(0);
          });
        },
      );
    } else {
      return InkWell(
        child:
         Image.asset(
          'assets/icons/mute.png',
           height: VetTheme.monitorCardSizeByDeviceHeight(context)/2,
        ),
        onTap: () {
          UtilityFunction.log.e('모니터링 소리 켬');
          setState(() {
            _bellState = 2;
            appCache.setMonitoringAlarmState(2);
          });
        },
      );
    }
  }
}
