import 'package:firebase_app_sec2/auth_service.dart';
import 'package:firebase_app_sec2/firebase_options.dart';
import 'package:firebase_app_sec2/notes_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthenticationWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const MyHomePage(
              title: "Log In",
            );
          }
          return NotesScreen(user: user);
        }
        
        return const CircularProgressIndicator(); // Handle loading state
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _emailc = TextEditingController();
  final TextEditingController _passc = TextEditingController();
  final AuthService authService = AuthService();
  User? user;
  signUp() async {
    user = await authService.signUp(
      _emailc.text,
      _passc.text,
    );
  }

  signIn() async {
    user = await authService.signIn(
      _emailc.text,
      _passc.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: "Email"),
                controller: _emailc,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: "Password"),
                controller: _passc,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  signUp();
                  if (user != null) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotesScreen(user: user!),
                    ));
                  }
                },
                child: const Text("Sign Up"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  signIn();
                  if (user != null) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotesScreen(user: user!),
                    ));
                  }
                },
                child: const Text("Sign In"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
