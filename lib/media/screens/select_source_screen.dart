import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/profile/screens/account_info_screen.dart';
import '../services/sources/base_media_source.dart';
import '../services/sources/media_source_manager.dart';
import 'media_web_view_screen.dart';

class SelectSourceScreen extends StatefulWidget {
  const SelectSourceScreen({super.key});

  @override
  State<SelectSourceScreen> createState() => _SelectSourceScreenState();
}

class _SelectSourceScreenState extends State<SelectSourceScreen> {
  final MediaSourceManager _sourceManager = MediaSourceManager();
  BaseMediaSource? _selectedSource;

  // Biến lưu trữ vai trò người dùng hiện tại (Mặc định là User)
  String _currentUserRole = 'User';

  @override
  void initState() {
    super.initState();
    if (_sourceManager.sources.isNotEmpty) {
      _selectedSource = _sourceManager.sources.first;
    }
  }

  // Xử lý Đăng xuất
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // Hàm hiển thị Popup để Admin sửa Link và tự động cập nhật lên Firestore
  void _showEditUrlDialog(BuildContext context, BaseMediaSource source) {
    final textController = TextEditingController(text: source.currentUrl);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181824),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Sửa Link - ${source.name}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: textController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Đường dẫn URL mới',
              labelStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurpleAccent),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurple),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final newUrl = textController.text.trim();
                if (newUrl.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('Links Media')
                        .doc(source.id)
                        .set({'URL': newUrl}, SetOptions(merge: true));

                    if (mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã cập nhật URL cho ${source.name}!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi khi cập nhật Firestore: $e'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text(
                'Lưu',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF121218), // Nền tối Cinema
      appBar: AppBar(
        backgroundColor: const Color(0xFF181824),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Chọn Nguồn Xem Phim',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _handleLogout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. CARD PROFILE NGƯỜI DÙNG
                    StreamBuilder<DocumentSnapshot>(
                      stream: currentUser != null
                          ? FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .snapshots()
                          : null,
                      builder: (context, snapshot) {
                        String userName = currentUser?.displayName ??
                            currentUser?.email?.split('@').first ??
                            'Người dùng';
                        String userRole = 'User';

                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data!.exists) {
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          if (data != null) {
                            userRole = data['role'] ?? 'User';
                            _currentUserRole = userRole;

                            if (data['fullName'] != null &&
                                data['fullName'].toString().trim().isNotEmpty) {
                              userName = data['fullName'];
                            } else if (data['name'] != null &&
                                data['name'].toString().trim().isNotEmpty) {
                              userName = data['name'];
                            }
                          }
                        }

                        final bool isAdmin = userRole.toLowerCase() == 'admin';

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AccountInfoScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 4.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.deepPurple,
                                  child: Text(
                                    userName.isNotEmpty
                                        ? userName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Vai trò: ${userRole.toUpperCase()}',
                                        style: TextStyle(
                                          color: isAdmin
                                              ? Colors.redAccent
                                              : (userRole.toLowerCase() == 'vip'
                                                  ? Colors.amber
                                                  : Colors.deepPurpleAccent),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // 2. DANH SÁCH SERVER VÀ PHÂN NHÓM EXPANSIONTILE (TRỎ XUỐNG DẠNG CARD)
                    StreamBuilder<List<BaseMediaSource>>(
                      stream: _sourceManager.getSourcesStream(),
                      builder: (context, snapshot) {
                        final rawSources =
                            snapshot.data ?? _sourceManager.sources;
                        final bool isAdmin =
                            _currentUserRole.toLowerCase() == 'admin';
                        final bool isVipOrAdmin =
                            isAdmin || _currentUserRole.toLowerCase() == 'vip';

                        // Lọc nguồn theo quyền hạn
                        final sources = isAdmin
                            ? rawSources
                            : rawSources
                                .where((s) => s.hasAccess(_currentUserRole))
                                .toList();

                        if (sources.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'Không có nguồn phim nào khả dụng cho vai trò của bạn.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }

                        // Phân tách nguồn thành nhóm Thường và nhóm VIP/Admin
                        final normalSources =
                            sources.where((s) => s.hasAccess('User')).toList();
                        final vipSources =
                            sources.where((s) => !s.hasAccess('User')).toList();

                        // Đồng bộ _selectedSource
                        if (_selectedSource == null ||
                            !sources.any((s) => s.id == _selectedSource!.id)) {
                          _selectedSource = sources.first;
                        } else {
                          _selectedSource = sources.firstWhere(
                            (s) => s.id == _selectedSource!.id,
                            orElse: () => sources.first,
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // KHUNG HIỂN THỊ NGUỒN ĐANG CHỌN
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.deepPurpleAccent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurpleAccent
                                          .withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.language_rounded,
                                      color: Colors.deepPurpleAccent,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Nguồn đang chọn:',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _selectedSource!.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isAdmin)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_note_rounded,
                                        color: Colors.amber,
                                        size: 28,
                                      ),
                                      tooltip: 'Sửa link nguồn này',
                                      onPressed: () => _showEditUrlDialog(
                                          context, _selectedSource!),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // KHU VỰC EXPANSIONTILE "LINK VIP & ĐẶC QUYỀN" (Mặc định ẩn, bấm vào trỏ xuống tràn danh sách card kèm nút sửa)
                            if (vipSources.isNotEmpty && isVipOrAdmin) ...[
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF181824),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.amber.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    initiallyExpanded:
                                        false, // Mặc định thu gọn khi vào app
                                    iconColor: Colors.amber,
                                    collapsedIconColor: Colors.amber,
                                    title: const Text(
                                      'Khu vực Link VIP & Đặc quyền',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    children: vipSources.map((source) {
                                      final isSelected =
                                          _selectedSource?.id == source.id;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedSource = source;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF222232)
                                                : const Color(0xFF181824),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.amber
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 6),
                                                width: 10,
                                                height: 10,
                                                decoration: const BoxDecoration(
                                                  color: Colors.amber,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            source.name,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 8,
                                                            vertical: 3,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.amber,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                          ),
                                                          child: Text(
                                                            source.badge,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          source.status,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors
                                                                .amberAccent,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.08),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: Text(
                                                        source.tag,
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Nút chỉnh sửa link hình cây bút dành cho Admin ở từng nguồn VIP
                                              if (isAdmin)
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    color: Colors.amber,
                                                    size: 20,
                                                  ),
                                                  tooltip:
                                                      'Chỉnh sửa nguồn VIP này',
                                                  onPressed: () =>
                                                      _showEditUrlDialog(
                                                          context, source),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // TIÊU ĐỀ DANH SÁCH SERVER THƯỜNG
                            const Text(
                              'Danh sách Server Web khả dụng',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // RENDER DANH SÁCH CÁC FILE SERVER THƯỜNG
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: normalSources.length,
                              itemBuilder: (context, index) {
                                final source = normalSources[index];
                                final isSelected =
                                    _selectedSource?.id == source.id;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSource = source;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF222232)
                                          : const Color(0xFF181824),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.deepPurpleAccent
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 6),
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      source.name,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Text(
                                                      source.badge,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    source.status,
                                                    style: const TextStyle(
                                                      color: Color(0xFF10B981),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  source.tag,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isAdmin)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              color: Colors.amber,
                                              size: 20,
                                            ),
                                            tooltip: 'Chỉnh sửa nguồn này',
                                            onPressed: () => _showEditUrlDialog(
                                                context, source),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 3. NÚT XÁC NHẬN CHỌN NGUỒN
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedSource == null
                      ? null
                      : () {
                          if (!_selectedSource!.hasAccess(_currentUserRole)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Tài khoản vai trò ${_currentUserRole.toUpperCase()} không có quyền truy cập ${_selectedSource!.name}!',
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MediaWebViewScreen(
                                source: _selectedSource!,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Dùng Nguồn Này Để Xem',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
