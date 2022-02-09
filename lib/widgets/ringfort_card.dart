import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/ringfort_detail_screen.dart';
import '../providers/historic_sites_provider.dart';

class RingfortCard extends StatelessWidget {
  final String uid;
  final String siteName;
  final String siteDesc;
  final String siteProvince;
  final String siteCounty;
  final io.File siteImage;

  const RingfortCard({
    @required this.uid,
    @required this.siteName,
    @required this.siteDesc,
    @required this.siteProvince,
    @required this.siteCounty,
    @required this.siteImage,
  });

  @override
  Widget build(BuildContext context) {
    // Adding the Dismissible which controls the deletion of a item from the
    // screen using swipe and allows the action to be defined when triggered.
    // Can also set the background i.e. red with a delete icon to appear
    // when the swipe is happening.
    return Dismissible(
      key: ValueKey(uid),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<HistoricSitesProvider>(context, listen: false)
            .deleteSite(uid);
      },
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: ListTile(
          leading: Container(
            width: 75,
            height: 75,
            child: Image.file(
              siteImage,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(siteName),
          subtitle: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siteDesc,
                ),
                Text(
                  siteProvince,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  siteCounty,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            // Navigates to the details page with the uid of
            // the Ringfort pressed.
            Navigator.of(context)
                .pushNamed(RingfortDetailScreen.routeName, arguments: uid);
          },
        ),
      ),
    );
  }
}
