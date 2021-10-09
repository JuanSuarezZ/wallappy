import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:wallappy/models/Global.dart';
import 'package:wallappy/provider/safe_provider.dart';

class FullImage extends StatefulWidget {
  @override
  _FullImageState createState() => _FullImageState();
}

class _FullImageState extends State<FullImage> {
  PaletteGenerator? paletteGenerator;
  Color? accent = Colors.transparent;
  List<Color?>? colors;

  PageController pageController = PageController(initialPage: Global.index);

  final provider = new SafeProvider();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: FutureBuilder(
        future: _loadColorsPalett(Global.photos[Global.index].src!.tiny!),
        builder: (context, snapshot) {
          return Stack(
            children: [
              _createFullImageHero(size),
              _crearteMenuBotones(size, provider),
              _createAppBar(size),
            ],
          );
        },
      ),
    );
  }

  SafeArea _createAppBar(Size size) {
    return SafeArea(
      child: Container(
          padding: EdgeInsets.only(top: 4, left: 15, right: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_sharp,
                  color: accent,
                  size: 24,
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      //TODO: info de la imagen
                    },
                    icon: Icon(
                      Icons.info_outline,
                      color: accent,
                      size: 24,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      //TODO: marcar como fav
                    },
                    icon: Icon(
                      Icons.favorite_outline,
                      color: accent,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  FutureBuilder _crearteMenuBotones(Size size, SafeProvider provider) {
    return FutureBuilder(
      future: provider.iniciarStream(),
      builder: (context, snapshot) {
        return StreamBuilder(
          stream: provider.estadosStrem,
          builder: (context, AsyncSnapshot<Object?> snapshot) {
            // print("Stream builder state: ${snapshot.data.toString()}");
            if (snapshot.hasData) {
              if (snapshot.data == true) {
                return CircularCustomProgress();
              }
              return _botones(size);
            }
            return CircularCustomProgress();
          },
        );
      },
    );
  }

  Container _botones(Size size) {
    return Container(
      width: size.width,
      margin: EdgeInsets.only(bottom: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _setWallpaperButton(size),
          SizedBox(width: 10),
          _downloadButton(size),
        ],
      ),
    );
  }

  Container _setWallpaperButton(Size size) {
    return Container(
      width: size.width,
      margin: EdgeInsets.symmetric(horizontal: size.width / 8),
      child: ElevatedButton(
          child: Text("Aplicar", style: TextStyle(fontSize: 14)),
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            backgroundColor:
                MaterialStateProperty.all(Colors.black.withOpacity(0.01)),
          ),
          onPressed: () async {
            if (await provider.checkStoragePermissions()) {
              String url = Global.photos[Global.index].src!.portrait!;

              if (await provider.setW(url)) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Se ha cambiado tu wallpaper :)"),
                  duration: Duration(milliseconds: 1500),
                ));
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("No ha cambiado tu wallpaper :("),
                duration: Duration(milliseconds: 1500),
              ));
            }
          }),
    );
  }

  Container _downloadButton(Size size) {
    return Container(
      width: size.width,
      margin: EdgeInsets.symmetric(horizontal: size.width / 8),
      child: ElevatedButton(
          child: Text("Descargar", style: TextStyle(fontSize: 14)),
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            backgroundColor:
                MaterialStateProperty.all(Colors.black.withOpacity(0.01)),
          ),
          onPressed: () async {
            if (await provider.checkStoragePermissions()) {
              String url = Global.photos[Global.index].src!.portrait!;
              String name = Global.photos[Global.index].photographer!;
              if (await provider.downloadIMG(url, name)) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Imagen Descargada :)"),
                  duration: Duration(milliseconds: 1500),
                ));
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("No hemos podido descargar la imagen :("),
                duration: Duration(milliseconds: 1500),
              ));
            }
          }),
    );
  }

  Future<void> _loadColorsPalett(String url) async {
    paletteGenerator = await PaletteGenerator.fromImageProvider(
      NetworkImage(url),
    );
    colors = paletteGenerator!.colors.toList();

    if (paletteGenerator!.colors.length > 5) {
      colors = colors!.sublist(0, 5);
    }
    accent = colors![0];
    if (accent!.computeLuminance() > 0.5) {
      //for white img
      accent = Colors.black;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
          .copyWith(statusBarIconBrightness: Brightness.dark));
    } else {
      //for black img
      accent = Colors.white;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
          .copyWith(statusBarIconBrightness: Brightness.light));
    }
    // print("paleta cargada!");

    return;
  }

  Future<void> _updatePalettColors(String url) async {
    paletteGenerator = await PaletteGenerator.fromImageProvider(
      NetworkImage(url),
    );
    colors = paletteGenerator!.colors.toList();

    if (paletteGenerator!.colors.length > 5) {
      colors = colors!.sublist(0, 5);
    }
    accent = colors![0];
    if (accent!.computeLuminance() > 0.5) {
      //for white img
      accent = Colors.black;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
          .copyWith(statusBarIconBrightness: Brightness.dark));
    } else {
      //for black img
      accent = Colors.white;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
          .copyWith(statusBarIconBrightness: Brightness.light));
    }

    // print("paleta actualizada!");

    setState(() {});
    return;
  }

  Container _createFullImageHero(Size size) {
    return Container(
      child: PageView.builder(
        onPageChanged: (int p) {
          _updatePalettColors(Global.photos[Global.index].src!.tiny!);
        },
        controller: pageController,
        itemCount: Global.photos.length,
        itemBuilder: (context, index) {
          Global.index = index;
          return Hero(
            tag: '$index',
            child: Container(
              child: CachedNetworkImage(
                filterQuality: FilterQuality.low,
                imageUrl: Global.photos[index].src!.large2x!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.white24,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CircularCustomProgress extends StatelessWidget {
  const CircularCustomProgress({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      padding: EdgeInsets.only(bottom: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircularProgressIndicator(),
        ],
      ),
    ));
  }
}
