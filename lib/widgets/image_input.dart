import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as pathHelp;
import 'package:path_provider/path_provider.dart' as systemPath;

class ImageInput extends StatefulWidget {
  final Function onSaveImage;

  // Class constructor taking in function to save image
  const ImageInput({
    @required this.onSaveImage,
  });

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  io.File _siteImage;

  Future<void> _takeCameraImage() async {
    // Set up an image picker object
    // and use it to take a picure on the camera
    final imagePicker = ImagePicker();
    final imageFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

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
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Colors.grey,
            ),
          ),
          child: _siteImage != null
              ? Image.file(
                  _siteImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              : Text(
                  'No Image',
                  textAlign: TextAlign.center,
                ),
          alignment: Alignment.center,
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 100,
            height: 100,
            child: ElevatedButton.icon(
              style: ButtonStyle(
                // Shrinks the space around the button
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: _takeCameraImage,
              icon: Icon(Icons.camera),
              label: Text(
                'Take Image',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
