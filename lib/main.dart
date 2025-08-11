import 'package:flutter/material.dart';

import 'pages/splash_screen.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/carts/cart.dart';
import 'pages/account/account.dart';
import 'pages/transactions/borrow.dart';
import 'pages/transactions/return.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Sarpras Taruna Bhakti',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/cart': (context) => const CartPage(),
        '/account': (context) => const AccountPage(),
        '/borrow': (context) => const BorrowPage(),
        '/return': (context) => const ReturnPage()
      },
    );
  }
}