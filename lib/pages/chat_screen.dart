import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Hope/main.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _bot = const types.User(id: 'bot');
  bool _isLoading = false;
  bool _initialBotResponseDisplayed = false;

  @override
  void initState() {
    super.initState();
    _simulateInitialUserInput();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFECF1FA),
      appBar: AppBar(
        title:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/Layer 1.png', height: 27,),
            const Text("Project Hope", style: TextStyle(fontSize: 20, color: Color(0XFF181461)),),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0XFFECF1FA),
        shadowColor: Colors.black,
        elevation: 4,
      ),
      body: Chat(
        theme: const DefaultChatTheme(
          backgroundColor: Color(0XFFCFCFCF),
          inputTextColor: Colors.black,
          inputBackgroundColor: Color(0XFFECF1FA),

        ),
        messages: _messages,
        user: _user,
        onSendPressed: _handleSendPressed,
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );

    setState(() {
      _isLoading = true;
      _messages.insert(0, textMessage);
      _messages.insert(
          0, types.TextMessage(author: _bot, id: DateTime.now().millisecondsSinceEpoch.toString(), text: '...'));
    });

    _getResponseFromGemini(message.text);
  }

  void _getResponseFromGemini(String query) async {
    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$APIKEY'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": query}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final botText = responseData['candidates'][0]['content']['parts'][0]['text'];

        final botMessage = types.TextMessage(
          author: _bot,
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: botText,
        );

        setState(() {
          _isLoading = false;
          _messages.removeAt(0);
          _messages.insert(0, botMessage);
        });
      } else {
        setState(() {
          _isLoading = false;
          _messages.removeAt(0);
          _messages.insert(0, types.TextMessage(
              author: _bot,
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: "Oops! Something went wrong. Please try again later."
          ),
          );
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _messages.removeAt(0);
        _messages.insert(0, types.TextMessage(
            author: _bot,
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: "Oops! Something went wrong. Please try again later."
        ),
        );
      });
    }
  }

  void _simulateInitialUserInput() {
    if (!_initialBotResponseDisplayed) {
      _getResponseFromGemini("Take on a role as a therapist");
      _initialBotResponseDisplayed = true;
    }
  }
}
