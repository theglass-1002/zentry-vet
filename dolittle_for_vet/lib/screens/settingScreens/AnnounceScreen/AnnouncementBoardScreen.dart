import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/components/announcementPost_card.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';

class AnnouncementBoardScreen extends StatefulWidget {
  const AnnouncementBoardScreen({super.key});
  static const routeName = '/AnnouncementBoardScreen';
  @override
  State<AnnouncementBoardScreen> createState() =>
      _AnnouncementBoardScreenState();
}

class _AnnouncementBoardScreenState extends State<AnnouncementBoardScreen> {
  final ScrollController _scrollController = ScrollController();
  late ProfileManager _profileManager = ProfileManager();
  late ApiService _apiService = ApiService();
  List<AnnouncementPost> _listAnnouncementPost = [];
  bool _isLoding = true;
  int _page = 1;
  int _offset = 0;
  final _limit = 30;
  bool isEndData = false;
  bool isFetchingData = false;

  @override
  void initState() {
    // TODO: implement initState
    _profileManager = Provider.of<ProfileManager>(context, listen: false);

    Map<String, dynamic> queryParameters = {
      'appCode': '2001',
      'offset': _offset.toString(),
      'limit': _limit.toString(),
    };
     getAnnouncementPosts(queryParameters);
    // _scrollController.addListener(() {
    //   scrollListener();
    // });
    super.initState();
  }


  void scrollListener() async {
    if (isFetchingData == false &&
        isEndData == false &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent - 80 &&
        !_scrollController.position.outOfRange) {
      UtilityFunction.log.e('스크롤닿음');
      isFetchingData = true;
      _page++;
      _offset = (_page - 1) * _limit;
      Map<String, dynamic> queryParameters = {
        'appCode': '2001',
        'offset': _offset.toString(),
        'limit': _limit.toString(),
      };
     return await getAnnouncementPosts(queryParameters);
    }
  }


  Future<void> getAnnouncementPosts(queryParameters) async {
    queryParameters['language'] = UtilityFunction.announcementLanguage(await _apiService.getTranslation());
    await _apiService
        .connectGetAnnouncementPosts(queryParameters)
        .then((result) {
      result.when((error) async {
        if (error.re_code == UnauthorizedCode && error.code == 101) {
          return await _apiService.refreshToken()
              ? await getAnnouncementPosts(queryParameters)
              : logoutAndPushToHome();
        }
        UtilityComponents.showToast(
            "${"Failed to load announcement list".tr()}:${error.message ?? ""}");
        UtilityFunction.goBackToPreviousPage(context);
        setLoading(false);
      }, (success) {
        if (_page == 1) {
          _listAnnouncementPost = success.announcementPost!;
        } else {
          _listAnnouncementPost.addAll(success.announcementPost!);
        }
        setLoading(false);
        return;
      });
    });
  }

  Future<void> logoutAndPushToHome() async {
    await _apiService.logout();
    await _profileManager.logout();
    setLoading(false);
  }

  void setLoading(bool isLoding) {
    setState(() {
      _isLoding = isLoding;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Announcement'.tr()),
        ),
        body: buildBody());
  }

  Widget buildBody() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _listAnnouncementPost.length,
      controller: _scrollController,
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
            UtilityFunction.moveScreen(context, '/announcementPost',_listAnnouncementPost[index].id);
            },
            child: AnnouncementPostCard(
                announcementPost: _listAnnouncementPost[index]));
      },
    );
  }
}


