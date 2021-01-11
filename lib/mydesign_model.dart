import 'package:flutter/material.dart'; //google提供のUIデザイン
import 'package:http/http.dart' as http; //httpリクエスト用
import 'dart:async'; //非同期処理用
import 'dart:convert'; //httpレスポンスをJSON形式に変換用
import 'package:image_picker/image_picker.dart';

class UploadImageDemo extends StatefulWidget {
  UploadImageDemo() : super();

  final String title = "Upload Image Demo";

  @override
  UploadImageDemoState createState() => UploadImageDemoState();
}

class UploadImageDemoState extends State<UploadImageDemo> {
  //
  static final String uploadEndPoint = 'http://127.0.0.1:5001/';
  Future<Image> future;
  Image image;
  String status = '';
  String errMessage = 'Error Uploading Image';

  chooseImage() {
    setState(() {
      future = ImagePicker().getImage(source: ImageSource.gallery).then(
          (file) => file
              .readAsBytes()
              .then((bytes) => Image.memory(bytes, fit: BoxFit.fill)));
    });
    setStatus('');
  }

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  startUpload() {
    setStatus('Uploading Image...');
    if (null == image) {
      setStatus(errMessage);
      return;
    }
    upload();
  }

  upload() async {
    // TODO
  }

  Widget showImage() {
    return FutureBuilder<Image>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          image = snapshot.data;
          return Flexible(child: snapshot.data);
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text(
            'No Image Selected',
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OutlineButton(
              onPressed: chooseImage,
              child: Text('Choose Image'),
            ),
            SizedBox(
              height: 20.0,
            ),
            showImage(),
            SizedBox(
              height: 20.0,
            ),
            OutlineButton(
              onPressed: startUpload,
              child: Text('Upload Image'),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
                fontSize: 20.0,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}

class MyDesignData {
  final List<List<int>> colorPalette;
  final List<List<int>> colorList;

  MyDesignData({
    this.colorPalette,
    this.colorList,
  });
  factory MyDesignData.fromJson(Map<String, dynamic> json) {
    return MyDesignData(
      colorList: (json['color_list'] as List)
          .map((items) => (items.map((item) => List<int>.from(item)).toList())),
      colorPalette: (json['color_palette'] as List)
          .map((items) => (items.map((item) => List<int>.from(item)).toList())),
    );
  }
}
