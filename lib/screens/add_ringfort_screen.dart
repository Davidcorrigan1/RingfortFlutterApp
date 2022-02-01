import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/historic_site.dart';
import '../providers/historic_sites_provider.dart';

import '../widgets/image_input.dart';

class AddRingfortScreen extends StatefulWidget {
  // Screen Route name to add to route table
  static const routeName = '/add-ringfort';

  @override
  State<AddRingfortScreen> createState() => _AddRingfortScreenState();
}

class _AddRingfortScreenState extends State<AddRingfortScreen> {
  // The taken site image
  io.File _siteImage;
  // Focus node for the description field.
  final _descFocusNode = FocusNode();
  // Create a global key so we can interact with the widget from code
  final _form = GlobalKey<FormState>();

  // Methd to save the taken image from image_input widget to this class
  void _saveImage(io.File takenImage) {
    _siteImage = takenImage;
  }

  // Create an initialize HistoricSite object
  var _newSite = HistoricSite(
    uid: null,
    siteName: '',
    siteDesc: '',
    latitude: 0.0,
    longitude: 0.0,
    address: '',
    image: null,
  );

  @override
  void dispose() {
    _descFocusNode.dispose();
    super.dispose();
  }

  // Function will generate an error dialogue
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error has occurred'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialogue
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Function which will be call to submit form if there are
  // no validation errors found.
  void _saveForm() {
    final noErrors = _form.currentState.validate();

    if (_siteImage == null) {
      _showErrorDialog('You need to take an Image');
      return;
    } else {
      _newSite.image = _siteImage;
    }

    if (!noErrors) {
      return;
    }
    _form.currentState.save();

    Provider.of<HistoricSitesProvider>(context, listen: false)
        .addSite(_newSite);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Ringfort'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          )
        ],
      ),
      body: Column(
        // This is main alignment top to botton and will force the
        // button to the botton of the screen. The cross alignment will
        // stretch it across the whole screen
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Expanded will take all the space except for the button
          Expanded(
            // This Form will have a nested column scrollable if necessary
            child: Form(
              key: _form, // linking our form to the GlobalKey
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      //--------------------------
                      // The Name form field
                      //--------------------------
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Name',
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_descFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter a name for the Ringfort';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _newSite.siteName = newValue;
                        },
                      ),
                      //---------------------------
                      // The Description form field
                      //---------------------------
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.next,
                        focusNode: _descFocusNode,
                        // validation to happen
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter a description of the Ringfort';
                          }
                          if (value.length < 20) {
                            return 'You must enter a description of at least 20 characters';
                          }
                          return null;
                        },
                        // what happens on saving the form
                        onSaved: (newValue) {
                          _newSite.siteDesc = newValue;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // This is the widget which controlls taking the image
                      ImageInput(onSaveImage: _saveImage),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ButtonStyle(
              // Shrinks the space around the button
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: _saveForm,
            icon: Icon(Icons.save),
            label: Text(
              'Add Ringfort',
            ),
          ),
        ],
      ),
    );
  }
}
