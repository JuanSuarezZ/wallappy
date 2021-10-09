import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SafeProvider {
  static const platform = const MethodChannel('setMyImagesAsWallpaper');
  // bool _cargando = false;

  //stream //broadcast = todos pueden escuchar
  final _estadosStreamController = StreamController<bool>.broadcast();

  //insertar informacion//agrega
  Function(bool) get estadosSink => _estadosStreamController.sink.add;

  //funcion que retorna la info constante
  Stream<bool> get estadosStrem => _estadosStreamController.stream;

  void disposeStreams() {
    _estadosStreamController.close();
  }

  iniciarStream() async {
    await Future.delayed(Duration(milliseconds: 500));
    await estadosSink(false);
  }

  Future<bool> setW(var getImage) async {
    await estadosSink(true);
    try {
      final res =
          await platform.invokeMethod("set_home_wallpaper", {'url': getImage});
      print("se ha cambiado el fondo");
      await estadosSink(false);
      return res;
    } on PlatformException catch (e) {
      print("No se ha cambiado el fondo");
      print("Error: $e");
      await estadosSink(false);
      return false;
    }
  }

  Future<bool> downloadIMG(var getImage, String nombre) async {
    await estadosSink(true);
    try {
      await Future.delayed(Duration(milliseconds: 1500));
      await platform.invokeMethod(
          "download_image_dm", {'link': getImage, 'filename': nombre});
      print("Se ha descargado la imagen");
      await estadosSink(false);
      return true;
    } on PlatformException catch (e) {
      print("No ha descargado la imagen");
      print("error: $e");
    }
    await estadosSink(false);
    return false;
  }

  Future<bool> checkStoragePermissions() async {
    if (await Permission.storage.status.isDenied) {
      print("No tenemos storage permisos");
      await Permission.storage.request();
      return false;
    }
    print("Si tenemos storage permisos");
    return true;
  }
}
