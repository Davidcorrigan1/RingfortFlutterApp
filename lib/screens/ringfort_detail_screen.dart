import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ringfort_app/providers/user_provider.dart';

import '../models/user_data.dart';
import '../models/historic_site.dart';
import '../providers/historic_sites_provider.dart';
import '../widgets/image_input.dart';
import '../widgets/location_input.dart';
import '../widgets/app_drawer.dart';

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
  // User collection uid
  var userUid = '';
  // userData from Firestore
  UserData userData;
  // Initialize a HistoricSite object to display
  var _updateSite = HistoricSite(
      uid: '',
      siteName: '',
      siteDesc: '',
      siteAccess: '',
      latitude: 0.0,
      longitude: 0.0,
      siteSize: 0.0,
      image: null,
      lastUpdatedBy: '',
      createdBy: '');

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

  // The taken site image
  io.File _siteImage;
  // Focus node for the description and access fields.
  final _descFocusNode = FocusNode();
  final _accessFocusNode = FocusNode();
  final _sizeFocusNode = FocusNode();
  // Create a global key so we can interact with the widget from code
  final _form = GlobalKey<FormState>();

  // Method to save the taken image from image_input widget to this class
  void _saveImage(io.File takenImage) {
    _siteImage = takenImage;
  }

  // A method to pass into 'location_input' widget to save the location lat,lng
  void _selectSiteLocation(
      double latitude, double longitude, String staticMapUrl) {
    _updateSite.latitude = latitude;
    _updateSite.longitude = longitude;
  }

  @override
  // This runs before the Widgets build but after initState and the context is available
  void didChangeDependencies() {
    if (_isInit) {
      uid = ModalRoute.of(context).settings.arguments;
      var matchSite = Provider.of<HistoricSitesProvider>(context, listen: false)
          .findSiteById(uid);
      _updateSite.uid = matchSite.uid;
      _updateSite.siteName = matchSite.siteName;
      _updateSite.siteDesc = matchSite.siteDesc;
      _updateSite.siteAccess = matchSite.siteAccess;
      _updateSite.siteSize = matchSite.siteSize;
      _updateSite.latitude = matchSite.latitude;
      _updateSite.longitude = matchSite.longitude;
      _updateSite.image = matchSite.image;
      _updateSite.address = matchSite.address;
      _updateSite.province = matchSite.province;
      _updateSite.county = matchSite.county;
      _updateSite.createdBy = matchSite.createdBy;
      _updateSite.lastUpdatedBy = matchSite.lastUpdatedBy;

      userUid = Provider.of<User>(context).uid;
      userData = Provider.of<UserProvider>(context).currentUserData;
      _initValues = {
        'uid': uid,
        'siteName': _updateSite.siteName,
        'siteDesc': _updateSite.siteDesc,
        'siteAccess': _updateSite.siteAccess,
        'latitude': _updateSite.latitude,
        'longitude': _updateSite.longitude,
        'siteSize': _updateSite.siteSize,
        'image': _updateSite.image,
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

  // Display a message on the bottom of screen
  void showScreenMessage(BuildContext context, String screenMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          screenMessage,
        ),
        duration: Duration(seconds: 4),
        elevation: 10,
        backgroundColor: Theme.of(context).errorColor,
        action: null,
      ),
    );
  }

  // Function which will be call to submit form if there are
  // no validation errors found.
  void _saveForm() {
    final noErrors = _form.currentState.validate();

    // Set the new site with the image taken
    if (_updateSite.image == null) {
      _showErrorDialog('You need to take an Image to proceed');
      return;
    }

    // Set the new site with the location picked.
    if (_updateSite.latitude == null || _updateSite.longitude == null) {
      _showErrorDialog('You need to select a location to proceed');
      return;
    }

    _updateSite.lastUpdatedBy = userUid;

    if (!noErrors) {
      return;
    }
    _form.currentState.save();

    // Add the new Ringfort Site to the List and Pop back to the
    // prewvious screen.
    Provider.of<HistoricSitesProvider>(context, listen: false)
        .updateSite(userData, uid, _updateSite, _siteImage);
    // If it's a normal user, then show message to say it's sent for approval.
    if (!userData.adminUser) {
      showScreenMessage(context, 'Update request sent for approval by Admin');
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_updateSite.siteName),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.cancel,
              size: 30,
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
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
                        passedImage: _siteImage,
                        passedUrl: _updateSite.image,
                        siteUID: _updateSite.uid,
                        useStaticMapImage: false,
                        staticMapUrl: null,
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
                                _updateSite.siteName = newValue;
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
                                _updateSite.siteDesc = newValue;
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
                                _updateSite.siteAccess = newValue;
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
                                _updateSite.siteSize = double.parse(newValue);
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
