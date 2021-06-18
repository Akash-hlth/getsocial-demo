import 'package:flutter/material.dart';
import 'package:getstream_af/provider/userdata_provider.dart';
import 'package:stream_feed/stream_feed.dart';

class ProfileActivityCard extends StatelessWidget {
  final Activity activity;
  final Function removeActivity;
  final Function updateActivity;

  const ProfileActivityCard({
    Key? key,
    required this.activity,
    required this.removeActivity,
    required this.updateActivity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = UserDataProvider.usersData.firstWhere((element) {
      return createUserReference(element['id'].toString()) == activity.actor;
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(user['name'].toString()),
                radius: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Msg By : ' + user['name'].toString()),
                    Text('Shared At : ' + activity.time.toString())
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => updateActivity(
                        activity.id, activity.extraData!['text']),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => removeActivity(activity.id),
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 10),
          Text(
            activity.extraData!['text'].toString(),
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
