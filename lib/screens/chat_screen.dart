import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_buffer/models/chat_model.dart';
import 'package:social_media_buffer/models/post_model.dart';
import 'package:social_media_buffer/widgets/message_list_title.dart';

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";

  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String _message = "";

  late TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Post post = ModalRoute.of(context)!.settings.arguments as Post;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("posts")
                    .doc(post.id)
                    .collection("comments")
                    .orderBy("timeStamp")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.none) {
                    return const Center(child: Text("Loading..."));
                  }
                  return ListView.builder(
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (context, index) {
                        final QueryDocumentSnapshot doc =
                            snapshot.data!.docs[index];

                        final ChatModel chatModel = ChatModel(
                            userId: doc["userId"],
                            userName: doc["userName"],
                            message: doc["message"],
                            timestamp: doc["timeStamp"]);

                        return Align(
                            alignment: chatModel.userId == currentUserId
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: MessageListTile(chatModel));
                      });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: TextField(
                          controller: _textEditingController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: "Enter message",
                          ),
                          onChanged: (value) {
                            _message = value;
                          },
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("posts")
                              .doc(post.id)
                              .collection("comments")
                              .add({
                                "userId":
                                    FirebaseAuth.instance.currentUser!.uid,
                                "userName": FirebaseAuth
                                    .instance.currentUser!.displayName,
                                "message": _message,
                                "timeStamp": Timestamp.now(),
                              })
                              .then((value) => print("chat doc added"))
                              .catchError((onError) => print(
                                  "Error has occurred while adding chat doc"));

                          _textEditingController.clear();
                          setState(() {
                            _message = "";
                          });
                        },
                        icon: const Icon(Icons.arrow_forward_ios_rounded)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
