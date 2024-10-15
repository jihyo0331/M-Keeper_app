import 'package:flutter/material.dart';
import 'package:mkeeper/main/main_page.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 변환을 위해 사용

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  _MapPageState createState() => _MapPageState();
}

final FlutterTts flutterTts = FlutterTts();
Future<void> _speak(String text) async {
  await flutterTts.setLanguage("ko-KR");
  await flutterTts.setPitch(1.0); // 음성 톤 설정
  await flutterTts.speak(text);
}

class _MapPageState extends State<MapPage> {
  SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<List<int>>? map_2d; // 서버에서 받을 2차원 배열

  @override
  void initState() {
    super.initState();
    _speak(
        "이곳은 길찾기 페이지 입니다. 길찾기를 하려면 화면을 길게 누르시고, 안내음이 나오면 목적지를 말씀해 주세요. 설명을 다시 듣고 싶으시면 화면을 한번 터치해 주세요.");
    _fetchMapData(); // 2차원 배열 데이터를 받아오는 함수 호출
  }

  // 서버로부터 2차원 배열 데이터를 받아오는 함수
  Future<void> _fetchMapData() async {
    final url = Uri.parse(
        'https://e9e2-219-241-108-31.ngrok-free.app/get_array'); // 서버 URL
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
    // 로컬에 있는 MP3 파일 경로를 지정하여 재생
    await _audioPlayer.play(AssetSource('audio1.mp3'));
  }

  // 목적지를 서버로 전송하는 함수
  Future<void> _sendDestination(String destination) async {
    final url = Uri.parse(
        'https://e9e2-219-241-108-31.ngrok-free.app/api/destination'); // 서버 URL
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json', // JSON 데이터임을 명시
      },
      body: jsonEncode({
        'destination': destination,
      }),
    );

    if (response.statusCode == 200) {
      // 서버 응답이 성공적인 경우
      print('Destination sent successfully');
    } else {
      // 서버 응답이 실패한 경우
      print('Failed to send destination: ${response.statusCode}');
    }
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
              _speak('인식된 목적지: $_recognizedText 까지 길안내를 시작합니다.');
              _sendDestination(_recognizedText); // 인식된 목적지를 서버로 전송
            }
          });
        },
        localeId: 'ko_KR', // 한국어 인식
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
          child: Image.asset(
            'assets/images/map.png',
            fit: BoxFit.cover, // 이미지를 화면에 꽉 차게 맞춤
            width: double.infinity, // 화면 너비에 맞게 조정
            height: double.infinity, // 화면 높이에 맞게 조정
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
            _playGuideVoice();
            _startListening(); // 음성 인식 시작
          },
          onLongPressEnd: (_) {
            _playGuideVoice();
            _stopListening(); // 손을 떼면 음성 인식 중지
          },
        ),
      ),
      bottomNavigationBar: map_2d == null
          ? CircularProgressIndicator() // 데이터 로딩 중일 때 보여줄 위젯
          : Column(
              children: map_2d!.map((row) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((value) {
                    return Container(
                      margin: EdgeInsets.all(4.0),
                      width: 30,
                      height: 30,
                      color: value == 1 ? Colors.blue : Colors.grey,
                      child: Center(child: Text('$value')),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
    );
  }
}
