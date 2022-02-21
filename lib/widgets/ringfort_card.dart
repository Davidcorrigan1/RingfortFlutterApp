import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:extended_image/extended_image.dart';

import '../screens/ringfort_detail_screen.dart';
import '../providers/historic_sites_provider.dart';

class RingfortCard extends StatelessWidget {
  final String uid;
  final String siteName;
  final String siteDesc;
  final String siteProvince;
  final String siteCounty;
  final String siteImage;
  final User user;

  const RingfortCard({
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
      // Making sure the user wants to delete it!
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to delete the Ringfort?'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
                child: Text('No '),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).errorColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Yes'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<HistoricSitesProvider>(context, listen: false)
            .deleteSite(uid);
      },
      child: Card(
        color: Colors.grey[100],
        elevation: 3.0,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        child: ListTile(
          leading: SizedBox(
            width: 90,
            height: 90,
            child: ExtendedImage.network(
              siteImage,
              cache: true,
              fit: BoxFit.fill,
            ),
          ),
          title: Text(siteName),
          subtitle: Container(
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
