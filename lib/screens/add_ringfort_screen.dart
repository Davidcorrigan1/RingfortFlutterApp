import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/historic_site.dart';
import '../providers/historic_sites_provider.dart';

import '../widgets/image_input.dart';
import '../widgets/location_input.dart';

class AddRingfortScreen extends StatefulWidget {
  // Screen Route name to add to route table
  static const routeName = '/add-ringfort';

  @override
  State<AddRingfortScreen> createState() => _AddRingfortScreenState();
}

class _AddRingfortScreenState extends State<AddRingfortScreen> {
  // The taken site image
  io.File _siteImage;
  // Focus node for the description and access fields.
  final _descFocusNode = FocusNode();
  final _accessFocusNode = FocusNode();
  // Create a global key so we can interact with the widget from code
  final _form = GlobalKey<FormState>();
  // Location picked  by the user
  LatLng _pickedLocation;

  // Method to save the taken image from image_input widget to this class
  void _saveImage(io.File takenImage) {
    _siteImage = takenImage;
  }

  // A method to pass into 'location_input' widget to save the location lat,lng
  void _selectSiteLocation(double latitude, double longitude) {
    _pickedLocation = LatLng(latitude, longitude);
  }

  // Create an initialize HistoricSite object
  var _newSite = HistoricSite(
    uid: null,
    siteName: '',
    siteDesc: '',
    siteAccess: '',
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

    // Set the new site with the image taken
    if (_siteImage == null) {
      _showErrorDialog('You need to take an Image');
      return;
    } else {
      _newSite.image = _siteImage;
    }

    // Set the new site with the location picked.
    if (_pickedLocation == null) {
      _showErrorDialog('You need to select a location');
      return;
    } else {
      _newSite.latitude = _pickedLocation.latitude;
      _newSite.longitude = _pickedLocation.longitude;
    }

    if (!noErrors) {
      return;
    }
    _form.currentState.save();

    // Add the new Ringfort Site to the List and Pop back to the
    // prewvious screen.
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
          // Takes all the available space in the column forcing the button
          // down to the bottom.
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  child: Column(
                    children: [
                      //----------------------------------------------------
                      // This widget controlls the location selection
                      //----------------------------------------------------
                      LocationInput(_selectSiteLocation),
                      SizedBox(
                        height: 10,
                      ),
                      //----------------------------------------------------
                      // This widget controlls taking the image
                      //----------------------------------------------------
                      ImageInput(onSaveImage: _saveImage),
                      SizedBox(
                        height: 10,
                      ),
                      //----------------------------------------------------
                      // This Form will have a nested columns
                      //----------------------------------------------------
                      Form(
                        key: _form, // linking our form to the GlobalKey
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                left: 3,
                                right: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                              ),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                ),
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_descFocusNode);
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
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            //---------------------------
                            // The Description form field
                            //---------------------------
                            Container(
                              padding: EdgeInsets.only(
                                left: 3,
                                right: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                              ),
                              child: TextFormField(
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
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            //---------------------------
                            // The Access form field
                            //---------------------------
                            Container(
                              padding: EdgeInsets.only(
                                left: 3,
                                right: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                              ),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Access to Site',
                                ),
                                maxLines: 4,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.next,
                                focusNode: _accessFocusNode,
                                // validation to happen
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'You must enter details of access';
                                  }
                                  return null;
                                },
                                // what happens on saving the form
                                onSaved: (newValue) {
                                  _newSite.siteAccess = newValue;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //--------------------------------------------
          // This is the button to add a new Ringfort
          //--------------------------------------------
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
