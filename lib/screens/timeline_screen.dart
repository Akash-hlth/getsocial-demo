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

    final userFeed =
        _client.flatFeed('timeline', widget.streamUser.id!); //Modified
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
                      return ActivityCard(activity: activity);
                    },
                  ),
      ),
    );
  }
}
