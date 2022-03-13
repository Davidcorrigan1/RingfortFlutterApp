import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/historic_site.dart';
import '../providers/historic_sites_provider.dart';
import '../widgets/app_drawer.dart';

class DisplayImageScreen extends StatefulWidget {
  static const routeName = '/display-image';

  @override
  State<DisplayImageScreen> createState() => _DisplayImageScreenState();
}

class _DisplayImageScreenState extends State<DisplayImageScreen> {
  bool _isInit = true;
  String _uid;
  HistoricSite _displaySite;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _uid = ModalRoute.of(context).settings.arguments;
      _displaySite = Provider.of<HistoricSitesProvider>(context, listen: false)
          .findSiteById(_uid);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_displaySite.siteName} image'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.cancel,
              size: 30,
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: InteractiveViewer(
        panEnabled: true,
        boundaryMargin: EdgeInsets.all(50),
        minScale: 0.5,
        maxScale: 3,
        child: Center(
          child: Hero(
            tag: 'hero-animation',
            child: Image.network(_displaySite.image),
          ),
        ),
      ),
    );
  }
}
