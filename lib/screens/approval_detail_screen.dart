import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ringfort_app/models/historic_site_staging.dart';

import '../widgets/location_input.dart';
import '../providers/historic_sites_provider.dart';
import '../widgets/app_drawer.dart';

class ApprovalDetailScreen extends StatefulWidget {
  static const routeName = '/approval-detail';

  @override
  State<ApprovalDetailScreen> createState() => _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends State<ApprovalDetailScreen> {
  // Making sure we only get the arguments once!
  var _isInit = true;
  // uid of site being updated
  var uid = '';
  // User collection uid
  var userUid = '';
  // Initialize a HistoricSite object to display
  HistoricSiteStaging _displayStagingSite;

  @override
  // This runs before the Widgets build but after initState and the context is available
  void didChangeDependencies() {
    if (_isInit) {
      uid = ModalRoute.of(context).settings.arguments;
      _displayStagingSite =
          Provider.of<HistoricSitesProvider>(context, listen: false)
              .findStagingSiteById(uid);
      userUid = Provider.of<User>(context).uid;
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_displayStagingSite.updatedSite.siteName),
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
                        () {},
                        LatLng(_displayStagingSite.updatedSite.latitude,
                            _displayStagingSite.updatedSite.longitude),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      //----------------------------------------------------
                      // This widget controlls taking the image
                      //----------------------------------------------------
                      Image.network(
                        _displayStagingSite.updatedSite.image,
                        fit: BoxFit.cover,
                        //  width: double.infinity,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      //----------------------------------------------------
                      // This Form will have a nested columns
                      //----------------------------------------------------
                      Form(
                        child: Column(
                          children: [
                            //---------------------------
                            // The Name form field
                            //---------------------------
                            TextFormField(
                              initialValue:
                                  _displayStagingSite.updatedSite.siteName,
                              decoration: InputDecoration(
                                hintText: 'Ringfort Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            //---------------------------
                            // The Description form field
                            //---------------------------
                            TextFormField(
                              initialValue:
                                  _displayStagingSite.updatedSite.siteDesc,
                              decoration: InputDecoration(
                                hintText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 4,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            //---------------------------
                            // The Access form field
                            //---------------------------
                            TextFormField(
                              initialValue:
                                  _displayStagingSite.updatedSite.siteAccess,
                              decoration: InputDecoration(
                                hintText: 'Access to Site',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            //---------------------------
                            // The Approx Size form field
                            //---------------------------
                            TextFormField(
                              initialValue: _displayStagingSite
                                  .updatedSite.siteSize
                                  .toString(),
                              decoration: InputDecoration(
                                hintText: 'Approx Size (Metres)',
                                border: OutlineInputBorder(),
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
        ],
      ),
    );
  }
}
