import 'package:flutter/material.dart'; //google提供のUIデザイン
import 'package:http/http.dart' as http; //httpリクエスト用
import 'dart:async'; //非同期処理用
import 'dart:convert'; //httpレスポンスをJSON形式に変換用
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:tinycolor/tinycolor.dart';

class UploadImageDemo extends StatefulWidget {
  UploadImageDemo() : super();

  final String title = "AC MyDesigner";

  @override
  UploadImageDemoState createState() => UploadImageDemoState();
}

class UploadImageDemoState extends State<UploadImageDemo> {
  Future<Image> futureImage;
  Image image;
  String status = '';
  String errMessage = 'Error Uploading Image';
  final String url = 'http://127.0.0.1:5000/';
  String jsonString;
  Size size;

  List<int> _selectedFile;
  Uint8List _bytesData;
  // GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  MyDesignData myDesignData;
  Future<MyDesignData> futureMyDesignData;

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  // chooseImage() async {
  //   setState(() {
  //     futureImage = ImagePicker().getImage(source: ImageSource.gallery).then(
  //         (file) => file
  //             .readAsBytes()
  //             .then((bytes) => Image.memory(bytes, fit: BoxFit.fill)));
  //   });
  //   setStatus('');
  // }

  // Future _getImageFromGallery() async {
  //   final _pickedFile =
  //       await ImagePicker().getImage(source: ImageSource.gallery);

  //   setState(() {
  //     if (_pickedFile != null) {
  //       _image = File(_pickedFile.path);
  //       futureImage = _pickedFile
  //           .readAsBytes()
  //           .then((bytes) => Image.memory(bytes, fit: BoxFit.fill));
  //     }
  //   });
  //   setStatus('');
  // }

  // startUpload() {
  //   setStatus('Uploading Image...');
  //   if (null == image) {
  //     setStatus(errMessage);
  //     return;
  //   }
  //   // upload();
  // }

  // upload() async {
  //   setStatus('yey');
  //   // var res2 = await sendFile(url, _image);
  //   // var res2 = await _request();
  //   // setState(() {
  //   //   status = res2.toString();
  //   // });
  //   await _request();
  // }

  startWebFilePicker() async {
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.draggable = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      final file = files[0];
      final reader = new html.FileReader();

      reader.onLoadEnd.listen((e) {
        _handleResult(reader.result);
      });
      reader.readAsDataUrl(file);
    });

    // final _pickedFile =
    //     await ImagePicker().getImage(source: ImageSource.gallery);

    // setState(() {
    //   if (_pickedFile != null) {
    //     _image = File(_pickedFile.path);
    //     futureImage = _pickedFile
    //         .readAsBytes()
    //         .then((bytes) => Image.memory(bytes, fit: BoxFit.fill));
    //   }
    // });

    setStatus("image picked");
  }

  void _handleResult(Object result) {
    setState(() {
      _bytesData = Base64Decoder().convert(result.toString().split(",").last);
      _selectedFile = _bytesData;
    });
  }

  makeRequest() async {
    var url = Uri.parse("http://localhost:5000/");
    var request = new http.MultipartRequest("POST", url);

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      _selectedFile,
      contentType: new MediaType('application', 'octet-stream'),
      filename: "file_up.jpg",
    ));

    await request.send().then((response) {
      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen((value) {
          jsonString = value;
          setState(() {
            myDesignData = MyDesignData.fromJson(json.decode(jsonString));
          });
        });
      }
    });
  }

  Future<MyDesignData> retFutureMyDesignData(String jsonString) async {
    return MyDesignData.fromJson(json.decode(jsonString));
  }

  Widget showImage() {
    return FutureBuilder<Image>(
      future: futureImage,
      builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          image = snapshot.data;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 200),
            child: image,
          );
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        }
        return Container(
          child: Text(
            'No Image Selected',
            textAlign: TextAlign.center,
          ),
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
          ),
        );
      },
    );
  }

  Widget appBarMain() {
    return AppBar(
      leading: Icon(Icons.menu),
      title: const Text('AC MyDesigner'),
      backgroundColor: Colors.orange,
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.face,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.email,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.favorite,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget showMyDesign() {
    return FutureBuilder<MyDesignData>(
      future: retFutureMyDesignData(jsonString),
      builder: (BuildContext context, AsyncSnapshot<MyDesignData> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          myDesignData = snapshot.data;
          return Column(
            children: [
              for (var i = 0; i < myDesignData.myDesignColorTable.length; i++)
                Row(
                  children: [
                    for (var j = 0;
                        j < myDesignData.myDesignColorTable.length;
                        j++)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Color.fromRGBO(
                            myDesignData.palette[
                                myDesignData.myDesignColorTable[i][j] - 1][0],
                            myDesignData.palette[
                                myDesignData.myDesignColorTable[i][j] - 1][1],
                            myDesignData.palette[
                                myDesignData.myDesignColorTable[i][j] - 1][2],
                            1,
                          ),
                        ),
                        width: 15,
                        height: 15,
                        child: Text(
                          "${myDesignData.myDesignColorTable[i][j]}",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                )
            ],
          );
        } else if (null != snapshot.error) {
          return Container(
            child: Text(
              'No Image Selected',
              textAlign: TextAlign.center,
            ),
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget showColorPalette() {
    return FutureBuilder<MyDesignData>(
      future: retFutureMyDesignData(jsonString),
      builder: (BuildContext context, AsyncSnapshot<MyDesignData> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          myDesignData = snapshot.data;
          return Column(
            children: [
              // index
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: Colors.white,
                    ),
                    width: 75,
                    height: 25,
                    child: Text(
                      "",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: Colors.white,
                    ),
                    width: 75,
                    height: 25,
                    child: Text(
                      "色相",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: Colors.white,
                    ),
                    width: 75,
                    height: 25,
                    child: Text(
                      "彩度",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: Colors.white,
                    ),
                    width: 75,
                    height: 25,
                    child: Text(
                      "明度",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              // information of each color
              for (var i = 0; i < myDesignData.myDesignPalette.length; i++)
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: Color.fromRGBO(
                          myDesignData.palette[i][0],
                          myDesignData.palette[i][1],
                          myDesignData.palette[i][2],
                          1,
                        ),
                      ),
                      width: 75,
                      height: 25,
                      child: Text(
                        "${i + 1}",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    for (var factor = 0;
                        factor < myDesignData.myDesignPalette[i].length;
                        factor++)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.white,
                        ),
                        width: 75,
                        height: 25,
                        child: Text(
                          "${myDesignData.myDesignPalette[i][factor]}",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                )
            ],
          );
        } else if (null != snapshot.error) {
          return Container(
            child: Text(
              'No Image Selected',
              textAlign: TextAlign.center,
            ),
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: appBarMain(),
      body: Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            showImage(),
            SizedBox(
              height: 20.0,
            ),
            OutlinedButton(
              onPressed: startWebFilePicker,
              child: Text('Choose Image'),
            ),
            SizedBox(
              height: 20.0,
            ),
            OutlinedButton(
              onPressed: makeRequest,
              child: Text('Upload Image'),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              children: <Widget>[
                // SizedBox(height: 20.0),
                showMyDesign(),
                SizedBox(width: 20.0),
                showColorPalette(),
              ],
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
  final List<List<int>> palette;
  final List<List<int>> myDesignColorTable;
  final List<List<int>> myDesignPalette;

  MyDesignData({
    this.palette,
    this.myDesignColorTable,
    this.myDesignPalette,
  });

  factory MyDesignData.fromJson(Map<String, dynamic> json) => MyDesignData(
        palette: List<List<int>>.from(json["palette"]
            .map((x) => List<int>.from(x.map((x) => x.toInt())))),
        myDesignColorTable: List<List<int>>.from(json["mydesign_color_table"]
            .map((x) => List<int>.from(x.map((x) => x.toInt())))),
        myDesignPalette: List<List<int>>.from(json["mydesign_palette"]
            .map((x) => List<int>.from(x.map((x) => x.toInt())))),
      );

  Map<String, dynamic> toJson() => {
        "palette": List<dynamic>.from(
            palette.map((x) => List<dynamic>.from(x.map((x) => x)))),
        "myDesignColorTable": List<dynamic>.from(
            myDesignColorTable.map((x) => List<dynamic>.from(x.map((x) => x)))),
        "myDesignPalette": List<dynamic>.from(
            myDesignPalette.map((x) => List<dynamic>.from(x.map((x) => x)))),
      };

  static String serialize(MyDesignData mat) {
    return jsonEncode(mat);
  }

  static MyDesignData deserialize(String jsonString) {
    Map mat = jsonDecode(jsonString);
    var result = MyDesignData.fromJson(mat);
    return result;
  }
}
