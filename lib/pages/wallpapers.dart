import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:wallappy/models/Global.dart';
import 'package:wallappy/models/photos.dart';

import 'package:wallappy/provider/pexels_provider.dart';

class Wallpaper extends StatefulWidget {
  @override
  _WallpaperState createState() => _WallpaperState();
}

class _WallpaperState extends State<Wallpaper> {
  late FocusNode myFocusNode;
  final provider = new PexelsProvider();

  @override
  void initState() {
    super.initState();
    provider.getInitialWallpaper();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _controller = new ScrollController();
    final size = MediaQuery.of(context).size;

    _controller.addListener(() {
      if (_controller.position.atEdge) {
        if (_controller.position.pixels >
            _controller.position.maxScrollExtent - 1000) {
          // You're at the top.
          print("List is on bottom");
          provider.seartchNextPage();
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.black26,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(top: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _crearAppbar(),
              _crearCategorias(),
              _crearStreamListPhotos(size, _controller),
            ],
          ),
        ),
      ),
    );
  }

  _crearAppbar() {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 10, right: 10),
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Color(0xffdadadb)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(
              'Wallpapers',
              style: TextStyle(
                fontFamily: "roboto",
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(child: Container()),
          _TextBox(
              focus: myFocusNode,
              estado: provider.getStateSearch(),
              controller: provider.getTextController()),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                // FocusScope.of(context).requestFocus(myFocusNode);
                provider.setStateSearch();
                provider.searchFromTextField();
                FocusScope.of(context).unfocus();
              });
            },
          ),
          InkWell(
            onTap: () {},
            child: Container(
                margin: EdgeInsets.only(right: 10),
                child: Icon(Icons.more_vert)),
          ),
        ],
      ),
    );
  }

  _crearCategorias() {
    return Container(
      height: 40,
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      width: double.infinity,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: provider.getTopics().length,
        itemBuilder: (context, index) {
          return InkWell(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              child: Chip(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        topLeft: Radius.circular(12))),
                backgroundColor: Color(0xffdadadb),
                label: Text('${provider.getTopics()[index]}'),
              ),
            ),
            onTap: () {
              provider.searchFromCategory(provider.getTopics()[index]);
            },
          );
        },
      ),
    );
  }

  _crearStreamListPhotos(Size size, ScrollController _controller) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: StreamBuilder(
          stream: provider.photosStrem,
          builder: (context, AsyncSnapshot<List<Photo>> snapshot) {
            if (snapshot.hasData) {
              // print("estado de la busqueda: ${provider.getStateSearch()}");
              // print("estado de la carga: ${provider.getCarga()}");
              if (provider.getCarga()) {
                return Center(child: CircularProgressIndicator());
              } else {
                final list = snapshot.data;
                return GridView.builder(
                  controller: _controller,
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.6,
                    crossAxisCount: 2,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                  ),
                  itemCount: list!.length,
                  itemBuilder: (context, i) {
                    return _PinterestItem(list[i], i);
                  },
                );
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class _PinterestItem extends StatelessWidget {
  final Photo photo;
  final int i;
  _PinterestItem(this.photo, this.i);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Global.index = i;
            Navigator.pushNamed(context, 'FullImage', arguments: i);
            // Navigator.pushNamed(context, 'testpage');
          },
          child: Hero(
            tag: '$i',
            child: Container(
              margin: EdgeInsets.only(top: 4, right: 2, left: 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _createImage(),
              ),
            ),
          ),
        ),
        // Align(
        //     alignment: Alignment.bottomRight,
        //     child: Container(
        //       margin: EdgeInsets.only(right: 10, bottom: 5),
        //       child: Icon(
        //         Icons.info,
        //         color: Colors.grey[400],
        //       ),
        //     ))
      ],
    );
  }

  _createImage() {
    try {
      return CachedNetworkImage(
        height: 400,
        width: 200,
        filterQuality: FilterQuality.low,
        imageUrl: photo.src!.large!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 500,
          color: Colors.white24,
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    } catch (e) {
      return Container(
        height: 50,
        width: 50,
        color: Colors.green,
      );
    }
  }
}

class _TextBox extends StatelessWidget {
  final bool? estado;
  final TextEditingController? controller;
  final FocusNode? focus;

  const _TextBox(
      {@required this.estado, @required this.controller, @required this.focus});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: AnimatedContainer(
          duration: Duration(milliseconds: 800),
          width: estado! ? size.width * 0.45 : 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black12,
            ),
            height: 40,
            child: TextField(
              focusNode: focus,
              controller: controller,
              keyboardType: TextInputType.text,
              cursorColor: Colors.black,
              decoration: new InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: "Busca algun tema..."),
            ),
          )),
    );
  }
}
