import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');

  // 1. DIALOG THÊM / SỬA THÔNG TIN NGƯỜI DÙNG
  void _showUserDialog({
    String? docId,
    String? currentName,
    String? currentEmail,
    String? currentGender,
    String? currentRole,
  }) {
    final nameController = TextEditingController(text: currentName ?? '');
    final emailController = TextEditingController(text: currentEmail ?? '');
    String selectedGender = currentGender ?? 'Nam';
    String selectedRole = currentRole ?? 'User';

    showDialog(
      context: context,
      builder: (context) {
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
                      items: const [
                        DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                        DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                        DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                      ],
                      onChanged: (val) {
                        if (val != null)
                          setDialogState(() => selectedGender = val);
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
                      items: const [
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'Vip', child: Text('Vip')),
                        DropdownMenuItem(value: 'User', child: Text('User')),
                      ],
                      onChanged: (val) {
                        if (val != null)
                          setDialogState(() => selectedRole = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
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
                        'fullName':
                            nameController.text.trim(), // Sửa thành fullName
                        'email': emailController.text.trim(),
                        'gender': selectedGender,
                        'role': selectedRole,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                    } else {
                      await _usersRef.doc(docId).update({
                        'fullName':
                            nameController.text.trim(), // Sửa thành fullName
                        'email': emailController.text.trim(),
                        'gender': selectedGender,
                        'role': selectedRole,
                      });
                    }
                    if (context.mounted) Navigator.pop(context);
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

  // 2. DIALOG ĐỔI VAI TRÒ NHANH
  void _showChangeRoleDialog(String docId, String currentRole) {
    String selectedRole = currentRole;
    showDialog(
      context: context,
      builder: (context) {
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
                items: const [
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'Vip', child: Text('Vip')),
                  DropdownMenuItem(value: 'User', child: Text('User')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedRole = val);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent),
                  onPressed: () async {
                    await _usersRef.doc(docId).update({'role': selectedRole});
                    if (context.mounted) Navigator.pop(context);
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

  // 3. DIALOG XÓA NGƯỜI DÙNG
  void _deleteUser(String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF181824),
        title:
            const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc chắn muốn xóa tài khoản "$name"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await _usersRef.doc(docId).delete();
              if (context.mounted) Navigator.pop(context);
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

          // Lấy theo trường fullName từ Firestore (có fallback về 'name' cũ nếu cần)
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
                      // Avatar
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

                      // Tên
                      Text(
                        myName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Badge Role
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

                      // Email Row
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

                      // Gender Row
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

                const SizedBox(height: 28),

                // ================= 2. PHẦN CHỨC NĂNG QUẢN TRỊ (CHỈ ADMIN MỚI THẤY) =================
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

                  // Danh sách người dùng
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

                          // Lấy theo fullName
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

                                // Thao tác Admin: Sửa, Đổi Role, Xóa
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
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.admin_panel_settings_outlined,
                                        color: Colors.orangeAccent,
                                        size: 22,
                                      ),
                                      onPressed: () => _showChangeRoleDialog(
                                        doc.id,
                                        uRole,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.redAccent,
                                        size: 22,
                                      ),
                                      onPressed: () =>
                                          _deleteUser(doc.id, uName),
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
