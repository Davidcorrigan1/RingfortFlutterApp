import 'package:flutter/material.dart';

import '../screens/add_ringfort_screen.dart';

class NMSCard extends StatelessWidget {
  final String uid;
  final String siteName;
  final String siteDesc;

  const NMSCard({
    @required this.uid,
    @required this.siteName,
    @required this.siteDesc,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Container(
        width: 370,
        height: 120,
        child: ListTile(
          leading: Container(
            width: 90,
            height: 90,
            child: Icon(
              Icons.add,
              size: 40,
            ),
          ),
          title: Text(siteName),
          subtitle: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siteDesc + '\n' + '\n' + 'Click To Update',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          onTap: () {
            // Navigates to the add Ringfort page with the uid of
            // the Ringfort pressed.
            Navigator.of(context)
                .pushNamed(AddRingfortScreen.routeName, arguments: uid);
          },
        ),
      ),
    );
  }
}
