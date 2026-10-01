import 'base_media_source.dart';

class Picture1Source extends BaseMediaSource {
  Picture1Source()
      : super(
          id: 'Picture 1', // Khớp chính xác với Document ID "Picture 1" trên Firebase
          name: 'Nguồn Ảnh 1',
          type: 'picture',
          defaultUrl: 'https://cosplaytele.com/',
          tag: 'Hình Ảnh HD',
          badge: 'Tốc độ cao',
          status: 'Ổn định',
          allowedRoles: ['admin', 'vip'], // Chỉ Admin và VIP mới xem được
        );

  @override
  List<String> getBlockedAdDomains() {
    return [
      'popunder.net',
      'adnetwork.com',
    ];
  }
}
