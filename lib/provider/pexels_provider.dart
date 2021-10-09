import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:wallappy/models/Global.dart';
import 'dart:convert';

import 'package:wallappy/models/photos.dart';

class PexelsProvider {
  TextEditingController _textcontroller = new TextEditingController();
  bool _search = false;
  int _page = 1;
  int _perPage = 15;
  List<Photo> _photos = [];
  bool _loading = false;
  String key = "563492ad6f917000010000013fbf5281da394befaa68fc6b9a568efa";
  String topic = "";
  final _topics = <String>[
    "Geography",
    "places",
    "Space",
    "Christmas",
    "anime",
    "animals",
    "minimalist",
    "tech",
    "builds",
    "art",
    "history",
    "nature",
    "colors"
  ];

  //stream //broadcast = todos pueden escuchar
  final _photosStreamController = StreamController<List<Photo>>.broadcast();

  //insertar informacion//agrega peliculas al stream
  Function(List<Photo>) get photosSink => _photosStreamController.sink.add;

  //funcion que retorna la info constante
  Stream<List<Photo>> get photosStrem => _photosStreamController.stream;

  void disposeStreams() {
    _photosStreamController.close();
  }

  getTopics() {
    return this._topics;
  }

  getCarga() {
    return this._loading;
  }

  setCarga(bool c) {
    this._loading = c;
  }

  setStateSearch() {
    this._search = !_search;
  }

  getStateSearch() {
    return this._search;
  }

  getPage() {
    return this._page;
  }

  setPage(int i) {
    this._page = i;
  }

  getTextController() {
    return this._textcontroller;
  }

  setTextController(String text) {
    this._textcontroller.text = text;
  }

  //initial wallpapers
  Future<bool> getInitialWallpaper() async {
    try {
      var random = new Random();
      int randomNumber = random.nextInt(this._topics.length);
      topic = this._topics[randomNumber];
      final respuesta = await http.get(
          Uri.parse(
              "https://api.pexels.com/v1/search?query=$topic&page=$_page&per_page=$_perPage"),
          headers: {"Authorization": key});

      final decoded = json.decode(respuesta.body);

      for (var i in decoded['photos']) {
        var a = Photo.fromJson(i);
        _photos.add(a);
      }
      _page++;
      Global.photos = _photos;
      // print(decoded['photos']);
      photosSink(_photos);
      return true;
    } catch (e) {
      return false;
    }
  }

  //update when list is on bottom
  Future<void> seartchNextPage() async {
    try {
      if (_loading) {
        // print("no peticion, estoy cargando");
        return;
      }
      _loading = true;

      // print("realizando peticion");
      // print("next page----------");

      final respuesta = await http.get(
          Uri.parse(
              "https://api.pexels.com/v1/search?query=$topic&page=$_page&per_page=$_perPage"),
          headers: {"Authorization": key});

      final decoded = json.decode(respuesta.body);

      for (var i in decoded['photos']) {
        var a = Photo.fromJson(i);
        _photos.add(a);
      }
      _page++;
      Global.photos = _photos;
      photosSink(_photos);
      // print("peticion terminada");

      _loading = false;
    } catch (e) {
      _loading = false;
    }
  }

  //para busquedas desde el buscador
  Future<void> searchFromTextField() async {
    try {
      if (_loading) {
        // print("no peticion, estoy cargando");
        return;
      }
      // print("estado controller: ${_textcontroller.text.isEmpty}");
      if (_textcontroller.text.isEmpty) {
        // print("busqueda nula");
      } else {
        _loading = true;
        _photos = [];
        Global.photos = [];
        photosSink(_photos);
        setPage(1);
        this.topic = _textcontroller.text;

        final respuesta = await http.get(
            Uri.parse(
                "https://api.pexels.com/v1/search?query=${_textcontroller.text}"),
            headers: {"Authorization": key});
        final decoded = json.decode(respuesta.body);

        for (var i in decoded['photos']) {
          var a = Photo.fromJson(i);
          _photos.add(a);
        }
        _page++;
        Global.photos = _photos;
        photosSink(_photos);
        _textcontroller.clear();

        // print("peticion terminada");

        _loading = false;
      }
    } catch (e) {
      _loading = false;
    }
  }

  //busqueda desde las categorias
  Future<void> searchFromCategory(String txt) async {
    try {
      if (_loading) {
        // print("no peticion, estoy cargando");
        return;
      }
      _loading = true;
      _photos = [];
      Global.photos = [];
      photosSink(_photos);
      setPage(1);
      this.topic = txt;
      // print("peticion desde categorias");
      // print("realizando peticion------");
      final respuesta = await http.get(
          Uri.parse("https://api.pexels.com/v1/search?query=$txt"),
          headers: {"Authorization": key});

      final decoded = json.decode(respuesta.body);

      for (var i in decoded['photos']) {
        var a = Photo.fromJson(i);
        _photos.add(a);
      }
      _page++;
      Global.photos = _photos;
      photosSink(_photos);
      _textcontroller.clear();

      print("peticion terminada");

      _loading = false;
    } catch (e) {
      _loading = false;
    }
  }
  //
}
