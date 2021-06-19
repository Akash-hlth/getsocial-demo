import 'package:flutter/material.dart';
import 'package:getstream_af/provider/userdata_provider.dart';
import 'package:stream_feed/stream_feed.dart';

class ActivityCard extends StatefulWidget {
  final Activity activity;
  final Function likeActivity;
  final Function getLikeCount;

  const ActivityCard(
      {Key? key,
      required this.activity,
      required this.likeActivity,
      required this.getLikeCount})
      : super(key: key);

  @override
  _ActivityCardState createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  late var likesCount = 0;

  Future<void> _likesCountFunc() async {
    var count = await widget.getLikeCount(widget.activity.id);
    setState(() {
      likesCount = count;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _likesCountFunc();
  }

  @override
  Widget build(BuildContext context) {
    final user = UserDataProvider.usersData.firstWhere((element) {
      return createUserReference(element['id'].toString()) ==
          widget.activity.actor;
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
                    Text('Shared At : ' + widget.activity.time.toString())
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Activity : ${widget.activity.extraData!['text']}',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          Row(
            children: [
              IconButton(
                  icon: Icon(Icons.thumb_up),
                  onPressed: () async {
                    await widget.likeActivity(widget.activity.id);
                    var count = await widget.getLikeCount(widget.activity.id);
                    setState(() {
                      likesCount = count;
                    });
                  }),
              Text('Likes Count : $likesCount'),
            ],
          )
        ],
      ),
    );
  }
}
