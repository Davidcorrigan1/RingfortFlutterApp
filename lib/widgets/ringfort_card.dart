import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ringfort_app/models/historic_site.dart';
import 'package:ringfort_app/models/user_data.dart';

import '../screens/ringfort_detail_screen.dart';
import '../providers/historic_sites_provider.dart';
import '../widgets/favourite_icon.dart';

class RingfortCard extends StatelessWidget {
  final HistoricSite site;
  final User user;
  final UserData userData;

  const RingfortCard(
      {@required this.site, @required this.user, @required this.userData});

  // Display a message on the bottom of screen
  void showScreenMessage(BuildContext context, String screenMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          screenMessage,
        ),
        duration: Duration(seconds: 4),
        elevation: 10,
        backgroundColor: Theme.of(context).errorColor,
        action: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Adding the Dismissible which controls the deletion of a item from the
    // screen using swipe and allows the action to be defined when triggered.
    // Can also set the background i.e. red with a delete icon to appear
    // when the swipe is happening.
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
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
            .deleteSite(userData, site);
        if (!userData.adminUser) {
          showScreenMessage(
              context, 'Delete Request sent for approval by Admin');
        }
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
              site.image,
              cache: true,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(site.siteName),
          subtitle: Stack(children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    site.siteDesc + '\n',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    site.province,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    site.county,
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
                        ringfortUID: site.uid,
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
              Navigator.of(context).pushNamed(RingfortDetailScreen.routeName,
                  arguments: site.uid);
            }
          },
        ),
      ),
    );
  }
}
