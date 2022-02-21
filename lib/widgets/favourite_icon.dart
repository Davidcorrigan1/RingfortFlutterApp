import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ringfort_app/models/user_data.dart';
import 'package:ringfort_app/widgets/ringfort_card.dart';

import '../providers/user_provider.dart';

class FavouriteIcon extends StatefulWidget {
  final String ringfortUID;

  const FavouriteIcon({@required this.ringfortUID});

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
          child: userData.userFavourites.any((fav) => fav == widget.ringfortUID)
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
