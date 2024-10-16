import 'package:flutter/material.dart';
import 'package:mkeeper/main/main_page.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 변환을 위해 사용
import 'dart:async'; // 타이머를 위한 패키지

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
  Timer? _timer; // 타이머 변수 추가

  @override
  void initState() {
    super.initState();
    _speak(
        "이곳은 길찾기 페이지 입니다. 길찾기를 하려면 화면을 길게 누르시고, 안내음이 나오면 목적지를 말씀해 주세요. 설명을 다시 듣고 싶으시면 화면을 한번 터치해 주세요.");
    _fetchMapData(); // 초기 데이터를 받아오기
    _startFetchingData(); // 1초마다 데이터 받아오는 함수 호출
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머가 있으면 해제
    super.dispose();
  }

  // 1초마다 데이터를 받아오는 함수
  void _startFetchingData() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _fetchMapData(); // 1초마다 데이터 갱신
    });
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

  Future<void> _resetMapData() async {
    final url =
        Uri.parse('https://e9e2-219-241-108-31.ngrok-free.app/get_resetmap');
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
      _fetchMapData(); // 목적지 전송 후 다시 맵 데이터를 받아오기
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
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/map.png',
                  fit: BoxFit.contain, // 이미지를 화면에 맞추기
                ),
                if (map_2d != null) _buildPathOverlay(), // 경로가 있을 때 경로만 오버레이
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
            _resetMapData(); // 지도를 초기화
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

  // 경로를 오버레이로 표시하는 함수 (4인 값만 표시)
  Widget _buildPathOverlay() {
    final numRows = map_2d!.length;
    final numCols = map_2d![0].length;
    return Transform.translate(
      offset: const Offset(-12, -15), // x 방향으로 20, y 방향으로 50 이동
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 15, // 한 행에 15개의 셀
          mainAxisSpacing: 0, // 세로 간격을 0으로 설정
          crossAxisSpacing: 0, // 가로 간격을 0으로 설정
          childAspectRatio: 1.0, // 셀의 가로 세로 비율을 1:1로 설정 (정사각형)
        ),
        shrinkWrap: true, // 그리드의 크기를 콘텐츠에 맞춤
        itemCount: numRows * numCols,
        itemBuilder: (context, index) {
          final row = index ~/ numCols;
          final col = index % numCols;
          final value = map_2d![row][col];
          return value == 4
              ? Container(
                  width: 40, // 사각형의 너비
                  height: 40, // 사각형의 높이
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 47, 113, 255)
                        .withOpacity(1), // 경로 색상
                    shape: BoxShape.rectangle, // 사각형 모양
                  ),
                )
              : value == 2
                  ? Container(
                      width: 30, // 동그라미의 너비
                      height: 30, // 동그라미의 높이
                      decoration: BoxDecoration(
                        color: Colors.red, // 시작점의 색상
                        shape: BoxShape.circle, // 원형으로 설정
                      ),
                    )
                  : Container(); // 다른 값은 투명
        },
      ),
    );
  }
}
