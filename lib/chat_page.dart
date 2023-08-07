import 'package:chat_bot/models/message_model.dart';
import 'package:dialogflow_flutter/dialogflowFlutter.dart';
import 'package:dialogflow_flutter/googleAuth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<MessageModel> messages = [];
  late DialogFlow dialogflow;
  bool isInitialized = false;
  List actions = [];

  TextEditingController textEditingController = TextEditingController();
  @override
  void initState() {
    initializeData();
    super.initState();
  }

  initializeData() async {
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: "assets/credentials.json").build();
    dialogflow = DialogFlow(authGoogle: authGoogle, language: "en");
    setState(() {
      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Chat Page', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: messages[index].isMyMessage
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (messages[index].isMyMessage)
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                          ),
                        Flexible(
                            child: Card(
                                color: messages[index].isMyMessage
                                    ? ThemeData().canvasColor
                                    : Colors.purple[100],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(messages[index].message),
                                ))),
                        if (!messages[index].isMyMessage)
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                          ),
                      ],
                    );
                  }),
            ),
            Wrap(
              children: [
                for (var action in actions)
                  InkWell(
                    onTap: () => _onActionClick(action),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(action),
                        ),
                      ),
                    ),
                  )
              ],
            ),
            if (isInitialized)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      decoration: const InputDecoration(
                        hintText: 'Enter a message',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _sendMessage(),
                    icon: const Icon(
                      Icons.send,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  _onActionClick(String action) {
    textEditingController.text = action;
    _sendMessage();
  }

  void _sendMessage() {
    setState(() {
      messages.insert(0,
          MessageModel(message: textEditingController.text, isMyMessage: true));
      _sendToDialogFlow(textEditingController.text);
      textEditingController.clear();
      actions = [];
    });
  }

  void _sendToDialogFlow(message) async {
    AIResponse aiResponse = await dialogflow.detectIntent(message);
    for (var data in aiResponse.queryResult?.fulfillmentMessages ?? []) {
      if (data['payload'] != null) {
        actions = data['payload']['actions'];
      }
    }
    var response = aiResponse.getMessage();

    print(response);
    setState(() {
      messages.insert(
          0,
          MessageModel(
            message: response ?? '...',
            isMyMessage: false,
          ));
    });
  }
}
