import 'package:flutter/material.dart';
import 'package:getstream_af/widgets/dialog.dart';
import 'package:stream_feed/stream_feed.dart';

import 'package:getstream_af/provider/client_provider.dart';

class ProfileScreen extends StatefulWidget {
  final User streamUser;
  const ProfileScreen({Key? key, required this.streamUser}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final StreamFeedClient _client;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // the client updates after each login
    _client = context.client;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Feeds')),
      body: Center(
        child: Column(
          children: [
            Container(
              child: Text('My feeds here'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message_outlined),
        onPressed: () async {
          // fetching the message from dialog box
          final message = await showDialog<String>(
            context: context,
            builder: (_) => AddMessageDialog(),
          );

          // if the message is not null proceed to post the activity
          if (message != null) {
            print('Message : ' + message);
            print('Id : ' + widget.streamUser.id!);

            // create the activity for the message
            // actor refers to the msg creator
            final activity = Activity(
                actor: createUserReference(widget.streamUser.id!),
                verb: 'text',
                object: '1',
                extraData: {
                  'text': message,
                });

            // create the flat-feed for the "user" channel (it enables option to follow and unfollow)
            final userFeed = _client.flatFeed('user', widget.streamUser.id!);

            // add single activity for the current streamuser
            await userFeed.addActivity(activity);
          }
        },
      ),
    );
  }
}
