import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/authentication/landing_screen.dart';
import 'package:flutter_chat_app/authentication/login_screen.dart';
import 'package:flutter_chat_app/authentication/otp_screen.dart';
import 'package:flutter_chat_app/authentication/user_information_screen.dart';
import 'package:flutter_chat_app/constants.dart';
import 'package:flutter_chat_app/firebase_options.dart';
import 'package:flutter_chat_app/main_screen/chat_screen.dart';
import 'package:flutter_chat_app/main_screen/friend_requests_screen.dart';
import 'package:flutter_chat_app/main_screen/friends_screen.dart';
import 'package:flutter_chat_app/main_screen/home_screen.dart';
import 'package:flutter_chat_app/main_screen/profile_screen.dart';
import 'package:flutter_chat_app/main_screen/settings_screen.dart';
import 'package:flutter_chat_app/providers/authentication_provider.dart';
import 'package:flutter_chat_app/providers/chat_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
  ], child: MyApp(savedThemeMode: savedThemeMode)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.savedThemeMode});

  final AdaptiveThemeMode? savedThemeMode;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pop Peep Chat',
          theme: theme,
          darkTheme: darkTheme,
          initialRoute: Constants.landingScreen,
          routes: {
            Constants.landingScreen: (context) => const LandingScreen(),
            Constants.loginScreen: (context) => const LoginScreen(),
            Constants.otpScreen: (context) => const OTPScreen(),
            Constants.userInformationScreen: (context) =>
                const UserInformationScreen(),
            Constants.homeScreen: (context) => const HomeScreen(),
            Constants.profileScreen: (context) => const ProfileScreen(),
            Constants.settingsScreen: (context) => const SettingsScreen(),
            Constants.friendsScreen: (context) => const FriendsScreen(),
            Constants.friendRequestsScreen: (context) =>
                const FriendRequestsScreen(),
            Constants.chatScreen: (context) => const ChatScreen(),
          }),
    );
  }
}
