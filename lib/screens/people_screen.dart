import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getstream_af/provider/userdata_provider.dart';
import 'package:stream_feed/stream_feed.dart';

import 'package:getstream_af/provider/client_provider.dart';

enum showUsers { all, followers, following }

class PeopleScreen extends StatefulWidget {
  final User streamUser;
  const PeopleScreen({Key? key, required this.streamUser}) : super(key: key);

  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late var userDisplay;
  late var usersArr = [];
  late StreamFeedClient _client;

  @override
  void initState() {
    super.initState();
    userDisplay = showUsers.all;
    usersArr = [...UserDataProvider.usersData]
      ..removeWhere((user) => user['id'].toString() == widget.streamUser.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _client = context.client;
  }

  @override
  Widget build(BuildContext context) {
    final userFeed = _client.flatFeed('user', widget.streamUser.id!);

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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: Text('All'),
                onPressed: () {
                  final allusers = [...UserDataProvider.usersData]..removeWhere(
                      (user) => user['id'].toString() == widget.streamUser.id);

                  setState(() {
                    userDisplay = showUsers.all;
                    usersArr = allusers;
                  });
                },
              ),
              TextButton(
                child: Text('Followers'),
                onPressed: () async {
                  final followers = await userFeed.followers();
                  setState(() {
                    userDisplay = showUsers.followers;
                    usersArr = followers;
                  });
                  print('Followers ');
                  print(followers);
                },
              ),
              TextButton(
                child: Text('Following'),
                onPressed: () async {
                  final timelinefeed =
                      _client.flatFeed('timeline', widget.streamUser.id!);
                  final following = await timelinefeed.following();
                  // await timelinefeed.followers();
                  setState(() {
                    userDisplay = showUsers.following;
                    usersArr = following;
                  });
                  print('Following ');
                  print(following);
                },
              ),
            ],
          ),
          if (usersArr.isEmpty && userDisplay == showUsers.all)
            Center(
              child: Text('Seems you are the only one here'),
            ),
          if (usersArr.isEmpty && userDisplay == showUsers.followers)
            Center(
              child: Text('You dont have any followers yet'),
            ),
          if (usersArr.isEmpty && userDisplay == showUsers.following)
            Center(
              child: Text('You dont follow anyone yet'),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: usersArr.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, index) {
                final user = usersArr[index];

                if (userDisplay == showUsers.all) {
                  return allUserCard(user, _client, followDialog);
                }

                if (userDisplay == showUsers.followers) {
                  return followUserCard(user);
                }

                if (userDisplay == showUsers.following) {
                  return followingUserCard(user, _client, followDialog);
                }
                return allUserCard(user, _client, followDialog);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget allUserCard(var user, var _client, Widget followDialog) {
    return ListTile(
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
      trailing: IconButton(
          icon: Icon(Icons.add_circle_outline),
          onPressed: () async {
            final result = await showDialog(
              context: context,
              builder: (_) => followDialog,
            );

            // if follow request is true
            if (result == true) {
              // for the follow request channel used is "timeline" of currentStream user is used
              final timelineUserFeed = _client.flatFeed(
                'timeline',
                widget.streamUser.id!,
              );

              // selecting the userfeed streamUser wants to follow
              final selectedUserFeed =
                  _client.flatFeed('user', user['id'].toString());

              // add selecteduser to "follow" of currentUser
              await timelineUserFeed.follow(selectedUserFeed);
            }
          }),
    );
  }

// widget to display followers of the user
  Widget followUserCard(var user) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(user.feedId.toString()),
      ),
      title: Text(
        user.feedId.toString(),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

// widget to display following members of the user
  Widget followingUserCard(var user, var _client, Widget followDialog) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(user.targetId.toString()),
      ),
      title: Text(
        user.targetId.toString(),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w300,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.remove_circle_outline),
        onPressed: () async {
          final result =
              await showDialog(context: context, builder: (_) => followDialog);

          // if unfollow request is true
          if (result == true) {
            // for the follow request channel used is "timeline" of currentStream user is used
            final timelineUserFeed = _client.flatFeed(
              'timeline',
              widget.streamUser.id!,
            );

            // selecting the userfeed streamUser wants to unfollow

            // instead of user1 get the dynamic id of user
            print(user);
            final selectedUserFeed =
                _client.flatFeed(user.target_id.toString());

            // add selecteduser to "unfollow" of currentUser
            await timelineUserFeed.unfollow(selectedUserFeed);

            // keepHistory = true allows to keep the previous history
          }
        },
      ),
    );
  }
}
