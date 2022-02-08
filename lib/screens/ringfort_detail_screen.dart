import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/historic_sites_provider.dart';

class RingfortDetailScreen extends StatelessWidget {
  static const routeName = '/ringfort-detail';

  @override
  Widget build(BuildContext context) {
    final uid = ModalRoute.of(context).settings.arguments;
    final displaySite =
        Provider.of<HistoricSitesProvider>(context, listen: false)
            .findSiteById(uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(displaySite.siteName),
      ),
      body: Container(),
    );
  }
}
