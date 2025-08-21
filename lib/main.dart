import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/features/auth/presentation/screens/home_screen.dart';
import 'package:park_chatapp/features/chat/presentation/screens/create_group_screen.dart';
import 'package:park_chatapp/features/chat/presentation/screens/group_chat_screen.dart';
import 'package:park_chatapp/features/chat/domain/models/group.dart';
// import 'package:park_chatapp/features/auth/presentation/screens/login_screen.dart';
// import 'package:park_chatapp/view/auth/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        360,
        690,
      ), // Design dimensions (default is iPhone 13 size)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(),
          routes: {'/create_group': (context) => const CreateGroupScreen()},
          onGenerateRoute: (settings) {
            if (settings.name == '/group_chat') {
              final Group group = settings.arguments as Group;
              return MaterialPageRoute(
                builder: (_) => GroupChatScreen(group: group),
              );
            }
            return null;
          },
          home: child,
        );
      },
      child: HomeScreen(), // Your login screen
    );
  }
}
