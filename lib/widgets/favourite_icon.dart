import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/user_provider.dart';

class FavouriteIcon extends StatefulWidget {
  final String ringfortUID;
  final User user;

  const FavouriteIcon({
    @required this.ringfortUID,
    @required this.user,
  });

  @override
  State<FavouriteIcon> createState() => _FavouriteIconState();
}

class _FavouriteIconState extends State<FavouriteIcon> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userData, child) => GestureDetector(
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: widget.user == null
              ? Container()
              : userData.userFavourites.any((fav) => fav == widget.ringfortUID)
                  ? Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                  : Icon(
                      Icons.favorite_border,
                      color: Colors.red,
                    ),
        ),
        onTap: () async {
          if (userData.userFavourites.any((fav) => fav == widget.ringfortUID)) {
            await Provider.of<UserProvider>(context, listen: false)
                .removeFavouriteFromCurrentUser(widget.ringfortUID);
          } else {
            await Provider.of<UserProvider>(context, listen: false)
                .addFavouritetoCurrentUser(widget.ringfortUID);
          }
        },
      ),
    );
  }
}
