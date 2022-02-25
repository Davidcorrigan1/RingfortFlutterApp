import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ringfort_app/models/historic_site_staging.dart';

import '../widgets/location_input.dart';
import '../providers/historic_sites_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/text_box.dart';

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
                      // This widget displays the location in static map
                      //----------------------------------------------------
                      LocationInput(
                        null,
                        LatLng(_displayStagingSite.updatedSite.latitude,
                            _displayStagingSite.updatedSite.longitude),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      //----------------------------------------------------
                      // This widget displays the image
                      //----------------------------------------------------
                      Container(
                        width: double.infinity,
                        //color: Colors.grey[100],
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Image.network(
                          _displayStagingSite.updatedSite.image,
                          fit: BoxFit.cover,
                          //  width: double.infinity,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      //----------------------------------------------------
                      // This Container will have nested columns
                      //----------------------------------------------------
                      Container(
                        child: Column(
                          children: [
                            //---------------------------
                            // The Name form field
                            //---------------------------
                            TextBox(
                              height: 45,
                              displayText:
                                  _displayStagingSite.updatedSite.siteName,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            //---------------------------
                            // The Description form field
                            //---------------------------
                            TextBox(
                              height: 120,
                              displayText:
                                  _displayStagingSite.updatedSite.siteDesc,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            //---------------------------
                            // The Access form field
                            //---------------------------
                            TextBox(
                              height: 60,
                              displayText:
                                  _displayStagingSite.updatedSite.siteAccess,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            //---------------------------
                            // The Approx Size field
                            //---------------------------
                            TextBox(
                              height: 45,
                              displayText: _displayStagingSite
                                  .updatedSite.siteSize
                                  .toString(),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            //---------------------------
                            // The Approx address field
                            //---------------------------
                            TextBox(
                              height: 60,
                              displayText:
                                  _displayStagingSite.updatedSite.address,
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
