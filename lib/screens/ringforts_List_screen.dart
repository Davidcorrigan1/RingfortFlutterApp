import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ringfort_app/providers/historic_sites_provider.dart';

import '../screens/add_ringfort_screen.dart';

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
                    itemBuilder: (ctx, index) => ListTile(
                      leading: Container(
                        width: 100,
                        height: 100,
                        child: Image.file(
                          historicSites.sites[index].image,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(historicSites.sites[index].siteName),
                      subtitle: Text(historicSites.sites[index].siteDesc),
                      //trailing: Text('${historicSites.sites[index].latitude}/${historicSites.sites[index].longitude}'),
                      onTap: () {},
                    ),
                  ),
      ),
    );
  }
}
