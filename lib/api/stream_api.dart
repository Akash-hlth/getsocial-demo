import 'package:getstream_af/config/config.dart';
import 'package:stream_feed/stream_feed.dart';

class StreamApi {
  Future<Token> login(String user) async {
    // register the user at backend first
    var serverClient = StreamFeedClient.connect(
      Config.apiKey,
      secret: Config.secret,
      runner: Runner.server,
      options: StreamHttpClientOptions(
        location: Location.usEast,
        connectTimeout: Duration(seconds: 15),
      ),
    );

    // get the token for the frontEnd
    final userToken = serverClient.frontendToken(user);
    // print(userToken);

    // use the token to set the user at frontEnd
    return userToken;
  }
}
