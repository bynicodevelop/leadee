import 'dart:io';

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class GalleryScreen extends StatefulWidget {
  List<dynamic> images;

  GalleryScreen({
    Key key,
    this.images,
  }) : super(key: key);

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text('Gallery'),
      ),
      body: GridView.builder(
        itemCount: widget.images[0]['files'].length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (context, index) => InkWell(
          onTap: () => Navigator.pop(
              context, {'path': widget.images[0]['files'][index]}),
          child: Container(
            child: FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: FileImage(
                File(widget.images[0]['files'][index]),
              ),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
