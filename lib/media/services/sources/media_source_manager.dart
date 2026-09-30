import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_media_source.dart';
import 'movie_1_source.dart';
import 'movie_2_source.dart';
import 'picture_1_source.dart';
import 'picture_2_source.dart';

class MediaSourceManager {
  final List<BaseMediaSource> _registeredSources = [
    Movie1Source(),
    Movie2Source(),
    Picture1Source(),
    Picture2Source(),
  ];

  List<BaseMediaSource> get sources => _registeredSources;

  List<BaseMediaSource> getMovieSources() =>
      _registeredSources.where((s) => s.type == 'movie').toList();

  List<BaseMediaSource> getPictureSources() =>
      _registeredSources.where((s) => s.type == 'picture').toList();

  Stream<List<BaseMediaSource>> getSourcesStream() {
    return FirebaseFirestore.instance
        .collection('Links Media')
        .snapshots()
        .map((snapshot) {
      for (var doc in snapshot.docs) {
        // Tìm các nguồn có ID khớp chính xác với Document ID trên Firestore
        final matches = _registeredSources.where(
          (s) => s.id.trim().toLowerCase() == doc.id.trim().toLowerCase(),
        );

        // Chỉ cập nhật URL khi tìm thấy nguồn khớp (tránh ghi đè nhầm vào Nguồn 1)
        if (matches.isNotEmpty) {
          matches.first.updateUrlFromFirestore(doc);
        }
      }
      return _registeredSources;
    });
  }
}
