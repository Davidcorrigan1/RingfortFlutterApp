import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

import '../providers/NMS_provider.dart';
import '../models/NMS_data.dart';
import '../models/user_data.dart';
import '../models/historic_site.dart';
import '../providers/historic_sites_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/image_input.dart';
import '../widgets/location_input.dart';
import '../widgets/app_drawer.dart';

class AddRingfortScreen extends StatefulWidget {
  // Screen Route name to add to route table
  static const routeName = '/add-ringfort';

  @override
  State<AddRingfortScreen> createState() => _AddRingfortScreenState();
}

class _AddRingfortScreenState extends State<AddRingfortScreen> {
  var _initFirst = true;
  String uid;
  String nmsUid;
  UserData user;
  NMSData nmsSite;

  // The taken site image
  io.File _siteImage;
  // Focus node for the description and access fields.
  final _descFocusNode = FocusNode();
  final _accessFocusNode = FocusNode();
  final _sizeFocusNode = FocusNode();
  // Create a global key so we can interact with the widget from code
  final _form = GlobalKey<FormState>();
  // Location picked  by the user
  LatLng _pickedLocation;
  // Static Map Picture URL
  String _staticMapURL;
  bool _useStaticMap = false;

  // Initial screen vales if adding NMS site
  var _initValues = {
    'siteName': '',
    'siteDesc': '',
    'latitude': 0.0,
    'longitude': 0.0,
  };

  // Method to save the taken image from image_input widget to this class
  void _saveImage(io.File chosenImage) {
    _siteImage = chosenImage;
  }

  // A method to pass into 'location_input' widget to save the location lat,lng
  void _selectSiteLocation(
      double latitude, double longitude, String staticMapUrl) {
    _pickedLocation = LatLng(latitude, longitude);
    _staticMapURL = staticMapUrl;
  }

  // Create an initialize HistoricSite object
  var _newSite = HistoricSite(
      uid: null,
      siteName: '',
      siteDesc: '',
      siteAccess: '',
      latitude: 0.0,
      longitude: 0.0,
      siteSize: 0.0,
      address: '',
      image: '',
      lastUpdatedBy: '',
      createdBy: '');

  @override
  void dispose() {
    _descFocusNode.dispose();
    _accessFocusNode.dispose();
    _sizeFocusNode.dispose();
    super.dispose();
  }

  @override
  // This runs when a dependency of the state object changes. It runs after
  // initState() but before build widget. Here I only call the providers
  // the first time this method runs, after the screen is loaded.
  void didChangeDependencies() {
    if (_initFirst) {
      uid = Provider.of<User>(context, listen: false).uid;
      user = Provider.of<UserProvider>(context, listen: false).currentUserData;
      nmsUid = ModalRoute.of(context).settings.arguments;
      if (nmsUid != null) {
        nmsSite = Provider.of<NMSProvider>(context, listen: false)
            .findSiteById(nmsUid);
        _initValues = {
          'siteName': nmsSite.siteName.titleCase,
          'siteDesc': nmsSite.siteDesc.titleCase,
          'latitude': nmsSite.latitude,
          'longitude': nmsSite.longitude,
        };
      }
    }
    _initFirst = false;
    super.didChangeDependencies();
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
              setState(() {
                _useStaticMap = true;
              });
              Navigator.of(ctx).pop(); // Close the dialogue
            },
            child: Text('YES'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _useStaticMap = false;
              });
              Navigator.of(ctx).pop(); // Close the dialogue
            },
            child: Text('NO'),
          )
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

    // Check an image has been picked or the user has chosen to use the satalite image
    if (_siteImage == null && !_useStaticMap) {
      _showErrorDialog(
          'You have not taken or chosen an image, do you want to use the satalite image?');
      return;
    }

    // Set the new site with the location picked.
    if (_pickedLocation != null) {
      _newSite.latitude = _pickedLocation.latitude;
      _newSite.longitude = _pickedLocation.longitude;
    }

    _newSite.createdBy = uid;
    _newSite.lastUpdatedBy = uid;

    if (!noErrors) {
      return;
    }
    _form.currentState.save();

    // Add the new Ringfort Site to the List and Pop back to the
    // prewvious screen.
    Provider.of<HistoricSitesProvider>(context, listen: false)
        .addSite(user, _newSite, nmsUid, _siteImage);

    // Delete the NMS data as it's now on the main collection
    if (nmsSite != null && user.adminUser) {
      Provider.of<NMSProvider>(context, listen: false).deleteSite(nmsUid);
    }
    // If it's a normal user, then show message to say it's sent for approval.
    if (!user.adminUser) {
      showScreenMessage(context, 'Add request sent for approval by Admin');
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: nmsSite != null
            ? Text('Update a NMS Site')
            : Text('Add New Ringfort'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.cancel,
              size: 30,
            ),
          ),
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save_rounded, size: 30),
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
                      nmsSite == null
                          ? LocationInput(_selectSiteLocation, null)
                          : LocationInput(_selectSiteLocation,
                              LatLng(nmsSite.latitude, nmsSite.longitude)),
                      SizedBox(
                        height: 5,
                      ),
                      //----------------------------------------------------
                      // This widget controlls taking the image
                      //----------------------------------------------------
                      ImageInput(
                        onSaveImage: _saveImage,
                        passedImage: null,
                        passedUrl: null,
                        siteUID: null,
                        useStaticMapImage: _useStaticMap,
                        staticMapUrl: _staticMapURL,
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
                                _newSite.siteName = newValue;
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
                                _newSite.siteDesc = newValue;
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            //---------------------------
                            // The Access form field
                            //---------------------------
                            TextFormField(
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
                                _newSite.siteAccess = newValue;
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            //---------------------------
                            // The Approx Size form field
                            //---------------------------
                            TextFormField(
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
                                _newSite.siteSize = double.parse(newValue);
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
                'SAVE',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
