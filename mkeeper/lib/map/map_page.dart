import 'package:flutter/material.dart';
import 'package:mkeeper/main/main_page.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  _MapPageState createState() => _MapPageState();
}

final FlutterTts flutterTts = FlutterTts();
Future<void> _speak(String text) async {
  await flutterTts.setLanguage("ko-KR");
  await flutterTts.setPitch(1.0);
  await flutterTts.speak(text);
}

class _MapPageState extends State<MapPage> {
  SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<List<int>>? map_2d;
  Timer? _timer;
  Timer? _statusCheckTimer; // 추가된 타이머

  @override
  void initState() {
    super.initState();
    _speak(
        "이곳은 길찾기 페이지 입니다. 길찾기를 하려면 화면을 길게 누르시고, 안내음이 나오면 목적지를 말씀해 주세요. 설명을 다시 듣고 싶으시면 화면을 한번 터치해 주세요.");
    _fetchMapData();
    _startFetchingData();
    _startCheckingPauseStatus(); // 추가된 함수 호출
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusCheckTimer?.cancel(); // 타이머 해제
    super.dispose();
  }

  void _startFetchingData() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _fetchMapData();
    });
  }

  void _startCheckingPauseStatus() {
    _statusCheckTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await _checkPauseStatus(); // 1초마다 상태를 확인
    });
  }

  Future<void> _checkPauseStatus() async {
    final url = Uri.parse('https://mkeeper.ngrok.app/get_pause_status');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pauseFlag = data['flag'];
        final pause = data['pause'];
        final end = data['end'];

        print("Pause Status: flag=$pauseFlag, pause=$pause, end=$end");

        // 상황에 맞게 상태 처리 (예: 일시 정지 상태라면 안내 음성을 추가로 말하는 등)
      } else {
        print('Failed to load pause status.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchMapData() async {
    final url = Uri.parse('https://mkeeper.ngrok.app/get_array');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          map_2d = List<List<int>>.from(
            data['array'].map((row) => List<int>.from(row)),
          );
        });
      } else {
        print('Failed to load map data.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _resetMapData() async {
    final url = Uri.parse('https://mkeeper.ngrok.app/get_resetmap');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          map_2d = List<List<int>>.from(
            data['array'].map((row) => List<int>.from(row)),
          );
        });
      } else {
        print('Failed to load map data.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _playGuideVoice() async {
    await _audioPlayer.play(AssetSource('audio1.mp3'));
  }

  Future<void> _sendDestination(String destination) async {
    final url = Uri.parse('https://mkeeper.ngrok.app/api/destination');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'destination': destination,
      }),
    );
    _speak('$destination 까지 길안내를 시작합니다.');
    _fetchMapData();
  }

  void _startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (val) {
          setState(() {
            _recognizedText = val.recognizedWords;
            if (val.finalResult) {
              _sendDestination(_recognizedText);
            }
          });
        },
        localeId: 'ko_KR',
      );
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/map.png',
                  fit: BoxFit.contain,
                ),
                if (map_2d != null) _buildPathOverlay(),
              ],
            ),
          ),
          onTap: () {
            _speak(
                "이곳은 길찾기 페이지 입니다. 길찾기를 하려면 화면을 길게 누르시고, 안내음이 나오면 목적지를 말씀해 주세요. 설명을 다시 듣고 싶으시면 화면을 한번 터치해 주세요.");
          },
          onDoubleTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DirectionPage()),
            );
          },
          onLongPressStart: (_) {
            _resetMapData();
            _playGuideVoice();
            _startListening();
          },
          onLongPressEnd: (_) {
            _playGuideVoice();
            _stopListening();
          },
        ),
      ),
    );
  }

  Widget _buildPathOverlay() {
    final numRows = map_2d!.length;
    final numCols = map_2d![0].length;
    return Transform.translate(
      offset: const Offset(-12, -15),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 15,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          childAspectRatio: 1.0,
        ),
        shrinkWrap: true,
        itemCount: numRows * numCols,
        itemBuilder: (context, index) {
          final row = index ~/ numCols;
          final col = index % numCols;
          final value = map_2d![row][col];
          return value == 4
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        const Color.fromARGB(255, 47, 113, 255).withOpacity(1),
                    shape: BoxShape.rectangle,
                  ),
                )
              : value == 2
                  ? Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    )
                  : Container();
        },
      ),
    );
  }
}
