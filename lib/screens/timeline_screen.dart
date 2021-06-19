import 'package:flutter/material.dart';
import 'package:getstream_af/widgets/activity_card.dart';
import 'package:stream_feed/stream_feed.dart';

import 'package:getstream_af/provider/client_provider.dart';

class TimeLineScreen extends StatefulWidget {
  final User streamUser;
  const TimeLineScreen({Key? key, required this.streamUser}) : super(key: key);

  @override
  _TimeLineScreenState createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen> {
  late final StreamFeedClient _client;
  bool _isLoading = true;
  List<Activity> activities = <Activity>[];

  Future<void> _loadActivities({bool pullToRefresh = false}) async {
    if (!pullToRefresh) setState(() => _isLoading = true);

    final userFeed = _client.flatFeed('timeline', widget.streamUser.id!);
    final data = await userFeed.getActivities();
    if (!pullToRefresh) _isLoading = false;
    setState(() => activities = data);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _client = context.client;
    _loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    print('Loading : ' + _isLoading.toString());
    return Scaffold(
      appBar: AppBar(title: Text('Follower Feeds')),
      body: RefreshIndicator(
        onRefresh: () => _loadActivities(pullToRefresh: true),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : activities.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        Text('No Followers yet!'),
                        TextButton(
                          onPressed: _loadActivities,
                          child: Text('Reload'),
                        )
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: activities.length,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, index) {
                      final activity = activities[index];
                      return ActivityCard(
                          activity: activity,
                          likeActivity: likeActivity,
                          getLikeCount: getLikesCount);
                    },
                  ),
      ),
    );
  }

  Future likeActivity(String activityId) async {
    try {
      // first the like button is added on activity Id
      final res = await _client.reactions.add('like', activityId);
      // print(res);

    } catch (e) {
      print('Could not Like the activity');
      print(e);
    }
    print('Like Added');
  }

  Future getLikesCount(String activityId) async {
    try {
      // reactions are fetched for data like -> count ,latest reactions
      // add the specific details in the flags
      final res2 = await _client
          .flatFeed('timeline', widget.streamUser.id!)
          .getEnrichedActivities(flags: EnrichmentFlags().withReactionCounts());

      var count = res2.firstWhere((element) => element.id == activityId);

      // print('Count : ' + count.toString());
      var likesCount = count.reactionCounts!['like'];
      return likesCount;
    } catch (e) {
      print('Could not get the activity');
      print(e);
    }
  }
}
