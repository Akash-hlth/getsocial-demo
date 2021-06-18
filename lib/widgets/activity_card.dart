import 'package:flutter/material.dart';
import 'package:getstream_af/provider/userdata_provider.dart';
import 'package:stream_feed/stream_feed.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print('Activity : ' + activity.toString());
    final user = UserDataProvider.usersData.firstWhere((element) {
      // print(element);
      return createUserReference(element['id'].toString()) == activity.actor;
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(user['name'].toString()),
                radius: 30,
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Msg By : ' + user['name'].toString()),
                    Text('Shared At : ' + activity.time.toString())
                  ],
                ),
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
