import 'package:flutter/material.dart';
import 'package:mkeeper/main/main_page.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Login Page",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget{
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: (){
            //Navigator.push(
              //context,
              //MaterialPageRoute(builder: (context) => const MainPage()),
            //);
          },
          child: const Text('로그인'),
        ),
      ),
    );
  }
}
