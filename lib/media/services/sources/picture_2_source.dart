import 'base_media_source.dart';

class Picture2Source extends BaseMediaSource {
  Picture2Source()
      : super(
          id: 'Picture_2',
          name: 'Nguồn Ảnh 2',
          type: 'picture',
          defaultUrl: 'https://capture2.example.com/',
          tag: 'Hình Ảnh 4K',
          badge: 'Ổn định',
          status: 'Ổn định',
        );

  @override
  List<String> getBlockedAdDomains() {
    return [
      'histats.com',
    ];
  }
}
