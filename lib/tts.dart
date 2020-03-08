import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';



class TexttoSpeech extends StatefulWidget {
  @override
  _TexttoSpeechState createState() => _TexttoSpeechState();
}

enum TtsState { playing, stopped }

class _TexttoSpeechState extends State<TexttoSpeech> {
  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;

  String _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    _getLanguages();

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

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    if (languages != null) setState(() => languages);
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

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

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems() {
    var items = List<DropdownMenuItem<String>>();
    for (String type in languages) {
      items.add(DropdownMenuItem(value: type, child: Text(type)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language);
    });
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('Flutter TTS'),
            ),
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(children: [
                  _inputSection(),
                  _btnSection(),
                  languages != null ? _languageDropDownSection() : Text(""),
                  _buildSliders()
                ]))));
  }

  Widget _inputSection() => Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      child: TextField(
        onChanged: (String value) {
          _onChange(value);
        },
      ));

  Widget _btnSection() => Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildButtonColumn(
            Colors.green, Colors.greenAccent, Icons.play_arrow, 'PLAY', _speak),
        _buildButtonColumn(
            Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop)
      ]));

  Widget _languageDropDownSection() => Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: language,
          items: getLanguageDropDownMenuItems(),
          onChanged: changedLanguageDropDownItem,
        )
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

  Widget _buildSliders() {
    return Column(
      children: [_volume(), _pitch(), _rate()],
    );
  }

  Widget _volume() {
    return Slider(
        value: volume,
        onChanged: (newVolume) {
          setState(() => volume = newVolume);
        },
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: "Volume: $volume");
  }

  Widget _pitch() {
    return Slider(
      value: pitch,
      onChanged: (newPitch) {
        setState(() => pitch = newPitch);
      },
      min: 0.5,
      max: 2.0,
      divisions: 15,
      label: "Pitch: $pitch",
      activeColor: Colors.red,
    );
  }

  Widget _rate() {
    return Slider(
      value: rate,
      onChanged: (newRate) {
        setState(() => rate = newRate);
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
      label: "Rate: $rate",
      activeColor: Colors.green,
    );
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
// import 'package:translate/stt.dart';
// import 'package:translate/tts.dart';
// import 'package:translator/translator.dart';

// import 'package:speech_to_text/speech_to_text.dart' as stt;

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime translation',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: VoiceHome(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   HomePage({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   HomePageState createState() => HomePageState();
// }

// class HomePageState extends State<HomePage> {

//   File _pickedImage;
//   bool _isImageLoaded = false;
//   bool _isTextLoaded = false;
//   String _text = "";

//   Future imagePicker() async {

//     var tempStore = await ImagePicker.pickImage(source: ImageSource.gallery);

//     setState(() {
//       _pickedImage = tempStore;
//       _isImageLoaded = true;
//     });
//   }

//   Future readText() async {

//     FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(_pickedImage);
//     TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
//     VisionText readText = await recognizeText.processImage(ourImage);

//     translate(readText.text);
//   }

//   void translate(String readText) async {
//     GoogleTranslator translator = GoogleTranslator();

//     String input = readText;

//     translator.translate(input, to: 'ur')
//       .then((_translatedText) => {
//           setState(() {
//             _text = _translatedText;
//             _isTextLoaded = true;
//         })
//       });
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('sdfklj'),
//       ),
//       body: ListView(
//         children: <Widget>[
//           _isImageLoaded ? Center(
//             child: Container(
//               height: 200.0,
//               width: 200.0,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: FileImage(_pickedImage), fit: BoxFit.cover)
//               ),
//             ),
//           ) : Container(),
//           _isTextLoaded ? Center(
//             child: Text(_text)
//           ) : Container(),
//           SizedBox(height: 10.0,),
//           RaisedButton(
//             child: Text('Choose an image'),
//             onPressed: imagePicker,
//           ),
//           SizedBox(height: 10.0,),
//           Padding(
//             padding: const EdgeInsets.all(0.0),
//             child: ButtonTheme(
//                           child: FlatButton(
//                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 color: Colors.green,
//                 child: Padding(
//                   padding: const EdgeInsets.all(0.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       Text('Read'),
//                       Padding(
//                         padding: const EdgeInsets.all(0.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.blue,
//                             borderRadius: BorderRadius.circular(20)
//                           ),
//                           height: 50,
//                           width: 100,

//                         ),
//                       ),
//                     ]
//                   ),
//                 ),
//                 onPressed: readText,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: RawMaterialButton(
//               elevation: 0,
//               fillColor: Colors.blue,
//             onPressed: (){},
//     constraints: BoxConstraints(),
//     padding: EdgeInsets.all(0.0), // optional, in order to add additional space around text if needed
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: <Widget>[
//         Text('dsfjlk'),
//         Container(
//             height: 50,
//             width: 50,

//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))
//             ),
//         )
//       ]
//     )
// ),
//           )
//         ],

//       )
//     );
//   }
// }