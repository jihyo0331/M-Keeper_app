import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Favorites(),
    );
  }
}

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  _FavoritesState createState() => _FavoritesState();
}

@override
final FlutterTts flutterTts = FlutterTts();
Future<void> _speak(String text) async {
  await flutterTts.setLanguage("ko-KR");
  await flutterTts.setPitch(1.0); // 음성 톤 설정
  await flutterTts.speak(text);
}

class _FavoritesState extends State<Favorites> {
  @override
  void initState() {
    super.initState();
    _speak(
        "이곳은 즐겨찾기 페이지 입니다. 화면을 한번 누르면 등록된 장소가 음성으로 안내됩니다. 화면을 길게 누른 후 등록된 장소중 하나를 말씀하시면 해당 목적지로 길안내가 시작됩니다. 설명을 다시 듣고 싶으시면 화면을 한번 누르세요.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            _speak(
                "화면을 한번 누르면 등록된 장소가 음성으로 안내됩니다. 화면을 길게 누른 후 등록된 장소중 하나를 말씀하시면 해당 목적지로 길안내가 시작됩니다. 설명을 다시 듣고 싶으시면 화면을 한번 누르세요.");
          },
        ),
      ),
    );
  }
}
