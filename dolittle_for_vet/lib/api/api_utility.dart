import 'dart:convert';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:http/http.dart' as http;
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:multiple_result/multiple_result.dart';

const ResponseSuccessCode = 200;
const BadRequestCode = 400;
const UnauthorizedCode = 401;
const InternalServerErrorCode = 500;

class ApiUtility{


  static bool isBuild = false;
  static bool _IsRealServerState = isBuild;
  static int _serverRoute = 0;
  final app_cache = AppCache();




  void setIsRealServerState(bool value){
    _IsRealServerState = value;
  }

  bool getIsRealServerState(){
    return _IsRealServerState;
  }

  void setServerRoute(int value){
    _serverRoute = value;
  }

  int getServerRoute(){
    return _serverRoute;
  }



  //서비스 이용약관
  static const String termsOfService = "https://zentry.kr/termsservice_vet.html";
  static const String termsOfService_en = "https://zentry.kr/termsservice_vet_en.html";
  static const String termsOfService_es = "https://zentry.kr/termsservice_vet_es.html";

  //개인정보 수집/이용동의 URL
  static const String personalInfoConsent = "https://zentry.kr/policyinfo_vet.html";
  static const String personalInfoConsent_en = "https://zentry.kr/policyinfo_vet_en.html";
  static const String personalInfoConsent_es = "https://zentry.kr/policyinfo_vet_es.html";
  //개인정보처리방침 URL
  static const String privacyPolicy = "https://zentry.kr/policy.html";
  static const String privacyPolicy_en = "https://zentry.kr/policy-en.html";
  static const String privacyPolicy_es = "https://zentry.kr/policy-es.html";

  String _hospitalServerUrl(){
    return getIsRealServerState()?'api.moon-cluster.zentry.kr':'api.dolittle-dev-cluster.zentry.kr';
  }
  final String _hospitalPath = 'hospital/api';





  String _productServerUrl(){
    return getIsRealServerState()? 'api.moon-cluster.zentry.kr':'api.dolittle-dev-cluster.zentry.kr';
  }
  final String _productPath = 'product/api';




  String _authServerUrl(){
    return getIsRealServerState()? 'api.moon-cluster.zentry.kr':'api.dolittle-dev-cluster.zentry.kr';
  }
  final String _authPath = 'auth/api';



  String _personalServerUrl(){
    return getIsRealServerState() ? "api.moon-cluster.zentry.kr"
        : "api.personal-dev.zentry.kr";
  }

  final String _personalPath = '/api';



  // String _socketHost(){
  //   return getIsServerReal() ?"multi.monitoring.realtime.zentry.kr":"multi.monitoring.realtime-dev.zentry.kr";
  // }
  // String _europDemoServer(){
  //   return getIsServerReal() ?"multi.monitoring.realtime.frankfurt.zentry.kr":"multi.monitoring.realtime.frankfurt.zentry.kr";
  // }

  final int SocketPort =  30000;



  String getSocketHost(){
    String socketHost = "";
    switch (getServerRoute()) {
      case 0:
       socketHost = getIsRealServerState() ?"multi.monitoring.realtime.zentry.kr":"multi.monitoring.realtime-dev.zentry.kr";

        break;
      case 1:
        socketHost = getIsRealServerState() ?"multi.monitoring.realtime.frankfurt.zentry.kr":"multi.monitoring.realtime.frankfurt.zentry.kr";
        break;
    }
    return socketHost;
  }

  Uri hospitalUri(String ver,String path,[Map<String, dynamic>? queryParameters]){
    String uriPath = "$_hospitalPath$ver$path";
    Uri uri = Uri.https(_hospitalServerUrl(),uriPath,queryParameters);
    return uri;
  }


  Uri authUri(String ver,String path,[Map<String, dynamic>? queryParameters]){
    String uriPath = "$_authPath$ver$path";
    Uri uri = Uri.https(_authServerUrl(),uriPath,queryParameters);
    return uri;
  }

  Uri productUri(String ver,String path,[Map<String, dynamic>? queryParameters]){
    String uriPath = "$_productPath$ver$path";
    Uri uri = Uri.https(_productServerUrl(),uriPath,queryParameters);
    return uri;
  }

  Uri personalUri(String ver,String path,[Map<String, dynamic>? queryParameters]){
    String uriPath = "$_personalPath$ver$path";
    Uri uri = getIsRealServerState()? Uri.https(_personalServerUrl(),uriPath,queryParameters):Uri.http(_personalServerUrl(),uriPath,queryParameters);
    return uri;
  }


  Future<Result<ResponseError, versionCheckResponse>> fetchAppForce(
      Uri uri) async {
    final response = await http.get(uri);
   //  UtilityFunction.log.e(response.body);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(versionCheckResponse.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  // 토큰이 존재하는 토큰인지 체크한다.
  Future<bool> fetchSession(Uri uri, Map<String, String> headers)
  async {
    final http.Response response = await http.get(uri, headers: headers);
    if (response.statusCode == ResponseSuccessCode){
      return true;
    }else{
      return false;
    }
  }

  Future<Result<ResponseError, RegistPost>> fetchJoin(
      Uri uri, Map<String, String> body) async {
    final response = await http.post(uri, body:body );
    UtilityFunction.log.e(response.toString());
    print(response);

    if (response.statusCode == ResponseSuccessCode) {
      return Success(RegistPost.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, LoginApplePost>> fetchAppleLogin(
      Uri uri, Map<String, String> body) async {
    final http.Response response = await http.post(uri, body: body);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(LoginApplePost.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }


  Future<Result<ResponseError, LoginApplePost>> fetchAppleLogin2(
      Uri uri,Map<String, String> headers,Map<String, String> bodys) async {
    final http.Response response = await http.post(uri, headers: headers,body: bodys);

    if (response.statusCode == ResponseSuccessCode) {
      UtilityFunction.log.e('appleV2로그인성공${response.body.toString()}');
      return Success(LoginApplePost.fromJson(json.decode(response.body)));
    } else {

      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, LoginPost>> fetchLoginV2(
      Uri uri, Map<String, String> body) async {
    final http.Response response = await http.post(uri, body: body);
    if (response.statusCode == ResponseSuccessCode) {
      //UtilityFunction.log.e('로그인 v2 ${response.body.toString()}');
      return Success(LoginPost.fromJson(json.decode(response.body)));
    } else {
      UtilityFunction.log.e('로그인 v2 ${response.body.toString()}');
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));

    }
  }

  Future<Result<ResponseError, LoginPost>> fetchLoginV3(
      Uri uri, Map<String, String> headers,Map<String, String> bodys) async {
    final http.Response response = await http.post(uri,headers: headers,body: bodys);
    if (response.statusCode == ResponseSuccessCode) {

      return Success(LoginPost.fromJson(json.decode(response.body)));
    } else {
     // UtilityFunction.log.e('로그인 v3${response.body.toString()}');
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));

    }
  }

  Future<String> fetchLogout(Uri uri,Map<String, String> header) async {
    final http.Response response = await http.delete(uri, headers: header);
    return response.body;
  }


  Future<Result<ResponseError, ResponseResult>> updateHospitalApi(
      Uri uri,
      Map<String, String> headers,
      Map<String, dynamic> body) async {
    final http.Response response = await http.patch(uri, headers: headers,body: body);
    if (response.statusCode == ResponseSuccessCode) {
      UtilityFunction.log.e(response.body.toString());
      return Success(ResponseResult.fromJson(json.decode(response.body)));
    } else {
      UtilityFunction.log.e(response.body.toString());
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }


  Future <Result<ResponseError,User>> fetchUserData(
      Uri uri, Map<String, String> headers) async {
    final response = await http.get(uri, headers: headers);
    if(response.statusCode == ResponseSuccessCode){
      //UtilityFunction.log.e(response.body.toString());
      return Success(User.fromJson(json.decode(response.body)));
    }else{
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }



  Future<Result<ResponseError, AnimalData>> fetchAnimalData(
      Uri uri, Map<String, String> headers) async {
    final response = await http.get(uri, headers: headers);
    //UtilityFunction.log.e(response.body);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(AnimalData.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, ResponseResult>> fetchAnimalQr(
      Uri uri, Map<String, String> headers, Map<String, String> body) async {
   // UtilityFunction.log.e(uri.toString());
    final http.Response response = await http.patch(uri,headers: headers, body: body);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(ResponseResult.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));

    }
  }



  Future<Result<ResponseError, AnimalList>> fetchAnimalList(
      Uri uri, Map<String, String> headers) async {
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(AnimalList.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }


  Future<Result<ResponseError, AnimalBreedListInfo>> fetchBreedInfo(
      Uri uri, Map<String, String> headers) async {
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == ResponseSuccessCode) {

      return Success(AnimalBreedListInfo.fromJson(json.decode(response.body)));
    } else {
      UtilityFunction.log.e(response.body.toString());
      UtilityFunction.log.e('breed info 에러');
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, String>> fetchBreedList(
      Uri uri, Map<String, String> headers) async {
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(response.body);
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, Hospital>> fetchHospitalData(
      Uri uri, Map<String, String> headers) async {
    final response = await http.get(uri, headers: headers);

    //UtilityFunction.log.e(uri.toString());
    if (response.statusCode == ResponseSuccessCode) {
     // UtilityFunction.log.e('병원정보 가져오기 ${response.body.toString()}');
      return Success(Hospital.fromJson(json.decode(response.body)));
    } else {
      UtilityFunction.log.e('병원정보 가져오기  ${response.body.toString()}');
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, VetList>> fetchVetList(Uri uri,Map<String, String> headers) async {
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == ResponseSuccessCode) {
       return Success(VetList.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError,bool>> fetchVet(Uri uri,Map<String, String> headers,Map<String, String> body) async {
    final response = await http.patch(uri, headers: headers ,body: body);
    UtilityFunction.log.e(response.body);
    if (response.statusCode == ResponseSuccessCode) {
      return const Success(true);
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, ResponseResult>> postAddPatient(
      Uri uri, Map<String, String> headers, Map<String, String> body) async {
    final http.Response response = await http.post(uri,headers: headers, body: body);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(ResponseResult.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));

    }
  }


  Future<Result<ResponseError, ResponseResult>> patchVetAuthority(
      Uri uri, Map<String, String> headers, Map<String, String> body) async {
    var response = await http.patch(uri, headers: headers, body: body);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(ResponseResult.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }


  Future<Result<ResponseError, ResponseResult>> patchVetDeregister(
      Uri uri, Map<String, String> headers) async {
    var response = await http.patch(uri, headers: headers);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(ResponseResult.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, bool>> fetchReport(
      Uri uri,
      Map<String, String> headers,
      Map<String, String> fields,
      List<http.MultipartFile> sendFiles) async {
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.fields.addAll(fields);
    request.files.addAll(sendFiles);
    http.StreamedResponse streamedResponse = await request.send();
    UtilityFunction.log.e(uri.toString());
    var response = await http.Response.fromStream(streamedResponse);
    UtilityFunction.log.e(response.body);
    if (response.statusCode == ResponseSuccessCode) {
      return const Success(true);
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }




  Future<Result<ResponseError, HandoverRequestMessage>> postHandoverHospitalV3(
      Uri uri,
      Map<String, String> headers,
      Map<String, String> fields,
      List<http.MultipartFile> files) async {
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.fields.addAll(fields);
    request.files.addAll(files);
    http.StreamedResponse streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    UtilityFunction.log.e(response.body.toString());
    if (response.statusCode == ResponseSuccessCode) {
      return Success(HandoverRequestMessage.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, HospitalRequest>> postHandoverHospital(
      Uri uri,
      Map<String, String> headers,
      Map<String, String> fields,
      List<http.MultipartFile> files) async {
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.fields.addAll(fields);
    request.files.addAll(files);
    http.StreamedResponse streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    UtilityFunction.log.e(response.body.toString());
    if (response.statusCode == ResponseSuccessCode) {
      UtilityFunction.log.e('양도 응답 ${response.body.toString()}');
      return Success(HospitalRequest.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }


  Future<Result<ResponseError, ResponseResult>> patchHandoverAuthRequestV3(Uri uri,
      Map<String, String> headers,Map<String, dynamic> body) async {
    final response = await http.patch(uri,headers: headers,body: body);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(ResponseResult.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, ResponseResult>> patchChartNumber(Uri uri,
      Map<String, String> headers,Map<String, String> body) async {

    final response = await http.patch(uri,headers: headers,body: body);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(ResponseResult.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }



  Future<Result<ResponseError, ResponseResult>> patchPatientsData(Uri uri,
      Map<String, String> headers,
      Map<String, String> body,
      ) async {
    final response = await http.patch(uri,headers: headers, body: body);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(ResponseResult.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }


  // updateChartNumber와 로직 동일
  Future<Result<ResponseError, ResponseResult>> patchVisibility(Uri uri,
      Map<String, String> headers,
      Map<String, dynamic> body,
      ) async {
    final response = await http.patch(uri,headers: headers, body: body);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(ResponseResult.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }



  Future <Result<ResponseError,String>> fetchrefreshToken(Uri uri, Map<String, String> headers) async {
    final response = await http.post(uri, headers: headers);
    if(response.statusCode == ResponseSuccessCode){
      return Success(json.decode(response.body)["accessToken"]);
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, HospitalRequest>> postjoinHospital(
      Uri uri,
      Map<String, String> headers,
      Map<String, String> fields,
      List<http.MultipartFile> sendFiles) async {
    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll(headers);
    request.fields.addAll(fields);
    request.files.addAll(sendFiles);
    http.StreamedResponse streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    UtilityFunction.log.e('병원등록 body ${fields.toString()}');
    if (response.statusCode == ResponseSuccessCode) {
      UtilityFunction.log.e(response.body.toString());
      return Success(HospitalRequest.fromJson(json.decode(response.body)));
    } else {
      UtilityFunction.log.e(response.body.toString());
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }


  Future<Result<ResponseError, Chart>> fetcPatientData(Uri uri,
      Map<String, String> headers) async {
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == ResponseSuccessCode) {

      return Success(Chart.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, ResponseResult>> fetchDeleteAnimal(Uri uri, Map<String, String> headers) async {
    final response = await http.delete(uri, headers: headers);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(ResponseResult.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, SearchAnimalList>> fetchSearchAnimalList(
      Uri uri, Map<String, String> headers) async {
    final response = await http.get(uri, headers: headers);
    UtilityFunction.log.e(response.body);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(SearchAnimalList.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }




  Future<Result<ResponseError, ResponseResult>> deleteUser(Uri uri, Map<String, String> headers) async {
    final http.Response response = await http.delete(uri, headers: headers);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(ResponseResult.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, NotificationsList>> fetchNotifyList(
      Uri uri, Map<String, String> headers) async {
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(NotificationsList.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, ResponseResult>> fetchMonitoringNotify(
      Uri uri,
      Map<String, String> headers,
      Map<String, dynamic> body) async {
    final http.Response response = await http.patch(uri, headers: headers,body: body);
    if (response.statusCode == ResponseSuccessCode) {

      return Success(ResponseResult.fromJson(json.decode(response.body)));
    } else {
      UtilityFunction.log.e(response.body.toString());
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }
  }

  Future<Result<ResponseError, Announcement>> getAnnouncementPostsAPI(Uri uri,Map<String, String> headers,) async {
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == ResponseSuccessCode) {
      return Success(Announcement.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }

  }

  Future<Result<ResponseError, AnnouncementDetail>> getAnnouncementDetailAPI(Uri uri,Map<String, String> headers,) async {
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == ResponseSuccessCode) {
      UtilityFunction.log.e(response.body);
      return Success(AnnouncementDetail.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }

  }



  /**----------------------------------------------------------------
   *  해외 승인용 임시 코드 로직 수정 예정
   */


  Future<bool>registerHospitalAPI(var bodys)async {
    var request = http.Request('POST', ApiService().hospitalUri('/v1', '/hospitalsV2'));
    var headers = {
      'authorization': await AppCache().getAccessToken(),
      'Content-Type': 'application/json'
    };
    request.body = bodys;
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    UtilityFunction.log.e('병원등록 v2: ${response.statusCode.toString()}');

    if(response.statusCode == ResponseSuccessCode){
      UtilityFunction.log.e('병원등록 v2 성공');
      return true;
    }else{
      UtilityFunction.log.e('병원등록 v2 실패${request.body.toString()}');
      return false;
    }
  }




/**
 * ---------------------------------------------------------------
 * */



/**
 *
 * 모니터링 데이터
 *
 * */

  Future<Result<ResponseError, PatientMonitoringChart>> getPatientMonitoringDataApi(Uri uri,Map<String, String> headers,) async {
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == ResponseSuccessCode) {

      return Success(PatientMonitoringChart.fromJson(json.decode(response.body)));
    } else {
      return Error(ResponseError.fromJson(
          json.decode(response.body)['error'] ?? json.decode(response.body),
          response.statusCode));
    }

  }



}

