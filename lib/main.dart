import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_buffer/bloc/auth_cubit.dart';
import 'package:social_media_buffer/screens/chat_screen.dart';
import 'package:social_media_buffer/screens/create_post_screen.dart';
import 'package:social_media_buffer/screens/sign_in_screen.dart';
import 'screens/post_screen.dart';
import 'screens/sign_up_screen.dart';
import 'package:sentry_flutter/sentry_flutter.dart';


void main() async {

  await SentryFlutter.init(
        (options) {
      options.dsn = 'https://318a69dcb066477dbdaa08b5f481ce7b@o1051694.ingest.sentry.io/6034838';
    },
    // Init your App.
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      runApp(MyApp());
    },
  );
}

class MyApp extends StatelessWidget {

  Widget _buildHomeScreen() {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return PostScreen();
          } else {
            return SignInScreen();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: _buildHomeScreen(),
        routes: {
          SignInScreen.id: (context) => SignInScreen(),
          SignUpScreen.id: (context) => SignUpScreen(),
          PostScreen.id: (context) => PostScreen(),
          CreatePostScreen.id: (context) => CreatePostScreen(),
          ChatScreen.id: (context) => ChatScreen(),
        },
      ),
    );
  }
}
