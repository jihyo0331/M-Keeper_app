import 'package:flutter/material.dart';
import 'package:mkeeper/map/map_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            // 화면을 탭했을 때 DirectionPage로 이동
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

class DirectionPage extends StatelessWidget {
  const DirectionPage({super.key});

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
            Navigator.pop(context);
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                child: Image.asset('assets/images/icon_Top_y.png'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 20.0),
                    child: Image.asset('assets/images/icon_Left_m.png'),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20.0),
                    child: Image.asset('assets/images/icon_Right_o.png'),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                child: Image.asset('assets/images/icon_Bottom_b.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Page'),
      ),
      body: const Center(
        child: Text('This is the Next Page!'),
      ),
    );
  }
}
