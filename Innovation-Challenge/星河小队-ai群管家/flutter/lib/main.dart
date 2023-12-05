import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import './api.dart';
import './bot_chat_page.dart';
import './messages_page.dart';

// var appKey = "1162221218164444#demo";
var appKey = "1181231114210730#demo";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  assert(appKey.isNotEmpty, "appKey is empty");
  EMOptions options =
      EMOptions(appKey: appKey, autoLogin: false, debugModel: true);
  await EMClient.getInstance.init(options);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter SDK Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController = ScrollController();
  String _userId = "";
  String _password = "";
  String _messageContent = "";
  String _chatId = "";
  bool isLocal = true;
  final List<String> _logText = [];

  @override
  void initState() {
    super.initState();
    _addChatListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          tooltip: "change env \tlocal:" + isLocal.toString(),
          onPressed: () {
            if (isLocal) {
              useRemoteApi();
            } else {
              useLocalApi();
            }
            setState(() {
              isLocal = !isLocal;
            });
          }),
      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            TextField(
              decoration: const InputDecoration(hintText: "Enter username"),
              onChanged: (username) => _userId = username,
            ),
            TextField(
              decoration: const InputDecoration(hintText: "Enter password"),
              onChanged: (password) => _password = password,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: _signIn,
                    child: const Text("SIGN IN"),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.lightBlue),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: _signOut,
                    child: const Text("SIGN OUT"),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.lightBlue),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: _signUp,
                    child: const Text("SIGN UP"),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.lightBlue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                  hintText: "Enter the username you want to send"),
              onChanged: (chatId) => _chatId = chatId,
            ),
            // TextField(
            //   decoration: const InputDecoration(hintText: "Enter content"),
            //   onChanged: (msg) => _messageContent = msg,
            // ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => pushToChatPage(_chatId),
              child: const Text("start chat with"),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
              ),
            ),
            TextButton(
              onPressed: () {
                if (EMClient.getInstance.currentUserId == null) {
                  _addLogToConsole('user not login');
                  return;
                }
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return const BotChatPage();
                }));
              },
              child: const Text("Go to chat list"),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
              ),
            ),
            Flexible(
              child: ListView.builder(
                controller: scrollController,
                itemBuilder: (_, index) {
                  return Text(_logText[index]);
                },
                itemCount: _logText.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    EMClient.getInstance.chatManager.removeMessageEvent("UNIQUE_HANDLER_ID");
    EMClient.getInstance.chatManager.removeEventHandler("UNIQUE_HANDLER_ID");
    super.dispose();
  }

  void _addChatListener() {
    EMClient.getInstance.chatManager.addMessageEvent(
        "UNIQUE_HANDLER_ID",
        ChatMessageEvent(
          onSuccess: (msgId, msg) {
            _addLogToConsole("on message succeed");
          },
          onProgress: (msgId, progress) {
            _addLogToConsole("on message progress");
          },
          onError: (msgId, msg, error) {
            _addLogToConsole(
              "on message failed, code: ${error.code}, desc: ${error.description}",
            );
          },
        ));

    EMClient.getInstance.chatManager.addEventHandler(
      "UNIQUE_HANDLER_ID",
      EMChatEventHandler(
        onMessagesReceived: (messages) {
          for (var msg in messages) {
            switch (msg.body.type) {
              case MessageType.TXT:
                {
                  EMTextMessageBody body = msg.body as EMTextMessageBody;
                  _addLogToConsole(
                    "receive text message: ${body.content}, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.IMAGE:
                {
                  _addLogToConsole(
                    "receive image message, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.VIDEO:
                {
                  _addLogToConsole(
                    "receive video message, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.LOCATION:
                {
                  _addLogToConsole(
                    "receive location message, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.VOICE:
                {
                  _addLogToConsole(
                    "receive voice message, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.FILE:
                {
                  EMClient.getInstance.chatManager.downloadAttachment(msg);
                  _addLogToConsole(
                    "receive file message, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.CUSTOM:
                {
                  _addLogToConsole(
                    "receive custom message, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.CMD:
                {
                  // 当前回调中不会有 CMD 类型消息，CMD 类型消息通过 [EMChatManagerEventHandle.onCmdMessagesReceived] 回调接收
                }
                break;
              case MessageType.COMBINE:
                {
                  _addLogToConsole(
                    "receive combine message, from: ${msg.from}",
                  );
                }
            }
          }
        },
      ),
    );
  }

  void pushToChatPage(String userId) async {
    if (userId.isEmpty) {
      _addLogToConsole('UserId is null');
      return;
    }
    if (EMClient.getInstance.currentUserId == null) {
      _addLogToConsole('user not login');
      return;
    }
    EMConversation? conv =
        await EMClient.getInstance.chatManager.getConversation(userId);
    Future(() {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return MessagesPage(conv!);
      }));
    });
  }

  void _signIn() async {
    if (_userId.isEmpty || _password.isEmpty) {
      _addLogToConsole("username or password is null");
      return;
    }

    try {
      _addLogToConsole("sign in...");
      await EMClient.getInstance.login(_userId, _password);
      _addLogToConsole("sign in succeed, username: $_userId");
    } on EMError catch (e) {
      _addLogToConsole("sign in failed, e: ${e.code} , ${e.description}");
    }
  }

  void _signOut() async {
    try {
      _addLogToConsole("sign out...");
      await EMClient.getInstance.logout(true);
      _addLogToConsole("sign out succeed");
    } on EMError catch (e) {
      _addLogToConsole(
          "sign out failed, code: ${e.code}, desc: ${e.description}");
    }
  }

  void _signUp() async {
    if (_userId.isEmpty || _password.isEmpty) {
      _addLogToConsole("username or password is null");
      return;
    }

    try {
      _addLogToConsole("sign up...");
      await EMClient.getInstance.createAccount(_userId, _password);
      _addLogToConsole("sign up succeed, username: $_userId");
    } on EMError catch (e) {
      _addLogToConsole("sign up failed, e: ${e.code} , ${e.description}");
    }
  }

  void _sendMessage() async {
    if (_chatId.isEmpty || _messageContent.isEmpty) {
      _addLogToConsole("single chat id or message content is null");
      return;
    }

    var msg = EMMessage.createTxtSendMessage(
      targetId: _chatId,
      content: _messageContent,
    );

    await EMClient.getInstance.chatManager.sendMessage(msg);
  }

  void _addLogToConsole(String log) {
    _logText.add(_timeString + ": " + log);
    setState(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  String get _timeString {
    return DateTime.now().toString().split(".").first;
  }
}
