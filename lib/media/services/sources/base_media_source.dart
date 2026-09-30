import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseMediaSource {
  final String id;
  final String name;
  final String type;
  final String defaultUrl;
  final String tag;
  final String badge;
  final String status;
  final List<String> allowedRoles; // Danh sách vai trò được phép xem

  String currentUrl;

  BaseMediaSource({
    required this.id,
    required this.name,
    required this.type,
    required this.defaultUrl,
    required this.tag,
    required this.badge,
    required this.status,
    this.allowedRoles = const [
      'Admin',
      'Vip',
      'User',
    ], // Mặc định cho phép Admin, Vip, User
  }) : currentUrl = defaultUrl;

  // Hàm kiểm tra người dùng hiện tại có quyền xem nguồn này hay không
  bool hasAccess(String userRole) {
    if (allowedRoles.isEmpty) return true;
    return allowedRoles.any(
      (role) => role.trim().toLowerCase() == userRole.trim().toLowerCase(),
    );
  }

  // Cập nhật URL động từ Firebase Firestore
  void updateUrlFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final firestoreUrl = data['URL'] ?? data['url'];
    if (firestoreUrl != null && firestoreUrl.toString().isNotEmpty) {
      currentUrl = firestoreUrl.toString();
    }
  }

  // Header khi tải trang
  Map<String, String> getHeaders() {
    return {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      'Referer': currentUrl,
    };
  }

  // Danh sách các domain quảng cáo bị chặn tải (ghi đè ở từng lớp con nếu cần)
  List<String> getBlockedAdDomains() => [];

  // BỔ SUNG: Mã JavaScript chặn Popup & Banner quảng cáo dành riêng cho từng nguồn
  String getAdBlockScript() => '';
}
