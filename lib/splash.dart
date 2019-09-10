import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override

  ///[initState] check if there is account or not. if there is account. the user is navigated to home screen. if user account is not found the user is redirected to login page.
  /// check if there is account or not. if there is account. the user is navigated to home screen. if user account is not found the user is redirected to login page.

  initState() {
    ///The entry point of the Firebase Authentication SDK
    /// [instance ] : Provides an instance of this class corresponding to the default app.
    FirebaseAuth.instance
        .currentUser()
        .then((currentUser) => {
              /// check if current user is null or not.
              if (currentUser == null)

                ///[if] not null navigate to login page.
                {Navigator.pushReplacementNamed(context, "/login")}
              else
                {
                  ///[else] get user data from firestore database .
                  ///[collection] Gets a Collection Reference for the specified Firestore path.
                  /// [document] Returns a DocumentReference with the provided path.
                  ///If no [path] is provided, an auto-generated ID is used.
                  ///The unique key generated is prefixed with a client-generated timestamp so that the resulting list will be chronologically-sorted.
                  ///[get] Reads the document referenced by this [DocumentReference].
                  ///If no document exists, the read will return null.
                  ///[then] Register callbacks to be called when this future completes.
                  Firestore.instance
                      .collection("users")
                      .document(currentUser.uid)
                      .get()
                      .then((DocumentSnapshot result) =>

                          ///navigates to the home page.
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage(
                                        title: result["fname"] + "'s Tasks",
                                        uid: currentUser.uid,
                                      ))))
                      .catchError((err) => print(err))
                }
            })

        /// catch error if the network call is not success and then prints error in console.
        .catchError((err) => print(err));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          child: Image.network(
              "https://upload.wikimedia.org/wikipedia/commons/5/53/Loading-red-spot.gif"),
        ),
      ),
    );
  }
}
