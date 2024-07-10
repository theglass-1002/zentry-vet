import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/utility_function.dart';

class ApiService extends ApiUtility with AppCache{




  final bool isAndroid = Platform.isAndroid;


  Future <Result<ResponseError, versionCheckResponse>> versionCheck() async {
    Uri platformVersionUrl = isAndroid? productUri('/v1', '/version/2001'):
    productUri('/v1', '/version/2002');
 //   UtilityFunction.log.e(platformVersionUrl.toString());
     return await fetchAppForce(platformVersionUrl);
  }



  Future<bool> checkToken() async {
   return await fetchSession(authUri('/v1','/vet/auth'),{
    'authorization':await getAccessToken()});

  }

  Future<bool> join (String name,String email, String pw, String authType, String authId) async{
   return await fetchJoin(hospitalUri('/v1', '/veterinarians'), {
      'name': name,
      'email': email,
      'password': pw,
      'authority': '0',
      'authType': authType,
      'authId': authId,
    }).then((result)
     => result.when((error) {
        UtilityFunction.log.e(error.message);
         return false;
      }, (success) => true));
  }

  Future<Result<ResponseError, LoginPost>> login(String pw) async {
    return await fetchLoginV2(authUri('/v2','/vet/auth'), {
            'password': pw,
            'pushMessageToken':await getFcmToken(),
    });
   }

  Future<Result<ResponseError, LoginPost>> loginV3(Map<String, String> headers,Map<String, String>  bodys) async {
   return await fetchLoginV3(authUri('/v3', '/vet/auth'),headers,bodys);
  }

  Future<bool> appleLogin(String authorizationCode, String identityToken,) async {
    return await fetchAppleLogin(authUri('/v1','/vet/auth/apple'), {
          'authorizationCode': authorizationCode,
          'identityToken':identityToken,
          'pushMessageToken':await getFcmToken(),
        }).then((result) => result.when((error) => false, (success) async {
      int nUserID = UtilityFunction.getUserIdJwt(success.accessToken);
      print('로그인 성공');
      UtilityFunction.log.e(nUserID);
      UtilityFunction.log.e(success.refreshToken);
      UtilityFunction.log.e(success.accessToken);
      print('로그인 성공');
      print(nUserID);
      print(nUserID.toString());
      await setUserId(nUserID.toString());
      await setAccessToken(success.accessToken);
      await setRefreshToken(success.refreshToken);
      return true;
    }));
  }


  Future<Result<ResponseError, LoginApplePost>> appleLoginV2(Map<String, String> headers,Map<String, String> bodys,) async {
   return await fetchAppleLogin2(authUri('/v2', '/vet/auth/apple'),headers,bodys);
  }


  Future<bool> logout() async {
    var result = await fetchLogout(authUri('/v1','/vet/auth'), {
      'authorization': await getAccessToken(),
      'x-refresh': await getRefreshToken()
    });
    Map<String, dynamic> resultJson = jsonDecode(result);
    if(resultJson['result']=="SUCCESS"){
     return true;
    }else{
      return false;
    }
  }

  Future <Result<ResponseError,User>> getUserData([String? userId]) async{
    String user_Id = userId??await getUserId();
    // return await fetchUserData(hospitalUri('/v1', '/veterinarians/$user_Id'),
    //     {'authorization':await getAccessToken()});
     return await fetchUserData(hospitalUri('/v1', '/hospital/users/$user_Id'),
            {'authorization':await getAccessToken()});
  }

  Future <Result<ResponseError,Hospital>> getHospitalData() async{
    return await fetchHospitalData(hospitalUri('/v1', '/hospitals/${await getHospitalId()}'),
        {'authorization':await getAccessToken()});
  }
  Future <Result<ResponseError,AnimalData>> getAnimalData(Map<String, String> header) async{
    return await fetchAnimalData(personalUri('/v1','/animal'),
        header
    );
  }

 Future <Result<ResponseError,ResponseResult>> updateAnimalQr(String animalId,Map<String, String> body) async{
   return await fetchAnimalQr(hospitalUri('/v2','/patients/$animalId/animal'),
       {'authorization':await getAccessToken()},body);
 }

 Future <Result<ResponseError,AnimalBreedListInfo>> getBreedsLastUpdate() async{
   return await fetchBreedInfo(personalUri('/v1','/breeds/breed/count'),
       {'authorization':await getAccessToken()}
   );
 }

 Future <Result<ResponseError, String>>  getBreedList() async{
  return await fetchBreedList(personalUri('/v1','/breeds'),
       {'authorization':await getAccessToken()});


 }

 Future <Result<ResponseError, ResponseResult>>  updateMonitoringNotify(String userId,Map<String, dynamic> body) async{
   return await fetchMonitoringNotify(hospitalUri('/v1','/hospital/users/$userId/monitoring/enabled'),
       {'authorization':await getAccessToken()},
       body);

 }



 Future <Result<ResponseError,VetList>> getVetList() async{
    return await fetchVetList(hospitalUri('/v1', '/veterinarians',{
      'hospitalId':await getHospitalId()
    }),
        {'authorization':await getAccessToken()});
  }


  
  Future <Result<ResponseError, AnimalList>> getAnimalList2([Map<String, dynamic>? queryParameters]) async{
   return await fetchAnimalList(hospitalUri('/v2', '/patients',queryParameters),
        {'authorization':await getAccessToken()});
  }


  Future <Result<ResponseError, AnimalList>> getAnimalList3([Map<String, dynamic>? queryParameters]) async{
    return await fetchAnimalList(hospitalUri('/v3', '/patients',queryParameters),
        {'authorization':await getAccessToken()});
  }

  Future <Result<ResponseError,HospitalRequest>> joinHospital2(Map<String, String> fields, List<MultipartFile> files) async{
    return await postjoinHospital(hospitalUri('/v2', '/requests'),{'authorization':await getAccessToken()}, fields, files);
  }

  Future <Result<ResponseError,HospitalRequest>> joinHospital(Map<String, String> fields, List<MultipartFile> files) async{
    return await postjoinHospital(hospitalUri('/v1', '/requests'),{'authorization':await getAccessToken()}, fields, files);
  }


  Future <Result<ResponseError, bool>> addVet(String vetId, Map<String, String> body) async{
    return await fetchVet(hospitalUri('/v1','/veterinarians/$vetId/register'), {
      'authorization':await getAccessToken()
    },body);
  }


  Future <Result<ResponseError, ResponseResult>> updateVetauthority(String vetId, Map<String, String> body) async{
    return await patchVetAuthority(hospitalUri('/v1','/veterinarians/$vetId/authority'), {
      'authorization':await getAccessToken()
    },body);
  }
  //
  // Future <Result<ResponseError, ResponseResult>> addPatient(Map<String, String> body) async{
  //   return await postAddPatient(hospitalUri('/v1', '/patients'), {
  //     'authorization':await getAccessToken()
  //   },body);
  // }
  //



 Future <Result<ResponseError, ResponseResult>> addPatient2(Map<String, String> body) async{
   return await postAddPatient(hospitalUri('/v2', '/patients'), {
     'authorization':await getAccessToken()
   },body);
 }

 // Future<Result<ResponseError, ResponseResult>> updateChartNumber(String animalId,Map<String, String> body) async{
 //   return await patchChartNumber(hospitalUri('/v1', '/patients/$animalId/chart'), {
 //     'authorization':await getAccessToken()
 //   },body);
 // }

 // Future<Result<ResponseError, ResponseResult>> updateVisibility(String animalId,
 //     Map<String, dynamic> body) async{
 //   return await patchVisibility(hospitalUri('/v1', '/patients/$animalId/visibility'),
 //       {'authorization':await getAccessToken()}, body);
 // }


 Future<Result<ResponseError, ResponseResult>> updatePatientsData(String animalId,
     Map<String, String> body) async{
   return await patchPatientsData(hospitalUri('/v2', '/patients/$animalId/info'),
       {'authorization':await getAccessToken()}, body);
 }


 Future<Result<ResponseError, ResponseResult>> updateVisibility2(String animalId,
     Map<String, dynamic> body) async{
   return await patchVisibility(hospitalUri('/v2', '/patients/$animalId/visibility'),
       {'authorization':await getAccessToken()}, body);
 }


 // Future<Result<ResponseError, ResponseResult>> deleteAnimal(String animalId,
 //     ) async{
 //   return await fetchDeleteAnimal(hospitalUri('/v1','/patients/$animalId'),
 //       {'authorization':await getAccessToken()});
 // }

 Future<Result<ResponseError, ResponseResult>> deleteAnimal2(String animalId,
     ) async{
   return await fetchDeleteAnimal(hospitalUri('/v2','/patients/$animalId'),
       {'authorization':await getAccessToken()});
 }
  Future <Result<ResponseError, ResponseResult>> deregisterVet(String vetId) async{
    return await patchVetDeregister(hospitalUri('/v1','/veterinarians/$vetId/deregister'), {
      'authorization':await getAccessToken()
    });
  }

  Future <Result<ResponseError, bool>> sendReport(Map<String, String> fields, List<MultipartFile> sendFiles) async{
    return await fetchReport(productUri('/v1','/reports'),
       {'authorization':await getAccessToken()},
       fields, sendFiles);
  }


  Future <Result<ResponseError, HandoverRequestMessage>> handOverApiV3(Map<String, String> fields, List<MultipartFile> sendFiles) async{
    return await postHandoverHospitalV3(hospitalUri('/v3', '/requests/handover'),
        {'authorization':await getAccessToken()}, fields, sendFiles);
  }

  Future <Result<ResponseError, HospitalRequest>> handOverApi2(Map<String, String> fields, List<MultipartFile> sendFiles) async{
    return await postHandoverHospital(hospitalUri('/v2', '/requests/handover'),
        {'authorization':await getAccessToken()}, fields, sendFiles);
  }

  Future<Result<ResponseError, ResponseResult>> executeHandoverAuthRequestV3(String handoverRequestId,Map<String, dynamic> body) async {
    return await patchHandoverAuthRequestV3(hospitalUri('/v3', '/requests/handover/$handoverRequestId/result'), {
      'authorization': await getAccessToken(),
    },body);
  }

  Future <Result<ResponseError,NotificationsList>> getNotifyList() async {
    return await fetchNotifyList(hospitalUri('/v1', '/push/logs', {'vetId': await getUserId()}),
        {'authorization': await getAccessToken()});
  }

  //
  // Future <Result<ResponseError, Chart>> getPatientData(String animalId, Map<String, String> params) async {
  //   return await fetcPatientData(hospitalUri('/v1', '/patients/$animalId', params),
  //       {'authorization': await getAccessToken()});
  // }

 Future <Result<ResponseError, Chart>> getPatientData2(String animalId, Map<String, String> params) async {
    return await fetcPatientData(hospitalUri('/v2', '/patients/$animalId', params),
       {'authorization': await getAccessToken()});
 }



 Future <Result<ResponseError, SearchAnimalList>> getSearchAnimalList2(Map<String, String> params) async {
   return await fetchSearchAnimalList(hospitalUri('/v2', '/patients', params),
       {'authorization': await getAccessToken()});
 }


  Future<Result<ResponseError, ResponseResult>>  setWithdrawalUser() async {
    return await deleteUser(hospitalUri('/v1', '/veterinarians/${await getUserId()}'), {
      'authorization': await getAccessToken(),
      'x-refresh': await getRefreshToken()
    });
  }

  Future<Result<ResponseError, ResponseResult>> executeUpdateHospital(String hospitalId,Map<String, dynamic> body) async {
    return await updateHospitalApi(hospitalUri('/v2','/hospitals/$hospitalId'),
        {'authorization': await getAccessToken()},body);
  }


  Future <Result<ResponseError, Announcement>> connectGetAnnouncementPosts(Map<String, dynamic> params) async {
    return await getAnnouncementPostsAPI(productUri('/v1', '/notices', params),
        {'authorization': await getAccessToken()});
  }


  Future <Result<ResponseError, AnnouncementDetail>> connectGetAnnouncementDetail(String post_id) async {
    return await getAnnouncementDetailAPI(productUri('/v1', '/notice/$post_id'),
        {'authorization': await getAccessToken()});
  }



  Future <bool> refreshToken()async {
    UtilityFunction.log.e('토큰 갱신 함수 실향');
     return await fetchrefreshToken(authUri('/v1', '/vet/auth/refresh'),
        {'authorization':await getAccessToken(),
          'x-refresh': await getRefreshToken()
        }).
         then((value) { return value.when((error) {
             UtilityFunction.log.e(error.code);
             UtilityFunction.log.e(error.message);
                return false;
          }, (success) async {
           UtilityFunction.log.e('토큰 갱신완료');
            await setAccessToken(success);
           return true;
         });
     });
  }


  /**
   *
   * 모니터링 데이터
   *
   * */

  Future <Result<ResponseError, PatientMonitoringChart>> getPatientMonitoringData(String monitoringType, String chartApiId) async {
    return await getPatientMonitoringDataApi(hospitalUri('/v1', '/chart/$monitoringType/$chartApiId'),
        {'authorization': await getAccessToken()});
  }


  final _appCache = AppCache();
  final _apiUtility = ApiUtility();




  // Future <Result<ResponseError,NotificationsList>> getNotifyList() async {
  //   var response = await _apiUtility.fetchNotifyList(
  //       _apiUtility.hospitalUri(
  //           '/v1', '/push/logs', {'vetId': await _appCache.getUserId()}),
  //       {'authorization': await _appCache.getAccessToken()});
  //     return response.when((error) async {
  //     if (error.re_code == UnauthorizedCode && error.code == 101) {
  //      return await refreshToken()?await getNotifyList():Error(error);
  //     }
  //     return Error(error);
  //   },(success) =>Success(success));
  // }


// Future<bool> login(String pw) async {
//  return _apiUtility.fetchLoginV2(_apiUtility.authUri('/v2','/vet/auth'),
//      {
//        'password': pw,
//        'pushMessageToken':await _appCache.getFcmToken(),
//      }).then((result) => result.when((error) => false, (success) {
//           int nUserID = UtilityFunction.getUserIdJwt(success.refreshToken);
//           _appCache.setUserId(nUserID.toString());
//           _appCache.setAccessToken(success.accessToken);
//           _appCache.setRefreshToken(success.refreshToken);
//           return true;
//      }));
//    }

 // Future<bool> getPermission() async =>await getIsPermission();

// Future<bool> checkToken() async {
//  return await fetchSession(authUri('/v1', '/vet/auth'),{
//    'authorization':await getAccessToken()
//  } );
//
// }
}

  
