import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/screens/login_screen.dart';

class MediaSource {
  final String id;
  final String name;
  final String url;
  final String tag;
  final String badge;
  final String status;

  const MediaSource({
    required this.id,
    required this.name,
    required this.url,
    required this.tag,
    required this.badge,
    required this.status,
  });
}

class SelectSourceScreen extends StatefulWidget {
  const SelectSourceScreen({super.key});

  @override
  State<SelectSourceScreen> createState() => _SelectSourceScreenState();
}

class _SelectSourceScreenState extends State<SelectSourceScreen> {
  // Danh sách các Server/Nguồn Phim khả dụng
  final List<MediaSource> _sources = const [
    MediaSource(
      id: '1',
      name: 'Nguồn PhimFull',
      url: 'https://phimfull.online/trang-chu',
      tag: 'Phim Vietsub',
      badge: 'Nhanh',
      status: 'Ổn định',
    ),
    MediaSource(
      id: '2',
      name: 'Nguồn KKPhim',
      url: 'https://kkphim.com/api',
      tag: 'Phim Thuyết Minh',
      badge: 'Nhanh & Ổn định',
      status: 'Ổn định',
    ),
    MediaSource(
      id: '3',
      name: 'Nguồn OPhim',
      url: 'https://ophim.org/v1/api',
      tag: 'Full HD 1080p',
      badge: 'Ổn định',
      status: 'Ổn định',
    ),
  ];

  late MediaSource _selectedSource;

  @override
  void initState() {
    super.initState();
    _selectedSource = _sources.first; // Mặc định chọn nguồn đầu tiên
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

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userName = currentUser?.displayName ??
        currentUser?.email?.split('@').first ??
        'Người dùng';

    return Scaffold(
      backgroundColor:
          const Color(0xFF121218), // Nền tối Cinema chuẩn App Xem Phim
      appBar: AppBar(
        backgroundColor: const Color(0xFF181824),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
                    // 1. CARD THÔNG TIN NGƯỜI DÙNG (User Profile Header)
                    InkWell(
                      onTap: () {},
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Cấp độ: VIP MEMBER',
                                    style: TextStyle(
                                      color: Colors.deepPurpleAccent,
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
                    ),

                    const SizedBox(height: 20),

                    // 2. KHUNG HIỂN THỊ NGUỒN ĐANG CHỌN (Active Source Box)
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
                              color: Colors.deepPurpleAccent.withOpacity(0.2),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  _selectedSource.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedSource.url,
                                  style: const TextStyle(
                                    color: Colors.deepPurpleAccent,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3. TIÊU ĐỀ DANH SÁCH SERVER
                    const Text(
                      'Danh sách Server Web khả dụng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. DANH SÁCH CÁC SERVER
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _sources.length,
                      itemBuilder: (context, index) {
                        final source = _sources[index];
                        final isSelected = _selectedSource.id == source.id;

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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Chấm màu xanh báo trạng thái Server
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(
                                        0xFF10B981), // Thay thế cho Colors.emerald
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Nội dung Server
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
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          // Badge Màu Cam
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              source.badge,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Chữ "Ổn định"
                                          Text(
                                            source.status,
                                            style: const TextStyle(
                                              color: Color(
                                                  0xFF10B981), // Thay thế cho Colors.emerald
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        source.url,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Tag Phim ảnh
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 5. NÚT XÁC NHẬN CHỌN NGUỒN Ở ĐÁY MÀN HÌNH
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã chọn ${_selectedSource.name}. Đang tải dữ liệu phim...',
                        ),
                        backgroundColor: Colors.deepPurple,
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
                    'Dùng Nguồn Này Để Xem Phim',
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
