import 'package:getstream_af/config/config.dart';
import 'package:stream_feed/stream_feed.dart';

class StreamApi {
  StreamFeedClient getServerClient() {
    // register the user at backend first
    var serverClient = StreamFeedClient.connect(
      Config.apiKey,
      secret: Config.secret,
      appId: '1129273',
      runner: Runner.server,
      options: StreamHttpClientOptions(
        location: Location.usEast,
        connectTimeout: Duration(seconds: 15),
      ),
    );

    return serverClient;
  }

  Future<Token> login(String user) async {
    // get the token for the frontEnd
    final userToken = getServerClient().frontendToken(user);
    // print(userToken);

    // use the token to set the user at frontEnd
    return userToken;
  }
}
