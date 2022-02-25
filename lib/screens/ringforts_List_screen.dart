import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ringfort_app/models/user_data.dart';
import 'package:ringfort_app/screens/authentication_screen.dart';

import '../providers/historic_sites_provider.dart';
import '../providers/user_provider.dart';
import '../screens/add_ringfort_screen.dart';
import '../widgets/ringfort_card.dart';
import '../widgets/app_drawer.dart';

// This screen will show the list of ringforts
class RingfortsListScreen extends StatefulWidget {
  static const routeName = '/ringfort-list';

  @override
  State<RingfortsListScreen> createState() => _RingfortsListScreenState();
}

class _RingfortsListScreenState extends State<RingfortsListScreen> {
  var _initRun = true;
  var _isLoading = false;
  var _showFavourites = false;
  User user;
  UserData userData;
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "";

  @override
  // Refresh the ringforts from Firebase and then run the filter query
  void didChangeDependencies() {
    if (_initRun) {
      print('didChangeDependancies run RingfortList');
      _isLoading = true;
      user = Provider.of<User>(context, listen: false);
      Provider.of<HistoricSitesProvider>(context, listen: false)
          .fetchAndSetRingforts()
          .then((value) =>
              Provider.of<HistoricSitesProvider>(context, listen: false)
                  .setFilteredSites(searchQuery, false, null))
          .then((value) {
        if (user != null) {
          Provider.of<UserProvider>(context, listen: false)
              .getCurrentUserData(user.uid)
              .then((value) {
            setState(() {
              userData = value;
              _isLoading = false;
            });
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      });

      _initRun = false;
      super.didChangeDependencies();
    }
  }

  // This method will ask user if they want to login to proceed Yes or no
  void _showErrorDialog(BuildContext ctx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('This option is only available to logged in Users'),
        content: Text('Do you want to login?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text('No '),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(ctx).backgroundColor,
            ),
            onPressed: () {
              Navigator.of(ctx).pushNamed(AuthenticationScreen.routeName);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  // This method is called then the list is pulled down to refresh.
  // it calls the HistoricSitesProvider to refresh the site list from Firebase
  // and then retrieves the list into the Widget class
  // Also used as the method for the future builder.
  // If there is a filter seach term entered it will filter the results to show.
  Future<void> _refreshRingfortList() async {
    print("calling refreshRingfortList");
    await Provider.of<HistoricSitesProvider>(context, listen: false)
        .fetchAndSetRingforts();

    setState(() {
      Provider.of<HistoricSitesProvider>(context, listen: false)
          .setFilteredSites(searchQuery, _showFavourites, userData);
    });
  }

  // Based on https://stackoverflow.com/questions/58908968/how-to-implement-a-flutter-search-app-bar
  // This method returns a Widget of TextField which is used to enter
  // the search term. It will be displayed in the toolbar if the
  // search icon is pressed. It triggers the updateSearchQuery method once
  // typing happen in the field. This triggers the state variable searchQuery
  // to be updated and triggers a rebuild. The rebuild will trigger the
  // Future builder which retrives the data and performs the filtering.
  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search Ringforts...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  // This method returns a Widget of an 'X' icon in the toolbar if isSearching
  // is true. If the search text input field is empty it will clear the text
  // on pressing it. It the search text input is already empty it will pop
  // the stack clearing the search input field.
  // If isSearching is not true it returns the search icon and the add Ringfort
  // Widget. (This is the default before the search icon is pressed.)
  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    // These are the appBar icons when the search icon is not pressed
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
      user != null
          ? Switch(
              value: _showFavourites,
              activeColor: Theme.of(context).errorColor,
              onChanged: (value) {
                setState(() {
                  _showFavourites = value;
                  Provider.of<HistoricSitesProvider>(context, listen: false)
                      .setFilteredSites(searchQuery, _showFavourites, userData);
                });
              },
            )
          : Container(),
      IconButton(
        onPressed: () {
          var user = Provider.of<User>(context, listen: false);
          if (user == null) {
            _showErrorDialog(context);
          } else {
            Navigator.of(context).pushNamed(AddRingfortScreen.routeName);
          }
        },
        icon: Icon(
          Icons.add_circle,
          size: 30,
        ),
      )
    ];
  }

  // This method is triggered when the search icon is pressed. It adds the
  // local history entry, which when 'pop' which trigger the _stopSearching method.
  // THe isSearching state variable is also set and rebuild triggered.
  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  // This method is triggered when typing starts in the search field.
  // It sets the state variable searchQuery and triggers a rebuild of the
  // widget tree. This will trigger the FutureBuilder to trigger in the
  // Widget tree and retrieve the ringforts and filter with searchQuery.
  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      Provider.of<HistoricSitesProvider>(context, listen: false)
          .setFilteredSites(searchQuery, _showFavourites, userData);
    });
  }

  // Triggered when the 'X' is pressed in search bar. Clears the filter
  // state variable searchQuery and triggers a rebuild.
  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  // Clears the search text field in toolbar and the searchQuery field.
  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  // Build a Text Widget for the Normal Screen title.
  Widget _buildTitle(BuildContext context) {
    return Text('Ringforts');
  }

  //--------------------------------------------------------
  // Widget build...
  //--------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : _buildTitle(context),
        actions: _buildActions(),
      ),
      drawer: AppDrawer(),
      // Wrapping with RefreshIndicator which takes a function which returns a future.
      // We define this to call the Provider class. The returned future tells the widget
      // to stop showing the loader symbol
      // Wrapping with a FutureBuilder which allows you to build a widget which depends on a Future
      // being returned. We can then check the status of the Future with the snapShow.connectionState
      // and display loader or the actual widget depending on if it's waiting or done.
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => _refreshRingfortList(),
              child: Consumer<HistoricSitesProvider>(
                builder: (context, historicSites, child) => historicSites
                            .filteredSites.length >
                        0
                    ? ListView.builder(
                        itemCount: historicSites.filteredSites.length,
                        itemBuilder: (ctx, index) => RingfortCard(
                              site: historicSites.filteredSites[index],
                              user: Provider.of<User>(context, listen: false),
                              userData: userData
                            ))
                    : Center(
                        child: Text('No matches'),
                      ),
              ),
            ),
    );
  }
}
