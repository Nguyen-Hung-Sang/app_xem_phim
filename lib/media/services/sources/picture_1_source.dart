import 'base_media_source.dart';

class Picture1Source extends BaseMediaSource {
  Picture1Source()
      : super(
          id: 'Picture_1',
          name: 'Nguồn Ảnh 1',
          type: 'picture',
          defaultUrl: 'https://capture1.example.com/',
          tag: 'Hình Ảnh HD',
          badge: 'Tốc độ cao',
          status: 'Ổn định',
        );

  @override
  List<String> getBlockedAdDomains() {
    return [
      'popunder.net',
      'adnetwork.com',
    ];
  }
}
