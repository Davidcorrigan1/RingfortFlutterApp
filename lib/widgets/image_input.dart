import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as pathHelp;
import 'package:path_provider/path_provider.dart' as systemPath;
import 'package:ringfort_app/screens/display_image_screen.dart';

class ImageInput extends StatefulWidget {
  final Function onSaveImage;
  final io.File passedImage;
  final String passedUrl;
  final String siteUID;

  // Class constructor taking in function to save image
  const ImageInput({
    @required this.onSaveImage,
    @required this.passedImage,
    @required this.passedUrl,
    @required this.siteUID,
  });

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  // Here the check to see if it's an update and we already have an image
  // if so we set the _siteImage to this value passed in.
  @override
  void initState() {
    if (widget.passedImage != null) {
      _siteImage = widget.passedImage;
    }
    if (widget.passedUrl != null) {
      _siteUrl = widget.passedUrl;
    }
    super.initState();
  }

  io.File _siteImage;
  String _siteUrl;

  Future<void> _getImage({bool camera}) async {
    // Set up an image picker object
    // and use it to take a picure on the camera
    final imagePicker = ImagePicker();
    XFile imageFile;
    if (camera) {
      imageFile = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 600,
      );
    } else {
      imageFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
      );
    }

    // Check if image taken or not
    if (imageFile == null) {
      return;
    }

    // store the image as a 'File' and trigger setState
    setState(() {
      _siteImage = io.File(imageFile.path);
    });
    // Get the location of the storage location for the application on IOS or Android
    final applicationDirectory =
        await systemPath.getApplicationDocumentsDirectory();
    // Get the default camera filename for the image using path package
    final fileName = pathHelp.basename(imageFile.path);
    // Copy the site image file to the application directory and save location.
    final savedSiteImage =
        await _siteImage.copy('${applicationDirectory.path}/${fileName}');
    print('The image was saved at ${savedSiteImage.path}');
    widget.onSaveImage(savedSiteImage);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          // only allow tap to display screen when editing site. Not on new site.
          onTap: () {
            if (widget.siteUID != null) {
              Navigator.of(context).pushNamed(DisplayImageScreen.routeName,
                  arguments: widget.siteUID);
            }
          },
          // This widget will trigger a transition animation when navigating
          // to the display image screen
          child: Hero(
            tag: 'hero-animation',
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
                // Deciding which image to display
                // Either the image taken by camera or
                // the image on the current Ringfort
                // else a No Image message.
                image: DecorationImage(
                    image: _siteImage != null
                        ? FileImage(_siteImage)
                        : _siteUrl != null
                            ? NetworkImage(_siteUrl)
                            : AssetImage(
                                'assets/images/no_image.jpg',
                              ),
                    alignment: Alignment.center,
                    fit: BoxFit.fill),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                width: 110,
                height: 50,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    // Shrinks the space around the button
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).backgroundColor),
                  ),
                  onPressed: () => _getImage(camera: true),
                  icon: Icon(Icons.camera),
                  label: Text(
                    'Take Image',
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                width: 110,
                height: 50,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    // Shrinks the space around the button
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).backgroundColor),
                  ),
                  onPressed: () => _getImage(camera: false),
                  icon: Icon(Icons.photo_album),
                  label: Text(
                    'Photos',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
