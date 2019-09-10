import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'commonComponents/customCard.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.uid})
      : super(key: key); //update this to include the uid in the constructor
  final String title;
  final String uid; //include this

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  void getCurrentUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
  }

  @override
  Widget build(BuildContext context) {
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
            child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection("users")
                    .document(widget.uid)
                    .collection('tasks')
                    .snapshots(),
                builder: (BuildContext context,
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
