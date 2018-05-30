import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  // const MyApp({Key key}) : super(Key : key);
  const MyApp({
    Key key,
    this.color = Colors.blue
  }) : super(key: key);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: color//Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter SQLite Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();

//   expect(dynamic value, dynamic expected, {String reason}) {
//   if (value != expected) {
//     if (value is List || value is Map) {
//       if (!const DeepCollectionEquality().equals(value, expected)) {
//         throw new Exception("collection $value != $expected ${reason ?? ""}");
//       }
//       return;
//     }
//     throw new Exception("$value != $expected ${reason ?? ""}");
//   }
// }
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    databaseConfig();
  }

  List<Map> sqlData;
  Database database;
  var userList = <Widget>[
    // new Text(
    //   'You have pushed the button this many times:',
    // ),
  ];

  void reloadList() {
    setState(() {
      userList = [];
      for (var i = 0; i < sqlData.length; i++) {
        print(sqlData[i]);
        var user = sqlData[i];

        userList.add(new Container(
          child: new ListTile(
            title: new Text(user.toString()),
          ),
        )

            // new Container(
            //   margin: new EdgeInsets.only(left:  20.0,top: 20.0),
            //   child: new Text(user.toString()),
            // )
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // setup();

    // for (var i=0; i<sqlData.length; i++ ){
    //   print(sqlData[i]);
    // }

    var textField = new TextFormField(
      // focusNode: new FocusNode(),
      decoration: new InputDecoration(labelText: "Enter Name"),
      controller: myController,
    );
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            height: 150.0,
            color: Colors.red[100],
            child: new Column(
              children: <Widget>[
                new Container(
                  margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                  child: textField,
                ),
                new Container(
                  height: 20.0,
                ),
                new RaisedButton(
                  child: new Text("Add"),
                  onPressed: insertData,
                )
                // new TextField(
                //   decoration: new InputDecoration(
                //     hintText: "Enter name",
                //     border: new OutlineInputBorder(gapPadding: 10.0 )
                //   ),
                // )
              ],
            ),
          ),
          new Container(
            height: 400.0,
            //MediaQuery.of(context).size.height - 100.0
            color: Colors.blue[50],
            child: new ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: userList,
                )
              ],
            ),
          ),
          new Container(height: 20.0),
          new Center(
              child: new RaisedButton(
            child: new Text("Delete Record"),
            onPressed: deleteFirtrecord,
          ))
        ],
      ),
    );
  }

  void databaseConfig() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    print(documentDirectory);

    String path = join(documentDirectory.path, "demo.db");
    //  await deleteDatabase(path);

    // open the database

    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, num REAL)");
    });
    getUserData();
  }

  void getUserData() async {
    List<Map> list = await database.rawQuery('SELECT * FROM Test');
    sqlData = list;
    reloadList();
  }

  void getLastItem() async {
    List<Map> list =
        await database.rawQuery('SELECT * from Test ORDER BY id DESC LIMIT 1;');
        print(list[0]);        
        sqlData.addAll(list);
        reloadList();
  }

  void insertData() async {
    // Insert some records in a transaction
    var name = myController.text;
    if (name != "") {
      await database.transaction((txn) async {
        int id1 = await txn.rawInsert('INSERT INTO Test(name, num) VALUES("$name", 456.789)');
        print("inserted1: $id1");
        getUserData();
        // getLastItem();
        myController.text = "";
      });
    }
  }

  void deleteFirtrecord() async {
    // Delete a record
    if (sqlData.length != 0) {
      var id = sqlData.first.values.elementAt(0);
    // List aa = [];
    // expect(sqlData,aa);
    var count = await database.rawDelete('DELETE FROM Test WHERE id = ?', [id]);
    print("Recored deleted $id");
    getUserData();
    }
    
  }

/*

  void setup() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    print(documentDirectory);

    String path = join(documentDirectory.path, "demo.db");
    //  await deleteDatabase(path);

    // open the database
    
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, num REAL)");
    });

// Insert some records in a transaction
    await database.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Test(name, num) VALUES("some name", 456.789)');
      print("inserted1: $id1");
      int id2 = await txn.rawInsert(
          'INSERT INTO Test(name, num) VALUES(?, ?)',
          ["another name", 3.1416]);
      print("inserted2: $id2");
    });

// Update some record
    // int count = await database.rawUpdate(
    //     'UPDATE Test SET name = ?, VALUE = ? WHERE name = ?',
    //     ["updated name", "9876", "some name"]);
    // print("updated: $count");

// Get the records
    List<Map> list = await database.rawQuery('SELECT * FROM Test');
    // List<Map> expectedList = [
    //   {"name": "updated name", "id": 1, "value": 9876, "num": 456.789},
    //   {"name": "another name", "id": 2, "value": 12345678, "num": 3.1416}
    // ];
    // print(list[0]);
    // print(expectedList);
    sqlData = [];
    sqlData = list;
    reloadList();
    // for (var i = 0; i < sqlData.length; i++) {
    //   print(sqlData[i]);
    //   // var user = sqlData[i];
    //   // userList.add(
    //   //   new Container(
    //   //     child: new Text(user.toString()),
    //   //   )
    //   // );

    // }

    // assert(const DeepCollectionEquality().equals(list, expectedList));

// Count the records
    // count = Sqflite
    //     .firstIntValue(await database.rawQuery("SELECT COUNT(*) FROM Test"));
    // assert(count == 2);

// Delete a record
    var count = await database
        .rawDelete('DELETE FROM Test WHERE id = ?', ['13']);
    // assert(count == 1);



// Close the database
    await database.close();
  }
*/

}
