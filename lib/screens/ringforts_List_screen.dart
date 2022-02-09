import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/historic_sites_provider.dart';
import '../screens/add_ringfort_screen.dart';
import '../widgets/ringfort_card.dart';

// This screen will show the list of ringforts
class RingfortsListScreen extends StatelessWidget {
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
      body: Consumer<HistoricSitesProvider>(
        child: Center(
          child: Text('No Ringforts Add yet'),
        ),
        builder: (context, historicSites, child) =>
            historicSites.sites.length <= 0
                ? child
                : ListView.builder(
                    itemCount: historicSites.sites.length,
                    itemBuilder: (ctx, index) => RingfortCard(
                        uid: historicSites.sites[index].uid,
                        siteName: historicSites.sites[index].siteName,
                        siteDesc: historicSites.sites[index].siteDesc,
                        siteProvince: historicSites.sites[index].province,
                        siteCounty: historicSites.sites[index].county,
                        siteImage: historicSites.sites[index].image),
                  ),
      ),
    );
  }
}

