import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_xem_phim/media/services/like_service.dart';
import 'package:app_xem_phim/media/screens/media_web_view_screen.dart';
import 'package:app_xem_phim/media/services/sources/base_media_source.dart';

// Source tạm thời dùng để truyền thông tin phim vào MediaWebViewScreen
class GenericMediaSource extends BaseMediaSource {
  final String _name;
  final String _url;

  GenericMediaSource({required String name, required String url})
      : _name = name,
        _url = url,
        super(
            id: '',
            name: '',
            type: '',
            defaultUrl: '',
            tag: '',
            badge: '',
            status: ''); // Kết thúc bằng dấu ';' ở đây, KHÔNG dùng super(...)

  @override
  String get name => _name;

  @override
  String get currentUrl => _url;

  @override
  Map<String, String> getHeaders() => {};

  @override
  String getAdBlockScript() => '';

  @override
  List<String> getBlockedAdDomains() => [];
}

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');
  final LikeService _likeService = LikeService();

  final List<String> _genderOptions = const ['Nam', 'Nữ', 'Khác'];
  final List<String> _roleOptions = const ['Admin', 'Vip', 'User'];

  String _getValidGender(String? gender) {
    if (gender == null) return 'Nam';
    return _genderOptions.firstWhere(
      (g) => g.toLowerCase() == gender.toLowerCase(),
      orElse: () => 'Nam',
    );
  }

  String _getValidRole(String? role) {
    if (role == null) return 'User';
    return _roleOptions.firstWhere(
      (r) => r.toLowerCase() == role.toLowerCase(),
      orElse: () => 'User',
    );
  }

  void _showUserDialog({
    String? docId,
    String? currentName,
    String? currentEmail,
    String? currentGender,
    String? currentRole,
  }) {
    final nameController = TextEditingController(text: currentName ?? '');
    final emailController = TextEditingController(text: currentEmail ?? '');
    String selectedGender = _getValidGender(currentGender);
    String selectedRole = _getValidRole(currentRole);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF181824),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                docId == null ? 'Thêm Người Dùng' : 'Sửa Thông Tin',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Họ và tên',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF121218),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF121218),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      dropdownColor: const Color(0xFF181824),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Giới tính',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF121218),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _genderOptions
                          .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedGender = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      dropdownColor: const Color(0xFF181824),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Vai trò (Role)',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF121218),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _roleOptions
                          .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedRole = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child:
                      const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                  ),
                  onPressed: () async {
                    if (docId == null) {
                      await _usersRef.add({
                        'fullName': nameController.text.trim(),
                        'email': emailController.text.trim(),
                        'gender': selectedGender,
                        'role': selectedRole,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                    } else {
                      await _usersRef.doc(docId).update({
                        'fullName': nameController.text.trim(),
                        'email': emailController.text.trim(),
                        'gender': selectedGender,
                        'role': selectedRole,
                      });
                    }
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                  child: Text(docId == null ? 'Thêm' : 'Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangeRoleDialog(String docId, String currentRole) {
    String selectedRole = _getValidRole(currentRole);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF181824),
              title: const Text('Đổi Vai Trò',
                  style: TextStyle(color: Colors.white)),
              content: DropdownButtonFormField<String>(
                value: selectedRole,
                dropdownColor: const Color(0xFF181824),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF121218),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _roleOptions
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedRole = val);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child:
                      const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent),
                  onPressed: () async {
                    await _usersRef.doc(docId).update({'role': selectedRole});
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteUser(String docId, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF181824),
        title:
            const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc chắn muốn xóa tài khoản "$name"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await _usersRef.doc(docId).delete();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121218),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181824),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông Tin Tài Khoản',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: currentUser != null
            ? _usersRef.doc(currentUser!.uid).snapshots()
            : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          Map<String, dynamic>? myData;
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.exists) {
            myData = snapshot.data!.data() as Map<String, dynamic>?;
          }
          final String myName = myData?['fullName'] ??
              myData?['name'] ??
              myData?['email']?.split('@').first ??
              currentUser?.displayName ??
              'Người dùng';
          final String myEmail =
              myData?['email'] ?? currentUser?.email ?? 'Chưa có Email';
          final String myGender = myData?['gender'] ?? 'Nam';
          final String myRole = myData?['role'] ?? 'User';
          final bool isAdmin = myRole.toLowerCase() == 'admin';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= 1. CARD THÔNG TIN CÁ NHÂN =================
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181824),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF2563EB),
                        child: Text(
                          myName.isNotEmpty ? myName[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        myName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? Colors.redAccent.withOpacity(0.2)
                              : Colors.deepPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Role: ${myRole.toUpperCase()}',
                          style: TextStyle(
                            color: isAdmin
                                ? Colors.redAccent
                                : const Color(0xFF8B5CF6),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(
                          color: Colors.white.withOpacity(0.1), thickness: 1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF3B82F6),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  myEmail,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF3B82F6),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Giới tính',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  myGender,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // ================= 2. PHẦN DANH SÁCH YÊU THÍCH =================
                const Text(
                  'Yêu Thích',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: _likeService.getFavoriteMediaStream(),
                  builder: (context, favSnap) {
                    if (favSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!favSnap.hasData || favSnap.data!.docs.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF181824),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Chưa có phim nào trong danh sách yêu thích',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final favDocs = favSnap.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: favDocs.length,
                      itemBuilder: (context, index) {
                        final favData =
                            favDocs[index].data() as Map<String, dynamic>;
                        final String docId = favDocs[index].id;
                        final String url =
                            favData['URL'] ?? favData['url'] ?? '';
                        final String title =
                            favData['title'] ?? favData['name'] ?? 'SaiGonPhim';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF181824),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                if (url.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MediaWebViewScreen(
                                        source: GenericMediaSource(
                                          name: title,
                                          url: url,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite,
                                      color: Colors.redAccent,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            url,
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.redAccent,
                                        size: 22,
                                      ),
                                      onPressed: () =>
                                          _likeService.removeLike(docId),
                                      tooltip: 'Xóa khỏi yêu thích',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                // ================= 3. PHẦN CHỨC NĂNG QUẢN TRỊ (CHỈ ADMIN MỚI THẤY) =================
                if (isAdmin) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chức Năng Quản Trị (Admin)',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: Colors.redAccent, size: 28),
                        onPressed: () => _showUserDialog(),
                        tooltip: 'Thêm người dùng',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot>(
                    stream: _usersRef.snapshots(),
                    builder: (context, userSnap) {
                      if (userSnap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!userSnap.hasData || userSnap.data!.docs.isEmpty) {
                        return const Text(
                          'Chưa có dữ liệu danh sách người dùng',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      final docs = userSnap.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final uData = doc.data() as Map<String, dynamic>;
                          final String uName =
                              uData['fullName'] ?? uData['name'] ?? 'Không tên';
                          final String uEmail = uData['email'] ?? 'Không email';
                          final String uGender = uData['gender'] ?? 'Chưa rõ';
                          final String uRole = uData['role'] ?? 'User';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF181824),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        uName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$uEmail | $uGender | Role: $uRole',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xFF3B82F6),
                                        size: 22,
                                      ),
                                      onPressed: () => _showUserDialog(
                                        docId: doc.id,
                                        currentName: uName,
                                        currentEmail: uEmail,
                                        currentGender: uGender,
                                        currentRole: uRole,
                                      ),
                                      tooltip: 'Sửa thông tin',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.shield_outlined,
                                        color: Colors.orangeAccent,
                                        size: 22,
                                      ),
                                      onPressed: () =>
                                          _showChangeRoleDialog(doc.id, uRole),
                                      tooltip: 'Đổi vai trò',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.redAccent,
                                        size: 22,
                                      ),
                                      onPressed: () =>
                                          _deleteUser(doc.id, uName),
                                      tooltip: 'Xóa người dùng',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
