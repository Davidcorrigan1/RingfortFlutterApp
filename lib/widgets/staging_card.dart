import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ringfort_app/providers/NMS_provider.dart';

import '../screens/approval_detail_screen.dart';
import '../providers/historic_sites_provider.dart';

class StagingCard extends StatefulWidget {
  final bool userHistoryData;
  final String uid;
  final String action;
  final String status;
  final String siteName;
  final String siteDesc;
  final String siteProvince;
  final String siteCounty;
  final String siteImage;
  final String nmsUID;
  final User user;

  const StagingCard({
    @required this.userHistoryData,
    @required this.uid,
    @required this.action,
    @required this.status,
    @required this.siteName,
    @required this.siteDesc,
    @required this.siteProvince,
    @required this.siteCounty,
    @required this.siteImage,
    @required this.nmsUID,
    @required this.user,
  });

  @override
  State<StagingCard> createState() => _StagingCardState();
}

class _StagingCardState extends State<StagingCard> {
  // Method to show a dialogue pop up which will return a boolean to
  // either confirm or reject an action.
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
    // the left swipe to reject. If it's used by the Approval History screen
    // then the background will be red with a delete icon for both directions.
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        // Depending on if this card is used in the Approval History screen
        // of a user or in the approvals screen of an Admin user, the
        // background icon for swipe right will be either thumbs up or delete
        color: widget.userHistoryData
            ? Theme.of(context).errorColor
            : Colors.green[400],
        child: widget.userHistoryData
            ? Icon(
                Icons.delete,
                color: Colors.white,
                size: 40,
              )
            : Icon(
                Icons.thumb_up,
                color: Colors.white,
                size: 40,
              ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      ),
      secondaryBackground: Container(
        // Depending on if this card is used in the Approval History screen
        // of a user or in the approvals screen of an Admin user, the
        // background icon for swipe left will be either thumbs down or delete
        color: Theme.of(context).errorColor,
        child: widget.userHistoryData
            ? Icon(
                Icons.delete,
                color: Colors.white,
                size: 40,
              )
            : Icon(
                Icons.thumb_down,
                color: Colors.white,
                size: 40,
              ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      ),
      direction: DismissDirection.horizontal,
      // Making sure the user wants to delete it!
      confirmDismiss: (direction) {
        if (!widget.userHistoryData) {
          if (direction == DismissDirection.startToEnd) {
            return _showConfirmationMessage('Approve');
          } else {
            return _showConfirmationMessage('Reject');
          }
        } else {
          return _showConfirmationMessage('Delete');
        }
      },
      onDismissed: (direction) {
        // Depending on if this card is used in the Approval History screen
        // of a user or in the approvals screen of an Admin user, the
        // dismiss directions will have different actions. The user history
        // will just delete staging record, which the Approvals screen
        // will either approve or reject the staged change.
        if (!widget.userHistoryData) {
          if (direction == DismissDirection.startToEnd) {
            Provider.of<HistoricSitesProvider>(context, listen: false)
                .approveStagingSite(widget.uid);
            print('nmdUID : ${widget.nmsUID}');
            Provider.of<NMSProvider>(context, listen: false)
                .deleteSite(widget.nmsUID);
          } else {
            Provider.of<HistoricSitesProvider>(context, listen: false)
                .rejectStagingSite(widget.uid);
          }
        } else {
          print('delete staging site');
          Provider.of<HistoricSitesProvider>(context, listen: false)
              .deleteStagingSite(widget.uid);
        }
      },
      child: Card(
        color: Colors.grey[100],
        elevation: 3.0,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        child: ListTile(
          leading: CircleAvatar(
            // This will show with 'A', 'U' or 'D' to indicate the action is
            // either Add, Update or Delete.
            backgroundColor: Colors.green[100],
            child: Text(
              widget.action.substring(0, 1).toUpperCase(),
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
          trailing: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Theme.of(context).primaryColor,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            height: 40,
            width: 100,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.status,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          onTap: () {
            // Navigates to the details page with the uid of
            // the Ringfort pressed. It will execute the passed in onGoBack
            // function when we pop back from update screen.
            // If this is used by the ApprovalHistoryPage don't enable onTap
            if (!widget.userHistoryData) {
              if (widget.user != null) {
                Navigator.of(context).pushNamed(ApprovalDetailScreen.routeName,
                    arguments: widget.uid);
              }
            }
          },
        ),
      ),
    );
  }
}
