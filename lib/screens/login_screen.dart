import 'package:flutter/material.dart';
import 'package:getstream_af/api/stream_api.dart';
import 'package:getstream_af/config/config.dart';
import 'package:getstream_af/provider/client_provider.dart';
import 'package:getstream_af/provider/userdata_provider.dart';
import 'package:getstream_af/screens/bottom_bar_screen.dart';
import 'package:stream_feed/stream_feed.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stream Feed Login')),
      body: Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text('Enter Username'),
                SizedBox(height: 20),
                TextField(
                  controller: userNameController,
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  child: Text('Login'),
                  onPressed: () async {
                    final client = await loginUser(context);

                    print(client);
                    final user = await client
                        .setUser({'userName': userNameController.text});

                    // the client provider wrapper helps to
                    // pass the client over the screens
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => ClientProvider(
                          client: client,
                          child: BottomBarScreen(streamUser: user),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future loginUser(BuildContext context) async {
    if (userNameController.text.length > 0) {
      var userName = userNameController.text;
      print('Users List : ' + UserDataProvider.usersData.toString());
      Token token;

      for (var userDoc in UserDataProvider.usersData) {
        if (userDoc.containsKey('id')) {
          if (userDoc['name'] == userName) {
            token = await StreamApi().login(userName);
            userDoc['token'] = token;
            print('Previous Account Logged In');

            final client =
                StreamFeedClient.connect(Config.apiKey, token: token);

            return client;
          }
        }
      }

      print('New Account Formed');
      token = await StreamApi().login(userName);

      // add the token for temporary data
      UserDataProvider.usersData
          .add({'id': userName.toLowerCase(), 'name': userName});

      final client = StreamFeedClient.connect(Config.apiKey, token: token);
      return client;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid User'),
        ),
      );
    }
  }
}
