import 'dart:io' as io;
import 'package:flutter/material.dart';

import '../screens/ringfort_detail_screen.dart';


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
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Container(
          width: 75,
          height: 75,
          child: Image.file(siteImage,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(siteName),
        subtitle: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(siteDesc,
              ),
              Text(siteProvince,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(siteCounty,
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
    );
  }
}
