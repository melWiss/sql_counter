import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    _counter = 0;
    getCounters().then((counters) {
      setState(() {
        counters.length > 0
            ? _counter = counters[0].toMap()['value']
            : _counter = 0;
      });
    });
  }

  Future<Database> getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), "my_counter.db"),
      onCreate: (db, version) {
        db.execute("""
          CREATE TABLE counter(
            id INTEGER PRIMARY KEY,
            value INTEGER
          )
        """);
      },
      version: 1,
    );
  }

  Future<List<Counter>> getCounters() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> map = await db.query('counter');
    return List.generate(
      map.length,
      (int index) {
        return Counter(
          id: map[index]['id'],
          value: map[index]['value'],
        );
      },
    );
  }

  Future<void> insertCounter(Counter counter) async {
    final Database db = await getDatabase();
    db.insert(
      'counter',
      counter.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCounter(int id) async {
    final Database db = await getDatabase();
    db.delete(
      'counter',
      where: "id = $id",
    );
  }

  Future<void> updateCounter(Counter counter) async {
    final Database db = await getDatabase();
    db.update(
      'counter',
      counter.toMap(),
      where: "id=${counter.toMap()['id']}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(5),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: FloatingActionButton.extended(
                onPressed: _incrementCounter,
                tooltip: 'Increment',
                label: Text('Increment'),
                icon: Icon(Icons.add),
              ),
            ),
            FloatingActionButton.extended(
              onPressed: ()=>insertCounter(Counter(id: 0,value:_counter)),
              tooltip: 'Insert',
              label: Text('Insert'),
              icon: Icon(Icons.insert_drive_file),
            ),
            FloatingActionButton.extended(
              onPressed: ()=>updateCounter(Counter(id: 0,value:_counter)),
              tooltip: 'Update',
              label: Text('Update'),
              icon: Icon(Icons.update),
            ),
            FloatingActionButton.extended(
              onPressed: ()=>deleteCounter(0),
              tooltip: 'Delete',
              label: Text('Delete'),
              icon: Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}

class Counter {
  final int id;
  final int value;
  Counter({this.id, this.value});
  Map<String, dynamic> toMap() {
    return {"id": id, "value": value};
  }
}
