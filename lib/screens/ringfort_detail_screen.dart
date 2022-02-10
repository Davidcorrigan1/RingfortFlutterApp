import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ringfort_app/models/historic_site.dart';

import '../providers/historic_sites_provider.dart';
import '../widgets/image_input.dart';
import '../widgets/location_input.dart';

class RingfortDetailScreen extends StatefulWidget {
  static const routeName = '/ringfort-detail';

  @override
  State<RingfortDetailScreen> createState() => _RingfortDetailScreenState();
}

class _RingfortDetailScreenState extends State<RingfortDetailScreen> {
  // Making sure we only get the arguments once!
  var _isInit = true;
  // uid of site being updated
  var uid = '';
  // Initialize a HistoricSite object to display
  var _displaySite = HistoricSite(
      uid: '',
      siteName: '',
      siteDesc: '',
      siteAccess: '',
      latitude: 0.0,
      longitude: 0.0,
      siteSize: 0.0,
      image: null);

  // Variable which will hold inital values of Ringfort being updated
  var _initValues = {
    'siteName': '',
    'siteDesc': '',
    'siteAccess': '',
    'latitude': 0.0,
    'longitude': 0.0,
    'siteSize': 0.0,
    'image': null
  };

  // Focus node for the description and access fields.
  final _descFocusNode = FocusNode();
  final _accessFocusNode = FocusNode();
  final _sizeFocusNode = FocusNode();
  // Create a global key so we can interact with the widget from code
  final _form = GlobalKey<FormState>();

  // Method to save the taken image from image_input widget to this class
  void _saveImage(io.File takenImage) {
    _displaySite.image = takenImage;
  }

  // A method to pass into 'location_input' widget to save the location lat,lng
  void _selectSiteLocation(double latitude, double longitude) {
    _displaySite.latitude = latitude;
    _displaySite.longitude = longitude;
  }

  @override
  // This runs before the Widgets build but after initState and the context is available
  void didChangeDependencies() {
    if (_isInit) {
      uid = ModalRoute.of(context).settings.arguments;
      _displaySite = Provider.of<HistoricSitesProvider>(context, listen: false)
          .findSiteById(uid);
      _initValues = {
        'siteName': _displaySite.siteName,
        'siteDesc': _displaySite.siteDesc,
        'siteAccess': _displaySite.siteAccess,
        'latitude': _displaySite.latitude,
        'longitude': _displaySite.longitude,
        'siteSize': _displaySite.siteSize,
        'image': _displaySite.image,
      };
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _descFocusNode.dispose();
    _accessFocusNode.dispose();
    _sizeFocusNode.dispose();
    super.dispose();
  }

  // Function will generate an error dialogue
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Not all required data entered'),
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
    if (_displaySite.image == null) {
      _showErrorDialog('You need to take an Image to proceed');
      return;
    }

    // Set the new site with the location picked.
    if (_displaySite.latitude == null || _displaySite.longitude == null) {
      _showErrorDialog('You need to select a location to proceed');
      return;
    }

    if (!noErrors) {
      return;
    }
    _form.currentState.save();

    // Add the new Ringfort Site to the List and Pop back to the
    // prewvious screen.
    Provider.of<HistoricSitesProvider>(context, listen: false)
        .updateSite(uid, _displaySite);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_displaySite.siteName),
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
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  child: Column(
                    children: [
                      //----------------------------------------------------
                      // This widget controlls the location selection
                      //----------------------------------------------------
                      LocationInput(
                          _selectSiteLocation,
                          LatLng(_initValues['latitude'],
                              _initValues['longitude'])),
                      SizedBox(
                        height: 5,
                      ),
                      //----------------------------------------------------
                      // This widget controlls taking the image
                      //----------------------------------------------------
                      ImageInput(
                        onSaveImage: _saveImage,
                        passedImage: _displaySite.image,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      //----------------------------------------------------
                      // This Form will have a nested columns
                      //----------------------------------------------------
                      Form(
                        key: _form, // linking our form to the GlobalKey
                        child: Column(
                          children: [
                            //---------------------------
                            // The Name form field
                            //---------------------------
                            TextFormField(
                              initialValue: _initValues['siteName'],
                              decoration: InputDecoration(
                                hintText: 'Ringfort Name',
                                border: OutlineInputBorder(),
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
                                _displaySite.siteName = newValue;
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            //---------------------------
                            // The Description form field
                            //---------------------------
                            TextFormField(
                              initialValue: _initValues['siteDesc'],
                              decoration: InputDecoration(
                                hintText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 4,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_accessFocusNode);
                              },
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
                                _displaySite.siteDesc = newValue;
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            //---------------------------
                            // The Access form field
                            //---------------------------
                            TextFormField(
                              initialValue: _initValues['siteAccess'],
                              decoration: InputDecoration(
                                hintText: 'Access to Site',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_sizeFocusNode);
                              },
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
                                _displaySite.siteAccess = newValue;
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            //---------------------------
                            // The Approx Size form field
                            //---------------------------
                            TextFormField(
                              initialValue: _initValues['siteSize'].toString(),
                              decoration: InputDecoration(
                                hintText: 'Approx Size (Metres)',
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              focusNode: _sizeFocusNode,
                              // validation to happen
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'You must enter approx size';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid numeric';
                                }
                                if (double.parse(value) <= 0.00) {
                                  return 'The size must be greater than 0.00';
                                }
                                return null;
                              },
                              // what happens on saving the form
                              onSaved: (newValue) {
                                _displaySite.siteSize = double.parse(newValue);
                              },
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
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              style: ButtonStyle(
                // Shrinks the space around the button
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: _saveForm,
              icon: Icon(Icons.save),
              label: Text(
                'UPDATE',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
