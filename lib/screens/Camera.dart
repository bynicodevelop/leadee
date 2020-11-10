import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leadeetuto/screens/Gallery.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:storage_path/storage_path.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  CameraScreen({
    Key key,
    this.cameras,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  Future<void> _initializeContollerFuture;
  CameraController _controller;
  int _selectedCameraIndex = -1;
  String _lastImage = null;
  bool _loading = false;

  Future<void> initCamera(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    if (_controller.value.hasError) {
      print('Camera Error ${_controller.value.errorDescription}');
    }

    _initializeContollerFuture = _controller.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _cameraToggle() async {
    if (_lastImage != null) {
      _lastImage = null;
    }

    setState(() {
      _selectedCameraIndex =
          _selectedCameraIndex > -1 ? _selectedCameraIndex == 0 ? 1 : 0 : 0;
    });

    await initCamera(widget.cameras[_selectedCameraIndex]);
  }

  Future<void> _takePhoto() async {
    try {
      await _initializeContollerFuture;

      String pathImage = join((await getTemporaryDirectory()).path,
          '${DateTime.now().millisecondsSinceEpoch}.jpg');

      await _controller.takePicture(pathImage);

      setState(() => _lastImage = pathImage);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    _cameraToggle();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: _lastImage != null
              ? FlatButton(
                  onPressed: () => setState(() => _lastImage = null),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        body: FutureBuilder(
          future: _initializeContollerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  Transform.scale(
                    scale: _controller.value.aspectRatio / size.aspectRatio,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: _lastImage != null
                            ? Image(
                                image: FileImage(
                                  File(_lastImage),
                                ),
                              )
                            : CameraPreview(_controller),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _lastImage == null,
                    child: Positioned(
                      left: 50.0,
                      bottom: 50.0,
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 3.0,
                            color: Colors.white,
                          ),
                        ),
                        child: FutureBuilder(
                          future: StoragePath.imagesPath,
                          builder: (context, snapshot) {
                            List<dynamic> images = [];

                            Widget defaultWidget = Icon(
                              Icons.photo_size_select_actual,
                              color: Colors.white,
                            );

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              images = jsonDecode(snapshot.data);

                              if (images.length > 0 &&
                                  images[0]['files'].length > 0) {
                                defaultWidget = CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: FileImage(
                                    File(images[0]['files'][0]),
                                  ),
                                );
                              }
                            }

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                customBorder: CircleBorder(),
                                onTap: () async {
                                  dynamic data = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GalleryScreen(
                                        images: images,
                                      ),
                                    ),
                                  );

                                  setState(() => _lastImage = data['path']);
                                },
                                child: defaultWidget,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _lastImage == null,
                    child: Positioned(
                      right: 50.0,
                      bottom: 50.0,
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 3.0,
                            color: Colors.white,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: CircleBorder(),
                            onTap: _cameraToggle,
                            child: Icon(
                              Icons.loop,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _loading == true,
                    child: Positioned(
                      bottom: 30.0,
                      left: 20.0,
                      child: Row(
                        children: [
                          SpinKitThreeBounce(
                            color: Colors.white,
                            size: 12.0,
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            'Publishing...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              );
            }

            return Center(
              child: Text('Loading'),
            );
          },
        ),
        floatingActionButton: _lastImage == null
            ? Container(
                margin: EdgeInsets.only(
                  bottom: 30.0,
                ),
                height: 80.0,
                width: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 3.0,
                    color: Colors.white,
                  ),
                ),
                child: FittedBox(
                  child: InkWell(
                    onLongPress: () => print('take video'),
                    child: FloatingActionButton(
                      onPressed: _takePhoto,
                      backgroundColor: Colors.transparent,
                      elevation: 0.0,
                    ),
                  ),
                ),
              )
            : FloatingActionButton.extended(
                elevation: 0.0,
                shape: RoundedRectangleBorder(),
                backgroundColor: Colors.white.withOpacity(0.6),
                onPressed: () async {
                  setState(() => _loading = !_loading);

                  await Future.delayed(Duration(seconds: 3));

                  setState(() => _lastImage = null);
                  setState(() => _loading = !_loading);
                },
                label: Text(
                  'Publish',
                  style: TextStyle(color: Colors.black),
                ),
                icon: Icon(
                  Icons.send,
                  color: Colors.black,
                ),
              ),
        floatingActionButtonLocation: _lastImage == null
            ? FloatingActionButtonLocation.centerFloat
            : FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
