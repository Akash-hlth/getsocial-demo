import 'package:flutter/material.dart';
import 'package:getstream_af/widgets/profile_activity_card.dart';
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
  bool _isLoading = true;

  List<Activity> myActivities = <Activity>[];

  Future<void> _loadActivities({bool pullToRefresh = false}) async {
    if (!pullToRefresh) setState(() => _isLoading = true);

    // set the stream to fetch the feeds of user
    // this first argument chooses the feed-type "user" ;
    // the second argument specifies the Id of current streamUser
    final userFeed = _client.flatFeed('user', widget.streamUser.id!);

    // using the userFeed we can access all the activities
    final activitesData = await userFeed.getActivities();

    if (!pullToRefresh) _isLoading = false;
    setState(() => myActivities = activitesData);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // the client updates after each login
    _client = context.client;
    _loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    final userFeed = _client.flatFeed('user', widget.streamUser.id!);
    return Scaffold(
      appBar: AppBar(title: Text('My Feeds')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : myActivities.isEmpty
                ? Text('No activities yet!')
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: myActivities.length,
                    itemBuilder: (_, index) {
                      final activity = myActivities[index];
                      final userFeed =
                          _client.flatFeed('user', widget.streamUser.id!);

                      return Card(
                        elevation: 15,
                        child: ProfileActivityCard(
                          activity: activity,
                          removeActivity: removeActivity,
                          updateActivity: updateActivity,
                        ),
                      );
                    },
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
            await postActivity(message);
            //load all the activities
            _loadActivities();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Message Feed Cant Be Empty'),
              ),
            );
          }
        },
      ),
    );
  }

  Future postActivity(String message) async {
    // create the activity for the message
    // actor refers to the msg creator
    int fId = 0;
    final activity = Activity(
        actor: createUserReference(widget.streamUser.id!),
        verb: 'text',
        object: '1',
        time: DateTime.now(),
        foreignId: 'msg:$fId',
        extraData: {
          'text': message,
        });

    // create the flat-feed for the "user" channel (it enables option to follow and unfollow)
    final userFeed = _client.flatFeed('user', widget.streamUser.id!);

    // add single activity for the current streamuser
    await userFeed.addActivity(activity);
    fId += 1;
  }

  Future removeActivity(String activityId) async {
    final userFeed = _client.flatFeed('user', widget.streamUser.id!);

    await userFeed.removeActivityById(activityId);
    _loadActivities();
    print("Removed Activity Here");
  }

  Future updateActivity(String activityId, String oldMsg) async {
    final msgUpdated = await showDialog<String>(
      context: context,
      builder: (_) => AddMessageDialog(oldMsg: oldMsg),
    );

    print('Updated : ' + msgUpdated.toString());

    if (msgUpdated != null) {
      print('ActivityId : ' + activityId);
      print('UserId : ' + widget.streamUser.id!);
      print(_client.currentUser!.userId);

      final userFeed1 = _client.flatFeed('user', 'user1');

      try {
        final res = await userFeed1.updateActivityById(
          id: activityId,
          set: {'text': msgUpdated},
        );
        print('Update Result : ');
        print(res);
        _loadActivities();
      } catch (e) {
        print("Error Updating");
        print(e);
      }
    }

    print("Updated Activity Here");
  }
}
