import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikeService {
  final CollectionReference _likeRef =
      FirebaseFirestore.instance.collection('Like');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream danh sách phim yêu thích của người dùng hiện tại
  Stream<QuerySnapshot> getFavoriteMediaStream() {
    final String? userEmail = _auth.currentUser?.email;
    if (userEmail == null) {
      return const Stream.empty();
    }
    return _likeRef.where('email', isEqualTo: userEmail).snapshots();
  }

  // Kiểm tra xem URL đã được lưu yêu thích chưa
  Future<bool> isLiked(String videoUrl) async {
    final String? userEmail = _auth.currentUser?.email;
    if (userEmail == null || videoUrl.isEmpty) return false;

    final query = await _likeRef
        .where('email', isEqualTo: userEmail)
        .where('URL', isEqualTo: videoUrl)
        .get();

    return query.docs.isNotEmpty;
  }

  // Hàm chuyển đổi trạng thái Thích / Bỏ thích (Tự động lưu vào Firebase)
  Future<bool> toggleLike({
    String? mediaId,
    String? title,
    String? url,
  }) async {
    final String targetUrl = (url != null && url.isNotEmpty)
        ? url
        : (mediaId != null && mediaId.isNotEmpty ? mediaId : '');
    final String? userEmail = _auth.currentUser?.email;

    if (userEmail == null || targetUrl.isEmpty) return false;

    // Kiểm tra xem link đã có trên Firestore chưa
    final query = await _likeRef
        .where('email', isEqualTo: userEmail)
        .where('URL', isEqualTo: targetUrl)
        .get();

    if (query.docs.isNotEmpty) {
      // Đã thích -> Bỏ thích (Xóa khỏi Firebase)
      for (var doc in query.docs) {
        await _likeRef.doc(doc.id).delete();
      }
      return false;
    } else {
      // Chưa thích -> Thêm vào Firebase đúng cấu trúc URL và email
      await _likeRef.add({
        'URL': targetUrl,
        'email': userEmail,
        'title': title ?? 'SaiGonPhim',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    }
  }

  // Xóa trực tiếp theo Doc ID
  Future<void> removeLike(String docId) async {
    if (docId.isNotEmpty) {
      await _likeRef.doc(docId).delete();
    }
  }
}
