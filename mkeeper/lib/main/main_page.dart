import 'package:flutter/material.dart';
import 'package:mkeeper/map/map_page.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

final FlutterTts flutterTts = FlutterTts();
Future<void> _speak(String text) async {
  await flutterTts.setLanguage("ko-KR");
  await flutterTts.setPitch(1.0); // 음성 톤 설정
  await flutterTts.speak(text);
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    _speak(
        "안녕하세요 시각장애인 이동권 보장을 위한 적정기술 시스템 앰키퍼 입니다. 화면을 두번 터치하면 조작 화면으로 넘어가실 수 있습니다. 설명을 다시 듣고 싶으시면 화면을 한번 터치해 주세요.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            _speak(
                "화면을 두번 터치하면 조작 화면으로 넘어가실 수 있습니다. 설명을 다시 듣고 싶으시면 화면을 한번 터치해 주세요.");
          },
          onDoubleTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DirectionPage()),
            );
          },
          child: Image.asset('assets/images/logo_mkeeper.png'),
        ),
      ),
    );
  }
}

class DirectionPage extends StatefulWidget {
  const DirectionPage({super.key});

  @override
  _DirectionPageState createState() => _DirectionPageState();
}

class _DirectionPageState extends State<DirectionPage> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speak(
        "지금은 조작 페이지 입니다. 해당 화면을 위로 밀면 길찾기, 아래로 밀면 이전 화면으로 돌아가실 수 있습니다. 설명을 다시 듣고 싶으시면 화면을 한번 터치해 주세요.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            // 위로 스와이프했을 때 (primaryVelocity가 음수일 때)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapPage()),
            );
          } else if (details.primaryVelocity! > 0) {
            // 아래로 스와이프했을 때 (primaryVelocity가 양수일 때)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
            );
          } //뒤로가기
        },
        onTap: () {
          _speak(
              "지금은 조작 페이지 입니다. 해당 페이지에서 화면을 위로 밀면 길찾기, 아래로 밀면 이전 화면으로 돌아가실 수 있습니다. 설명을 다시 듣고 싶으시면 화면을 한번 터치해 주세요.");
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 200.0),
                child: Image.asset('assets/images/icon_Top_y.png'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    // margin: const EdgeInsets.only(right: 100.0),
                    child: Image.asset('assets/images/icon_Left_m.png'),
                  ),
                  Container(
                    child: const Text(
                      "M-Keeper",
                      style: TextStyle(
                        fontSize: 50,
                        color: Color(0xF1EAF1),
                      ),
                    ),
                  ),
                  Container(
                    // margin: const EdgeInsets.only(left: 100.0),
                    child: Image.asset('assets/images/icon_Right_o.png'),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 200.0),
                child: Image.asset('assets/images/icon_Bottom_b.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
