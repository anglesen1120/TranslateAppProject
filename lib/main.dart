
import 'dart:io';
import 'dart:ui';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:translate/stt.dart';
import 'package:translator/translator.dart';

void main() => runApp(VoiceHome());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VoiceHome();
  }
}

class VoiceHome extends StatefulWidget {
  @override
  _VoiceHomeState createState() => _VoiceHomeState();
}

enum TtsState { playing, stopped }

class _VoiceHomeState extends State<VoiceHome> {
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  File _pickedImage;
  bool _isImageLoaded = false;
  bool _isTextLoaded = false;
  String _text = "";
  String resultText = "";
  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 1;
  double pitch = 0.8;
  double rate = 0.5;
  var translatedText = TextEditingController();
  double customRowHeight = 70;
  String _fvalue = "en";
  String _tvalue = "en";
  String _newVoiceText;
double device_height = window.physicalSize.height / window.devicePixelRatio;
  double device_width = window.physicalSize.width / window.devicePixelRatio;
  
  TtsState ttsState = TtsState.stopped;

  Future imagePicker() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _pickedImage = tempStore;
      _isImageLoaded = true;
    });
  }

  Future readText() async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(_pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);
  
    myText.text = readText.text;
  }

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
    initTts();
  }

  var myText = TextEditingController();
  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() {
        resultText = speech;
        myText.text = speech;
      }),
    );

    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  }

  void translate(String readText) async {
    GoogleTranslator translator = GoogleTranslator();

    String input = readText;

    translator.translate(input, to: '$_tvalue').then((_translatedText) => {
          setState(() {
            _text = _translatedText;
            _isTextLoaded = true;
          })
        });
  }

  initTts() {
    flutterTts = FlutterTts();

    flutterTts.setStartHandler(() {
      setState(() {
        print("playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _speak() async {
    await flutterTts.setLanguage(_tvalue);
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    setState(() {
      _newVoiceText = _text;
    });
    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
   double device_size = device_height*device_width;
    return MaterialApp(
          home: Scaffold(
          appBar: AppBar(
            title: Text('Translate Easy'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
          ),
          body: Container(
            child: ListView(
              
              children: <Widget>[
                SizedBox(height: 20,),
                _isImageLoaded == true && _pickedImage != null
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: device_width / 12),
                    child: Container(
                        height: device_height / 3.2,
                        width: device_width / 0.2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Color(0xff087CD5), width: 2),
                          image: DecorationImage(
                              image: FileImage(_pickedImage), fit: BoxFit.fitWidth),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: FlatButton(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  color: Color(0xff087CD5),
                                  onPressed: () {
                                    setState(() {
                                      _isImageLoaded = false;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: device_width / 45),
                                    child: Text(
                                      'Close',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: device_size / 12800,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10))),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: FlatButton(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  color: Color(0xff087CD5),
                                  onPressed: () {
                                    readText();
                                      
                                    
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: device_width / 45),
                                    child: Text(
                                      'Read',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: device_size / 12800,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10))),
                                ),
                              ),
                            ])),
                  )
                : Container(),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: TextFormField(
                    controller: myText,
                    decoration: InputDecoration(
                      fillColor: Color(0xffF5EFEF),
                      filled: true,
                      border: InputBorder.none,
                      disabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                    ),
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Container(
                      color: Colors.green,
                      height: 100,
                      width: 400,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                height: customRowHeight,
                                width: 110,
                                color: Colors.green,
                                child: Stack(children: <Widget>[
                                  Container(
                                    child: DropdownButton(
                                      items: [
                                        DropdownMenuItem(
                                          value: "en",
                                          child: Text(
                                            "English",
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: "ur",
                                          child: Text(
                                            "Urdu",
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _fvalue = value;
                                        });
                                      },
                                      value: _fvalue,
                                    ),
                                    height: customRowHeight,
                                    width: 110,
                                    decoration: BoxDecoration(
                                        color: Colors.cyan,
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            topLeft: Radius.circular(10))),
                                  ),
                                  Positioned(
                                      left: 90,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.yellow,
                                            borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(10),
                                                topLeft: Radius.circular(10))),
                                        height: customRowHeight,
                                        width: 20,
                                      ))
                                ]),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 120,
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: InkWell(
                                  onTap: () => translate(myText.text),
                                  child: Container(
                                    child: Text('Translate'),
                                    height: customRowHeight,
                                    width: 80,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(10)),
                                  )),
                            ),
                          ),
                          Positioned(
                            left: 200,
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  height: customRowHeight,
                                  width: 110,
                                  color: Colors.green,
                                  child: Stack(children: <Widget>[
                                    Container(
                                      child: DropdownButton(
                                        items: [
                                          DropdownMenuItem(
                                            value: "en",
                                            child: Text(
                                              "English",
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: "ur",
                                            child: Text(
                                              "Urdu",
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _tvalue = value;
                                          });
                                        },
                                        value: _tvalue,
                                      ),
                                      height: customRowHeight,
                                      width: 110,
                                      decoration: BoxDecoration(
                                          color: Colors.cyan,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              topLeft: Radius.circular(10))),
                                    ),
                                    Positioned(
                                        left: 90,
                                        child: InkWell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.yellow,
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                    topLeft:
                                                        Radius.circular(10))),
                                            height: customRowHeight,
                                            width: 20,
                                          ),
                                        ))
                                  ]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                    Container(
                    decoration: BoxDecoration(
                      color:  Color(0xffF5EFEF),
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Padding(padding: EdgeInsets.symmetric(horizontal: 28, vertical: 50),
                    child: Text('$_text'))
                  ),
                  IconButton(icon: Icon(Icons.play_circle_outline), onPressed: ()=>_speak())
                  ],)
                ),
                SizedBox(height: 30,)
              ],
            ),
          ),
          bottomNavigationBar: CurvedNavigationBar(
            height: 60,
            backgroundColor: Colors.blueAccent,
            items: <Widget>[
              Icon(Icons.mic, size: 25),
              Icon(Icons.camera_alt, size: 25),
              Icon(Icons.security, size: 25),
              Icon(Icons.contact_phone, size: 25),
            ],
            onTap: (index) {
              if (index == 0) {
                if (_isAvailable && !_isListening) print('pressed');
                _speechRecognition
                    .listen(locale: "en_US")
                    .then((result) => print('$result'));
              } else if (index == 1) {
                imagePicker();
              } else {
                print('');
              }
              //Handle button tap
            },
          ),
        
      ),
    );
  }

  Widget _btnSection() => Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildButtonColumn(
            Colors.green, Colors.greenAccent, Icons.play_arrow, 'PLAY', _speak),
        _buildButtonColumn(
            Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop)
      ]));

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(icon),
              color: color,
              splashColor: splashColor,
              onPressed: () => func()),
          Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: color)))
        ]);
  }
}
