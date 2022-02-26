import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_data.dart';
import '../providers/historic_sites_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/staging_card.dart';
import '../widgets/app_drawer.dart';

// This screen will show the list of ringforts
class ApprovalHistoryScreen extends StatefulWidget {
  static const routeName = '/approval-history';

  @override
  State<ApprovalHistoryScreen> createState() => _ApprovalHistoryScreenState();
}

class _ApprovalHistoryScreenState extends State<ApprovalHistoryScreen> {
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
          .fetchAndSetUserApprovalHistory(user.uid)
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

  // This method is called then the list is pulled down to refresh.
  // it calls the HistoricSitesProvider to refresh the site list from Firebase
  // and then retrieves the list into the Widget class
  // Also used as the method for the future builder.
  // If there is a filter seach term entered it will filter the results to show.
  Future<void> _refreshStagingRingfortList() async {
    await Provider.of<HistoricSitesProvider>(context, listen: false)
        .fetchAndSetUserApprovalHistory(userData.uid);

    setState(() {});
  }

  // Build a Text Widget for the Normal Screen title.
  Widget _buildTitle(BuildContext context) {
    return Text('My Approval History');
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
              onRefresh: () => _refreshStagingRingfortList(),
              child: Consumer<HistoricSitesProvider>(
                builder: (context, historicSites, child) => historicSites
                            .userApprovalHistory.length >
                        0
                    ? ListView.builder(
                        itemCount: historicSites.userApprovalHistory.length,
                        itemBuilder: (ctx, index) => StagingCard(
                              userHistoryData: true,
                              uid: historicSites.userApprovalHistory[index].uid,
                              action: historicSites
                                  .userApprovalHistory[index].action,
                              status: historicSites
                                  .userApprovalHistory[index].actionStatus,
                              siteName: historicSites.userApprovalHistory[index]
                                  .updatedSite.siteName,
                              siteDesc: historicSites.userApprovalHistory[index]
                                  .updatedSite.siteDesc,
                              siteProvince: historicSites
                                  .userApprovalHistory[index]
                                  .updatedSite
                                  .province,
                              siteCounty: historicSites
                                  .userApprovalHistory[index]
                                  .updatedSite
                                  .county,
                              siteImage: historicSites
                                  .userApprovalHistory[index].updatedSite.image,
                              user: Provider.of<User>(context, listen: false),
                            ))
                    : Center(
                        child: Text('No Approval History'),
                      ),
              ),
            ),
    );
  }
}
