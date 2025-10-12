import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async{

WidgetsFlutterBinding.ensureInitialized();

//Took a list of available cameras
final cameras = await availableCameras();

//Choosing the first camera (which is usually the rear camera)
final firstCamera = cameras.first;

//Running the app
runApp(
  MaterialApp(
    theme:ThemeData.dark(), debugShowCheckedModeBanner: false, home: CameraScreen(camera: firstCamera),)
);
}


// Definition of the Main Widget (Camera Screen)
class CameraScreen extends StatefulWidget {

  final CameraDescription camera;

  const CameraScreen ({
    Key? key, 
    required this.camera,
  }): super(key: key);

@override
State<CameraScreen> createState() => CameraScreenState();
}


class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;


  @override
  void initState(){
    super.initState();
  

  _controller = CameraController(widget.camera, ResolutionPreset.medium);

  _initializeControllerFuture = _controller.initialize();

}

@override
void dispose(){
  _controller.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context){
return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}




