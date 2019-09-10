import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.uid})
      : super(key: key); //update this to include the uid in the constructor

  /// create a variable to save the data passed through navigation . if you look at splash screen where the user navigates to home page. title and user id or uid is passed throught it
  final String title;
  final String uid;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ///[TextEditingController] A controller for an editable text field.
  ///Whenever the user modifies a text field with an associated [TextEditingController], the text field updates [value] and the controller notifies its listeners. Listeners can then read the [text] and [selection] properties to learn what the user has typed or how the selection has been updated.
  TextEditingController taskTitleInputController;
  TextEditingController taskDescripInputController;
  FirebaseUser currentUser;

  @override
  initState() {
    taskTitleInputController = new TextEditingController();
    taskDescripInputController = new TextEditingController();
    this.getCurrentUser();
    super.initState();
  }

  ///[getCurrentUser] gets the current user  data from database
  void getCurrentUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    ///[deleteData] deletes a document from firestore database.
    deleteData(docId) {
      Firestore.instance
          .collection("users")
          .document(widget.uid)
          .collection('tasks')
          .document(docId)
          .delete()
          .catchError((e) {
        print(e);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            child: Text("Log Out"),
            textColor: Colors.white,
            onPressed: () {
              ///[FirebaseAuth.instance.signOut()] logouts the user.
              FirebaseAuth.instance
                  .signOut()
                  .then((result) =>
                      Navigator.pushReplacementNamed(context, "/login"))
                  .catchError((err) => print(err));
            },
          )
        ],
      ),
      body: Center(
        child: Container(
            padding: const EdgeInsets.all(20.0),

            ///[StreamBuilder] Creates a new [StreamBuilder] that builds itself based on the latest snapshot of interaction with the specified [stream] and whose build strategy is given by [builder].
            ///The [initialData] is used to create the initial snapshot.
            ///The [builder] must not be null.
            child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection("users")
                    .document(widget.uid)
                    .collection('tasks')
                    .snapshots(),
                builder: (BuildContext context,

                    ///[AsyncSnapshot] Immutable representation of the most recent interaction with an asynchronous computation.
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          final document = snapshot.data.documents;
                          final itemID =
                              snapshot.data.documents[index].documentID;
                          return Dismissible(
                            key: Key(itemID[index]),
                            onDismissed: (direction) {
                              deleteData(document[index].documentID);
                              Scaffold.of(context).showSnackBar(
                                  SnackBar(content: Text("item deleted")));
                            },
                            background: Container(color: Colors.red),
                            child: InkWell(
                              onTap: () {
                                taskTitleInputController.text =
                                    document[index].data["title"];
                                taskDescripInputController.text =
                                    document[index].data["description"];
                                _showDialog(true, itemID);
                              },
                              child: ListTile(
                                title: Text(document[index].data["title"]),
                                subtitle:
                                    Text(document[index].data["description"]),
                              ),
                            ),
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return Text("No Data");
                  } else {
                    return Container();
                  }
                }
                // },
                )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(false, ""),
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }

  _showDialog(bool update, String docId) async {
    await showDialog<String>(
      context: context,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          children: <Widget>[
            Text("Please fill all fields to create a new task"),
            Expanded(
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(labelText: 'Task Title*'),
                controller: taskTitleInputController,
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(labelText: 'Task Description*'),
                controller: taskDescripInputController,
              ),
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                taskTitleInputController.clear();
                taskDescripInputController.clear();
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text(update ? "Update" : 'Add'),
              onPressed: update
                  ? () {
                      if (taskDescripInputController.text.isNotEmpty &&
                          taskTitleInputController.text.isNotEmpty) {
                        Firestore.instance
                            .collection("users")
                            .document(widget.uid)
                            .collection('tasks')
                            .document(docId)
                            .updateData({
                              "title": taskTitleInputController.text,
                              "description": taskDescripInputController.text
                            })
                            .then((result) => {
                                  Navigator.pop(context),
                                  taskTitleInputController.clear(),
                                  taskDescripInputController.clear(),
                                })
                            .catchError((err) => print(err));
                      }
                    }
                  : () {
                      if (taskDescripInputController.text.isNotEmpty &&
                          taskTitleInputController.text.isNotEmpty) {
                        Firestore.instance
                            .collection("users")
                            .document(widget.uid)
                            .collection('tasks')
                            .add({
                              "title": taskTitleInputController.text,
                              "description": taskDescripInputController.text
                            })
                            .then((result) => {
                                  Navigator.pop(context),
                                  taskTitleInputController.clear(),
                                  taskDescripInputController.clear(),
                                })
                            .catchError((err) => print(err));
                      }
                    })
        ],
      ),
    );
  }
}
