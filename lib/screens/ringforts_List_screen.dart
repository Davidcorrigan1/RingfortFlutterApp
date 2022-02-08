import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ringfort_app/providers/historic_sites_provider.dart';

import '../screens/add_ringfort_screen.dart';
import '../screens/ringfort_detail_screen.dart';

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
                    itemBuilder: (ctx, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 75,
                            height: 75,
                            child: Image.file(
                              historicSites.sites[index].image,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(historicSites.sites[index].siteName),
                          subtitle: Container(
                            child: Column(
                              children: [
                                Text(
                                  historicSites.sites[index].siteDesc,
                                ),
                                Text(
                                  historicSites.sites[index].province,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  historicSites.sites[index].county,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                RingfortDetailScreen.routeName,
                                arguments: historicSites.sites[index].uid);
                          },
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
