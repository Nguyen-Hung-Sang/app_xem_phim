import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import '../../../media/screens/select_source_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Tải thông tin và trạng thái "Ghi nhớ mật khẩu" từ bộ nhớ thiết bị
    _loadRememberedCredentials();
  }

  // Tải dữ liệu đã lưu
  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    // Lấy trạng thái đã nhớ trước đó (mặc định false nếu chưa bao giờ tích)
    final isRemembered = prefs.getBool('remember_me') ?? false;

    if (isRemembered) {
      final savedEmail = prefs.getString('remembered_email') ?? '';
      final savedPassword = prefs.getString('remembered_password') ?? '';

      setState(() {
        _rememberMe = true; // Tự động tích chọn ô checkbox
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
      });
    } else {
      setState(() {
        _rememberMe = false; // Bỏ tích nếu lần trước không ghi nhớ
      });
    }
  }

  // Lưu hoặc Xóa dữ liệu đăng nhập dựa vào ô Checkbox lúc người dùng bấm Đăng nhập
  Future<void> _saveOrClearCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    if (_rememberMe) {
      // Lưu lại trạng thái tích chọn cùng Email & Mật khẩu
      await prefs.setBool('remember_me', true);
      await prefs.setString('remembered_email', _emailController.text.trim());
      await prefs.setString('remembered_password', _passwordController.text);
    } else {
      // Xóa hoàn toàn trạng thái và dữ liệu khi người dùng bỏ tích
      await prefs.setBool('remember_me', false);
      await prefs.remove('remembered_email');
      await prefs.remove('remembered_password');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Xử lý Đăng nhập
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Lưu hoặc xóa thông tin tùy theo trạng thái ô checkbox hiện tại
      await _saveOrClearCredentials();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SelectSourceScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng nhập thất bại. Vui lòng thử lại!';
      if (e.code == 'user-not-found') {
        message = 'Tài khoản không tồn tại.';
      } else if (e.code == 'wrong-password') {
        message = 'Mật khẩu không chính xác.';
      } else if (e.code == 'invalid-email') {
        message = 'Định dạng email không hợp lệ.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0F17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // 1. TIÊU ĐỀ & PHỤ ĐỀ
                const Text(
                  'Đăng nhập',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chào mừng bạn trở lại, hãy đăng nhập để tiếp tục!',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 36),

                // 2. Ô NHẬP EMAIL
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF64748B),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF181D28),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF7C3AED),
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập Email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 3. Ô NHẬP MẬT KHẨU
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Mật khẩu',
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF64748B),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFF181D28),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF7C3AED),
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập Mật khẩu';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // 4. CHECKBOX GHI NHỚ MẬT KHẨU
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: const Color(0xFF7C3AED),
                        checkColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF64748B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ghi nhớ mật khẩu',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 5. NÚT ĐĂNG NHẬP
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // 6. CHUYỂN SANG MÀN HÌNH ĐĂNG KÝ
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Chưa có tài khoản? ',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
