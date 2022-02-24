import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/approval_detail_screen.dart';
import '../providers/historic_sites_provider.dart';

class StagingCard extends StatefulWidget {
  final String uid;
  final String action;
  final String siteName;
  final String siteDesc;
  final String siteProvince;
  final String siteCounty;
  final String siteImage;
  final User user;

  const StagingCard({
    @required this.uid,
    @required this.action,
    @required this.siteName,
    @required this.siteDesc,
    @required this.siteProvince,
    @required this.siteCounty,
    @required this.siteImage,
    @required this.user,
  });

  @override
  State<StagingCard> createState() => _StagingCardState();
}

class _StagingCardState extends State<StagingCard> {
  bool swipeRight = false;

  Future<bool> _showConfirmationMessage(String messageText) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to $messageText this change?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
            child: Text('No '),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Adding the Dismissible which controls the deletion of a item from the
    // screen using swipe and allows the action to be defined when triggered.
    // Can also set the background i.e. red with a thumbs down icon to appear
    // when the right swipe is happening to approve. And green with a thumbs dowm when
    // the left swipe to reject.
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.green[400],
        child: Icon(
          Icons.thumb_up,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.thumb_down,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      direction: DismissDirection.horizontal,
      // Making sure the user wants to delete it!
      confirmDismiss: (direction) {
        if (direction == DismissDirection.startToEnd) {
          print('swipe right');
          swipeRight = true;
          return _showConfirmationMessage('Approve');
        } else {
          print('swipe left');
          swipeRight = false;
          return _showConfirmationMessage('Reject');
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          Provider.of<HistoricSitesProvider>(context, listen: false)
              .approveStagingSite(widget.uid);
        }
      },
      child: Card(
        color: Colors.grey[100],
        elevation: 3.0,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        child: ListTile(
          leading: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.green[100],
            child: Text(
              widget.action,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          title: Text(widget.siteName),
          subtitle: Stack(children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.siteDesc + '\n',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.siteProvince,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.siteCounty,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ]),
          onTap: () {
            // Navigates to the details page with the uid of
            // the Ringfort pressed. It will execute the passed in onGoBack
            // function when we pop back from update screen.
            if (widget.user != null) {
              Navigator.of(context).pushNamed(ApprovalDetailScreen.routeName,
                  arguments: widget.uid);
            }
          },
        ),
      ),
    );
  }
}
