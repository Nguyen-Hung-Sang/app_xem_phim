import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/screens/welcome_screen.dart';

void main() async {
  // Bắt buộc phải có dòng này khi khởi tạo bất kỳ dịch vụ bất đồng bộ nào trước runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo kết nối Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineFrame',
      theme: ThemeData.dark(),
      home: const WelcomeScreen(),
    );
  }
}
