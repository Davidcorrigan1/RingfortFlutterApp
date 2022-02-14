import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/historic_sites_provider.dart';
import '../screens/add_ringfort_screen.dart';
import '../widgets/ringfort_card.dart';
import '../widgets/app_drawer.dart';


// This screen will show the list of ringforts
class RingfortsListScreen extends StatelessWidget {
  Future<void> _refreshRingfortList(BuildContext context) async {
    await Provider.of<HistoricSitesProvider>(context, listen: false)
        .fetchAndSetRingforts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ringforts'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AddRingfortScreen.routeName);
            },
            icon: Icon(Icons.add_box_rounded),
          )
        ],
      ),
      drawer: AppDrawer(),
      // Wrapping with RefreshIndicator which takes a function which returns a future.
      // We define this to call the Provider class. The returned future tells the widget
      // to stop showing the loader symbol
      // Wrapping with a FutureBuilder which allows you to build a widget which depends on a Future
      // being returned. We can then check the status of the Future with the snapShow.connectionState
      // and display loader or the actual widget depending on if it's waiting or done.
      body: FutureBuilder(
        future: _refreshRingfortList(context),
        builder: (context, snapShot) => snapShot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshRingfortList(context),
                child: Consumer<HistoricSitesProvider>(
                  builder: (context, historicSites, child) =>
                      historicSites.sites.length <= 0
                          ? child
                          : ListView.builder(
                              itemCount: historicSites.sites.length,
                              itemBuilder: (ctx, index) => RingfortCard(
                                uid: historicSites.sites[index].uid,
                                siteName: historicSites.sites[index].siteName,
                                siteDesc: historicSites.sites[index].siteDesc,
                                siteProvince:
                                    historicSites.sites[index].province,
                                siteCounty: historicSites.sites[index].county,
                                siteImage: historicSites.sites[index].image,
                              ),
                            ),
                ),
              ),
      ),
    );
  }
}
