import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Anket"),
        ),
        body: SurveyList(),
      ),
    );
  }
}


class SurveyList extends StatefulWidget {
  //Firebase.initializeApp();
  //FirebaseFirestore firestore = FirebaseFirestore.instance;
  //final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('dilanketi').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text("Error: ${snapshot.error}");
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text("Loading...");
          default:
            return new ListView(
              children: snapshot.data.docs.map((DocumentSnapshot document) {
                  return new ListTile(
                    title: new Text(document.data()['isim']),
                    subtitle: new Text(document.data()["oy"].toString()),
                  );
              }).toList(),
            );
        }
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    return SurveyListState();
  }
}


class SurveyListState extends State{
  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("dilanketi").snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return LinearProgressIndicator();
        }
        else{
          buildBody(context, snapshot.data.docs);
        }
      },
    );


  }

  Widget buildBody(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: EdgeInsets.only(top:20.0),
      children: snapshot.map <Widget> ((data) => buildListItem(context, data)).toList(),
    );
  }

  buildListItem(BuildContext context, DocumentSnapshot data) {
      final row = Anket.fromSnapshot(data);
      return Padding(
        key:ValueKey(row.isim),
        padding: EdgeInsets.symmetric(horizontal:16.0, vertical:8.0),
        child:Container(
          decoration:BoxDecoration(
             border: Border.all(color:Colors.grey),
              borderRadius:BorderRadius.circular(5.0)
            ),
          child: ListTile(
            title:Text(row.isim),
            trailing: Text(row.oy.toString()),
            onTap:() => Firestore.instance.runTransaction((transaction) async{
              final freshSnapshot = await transaction.get(row.reference);
              final fresh= Anket.fromSnapshot(freshSnapshot);

              await transaction.update((row.reference), {'oy':fresh.oy+1});
            }),
          ),
      )
      );
  }
}

final sahteSnapshot = [
  {"isim":"C#","oy":3},
  {"isim":"Java","oy":5},
  {"isim":"C++","oy":1},
  {"isim":"Python","oy":8},
];

class Anket{
  String isim;
  int oy;
  DocumentReference reference;
  Anket.fromMap(Map<String,dynamic> map, {this.reference})
      :assert(map["isim"]!=null),assert(map["oy"]!=null),
        isim=map["isim"], oy=map["oy"];

  Anket.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data(),reference:snapshot.reference);
}