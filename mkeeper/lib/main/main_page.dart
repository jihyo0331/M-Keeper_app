import 'package:flutter/material.dart';
import 'package:mkeeper/map/map_page.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

@override
final FlutterTts flutterTts = FlutterTts();
Future<void> _speak(String text) async {
  await flutterTts.setLanguage("ko-KR");
  await flutterTts.setPitch(1.0);
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
          child: Center(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 300.0),
                ),
                Image.asset('assets/images/logo_mkeeper.png'),
                const Text(
                  "M-Keeper",
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 추가할 이미지
              ],
            ),
          ),
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

class _DirectionPageState extends State<DirectionPage>
    with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation1;
  late Animation<double> _opacityAnimation2;
  late Animation<double> _opacityAnimation3;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _speak(
        "지금은 조작 페이지 입니다. 해당 화면을 위로 밀면 길찾기, 아래로 밀면 이전 화면으로 돌아가실 수 있습니다. 설명을 다시 듣고 싶으시면 화면을 한번 터치해 주세요.");

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation1 =
        Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);
    _opacityAnimation2 =
        Tween<double>(begin: 0.8, end: 0.0).animate(_animationController);
    _opacityAnimation3 =
        Tween<double>(begin: 0.6, end: 0.0).animate(_animationController);

    _positionAnimation =
        Tween<Offset>(begin: Offset(0, 2), end: Offset(0, -1.0))
            .animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
        _animationController.forward();
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapPage()),
            );
          } else if (details.primaryVelocity! > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
            );
          }
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
                margin: const EdgeInsets.only(bottom: 100.0),
                child: Image.asset('assets/images/icon_Top_y.png'),
              ),
              SlideTransition(
                position: _positionAnimation,
                child: Column(
                  children: [
                    FadeTransition(
                      opacity: _opacityAnimation1,
                      child: Image.asset(
                          'assets/images/arrow.png'), // 첫 번째 화살표 이미지
                    ),
                    FadeTransition(
                      opacity: _opacityAnimation2,
                      child: Image.asset(
                          'assets/images/arrow.png'), // 두 번째 화살표 이미지
                    ),
                    FadeTransition(
                      opacity: _opacityAnimation3,
                      child: Image.asset(
                          'assets/images/arrow.png'), // 세 번째 화살표 이미지
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Image.asset('assets/images/icon_Left_m.png'),
                  ),
                  const Text(
                    "M-Keeper",
                    style: TextStyle(
                      fontSize: 50,
                      color: Color(0xF1EAF1),
                    ),
                  ),
                  Container(
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
