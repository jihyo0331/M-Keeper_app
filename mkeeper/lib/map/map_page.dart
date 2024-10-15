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

  @override
  void initState() {
    super.initState();
    _speak(
        "이곳은 길찾기 페이지 입니다. 길찾기를 하려면 화면을 길게 누르시고, 안내음이 나오면 목적지를 말씀해 주세요. 설명을 다시 듣고 싶으시면 화면을 한번 터치해 주세요.");
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
    );
  }
}
