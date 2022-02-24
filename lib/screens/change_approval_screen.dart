import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_data.dart';
import '../screens/authentication_screen.dart';
import '../providers/historic_sites_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/staging_card.dart';
import '../widgets/app_drawer.dart';

// This screen will show the list of ringforts
class ChangeApprovalScreen extends StatefulWidget {
  static const routeName = '/change-approval';

  @override
  State<ChangeApprovalScreen> createState() => _ChangeApprovalScreenState();
}

class _ChangeApprovalScreenState extends State<ChangeApprovalScreen> {
  var _initRun = true;
  var _isLoading = false;
  User user;
  UserData userData;

  @override
  // Refresh the ringforts from Firebase and then run the filter query
  void didChangeDependencies() {
    if (_initRun) {
      _isLoading = true;
      user = Provider.of<User>(context, listen: false);
      Provider.of<HistoricSitesProvider>(context, listen: false)
          .fetchAndSetStagingRingforts()
          .then((value) {
        Provider.of<UserProvider>(context, listen: false)
            .getCurrentUserData(user.uid)
            .then((value) {
          setState(() {
            userData = value;
            _isLoading = false;
          });
        });
      });
      _initRun = false;
      super.didChangeDependencies();
    }
  }

  // This method will ask user if they want to login to proceed Yes or no
  void _showErrorDialog(BuildContext ctx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('This option is only available to logged in Users'),
        content: Text('Do you want to login?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text('No '),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(ctx).backgroundColor,
            ),
            onPressed: () {
              Navigator.of(ctx).pushNamed(AuthenticationScreen.routeName);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  // This method is called then the list is pulled down to refresh.
  // it calls the HistoricSitesProvider to refresh the site list from Firebase
  // and then retrieves the list into the Widget class
  // Also used as the method for the future builder.
  // If there is a filter seach term entered it will filter the results to show.
  Future<void> _refreshRingfortList() async {
    print("calling refreshRingfortList");
    await Provider.of<HistoricSitesProvider>(context, listen: false)
        .fetchAndSetStagingRingforts();

    setState(() {});
  }

  // Build a Text Widget for the Normal Screen title.
  Widget _buildTitle(BuildContext context) {
    return Text('Changes for Approval');
  }

  //--------------------------------------------------------
  // Widget build...
  //--------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(context),
        actions: [],
      ),
      drawer: AppDrawer(),
      // Wrapping with RefreshIndicator which takes a function which returns a future.
      // We define this to call the Provider class. The returned future tells the widget
      // to stop showing the loader symbol
      // Wrapping with a FutureBuilder which allows you to build a widget which depends on a Future
      // being returned. We can then check the status of the Future with the snapShow.connectionState
      // and display loader or the actual widget depending on if it's waiting or done.
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => _refreshRingfortList(),
              child: Consumer<HistoricSitesProvider>(
                builder: (context, historicSites, child) =>
                    historicSites.stagingSites.length > 0
                        ? ListView.builder(
                            itemCount: historicSites.stagingSites.length,
                            itemBuilder: (ctx, index) => StagingCard(
                                  uid: historicSites.stagingSites[index].uid,
                                  action: historicSites.stagingSites[index].action,
                                  siteName: historicSites
                                      .stagingSites[index].updatedSite.siteName,
                                  siteDesc: historicSites
                                      .stagingSites[index].updatedSite.siteDesc,
                                  siteProvince: historicSites
                                      .stagingSites[index].updatedSite.province,
                                  siteCounty: historicSites
                                      .stagingSites[index].updatedSite.county,
                                  siteImage: historicSites
                                      .stagingSites[index].updatedSite.image,
                                  user:
                                      Provider.of<User>(context, listen: false),
                                ))
                        : Center(
                            child: Text('No Changes for Approval'),
                          ),
              ),
            ),
    );
  }
}
