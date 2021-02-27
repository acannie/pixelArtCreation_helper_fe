import 'package:flutter/material.dart'; //google提供のUIデザイン
import 'package:http/http.dart' as http; //httpリクエスト用
import 'dart:async'; //非同期処理用
import 'dart:convert'; //httpレスポンスをJSON形式に変換用
import 'package:image_picker/image_picker.dart';
// import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_color/flutter_color.dart';
// import 'package:tinycolor/tinycolor.dart';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:image_whisperer/image_whisperer.dart';

class UploadImageDemo extends StatefulWidget {
  UploadImageDemo() : super();

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
  File _image;

  List<int> _selectedFile;
  Uint8List _bytesData;
  // GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  MyDesignData myDesignData;
  // Future<MyDesignData> futureMyDesignData;

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

    // final picker = ImagePicker();

    // Future getImage() async {
    //   final pickedFile = await picker.getImage(source: ImageSource.camera);

    //   setState(() {
    //     if (pickedFile != null) {
    //       _image = File(pickedFile.path);
    //     } else {
    //       print('No image selected.');
    //     }
    //   });
    // }

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      final file = files[0];
      final reader = new html.FileReader();

      reader.onLoadEnd.listen((e) {
        _handleResult(reader.result);
      });
      reader.readAsDataUrl(file);

      reader.onLoad.first.then((res) {
        final encoded = reader.result as String;
        final imageBase64 =
            encoded.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
        File _itemPicIoFile = File.fromRawPath(base64Decode(imageBase64));
        setState(() => {_image = _itemPicIoFile});
      });
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
    if (_image == null) {
      return Center(
        child: Container(
          child: Text(
            'No Image Selected',
          ),
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
          ),
        ),
      );
    } else {
      return Center(child: Image.file(_image));
    }
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

  Border markLineBorder(int i, int j, int n) {
    int halfwayPoint = (n / 2).round();
    return Border(
      bottom: (() {
        if (i + 1 == halfwayPoint) {
          return BorderSide(
            color: Colors.black38,
            width: 2,
          );
        } else {
          return BorderSide(
            color: Colors.black12,
            width: 1,
          );
        }
      })(),
      right: (() {
        if (j + 1 == halfwayPoint) {
          return BorderSide(
            color: Colors.black38,
            width: 2,
          );
        } else {
          return BorderSide(
            color: Colors.black12,
            width: 1,
          );
        }
      })(),
    );
  }

  Widget showMyDesign() {
    Size screenSize = MediaQuery.of(context).size;
    return FutureBuilder<MyDesignData>(
      future: retFutureMyDesignData(jsonString),
      builder: (BuildContext context, AsyncSnapshot<MyDesignData> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          myDesignData = snapshot.data;
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Container(
              child: Column(
                children: [
                  for (var i = 0;
                      i < myDesignData.myDesignColorTable.length;
                      i++)
                    Row(
                      children: [
                        for (var j = 0;
                            j < myDesignData.myDesignColorTable.length;
                            j++)
                          Expanded(
                            flex: 1,
                            child: Container(
                              // width: 10,
                              // height: 10,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(
                                  myDesignData.palette[
                                      myDesignData.myDesignColorTable[i][j]][0],
                                  myDesignData.palette[
                                      myDesignData.myDesignColorTable[i][j]][1],
                                  myDesignData.palette[
                                      myDesignData.myDesignColorTable[i][j]][2],
                                  1,
                                ),
                                border: markLineBorder(i, j,
                                    myDesignData.myDesignColorTable.length),
                              ),
                              child: AutoSizeText(
                                "${myDesignData.myDesignColorTable[i][j] + 1}",
                                maxLines: 1,
                                style: TextStyle(
                                    color: fontColor(
                                  Color.fromRGBO(
                                    myDesignData.palette[myDesignData
                                        .myDesignColorTable[i][j]][0],
                                    myDesignData.palette[myDesignData
                                        .myDesignColorTable[i][j]][1],
                                    myDesignData.palette[myDesignData
                                        .myDesignColorTable[i][j]][2],
                                    1,
                                  ),
                                )),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
            ),
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

  Color fontColor(Color backgroundColor) {
    int brightness = [
      backgroundColor.red,
      backgroundColor.green,
      backgroundColor.blue
    ].reduce(max);
    if (brightness > 180) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  Widget showColorPalette() {
    Size screenSize = MediaQuery.of(context).size;

    List<String> columnTitles = ["", "色相", "彩度", "明度"];
    return FutureBuilder<MyDesignData>(
      future: retFutureMyDesignData(jsonString),
      builder: (BuildContext context, AsyncSnapshot<MyDesignData> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          myDesignData = snapshot.data;
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300),
            child: Column(
              children: [
                // index
                Row(
                  children: columnTitles
                      .map(
                        (columnTitle) => Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: Colors.white,
                            ),
                            // width: screenSize.width * 0.1,
                            // height: screenSize.height * 0.025,
                            child: AutoSizeText(
                              columnTitle.toString(),
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                // information of each color
                for (var i = 0; i < myDesignData.myDesignPalette.length; i++)
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: Color.fromRGBO(
                              myDesignData.palette[i][0],
                              myDesignData.palette[i][1],
                              myDesignData.palette[i][2],
                              1,
                            ),
                          ),
                          // width: screenSize.width * 0.1,
                          // height: screenSize.height * 0.025,
                          child: AutoSizeText(
                            "${i + 1}",
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 20,
                              color: fontColor(
                                Color.fromRGBO(
                                  myDesignData.palette[i][0],
                                  myDesignData.palette[i][1],
                                  myDesignData.palette[i][2],
                                  1,
                                ),
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      for (var factor = 0;
                          factor < myDesignData.myDesignPalette[i].length;
                          factor++)
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: Colors.white,
                            ),
                            child: AutoSizeText(
                              "${myDesignData.myDesignPalette[i][factor]}",
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  )
              ],
            ),
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
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: appBarMain(),
      body: Center(
        child: Container(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  showImage(),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: OutlinedButton(
                      onPressed: startWebFilePicker,
                      child: Text('Choose Image'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: OutlinedButton(
                      onPressed: makeRequest,
                      child: Text('Upload Image'),
                    ),
                  ),
                  Wrap(
                    direction: Axis.horizontal,

                    // mainAxisSize: MainAxisSize.max,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: showMyDesign(),
                      ),
                      // ConstrainedBox(
                      //   constraints: BoxConstraints(maxWidth: 300),
                      //   child: SizedBox(
                      //     width: screenSize.width * 0.6,
                      //     child: ElevatedButton(
                      //       child: Text('Happy Flutter'),
                      //       onPressed: () {},
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: showColorPalette(),
                      ),
                    ],
                  ),
                  // SelectableText(
                  //   status,
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     color: Colors.green,
                  //     fontWeight: FontWeight.w500,
                  //     fontSize: 20.0,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
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
