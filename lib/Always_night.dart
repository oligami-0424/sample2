import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'dart:async';

class Always_night extends StatelessWidget {
  final List<String> items = List<String>.generate(10000, (i) => 'Item $i');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FutureBuilder(
        future: reading_nights(),
        builder:
          (BuildContext context, AsyncSnapshot<List<night_world>> snapshot) {
        // 通信中はローディングのぐるぐるを表示
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('あああああああああ');
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        // 通信が失敗した場合
        if (snapshot.hasError) {
          print('データ取得に失敗しました');
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        // snapshot.dataにデータが格納されていれば
        if (snapshot.hasData) {
          List<night_world> data_ = snapshot.data!;
          print('データ取得を確認しました ${data_[0].id} : ${data_[0].name} : ${data_.length}');
          return Column (
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data_.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(data_[index].name),
                  );
                },
              ),
              FloatingActionButton(
                onPressed: () async {
                  if (data_.length == 0) {
                    print('abcedfg');
                    await new_night_world(0);
                  }
                  else {
                    print('1000000');
                    await new_night_world(data_[data_.length - 1].id + 1);
                  }
                  print('あいうえお ${data_.length}');
                  data_ = await reading_nights();
                  print(data_.length);

                },
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
            ],
          );
        }
          return Text('データが取れませんでした。');
        },
      ),
    ]
  );
  }
}

class night {
  final int id;
  String name;
  double x;
  double y;

  night ({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
});

  Map<String, dynamic> toMap() {
    return {
      'id'   : id,
      'name' : name,
      'x'    : x,
      'y'    : y,
    };
  }

  @override
  String toString() {
    return 'night{id: $id, name: $name, x: $x, y: $y}';
  }
}

class night_world {
  final int id;
  String name;

  night_world ({
    required this.id,
    required this.name,
});
  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'name' : name,
    };
  }
}

Future<void> create_db(int id) async {
  var database = openDatabase(
    join(await getDatabasesPath(), 'night_database_$id.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE nights(id INTEGER PRIMARY KEY, name String, x REAL, y REAL)'
      );
    },
    version: 1,
  );
}

Future<void> new_night_world(int id) async {
  final database = await openDatabase(
    join(await getDatabasesPath(), 'night_database_last.db'),
    onCreate: (db, version) {},
    version: 1,
  );
  await database.insert(
    'nights_db_name',
    night_world (id: id, name: 'no-name').toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  create_db(id);
}

Future<void> insert_night(database, night night_) async {
  final db = await database;
  await db.insert(
    'nights',
    night_.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<night_world>> reading_nights() async {
  final database = await openDatabase(
    join(await getDatabasesPath(), 'night_database_last.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE nights_db_name(id INTEGER PRIMARY KEY, name String)'
      );
    },
    version: 1,
  );
  print('テーブル作成完了');
  final List<Map<String, dynamic>> nights_db_last = await database.query('nights_db_name');
  if (nights_db_last.length == 0){
    print('リスト存在せず');
    return [night_world(id : 0,name : 'なし'),];
  }
  else {
    return List.generate(nights_db_last.length, (i) {
      print('night_world : $i : ${nights_db_last[i]['id']}');
      return night_world(
        id: nights_db_last[i]['id'],
        name: nights_db_last[i]['name'],
      );
    });
  }
}