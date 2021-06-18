import 'package:flutter/material.dart';
import 'package:getstream_af/provider/userdata_provider.dart';
import 'package:stream_feed/stream_feed.dart';

import 'package:getstream_af/provider/client_provider.dart';

class PeopleScreen extends StatefulWidget {
  final User streamUser;
  const PeopleScreen({Key? key, required this.streamUser}) : super(key: key);

  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  Widget build(BuildContext context) {
    final _client = context.client;
    final users = UserDataProvider.usersData;
    // ..removeWhere((user) => user['id'].toString() == widget.streamUser.id);

    final followDialog = AlertDialog(
      title: Text('Follow User ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text("Yes"),
        ),
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text("No"),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('People'),
      ),
      body: ListView.separated(
        itemCount: users.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, index) {
          final user = users[index];
          return InkWell(
            onTap: () async {
              // dialog to request the follow request
              final result = await showDialog(
                context: context,
                builder: (_) => followDialog,
              );

              // if follow request is true
              if (result == true) {
                // for the follow request channel used is "timeline" of currentStream user is used
                final currentUserFeed = _client.flatFeed(
                  'timeline',
                  widget.streamUser.id!,
                );

                // selecting the userfeed streamUser wants to follow
                final selectedUserFeed =
                    _client.flatFeed('user', user['id'].toString());

                // add selecteduser to "follow" of currentUser
                await currentUserFeed.follow(selectedUserFeed);
              }
            },
            child: ListTile(
              leading: CircleAvatar(
                child: Text(user['name'].toString()),
              ),
              title: Text(
                user['name'].toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
