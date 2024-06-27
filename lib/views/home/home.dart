import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/components/text.dart'; // Ensure this exists and is correctly implemented
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();

  String translatedText = "Translation";
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordspoken = "";
  double _confidenceLevel = 0;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordspoken = result.recognizedWords;
      _controller.text = _wordspoken;
      _confidenceLevel = result.confidence;
      _translateText(_wordspoken);
    });
  }

  // text tospeech

  Future<void> textTospeech(String text) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  Future<void> _translateText(String text) async {
    const apiKey = '';
    const to = 'es';
    final url = Uri.parse(
      'https://translation.googleapis.com/language/translate/v2?q=$text&target=$to&key=$apiKey',
    );

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final translations = body['data']['translations'] as List;
        final translation = translations.first['translatedText'];

        setState(() {
          translatedText = translation;
        });
      } else {
        setState(() {
          translatedText = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        translatedText = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: customText('Translation', FontWeight.normal, 18, Colors.white),
        backgroundColor: Colors.black87,
        leading: const Icon(
          Icons.translate,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(206, 17, 17, 17),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 20),
                child: ListView(
                  children: [
                    customText(
                        'English (US)', FontWeight.w400, 18, Colors.white),

                    const SizedBox(height: 10),
                    // Text(_wordspoken, style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 10),
                    customText(
                      _speechToText.isListening
                          ? "Listening..."
                          : _speechEnabled
                              ? "Tap the microphone to start speacking..."
                              : "Speech not available",
                      FontWeight.w400,
                      15,
                      _speechToText.isListening ? Colors.green : Colors.white,
                    ),
                    TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 100,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      cursorColor: Colors.white,
                      onChanged: (text) => _translateText(text),
                      decoration: InputDecoration(
                        suffix: IconButton(
                            onPressed: () {
                              textTospeech(_controller.text);
                            },
                            icon: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            )),
                        hintText: 'Enter Text',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Colors.white.withOpacity(.5),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: .8),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: .8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    customText(
                        translatedText, FontWeight.bold, 16, Colors.blue),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                side: BorderSide(
                  color: Colors.white.withOpacity(.4),
                ),
                minimumSize: const Size(70, 70)),
            onPressed:
                _speechToText.isListening ? _stopListening : _startListening,
            label: customText('Tap To Speak', FontWeight.bold, 16,
                _speechToText.isNotListening ? Colors.white : Colors.green),
            icon: Icon(
              _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
              color: _speechToText.isNotListening ? Colors.white : Colors.green,
            ),
          ),
          const SizedBox(
            height: 13,
          ),
        ],
      ),
    );
  }
}
