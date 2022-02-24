import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:extended_image/extended_image.dart';

import '../screens/ringfort_detail_screen.dart';
import '../widgets/favourite_icon.dart';

class MapCard extends StatelessWidget {
  final String uid;
  final String siteName;
  final String siteDesc;
  final String siteProvince;
  final String siteCounty;
  final String siteImage;
  final User user;

  const MapCard({
    @required this.uid,
    @required this.siteName,
    @required this.siteDesc,
    @required this.siteProvince,
    @required this.siteCounty,
    @required this.siteImage,
    @required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        width: 300,
        height: 120,
        child: ListTile(
          leading: Container(
            width: 90,
            height: 90,
            child: ExtendedImage.network(
              siteImage,
              cache: true,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(siteName),
          subtitle: Stack(children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    siteDesc + '\n',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
            // This will display the favourites icon if a user is logged in.
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
                child: user != null
                    ? FavouriteIcon(
                        ringfortUID: uid,
                        user: user,
                      )
                    : Container(),
              ),
            ),
          ]),
          onTap: () {
            // Navigates to the details page with the uid of
            // the Ringfort pressed. It will execute the passed in onGoBack
            // function when we pop back from update screen.
            if (user != null) {
              Navigator.of(context)
                  .pushNamed(RingfortDetailScreen.routeName, arguments: uid);
            }
          },
        ),
      ),
    );
  }
}
