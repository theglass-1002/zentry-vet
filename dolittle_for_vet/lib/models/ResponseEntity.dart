import 'dart:convert';
import 'dart:typed_data';

import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';

enum eLoginType {
  KAKAO,
  APPLE,
  GOOGLE
}


class AnimalBreedListInfo {
  int? cnt;
  String? updatedAt;

  AnimalBreedListInfo({this.cnt, this.updatedAt});

  AnimalBreedListInfo.fromJson(Map<String, dynamic> json) {
    cnt = json['cnt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cnt'] = this.cnt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

List<String>? animalBreedList = [];



class AnimalBreed {
  String? code;
  String? enName;
  String? koName;
  String? updatedAt;

  AnimalBreed({this.code, this.enName, this.koName, this.updatedAt});

  AnimalBreed.fromJson(List<dynamic> list) {
    UtilityFunction.log.e(list.toString());
    list.forEach((element) {
     code = element['code'].toString();
     enName = element['enName'];
     koName = element['koName'];
     updatedAt = element['updatedAt'];
   });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['enName'] = this.enName;
    data['koName'] = this.koName;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}





class LoginArguments {
  final eLoginType loginType;
  final String userId;
  final String email;
  final String name;
  final String nickName;

  final String authorizationCode;
  final String identityToken;

  LoginArguments({
    required this.loginType,
    required this.userId,
    required this.email,
    required this.name,
    required this.nickName,
    required this.authorizationCode,
    required this.identityToken,
  });
}

class RegistPost {
  final int id;
  final String name;
  final String email;
  final String authority;
  final String authType;
  final String authId;
  final String updatedAt;
  final String createdAt;

  RegistPost({
    required this.id,
    required this.name,
    required this.email,
    required this.authority,
    required this.authType,
    required this.authId,
    required this.updatedAt,
    required this.createdAt,
  });

  factory RegistPost.fromJson(Map<String, dynamic> json) {
    return RegistPost(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      authority: json['authority'].toString(),
      authType: json['authType'],
      authId: json['authId'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
    );
  }
}

class LoginPost {
  final String accessToken;
  final String refreshToken;

  LoginPost({
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginPost.fromJson(Map<String, dynamic> json) {
    return LoginPost(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}

class LoginApplePost {
  final String accessToken;
  final String refreshToken;

  LoginApplePost({
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginApplePost.fromJson(Map<String, dynamic> json) {
    return LoginApplePost(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
class User {
  String? id;
  String? email;
  String? name;
  int? authority;
  String? license;
  String? hospitalId;
  String? authType;
  String? authId;
  String? createdAt;
  String? updatedAt;
  HospitalUserNotificationPreferences? hospitalUserNotificationPreferences;

  User(
      {this.id,
        this.email,
        this.name,
        this.authority,
        this.license,
        this.hospitalId,
        this.authType,
        this.authId,
        this.createdAt,
        this.updatedAt,
        this.hospitalUserNotificationPreferences});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    email = json['email'];
    name = json['name'];
    authority = json['authority'];
    license = json['license']??'none';
    hospitalId = json['hospital_id'].toString()??'none';
    authType = json['authType'];
    authId = json['authId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    hospitalUserNotificationPreferences =
    json['hospital_user_notification_preferences'] != null
        ? new HospitalUserNotificationPreferences.fromJson(
        json['hospital_user_notification_preferences'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['name'] = this.name;
    data['authority'] = this.authority;
    data['license'] = this.license;
    data['hospital_id'] = this.hospitalId;
    data['authType'] = this.authType;
    data['authId'] = this.authId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.hospitalUserNotificationPreferences != null) {
      data['hospital_user_notification_preferences'] =
          this.hospitalUserNotificationPreferences!.toJson();
    }
    return data;
  }
}


class HospitalUserNotificationPreferences {
  bool? hospitalManagementEnabled;
  bool? multimonitoringEnabled;

  HospitalUserNotificationPreferences(
      {this.hospitalManagementEnabled, this.multimonitoringEnabled});

  HospitalUserNotificationPreferences.fromJson(Map<String, dynamic> json) {
    hospitalManagementEnabled = json['hospital_management_enabled']??true;
    multimonitoringEnabled = json['multimonitoring_enabled']??true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hospital_management_enabled'] = this.hospitalManagementEnabled;
    data['multimonitoring_enabled'] = this.multimonitoringEnabled;
    return data;
  }
}


// class User {
//   String? id;
//   String? email;
//   String? name;
//   int? authority;
//   String? license;
//   String? hospitalId;
//   String? authType;
//   String? authId;
//   String? createdAt;
//   String? updatedAt;
//   String? registeredAt;
//
//   User(
//       {this.id,
//       this.email,
//       this.name,
//       this.authority,
//       this.license,
//       this.hospitalId,
//       this.authType,
//       this.authId,
//       this.createdAt,
//       this.updatedAt,
//       this.registeredAt});
//
//   User.fromJson(Map<String, dynamic> json) {
//     // mapUserinfo = json;
//     // mapUserinfo['EventNotice'] = Singleton.getEventNotice();
//     // mapUserinfo['DiseaseNotice'] = Singleton.getDiseaseNotice();
//     id = json['id'].toString();
//     email = json['email'];
//     name = json['name'];
//     authority = json['authority'];
//     license = json['license'] ?? 'none';
//     hospitalId = json['hospital_id'].toString()?? 'none';
//     authType = json['authType'];
//     authId = json['authId'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     registeredAt = json['registeredAt'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['email'] = this.email;
//     data['name'] = this.name;
//     data['authority'] = this.authority;
//     data['license'] = this.license;
//     data['hospital_id'] = this.hospitalId;
//     data['authType'] = this.authType;
//     data['authId'] = this.authId;
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     data['registeredAt'] = this.registeredAt;
//     return data;
//   }
// }

class Hospital {
   int? id;
   String? name;
   String? phoneContact;
   String? business_registration_number;
   int? country_id;
   String? address_first;
   String? address_second;
   String? address_road;
   String? address_detail;
   String? createdAt;
   String? updatedAt;

   Hospital(
      {this.id,
       this.name,
       this.phoneContact,
       this.business_registration_number,
       this.country_id,
       this.address_first,
       this.address_second,
       this.address_road,
       this.address_detail,
        this.createdAt,
        this.updatedAt
      });

  factory Hospital.fromJson(Map<String, dynamic> json) {
 //   mapHospitalinfo = json;
    //Utill.log_e('${mapHospitalinfo.length}');
    //Utill.log_e(json.toString());

    return Hospital(
      id: json['id'],
      name: json['name'],
      phoneContact: json['phone_contact']??"",
      business_registration_number: json['business_registration_number'],
      country_id: json['country_id'],
      address_first: json['address_first'],
      address_second: json['address_second'],
      address_road: json['address_road'],
      address_detail: json['address_detail'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt']
    );
  }
}

class AnimalList {
  List<Animal>? animal_list = [];

  AnimalList({this.animal_list});
  AnimalList.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {

      json['result'].forEach((v) {
        animal_list!.add(Animal.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.animal_list != null) {
      data['result'] = this.animal_list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Animal {
  String? id;
  String? chart_number;
  String? name;
  String? birth;
  int? animal_type;
  int? sex;
  String? breedCode;
  String? breed;
  String? cardiac;
  String? lastdate;
  bool? hasQRLink;
  bool? isVisible;
  String? updatedAt;

  Animal(
      {this.id,
      this.chart_number,
      this.name,
      this.birth,
      this.animal_type,
      this.sex,
      this.breedCode,
      this.breed,
      this.cardiac,
      this.lastdate,
      this.hasQRLink,
      this.isVisible,
      this.updatedAt
      });

  Animal.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    chart_number = json['chart_no'].toString();
    name = json['name'];
    birth = json['birth'];
    animal_type = json['animal_type'];
    sex = json['sex']??json['gender'];
    breedCode = json['breedCode'].toString();
    breed = json['breed'];
    cardiac = json['cardiac'] ?? "";
    lastdate = json['latestMeasuredAt'] ?? "";
    hasQRLink = json['hasQRLink'] ?? false;
    isVisible = json['isVisible'] ?? true;
    updatedAt = json['updatedAt'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['chart_no'] = this.chart_number;
    data['name'] = this.name;
    data['birth'] = this.birth;
    data['animal_type'] = this.animal_type;
    data['gender'] = this.sex;
    data['breedCode'] = this.breedCode;
    data['breed'] = this.breed;
    data['cardiac'] = this.cardiac;
    data['latestMeasuredAt'] = this.lastdate;
    data['hasQRLink'] = this.hasQRLink;
    data['isVisible'] = this.isVisible;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class AnimalData {
  String? sId;
  String? owner;
  String? animal;
  String? name;
  String? birth;
  int? animalType;
  int? gender;
  String? breed;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? latestMesurementAt;
  String? breedCode;

  AnimalData(
      {this.sId,
      this.owner,
      this.animal,
      this.name,
      this.birth,
      this.animalType,
      this.gender,
      this.breed,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.latestMesurementAt,
      this.breedCode
      });

  AnimalData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    owner = json['owner'];
    animal = json['animal'];
    name = json['name'];
    birth = json['birth'];
    animalType = json['animal_type'];
    gender = json['gender'];
    breed = json['breed'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    latestMesurementAt = json['latestMesurementAt'];
    breedCode = json['breedCode'].toString()??'';

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = this.sId;
    data['owner'] = this.owner;
    data['animal'] = this.animal;
    data['name'] = this.name;
    data['birth'] = this.birth;
    data['animal_type'] = this.animalType;
    data['gender'] = this.gender;
    data['breed'] = this.breed;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['latestMesurementAt'] = this.latestMesurementAt;
    data['breedCode'] = this.breedCode;
    return data;
  }
}

class SearchAnimalList {
  List<Animal>? Searchlist = [];
  SearchAnimalList({this.Searchlist});
  SearchAnimalList.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      json['result'].forEach((v) {
        Searchlist!.add(Animal.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.Searchlist != null) {
      data['result'] = this.Searchlist!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SettingCategory {
  //기본 카테고리   ---base.none--
  //프로필
  static final Map<String, dynamic> profile = {
    'authority': 'none',
    'route': '/profile',
    'name': 'name_Profile',
    'trailing': 'icon',
    'type': 'link',
    'group': 'group_Profile'
  };
  //약관
  // static final Map<String, dynamic> terms = {
  //   'authority': 'none',
  //   'route': '/webView',
  //   'name': 'name_Privacy Policy',
  //   'trailing': 'icon',
  //   'type': 'link',
  //   'group': 'group_Terms and conditions'
  // };

  //문의
  static final Map<String, dynamic> announcementBoard = {
    'authority': 'none',
    'route': '/announcementBoard',
    'name': 'name_Announcement',
    'trailing': 'icon',
    'type': 'link',
    'group': 'group_✢ Etc ✢'
  };

  //문의
  static final Map<String, dynamic> help = {
    'authority': 'none',
    'route': '/help',
    'name': 'name_Help',
    'trailing': 'icon',
    'type': 'link',
    'group': 'group_✢ Etc ✢'
  };

  //병원가입
  //권한 0 카테고리   ---base.0--
  static final Map<String, dynamic> regis_hospital = {
    'authority': 0,
    'route': '/hospitalRegister',
    'name': 'name_Hospital registration',
    'trailing': 'icon',
    'type': 'link',
    'group': 'group_Registration'
  };

  //수의사가입
  static final Map<String, dynamic> regis_vet = {
    'authority': 0,
    'route': '/veterinarianRegister',
    'name': 'name_Veterinary registration',
    'trailing': 'icon',
    'type': 'link',
    'group': 'group_Registration'
  };

  //간호사가입
  static final Map<String, dynamic> regis_technician = {
    'authority': 0,
    'route': '/technicianRegister',
    'name': 'name_Technician registration',
    'trailing': 'icon',
    'type': 'link',
    'group': 'group_Registration'
  };

  //동물숨김
  static final Map<String, dynamic> hidden_animal = {
    'authority': 9,
    'route': '/hiddenAnimal',
    'name': 'Hidden animal',
    'trailing': 'icon',
    'type': 'link',
    'group': 'Animal care'
  };

  //수의사관리
  //권한 2 카테고리 ---base.2--
  static final Map<String, dynamic> manage_vet = {
    'authority': 2,
    'route': '/veterinarianManagement',
    'name': 'name_Staff management',
    'trailing': 'icon',
    'type': 'link',
    'group': 'group_Management'
  };

  //병원관리
  //권한 3 카테고리 ---base.3--
  static final Map<String, dynamic> manage_hospital = {
    'authority': 3,
    'route': '/hospitalManagement',
    'name': 'name_Hospital management',
    'trailing': 'icon',
    'type': 'link',
    'group': 'group_Management'
  };

  //병원양도
  //권한 3 카테고리 ---base.3--
  static final Map<String, dynamic> manage_Handover = {
    'authority': 3,
    'route': '/hospitalHandover',
    'name': 'name_Hospital Handover',
    'trailing': 'icon',
    'type': 'link',
    'group': 'group_Management'
  };


  //멀티로그인Qr
  //권한 3 카테고리 ---base.3--
  static final Map<String, dynamic> multi_Login = {
    'authority': 3,
    'route': '/createMultiLoginQr',
    'name': 'name_multiLoginQrCode',
    'trailing': 'icon',
    'type': 'link',
    'group': 'group_MultiLogin'
  };

  //이벤트 알림
  //권한 1 카테고리
  static final Map<String, dynamic> event_notice = {
    'authority': 1,
    'route': 'none',
    'name': 'name_Notice/Event Notification',
    'trailing': 'switch',
    'type': 'switch',
    //'value': mapUserinfo['EventNotice'] ?? false,
    'group': 'group_Notifications'
  };

  //심장병알림
  static final Map<String, dynamic> cardiac_notice = {
    'authority': 1,
    'route': 'none',
    'name': 'name_Heart disease notification',
    'trailing': 'switch',
    'type': 'switch',
    //  'value': mapUserinfo['DiseaseNotice'] ?? false,
    'group': 'group_Notifications'
  };
//멀티알림
  static final Map<String, dynamic> monitoring_notice = {
    'authority': 1,
    'route': 'none',
    'name': 'name_Monitoring notification',
    'trailing': 'switch',
    'type': 'switch',
    'group': 'group_Notifications'
  };
  //로그아웃
  static final Map<String, dynamic> etc = {
    'authority': 'none',
    'route': 'none',
    'name': 'name_Logout',
    'type': 'dialog',
    'group': 'group_✢ Etc ✢'
  };

  //탈퇴
  static final Map<String, dynamic> resign_membership = {
    'authority': 'none',
    'name': 'name_Resign',
    'type': 'dialog',
    'group': 'group_✢ Etc ✢'
  };
  //버전
  static final Map<String, dynamic> version = {
    'authority': 'none',
    'name': 'name_Version',
    'type': 'none',
    'group': 'Version'
  };

  //언어
  static final Map<String, dynamic> trans = {
    'authority': 'none',
    'type': 'radio',
    'group': 'Language'
  };


  //권한변경 화면
  static final Map<String, dynamic> test_auth = {
    'authority': 'none',
    'type': 'radio',
    'group': 'testAuthChange',
    'server': false
  };

  // //서버변경
  // static final Map<String, dynamic> server_change = {
  //   'authority': 'none',
  //   'type': 'radio',
  //   'group': 'europDemoServer',
  // };

}



List<Map<String, dynamic>> ListSettingCategory = [
  SettingCategory.profile,
  SettingCategory.manage_vet,
  SettingCategory.manage_hospital,
  SettingCategory.manage_Handover,
  SettingCategory.multi_Login,
  SettingCategory.hidden_animal,
  SettingCategory.monitoring_notice,
  // SettingCategory.event_notice,
  // SettingCategory.cardiac_notice,
  SettingCategory.regis_hospital,
  SettingCategory.regis_vet,
  SettingCategory.regis_technician,
  SettingCategory.trans,
  SettingCategory.version,
  SettingCategory.announcementBoard,
  SettingCategory.help,
  SettingCategory.etc,
  SettingCategory.resign_membership,
//  SettingCategory.server_change,
//  SettingCategory.test_auth

];


List<Map<String, dynamic>> MonitoringListSettingCategory = [
  SettingCategory.profile,
  SettingCategory.monitoring_notice,
  SettingCategory.version,
];

class VetList {
  List<Vet>? vet_list;
  VetList({this.vet_list});
  VetList.fromJson(Map<String, dynamic> json) {
    if (json['vets'] != null) {
      vet_list = <Vet>[];
      json['vets'].forEach((v) {
        vet_list!.add(new Vet.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.vet_list != null) {
      data['vets'] = this.vet_list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Vet {
  int? id;
  String? email;
  String? name;
  int? authority;
  String? license;
  int? hospitalId;
  String? authType;
  String? authId;
  String? pushMessageToken;
  String? createdAt;
  String? updatedAt;
  String? registeredAt;

  Vet(
      {this.id,
      this.email,
      this.name,
      this.authority,
      this.license,
      this.hospitalId,
      this.authType,
      this.authId,
      this.pushMessageToken,
      this.createdAt,
      this.updatedAt,
      this.registeredAt});

  Vet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    name = json['name'];
    authority = json['authority'];
    license = json['license'] ?? 'none';
    hospitalId = json['hospital_id'];
    authType = json['authType'];
    authId = json['authId'];
    pushMessageToken = json['push_message_token'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    registeredAt = json['registeredAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['name'] = this.name;
    data['authority'] = this.authority;
    data['license'] = this.license;
    data['hospital_id'] = this.hospitalId;
    data['authType'] = this.authType;
    data['authId'] = this.authId;
    data['push_message_token'] = this.pushMessageToken;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['registeredAt'] = this.registeredAt;
    return data;
  }
}

class ResponseError {
  int? re_code;
  int? code;
  String? message;

  ResponseError({this.code, this.message, this.re_code});

  ResponseError.fromJson(Map<String, dynamic> json, r_code) {

    code = json['code'] ?? 10;
    message = json['message'] ?? json['result'];
    re_code = r_code;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    return data;
  }
}

class ResponseResult {
  String? result;

  ResponseResult({this.result});

  ResponseResult.fromJson(Map<String, dynamic> json) {
    result = json['result']??'200';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    return data;
  }
}

class HospitalRequest {
  int? id;
  String? reqVetId;
  String? reqType;
  String? reqHospitalName;
  String? reqHospitalAddress;
  String? businessRegistrationUri;
  String? licenseUri;
  int? status;
  String? comment;
  String? updatedAt;
  String? createdAt;

  HospitalRequest(
      {this.id,
      this.reqVetId,
      this.reqType,
      this.reqHospitalName,
      this.reqHospitalAddress,
      this.businessRegistrationUri,
      this.licenseUri,
      this.status,
      this.comment,
      this.updatedAt,
      this.createdAt});

  HospitalRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reqVetId = json['req_vet_id'];
    reqType = json['req_type'];
    reqHospitalName = json['req_hospital_name'];
    reqHospitalAddress = json['req_hospital_address'];
    businessRegistrationUri = json['business_registration_uri']??"";
    licenseUri = json['license_uri']??"";
    status = json['status'];
    comment = json['comment'];
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['req_vet_id'] = this.reqVetId;
    data['req_type'] = this.reqType;
    data['req_hospital_name'] = this.reqHospitalName;
    data['req_hospital_address'] = this.reqHospitalAddress;
    data['business_registration_uri'] = this.businessRegistrationUri;
    data['license_uri'] = this.licenseUri;
    data['status'] = this.status;
    data['comment'] = this.comment;
    data['updatedAt'] = this.updatedAt;
    data['createdAt'] = this.createdAt;
    return data;
  }
}


class HandoverRequestMessage {
  String? message;
  int? handoverRequestId;

  HandoverRequestMessage({this.message, this.handoverRequestId});

  HandoverRequestMessage.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    handoverRequestId = json['handoverRequestId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['handoverRequestId'] = this.handoverRequestId;
    return data;
  }
}

class Chart {
  List<HrRr>? hrRr;
  List<Weights>? weights;

  Chart({this.hrRr, this.weights});

  Chart.fromJson(Map<String, dynamic> json) {
    if (json['hr_rr'] != null) {
      hrRr = <HrRr>[];
      json['hr_rr'].forEach((v) {
        hrRr!.add(HrRr.fromJson(v));
      });
    }
    if (json['weights'] != null) {
      weights = <Weights>[];
      json['weights'].forEach((v) {
        weights!.add(Weights.fromJson(v));
      });
    }
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   if (hrRr != null) {
  //     data['hr_rr'] = hrRr!.map((v) => v.toJson()).toList();
  //   }
  //   if (weights != null) {
  //     data['weights'] = weights!.map((v) => v.toJson()).toList();
  //   }
  //   return data;
  // }
}

class HrRr {
  String? type;
  int? data;
  String? createdAt;
  String? updatedAt;
  String? measuredAt;

  HrRr({this.type, this.data, this.createdAt, this.updatedAt, this.measuredAt});

  HrRr.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    data = json['data'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    measuredAt = json['measuredAt'];
    if (measuredAt == null || measuredAt!.isEmpty) {
      measuredAt = createdAt;
    }
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['type'] = type;
  //   data['data'] = this.data;
  //   data['createdAt'] = createdAt;
  //   data['updatedAt'] = updatedAt;
  //   data['measuredAt'] = measuredAt;
  //   return data;
  // }
}

class Weights {
  dynamic weight;
  String? unit;
  String? date;

  Weights({this.weight, this.unit, this.date});

  Weights.fromJson(Map<String, dynamic> json) {
    weight = json['weight'];
    unit = json['unit'];
    date = json['date'];
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['weight'] = weight;
  //   data['unit'] = unit;
  //   data['date'] = date;
  //   return data;
  // }
}

// 알림 리스트 ----------------------------------------------------------------------------------------------------------------
class NotificationsList {
  List<PushMessages>? pushMessages;

  NotificationsList({this.pushMessages});

  NotificationsList.fromJson(Map<String, dynamic> json) {
    if (json['pushMessages'] != null) {
      pushMessages = <PushMessages>[];
      json['pushMessages'].forEach((v) {
        pushMessages!.add(PushMessages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (pushMessages != null) {
      data['pushMessages'] = pushMessages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PushMessages {
  String? sId;
  String? title;
  String? body;
  int? type;
  int? vetId;
  bool? isExpired;
  String? createdAt;
  String? updatedAt;
  int? iV;

  PushMessages(
      {this.sId,
      this.title,
      this.body,
      this.type,
      this.vetId,
      this.isExpired,
      this.createdAt,
      this.updatedAt,
      this.iV});

  PushMessages.fromJson(Map<String, dynamic> json) {
    sId = json['id'];
    title = json['title'];
    body = json['body'];
    type = json['type'];
    vetId = json['vetId'];
    isExpired = json['isExpired'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = sId;
    data['title'] = title;
    data['body'] = body;
    data['type'] = type;
    data['vetId'] = vetId;
    data['isExpired'] = isExpired;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class versionCheckResponse {
  int? id;
  String? forceVersion;
  String? recommendVersion;
  String? downloadUri;

  versionCheckResponse(
      {this.id, this.forceVersion, this.recommendVersion, this.downloadUri});

  versionCheckResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    forceVersion = json['force_version'];
    recommendVersion = json['recommend_version'];
    downloadUri = json['download_uri'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['force_version'] = this.forceVersion;
    data['recommend_version'] = this.recommendVersion;
    data['download_uri'] = this.downloadUri;
    return data;
  }
}


class Announcement {
  List<AnnouncementPost>? announcementPost;
  int? count;

  Announcement({this.announcementPost, this.count});

  Announcement.fromJson(Map<String, dynamic> json) {
    if (json['notices'] != null) {
      announcementPost = <AnnouncementPost>[];
      json['notices'].forEach((v) {
        announcementPost!.add(new AnnouncementPost.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.announcementPost != null) {
      data['notices'] =
          this.announcementPost!.map((v) => v.toJson()).toList();
    }
    data['count'] = this.count;
    return data;
  }
}

class AnnouncementPost {
  int? id;
  int? adminUserId;
  String? nickname;
  String? title;
  String? content;
  int? type;
  int? appCode;
  String? createdAt;
  String? updatedAt;

  AnnouncementPost(
      {this.id,
        this.adminUserId,
        this.nickname,
        this.title,
        this.content,
        this.type,
        this.appCode,
        this.createdAt,
        this.updatedAt});

  AnnouncementPost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    adminUserId = json['admin_user_id'];
    nickname = json['nickname'];
    title = json['title'];
    content = json['content'];
    type = json['type'];
    appCode = json['app_code'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['admin_user_id'] = this.adminUserId;
    data['nickname'] = this.nickname;
    data['title'] = this.title;
    data['content'] = this.content;
    data['type'] = this.type;
    data['app_code'] = this.appCode;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}


class AnnouncementDetail {
  int? id;
  int? adminUserId;
  String? nickname;
  int? appCode;
  int? type;
  int? language;
  String? title;
  String? content;
  List<String>? images;
  String? createdAt;
  String? updatedAt;

  AnnouncementDetail(
      {this.id,
        this.adminUserId,
        this.nickname,
        this.appCode,
        this.type,
        this.language,
        this.title,
        this.content,
        this.images,
        this.createdAt,
        this.updatedAt});

  AnnouncementDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    adminUserId = json['admin_user_id'];
    nickname = json['nickname'];
    appCode = json['app_code'];
    type = json['type'];
    language = json['language'];
    title = json['title'];
    content = json['content'];
    images = (json['images'] as List?)?.cast<String>() ?? [];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
   Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['admin_user_id'] = this.adminUserId;
    data['nickname'] = this.nickname;
    data['app_code'] = this.appCode;
    data['type'] = this.type;
    data['language'] = this.language;
    data['title'] = this.title;
    data['content'] = this.content;
    data['images'] = this.images;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}


/**
 * ----------------------------------------------------------------
 *   MultieService V1 (2000)
 * */

//ReceiveHeader
class ReceiveHeader{
  late int msgSize;
  late int msgId;
  late int reId;
  ReceiveHeader({required this.msgSize, required this.msgId, required this.reId});

  ReceiveHeader.fromBytes(int length,List<int> bytes) {
    int index = length;
    this.msgSize = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    this.msgId = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    this.reId = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
  }

  @override
  String toString() {
    return 'msgSize: $msgSize\n'
        'msgId: $msgId\n'
        'RequestId: $reId\n';

  }

}

class InputHeader{
  late int msgSize;
  late int msgId;
  late int reId;

  InputHeader({required this.msgSize, required this.msgId, required this.reId});

}

//보냄
class Message2101 extends InputHeader{
  late int hospitalId;
  late int vetId;
  late bool isReceivedData;

  Message2101({
    required super.msgSize, required super.msgId, required super.reId,
    required this.hospitalId,
    required this.vetId,
    required this.isReceivedData
  });


  List<int> toByteArray() {
    final buffer = ByteData(21);
    buffer.setInt32(0, msgSize);
    buffer.setInt32(4, msgId);
    buffer.setInt32(8, reId);
    buffer.setInt32(12, hospitalId);
    buffer.setInt32(16,  vetId);
    buffer.setUint8(20,  isReceivedData ? 1 : 0);
    return buffer.buffer.asUint8List();
  }
}



class Message2201 {
  int? connectedMultiAppCount;
  List<MultiAppData>? multiAppDatas =[] ;

  Message2201({this.connectedMultiAppCount,  this.multiAppDatas});

  void addMultiAppData(MultiAppData multiAppData){
    multiAppDatas?.add(multiAppData);
  }


  Message2201.fromBytes(int length,List<int> bytes) {
    //헤더를자르자
    int index = length;
    this.connectedMultiAppCount = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    for (int i = 0; i < connectedMultiAppCount!; i++) {
      MultiAppData multiAppData = MultiAppData.fromBytes(index, bytes);
      multiAppDatas?.add(multiAppData);
      //addMultiAppData(multiAppData);
      index = multiAppData.RoomInfosLength ?? 0;
    }
  }



  factory Message2201.fromJson(Map<String, dynamic> json) {
    return Message2201(
      connectedMultiAppCount: json['connectedMultiAppCount'],
      multiAppDatas: (json['multiAppDatas'] as List<dynamic>?)
          ?.map((e) => MultiAppData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['connectedMultiAppCount'] = connectedMultiAppCount;
    data['multiAppDatas'] =
        multiAppDatas?.map((e) => e.toJson()).toList(growable: false);
    return data;
  }

  @override
  String toString() {
    // TODO: implement toString
    return '연결되어있는 모니터링앱 갯수: $connectedMultiAppCount\n'
        '모니터링앱이 관리하는 데이터: ${multiAppDatas!.length}\n'


    ;
  }

}

class MultiAppData{
  String? multiAppUUID;
  int? multiAppNameLength;
  String? multiAppName;
  int? roomCount;
  List<RoomInfo>? RoomInfos=[];
  int? RoomInfosLength ;

  MultiAppData(){
    RoomInfos = [];
  }

  void addRoomInfos(RoomInfo roomInfo){
    this.RoomInfos!.add(roomInfo);
    // this.roomCount =this.RoomInfos!.length;
  }

  void updateRoomInfos(RoomInfo roomInfo) {
    UtilityFunction.log.e('리스트 값 변경전 ${this.RoomInfos.toString()}');
    this.RoomInfos = RoomInfos!.map((e) {
      if (e.roomId == roomInfo.roomId) {
        return e = roomInfo;
      } else {
        return e;
      }
    }).toList();

    UtilityFunction.log.e('리스트 값 변경후 ${this.RoomInfos.toString()}');
  }


  void removeRoomInfo(int roomId) {
    this.RoomInfos!.remove((room) => room.roomId == roomId);
    // this.roomCount =this.RoomInfos!.length;
    // removedInfo 변수에는 삭제된 RoomInfo 요소가 들어갑니다.
  }




  MultiAppData.fromBytes(int length,List<int> bytes) {
    int index = length;
    List<int> listuuid = bytes.sublist(index, index + 36);
    this.multiAppUUID = utf8.decode(listuuid);
    index += 36;
    this.multiAppNameLength =  UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index+=4;
    List<int> multiName = bytes.sublist(index, index + multiAppNameLength!);
    this.multiAppName = utf8.decode(multiName);
    index += multiName.length;
    this.roomCount = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index +=4;
    if(roomCount==0){
     // RoomInfos = [];
      RoomInfosLength = index;
    }else {
     // RoomInfos = [];
      for (int i = 0; i < roomCount!; i++) {
        RoomInfo roomInfo = RoomInfo.fromBytes(index, bytes);
        RoomInfos?.add(roomInfo);
        index += RoomInfos![i].totalLength!;
        this.RoomInfosLength = index;

      }
    }
  }

  MultiAppData.fromJson(Map<String, dynamic> json) {
    this.roomCount = json['roomcount'];
    this.multiAppUUID = json['multiAppUUID'];
    this.multiAppNameLength = json['multiAppNameLength'];
    this.multiAppName = json['multiAppName'];
    if (json['RoomInfos'] != null) {
      RoomInfos = <RoomInfo>[];
      json['RoomInfos'].forEach((v) {
        RoomInfos!.add(RoomInfo.fromJson(v));
      });
    }

    UtilityFunction.log.e(toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomcount'] = this.roomCount;
    data['multiAppUUID'] = this.multiAppUUID;
    data['multiAppName'] = this.multiAppName;
    data['multiAppNameLength'] = this.multiAppNameLength;
    if (this.RoomInfos != null) {
      data['RoomInfos'] =
          this.RoomInfos!.map((v) => v.toJson()).toList();
    }
    return data;
  }
  @override
  String toString() {
    // TODO: implement toString
    return 'multiAppUUID: $multiAppUUID\n'
        'multiAppNameLength: ${multiAppNameLength}\n'
        'multiAppName: ${multiAppName}\n'
        'roomCount: ${roomCount}\n'
        'RoomInfosLength: $RoomInfosLength\n';
  }


}

class RoomInfo {
  int? roomId;
  int? type;
  int? roomNameLength;
  int? patientsNameLength;
  int? chartNumberLength;
  String? roomName;
  String? patientName;
  String? chartNumber;
  int? totalLength;
  String? dataType0='--';
  String? dataType1='--';


  RoomInfo({
    this.roomId,
    this.type,
    this.roomNameLength,
    this.patientsNameLength,
    this.chartNumberLength,
    this.roomName,
    this.patientName,
    this.chartNumber,
    this.totalLength,
  });

  RoomInfo.fromBytes(int length,List<int> bytes) {
    int index = length;
    this.roomId = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    this.type = bytes[index++];
    this.roomNameLength =UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    List<int> listRoomName = bytes.sublist(index, index + roomNameLength!);
    this.roomName = utf8.decode(listRoomName);
    index += listRoomName.length;
    this.patientsNameLength = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    List<int> listPatientName = bytes.sublist(index, index + patientsNameLength!);
    this.patientName = utf8.decode(listPatientName);
    index += listPatientName.length;
    this.chartNumberLength = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    List<int> listChartName = bytes.sublist(index, index + chartNumberLength!);
    this.chartNumber = utf8.decode(listChartName);
    index+=listChartName.length;
    this.totalLength = 16+1+roomNameLength!+patientsNameLength!+chartNumberLength!;
    //Util.log.e('하나의 클래스길이는 몇입니까? : $totalLength');
    // Util.log.e('현재 인덱스길이는 몇입니까? ${index.toString()}');
    //this.totalLength = 4+4 + 1 + 4 + patientsNameLength! + 4 + chartNumberLength!;
    //Util.log.e(toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomId'] = this.roomId;
    data['type'] = this.type;
    data['roomNameLength'] = this.roomNameLength;
    data['patientsNameLength'] = this.patientsNameLength;
    data['chartNumberLength'] = this.chartNumberLength;
    data['roomName'] = this.roomName;
    data['patientName'] = this.patientName;
    data['chartNumber'] = this.chartNumber;
    data['totalLength'] = this.totalLength;
    data['dataType0']=this.dataType0;
    data['dataType1']=this.dataType1;

    return data;
  }

  factory RoomInfo.fromJson(Map<String, dynamic> json) {
    return RoomInfo(
      roomId: json['roomId'],
      type: json['type'],
      roomNameLength: json['roomNameLength'],
      patientsNameLength: json['patientsNameLength'],
      chartNumberLength: json['chartNumberLength'],
      roomName: json['roomName'],
      patientName: json['patientName'],
      chartNumber: json['chartNumber'],
      totalLength: json['totalLength'],

    );
  }

  @override
  String toString() {
    return
      'roomId: $roomId\n'
          'Type: $type\n'
          'roomname: $roomName\n'
          'Patient Name: $patientName\n'
          'totalLength: $totalLength\n'
          'datatype0: $dataType0\n'
          'datatype1: $dataType1\n'
          'Chart Number: $chartNumber';
  }

}

class Message2205{
  String? MultiAppUUID;
  int? RoomID;
  String? DolittleMacAddress;
  int? DataType;
  String? Data;

  Message2205(
      {this.MultiAppUUID,
        this.RoomID,
        this.DolittleMacAddress,
        this.DataType,
        this.Data});


  Message2205.fromBytes(int lenth, List<int> bytes){
    int index = lenth;
    List<int> listuuid = bytes.sublist(index, index + 36);
    this.MultiAppUUID = utf8.decode(listuuid);
    index+=36;
    this.RoomID =UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    List<int> Listmacaddress = bytes.sublist(index, index + 6);
    this.DolittleMacAddress = UtilityFunction.bytesToHex(
        [Listmacaddress[0],
          Listmacaddress[1],
          Listmacaddress[2],
          Listmacaddress[3],
          Listmacaddress[4],
          Listmacaddress[5],
        ]);
    index += 6;
    this.DataType  = bytes[index++];
    this.Data = UtilityFunction.readIntFromBytesBigEndian(bytes,index).toString();
    index +=4;

  }

  @override
  String toString() {
    // TODO: implement toString
    return "MultiAppUUID : $MultiAppUUID\n "
        "RoomId : $RoomID\n"
        "address : $DolittleMacAddress\n"
        "dataType : $DataType\n"
        "data : $Data\n";
  }

  factory Message2205.fromJson(Map<String, dynamic> json) {
    return Message2205(
      MultiAppUUID: json['MultiAppUUID'],
      RoomID: json['RoomID'],
      DolittleMacAddress: json['DolittleMacAddress'],
      DataType: json['DataType'],
      Data: json['Data'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MultiAppUUID'] = this.MultiAppUUID;
    data['RoomID'] = this.RoomID;
    data['DolittleMacAddress'] = this.DolittleMacAddress;
    data['DataType'] = this.DataType;
    data['Data'] = this.Data;
    return data;
  }

}

class Message2206{
  String? MultiAppUUID;
  int? RoomID;
  int? AlarmType;

  Message2206({this.MultiAppUUID, this.RoomID, this.AlarmType});



  Message2206.fromBytes(int lenth, List<int> bytes){
    int index = lenth;
    List<int> listuuid = bytes.sublist(index, index + 36);
    this.MultiAppUUID = utf8.decode(listuuid);
    index+=36;
    this.RoomID =UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    this.AlarmType  = bytes[index++];


  }

  @override
  String toString() {
    // TODO: implement toString
    return "MultiAppUUID : $MultiAppUUID\n "
        "RoomId : $RoomID\n"
        "AlarmType : $AlarmType\n";
  }

  factory Message2206.fromJson(Map<String, dynamic> json) {
    return Message2206(
      MultiAppUUID: json['MultiAppUUID'],
      RoomID: json['RoomID'],
      AlarmType: json['AlarmType'],

    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MultiAppUUID'] = this.MultiAppUUID;
    data['RoomID'] = this.RoomID;
    data['AlarmType'] = this.AlarmType;
    return data;
  }

}

class Message2203{
  String? multiAppUUID;
  Message2203({this.multiAppUUID});

  Message2203.fromBytes(int lenth, List<int> bytes){
    int index = lenth;
    List<int> listuuid = bytes.sublist(index, index + 36);
    this.multiAppUUID = utf8.decode(listuuid);
  }

}
class Message2204{
  String? multiAppUUID;
  int? actionType;
  RoomInfo? roominfo;

  Message2204({this.multiAppUUID, this.actionType, this.roominfo});

  Message2204.fromBytes(int length, List<int> bytes){
    int index = length;
    List<int> listuuid = bytes.sublist(index, index + 36);
    this.multiAppUUID = utf8.decode(listuuid);
    index += 36;
    this.actionType = bytes[index++];
    this.roominfo=RoomInfo.fromBytes(index, bytes);

  }

  @override
  String toString() {
    return
      'multiAppUUID: $multiAppUUID\n'
          'actionType: $actionType\n'
          'roominfo: ${roominfo.toString()}';
  }



}

class Message2208{
  String? multiAppUUID;
  int? multiAppNameLength;
  String? multiAppName;


  Message2208({this.multiAppUUID, this.multiAppNameLength, this.multiAppName});


  Message2208.fromBytes(int length,List<int> bytes) {
    int index = length;
    List<int> listuuid = bytes.sublist(index, index + 36);
    this.multiAppUUID = utf8.decode(listuuid);
    index += 36;
    this.multiAppNameLength =  UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index+=4;
    List<int> multiName = bytes.sublist(index, index + multiAppNameLength!);
    this.multiAppName = utf8.decode(multiName);
    index += multiName.length;
    UtilityFunction.log.e(multiAppName.toString());
  }

  Message2208.fromJson(Map<String, dynamic> json) {
    this.multiAppUUID = json['multiAppUUID'];
    this.multiAppName = json['multiAppName'];
    this.multiAppNameLength = json['multiAppNameLength'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['multiAppUUID'] = this.multiAppUUID;
    data['multiAppNameLength'] = this.multiAppNameLength;
    data['multiAppName'] = this.multiAppName;

    return data;
  }
  @override
  String toString() {
    // TODO: implement toString
    return 'multiAppUUID: $multiAppUUID\n'
        'multiAppNameLength: ${multiAppNameLength}\n'
        'multiAppName: ${multiAppName}';
  }


}



/**
 * ----------------------------------------------------------------
 *   MultieService V2 (4000)
 * */


class Message4101 extends InputHeader{
  late int hospitalId;
  late int vetId;
  late bool isReceivedData;

  Message4101({
    required super.msgSize, required super.msgId, required super.reId,
    required this.hospitalId,
    required this.vetId,
    required this.isReceivedData
  });


  List<int> toByteArray() {
    final buffer = ByteData(21);
    buffer.setInt32(0, msgSize);
    buffer.setInt32(4, msgId);
    buffer.setInt32(8, reId);
    buffer.setInt32(12, hospitalId);
    buffer.setInt32(16,  vetId);
    buffer.setUint8(20,  isReceivedData ? 1 : 0);
    return buffer.buffer.asUint8List();
  }
}

class Message4201 {
  int? connectedMultiAppCount;
  List<MultiAppDataV2>? multiAppDatasV2 =[] ;

  Message4201({this.connectedMultiAppCount,  this.multiAppDatasV2});

  // void addMultiAppData(MultiAppData multiAppDatas){
  //   multiAppDatas?.add(multiAppDataV2);
  // }


  Message4201.fromBytes(int length, List<int> bytes) {
    //헤더를자르자
    int index = length;
    this.connectedMultiAppCount = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    for (int i = 0; i < connectedMultiAppCount!; i++) {
      MultiAppDataV2 multiAppDataV2 = MultiAppDataV2.fromBytes(index, bytes);
      multiAppDatasV2?.add(multiAppDataV2);
      index = multiAppDataV2.RoomInfosV2Length??0;
    //  index = multiAppDatas?.RoomInfosV2Length??0;
    }
  }



  factory Message4201.fromJson(Map<String, dynamic> json) {
    return Message4201(
      connectedMultiAppCount: json['connectedMultiAppCount'],
      multiAppDatasV2: (json['multiAppDatasV2'] as List<dynamic>?)
          ?.map((e) => MultiAppDataV2.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['connectedMultiAppCount'] = connectedMultiAppCount;
    data['multiAppDatasV2'] =
        multiAppDatasV2?.map((e) => e.toJson()).toList(growable: false);
    return data;
  }

  @override
  String toString() {
    // TODO: implement toString
    return '연결되어있는 모니터링앱 갯수: $connectedMultiAppCount\n'
        '모니터링앱이 관리하는 데이터: ${multiAppDatasV2!.length}\n'


    ;
  }

}

class Message4204 extends Message2204{
  RoomInfoV2? roomInfoV2;
  Message4204({super.multiAppUUID,super.actionType,this.roomInfoV2});

  Message4204.fromBytes(int length, List<int> bytes){
    int index = length;
    List<int> listuuid = bytes.sublist(index, index + 36);
    this.multiAppUUID = utf8.decode(listuuid);
    index += 36;
    this.actionType = bytes[index++];
    this.roomInfoV2=RoomInfoV2.fromBytes(index, bytes);

  }

  @override
  String toString() {
    return
      'multiAppUUID: $multiAppUUID\n'
          'actionType: $actionType\n'
          'roominfo: ${roomInfoV2.toString()}';
  }



}


class MultiAppDataV2 extends MultiAppData{
  // String? multiAppUUID;
  // int? multiAppNameLength;
  // String? multiAppName;
  // int? roomCount;
  int? monitoringType;
  List<RoomInfoV2>? RoomInfosV2=[];
  int? RoomInfosV2Length ;

  MultiAppDataV2(){
    RoomInfosV2 = [];
  }

  void addRoomInfoV2(RoomInfoV2 roomInfoV2){
    this.RoomInfosV2!.add(roomInfoV2);
  }

  void updateRoomInfoV2(RoomInfoV2 roomInfoV2) {
    UtilityFunction.log.e('리스트 값 변경전 ${this.RoomInfosV2.toString()}');
    this.RoomInfosV2 = RoomInfosV2!.map((e) {
      if (e.roomId == roomInfoV2.roomId) {
        return e = roomInfoV2;
      } else {
        return e;
      }
    }).toList();
    UtilityFunction.log.e('리스트 값 변경후 ${this.RoomInfosV2.toString()}');
  }


  void removeRoomInfoV2(int roomId) {
    this.RoomInfosV2!.remove((room) => room.roomId == roomId);
  }




  MultiAppDataV2.fromBytes(int length,List<int> bytes) {
    int index = length;
    List<int> listuuid = bytes.sublist(index, index + 36);
    this.multiAppUUID = utf8.decode(listuuid);
    index += 36;
    this.multiAppNameLength =  UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index+=4;
    List<int> multiName = bytes.sublist(index, index + multiAppNameLength!);
    this.multiAppName = utf8.decode(multiName);
    index += multiName.length;
    this.monitoringType = bytes[index++];
    this.roomCount = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index +=4;
    if(roomCount==0){
      RoomInfosV2Length = index;
    }else {
      for (int i = 0; i < roomCount!; i++) {
        RoomInfoV2 roomInfoV2 = RoomInfoV2.fromBytes(index, bytes);
        RoomInfosV2?.add(roomInfoV2);
        index += RoomInfosV2![i].totalLength!;
        this.RoomInfosV2Length = index;
      }
    }
  }

  MultiAppDataV2.fromJson(Map<String, dynamic> json) {
    this.roomCount = json['roomcount'];
    this.multiAppUUID = json['multiAppUUID'];
    this.multiAppNameLength = json['multiAppNameLength'];
    this.multiAppName = json['multiAppName'];
    this.monitoringType = json['monitoringType'];
    if (json['RoomInfosV2'] != null) {
      RoomInfosV2 = <RoomInfoV2>[];
      json['RoomInfosV2'].forEach((v) {
        RoomInfosV2!.add(RoomInfoV2.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomcount'] = this.roomCount;
    data['multiAppUUID'] = this.multiAppUUID;
    data['multiAppName'] = this.multiAppName;
    data['multiAppNameLength'] = this.multiAppNameLength;
    data['monitoringType'] = this.monitoringType;
    if (this.RoomInfosV2 != null) {
      data['RoomInfos'] =
          this.RoomInfosV2!.map((v) => v.toJson()).toList();
    }
    return data;
  }
  @override
  String toString() {
    // TODO: implement toString
    return 'multiAppUUID: $multiAppUUID\n'
        'multiAppNameLength: ${multiAppNameLength}\n'
        'multiAppName: ${multiAppName}\n'
        'monitoringType: ${monitoringType}\n'
        'roomCount: ${roomCount}\n'
        'RoomInfosLength: $RoomInfosV2Length\n';
  }

}

class RoomInfoV2 extends RoomInfo{

  int? roomInfoSize;
  int? chartApiIdLength;
  String? chartApiId;
  String? dataType0='--';
  String? dataType1='--';


  RoomInfoV2({
    this.roomInfoSize,
    super.roomId,
    super.type,
    super.roomNameLength,
    super.roomName,
    super.patientsNameLength,
    super.patientName,
    super.chartNumberLength,
    super.chartNumber,
    this.chartApiIdLength,
    this.chartApiId,
    super.totalLength,});
  
  
  RoomInfoV2.fromBytes(int length, List<int> bytes){
    int index = length;
    this.roomInfoSize = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index +=4;
    
    this.roomId = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index +=4;
    
    this.type = bytes[index++];
    
    this.roomNameLength = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index += 4;
    
    List<int> listRoomName = bytes.sublist(index, index + roomNameLength!);
    this.roomName = utf8.decode(listRoomName);
    index += listRoomName.length;

    this.patientsNameLength = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index += 4;

    List<int> listPatientName = bytes.sublist(index, index + patientsNameLength!);
    this.patientName = utf8.decode(listPatientName);
    index += listPatientName.length;

    this.chartNumberLength = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index +=4;

    List<int> listChartName = bytes.sublist(index, index + chartNumberLength!);
    this.chartNumber = utf8.decode(listChartName);
    index+=listChartName.length;

    this.chartApiIdLength = UtilityFunction.readIntFromBytesBigEndian(bytes, index);
    index += 4;

    List<int> listChartApiIdName = bytes.sublist(index, index + chartApiIdLength!);
    this.chartApiId = utf8.decode(listChartApiIdName);
    index+=listChartApiIdName.length;

    this.totalLength = 24+1+roomNameLength!+patientsNameLength!+chartNumberLength!+chartApiIdLength!;
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomInfoSize'] = this.roomInfoSize;
    data['roomId'] = this.roomId;
    data['type'] = this.type;
    data['roomNameLength'] = this.roomNameLength;
    data['patientsNameLength'] = this.patientsNameLength;
    data['chartNumberLength'] = this.chartNumberLength;
    data['chartApiIdLength'] = this.chartApiIdLength;
    data['roomName'] = this.roomName;
    data['patientName'] = this.patientName;
    data['chartNumber'] = this.chartNumber;
    data['chartApiId'] = this.chartApiId;
    data['totalLength'] = this.totalLength;
    data['dataType0'] = this.dataType0;
    data['dataType1'] = this.dataType1;
    return data;
  }

  factory RoomInfoV2.fromJson(Map<String, dynamic> json){
    return RoomInfoV2(
      roomInfoSize: json['roomInfoSize'],
      roomId:json['roomId'],
      type:json['type'],
      roomNameLength: json['roomNameLength'],
      patientsNameLength: json['patientNameLength'],
      chartNumberLength: json['chartNumberLength'],
      chartApiIdLength: json['chartApiIdLength'],
      roomName: json['roomName'],
      patientName: json['patientName'],
      chartNumber: json['chartNumber'],
      chartApiId: json['chartApiId'],
      totalLength: json['totalLength']
    );
  }

  @override
  String toString() {
    return
      'roomindfosize : $roomInfoSize\n'
      'roomId : $roomId\n'
      'Type: $type\n'
      'roomName $roomName\n'
      'Patient Name: $patientName\n'
      'Chart Number:$chartNumber\n'
      'chartApiId :$chartApiId\n'
      'totalLength: $totalLength\n'
      'datatype0 :$dataType0\n'
      'datatype1 :$dataType1';
  }

}






/**----------------------------------------------------------------
 *  해외 승인용 임시 코드 로직 수정 예정
 */

class RegisterHospitalInfo {
  int? id;
  String? name;
  String? businessRegistrationNumber;
  int? countryId;
  String? addressFirst;
  String? addressSecond;
  String? addressRoad;
  String? addressDetail;
  String? zipcode;
  int? vetMaxCount;
  bool? isShutdown;
  String? businessRegistrationUri;
  String? licenseUri;
  String? updatedAt;
  String? createdAt;

  RegisterHospitalInfo(
      {this.id,
        this.name,
        this.businessRegistrationNumber,
        this.countryId,
        this.addressFirst,
        this.addressSecond,
        this.addressRoad,
        this.addressDetail,
        this.zipcode,
        this.vetMaxCount,
        this.isShutdown,
        this.businessRegistrationUri,
        this.licenseUri,
        this.updatedAt,
        this.createdAt});

  RegisterHospitalInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    businessRegistrationNumber = json['business_registration_number'];
    countryId = json['country_id'];
    addressFirst = json['address_first'];
    addressSecond = json['address_second'];
    addressRoad = json['address_road'];
    addressDetail = json['address_detail'];
    zipcode = json['zipcode'];
    vetMaxCount = json['vet_max_count'];
    isShutdown = json['is_shutdown'];
    businessRegistrationUri = json['business_registration_uri'];
    licenseUri = json['license_uri'];
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['business_registration_number'] = this.businessRegistrationNumber;
    data['country_id'] = this.countryId;
    data['address_first'] = this.addressFirst;
    data['address_second'] = this.addressSecond;
    data['address_road'] = this.addressRoad;
    data['address_detail'] = this.addressDetail;
    data['zipcode'] = this.zipcode;
    data['vet_max_count'] = this.vetMaxCount;
    data['is_shutdown'] = this.isShutdown;
    data['business_registration_uri'] = this.businessRegistrationUri;
    data['license_uri'] = this.licenseUri;
    data['updatedAt'] = this.updatedAt;
    data['createdAt'] = this.createdAt;
    return data;
  }
}

class CountryList {
  List<CountryInfoItem>? countryInfoList;

  CountryList({this.countryInfoList});

  CountryList.fromJson(Map<String, dynamic> json) {
    UtilityFunction.log.e('${json.toString()}');
    if (json['countryList'] != null) {
      countryInfoList = <CountryInfoItem>[];
      json['countryList'].forEach((v) {
        countryInfoList!.add(CountryInfoItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.countryInfoList != null) {
      data['countryList'] = this.countryInfoList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CountryInfoItem {
  String? numericCode;
  String? countryName;
  String? tld;
  String? countryNumberCode;

  CountryInfoItem({this.numericCode, this.countryName, this.tld, this.countryNumberCode});

  CountryInfoItem.fromJson(Map<String, dynamic> json) {
    numericCode = json['numericCode'];
    countryName = json['countryName'];
    tld = json['tld'];
    countryNumberCode = json['countryNumberCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['numericCode'] = this.numericCode;
    data['countryName'] = this.countryName;
    data['tld'] = this.tld;
    data['countryNumberCode'] = this.countryNumberCode;
    return data;
  }
}

class PatientMonitoringChart {
  String? sId;
  String? name;
  String? breed;
  int? animalType;
  String? chartNumber;
  double? weight;
  int? sex;
  int? hospitalId;
  String? createdAt;
  String? updatedAt;
  int? age;
  List<MonitoringRecords>? monitoringRecords;

  PatientMonitoringChart(
      {this.sId,
        this.name,
        this.breed,
        this.animalType,
        this.chartNumber,
        this.weight,
        this.sex,
        this.hospitalId,
        this.createdAt,
        this.updatedAt,
        this.age,
        this.monitoringRecords});

  PatientMonitoringChart.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    breed = json['breed'];
    animalType = json['animalType'];
    chartNumber = json['chartNumber'];
    weight = json['weight'];
    sex = json['sex'];
    hospitalId = json['hospitalId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    age = json['age'];
    if (json['monitoringRecords'] != null) {
      monitoringRecords = <MonitoringRecords>[];
      json['monitoringRecords'].forEach((v) {
        monitoringRecords!.add(new MonitoringRecords.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['breed'] = this.breed;
    data['animalType'] = this.animalType;
    data['chartNumber'] = this.chartNumber;
    data['weight'] = this.weight;
    data['sex'] = this.sex;
    data['hospitalId'] = this.hospitalId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['age'] = this.age;
    if (this.monitoringRecords != null) {
      data['monitoringRecords'] =
          this.monitoringRecords!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MonitoringRecords {
  int? hr;
  int? rr;
  int? interval;
  String? startedAt;

  MonitoringRecords({this.hr, this.rr, this.interval, this.startedAt});

  MonitoringRecords.fromJson(Map<String, dynamic> json) {
    hr = json['hr'];
    rr = json['rr'];
    interval = json['interval'];
    startedAt = json['startedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hr'] = this.hr;
    data['rr'] = this.rr;
    data['interval'] = this.interval;
    data['startedAt'] = this.startedAt;
    return data;
  }
}

/**----------------------------------------------------------------
 */

