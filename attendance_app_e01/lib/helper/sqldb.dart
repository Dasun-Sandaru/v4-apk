import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await intialDb();
      return _db;
    } else {
      return _db;
    }
  }

  intialDb() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'market.db'); // databasepath/products.db
    Database mydb = await openDatabase(path, onCreate: _onCreate, version: 1);
    return mydb;
  }

  _onCreate(Database db, int version) async {
    String sql =
        'CREATE TABLE "markettbl" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "userid" TEXT,"geo_location" TEXT,"longitude" TEXT,"latitude" TEXT,"outlet_name" TEXT,"execution_type" TEXT,"remarks" TEXT,"image1" TEXT,"image2" TEXT,"image3" TEXT,"image4" TEXT,"image5" TEXT)';
    String sqlfordropdown =
        'CREATE TABLE "ExecutionTypes" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "types" TEXT)';

    Batch batch = db.batch();
    batch.execute(sql);
    batch.execute(sqlfordropdown);
    List<dynamic> res = await batch.commit();
    // await db.execute(sql);

    print(
        '---------------------Create DATABASE AND Table---------------------');
  }

  // delete database
  deleteDB() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, '');
    await deleteDatabase(path);

    print('DB Deleted !');
  }

  insertData(String table, Map<String, dynamic> json) async {
    Database? mydb = await db;
    int response = await mydb!.insert(table, json);
    //int response = await mydb!.insert(sql);
    return response;
  }

  readData(String sql) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

  readExecutionTypes(String sql) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    // print(response);
    // print(response[0]);
    // print(response[0]['types']);

    String newString = response[0]['types'];
    //print(newString);

    Map newMap = jsonDecode(newString);
    //print(newMap['data']);
    var aa = newMap['data'];
    print(aa.runtimeType);
    return aa;
  }

  Future<int?> getRowCount() async {
    try {
      String sql = 'SELECT COUNT(*) FROM markettbl';
      Database? mydb = await db;
      int? count = Sqflite.firstIntValue(await mydb!.rawQuery(sql));
      return count;
    } catch (e) {
      print(e.toString());
    }
  }

  // delete data
  deleteData(String sql) async {
    try {
      Database? mydb = await db;
      int response = await mydb!.rawDelete(sql);
      return response;
    } catch (e) {
      print(e.toString());
    }
  }

  //---------------------------------------------------------

  // insertExecutionTypes(List<Map> list) async{
  //   try {
  //     // String sql = 'INSERT INTO ExecutionTypes (types) VALUES (?,?)' ,['another name', 12345678];
  //   Database? mydb = await db;
  //   int response = await mydb!.rawInsert('INSERT INTO ExecutionTypes (types) VALUES (?)',list);
  //   //int response = await mydb!.insert(sql);
  //   print(response);
  //   return response;
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  // insertExecutionTypes(Map map) async{
  //   try {
  //     // String sql = 'INSERT INTO ExecutionTypes (types) VALUES (?,?)' ,['another name', 12345678];
  //   Database? mydb = await db;
  //   int response = await mydb!.rawInsert('INSERT INTO ExecutionTypes (types) VALUES (?)',[map]);
  //   //int response = await mydb!.insert(sql);
  //   print(response);
  //   return response;
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  // insertExecutionTypes(String dataAsJson) async {
  //   try {
  //     // String sql = 'INSERT INTO ExecutionTypes (types) VALUES (?,?)' ,['another name', 12345678];
  //     Database? mydb = await db;
  //     int response = await mydb!
  //         .rawInsert('INSERT INTO ExecutionTypes (types) VALUES (?)', [dataAsJson]);
  //     //int response = await mydb!.insert(sql);
  //     print(response);
  //     return response;
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  insertExecutionTypes(String dataAsJson) async {
    try {
      // String sql = 'INSERT INTO ExecutionTypes (types) VALUES (?,?)' ,['another name', 12345678];
      Database? mydb = await db;
      int response =
          await mydb!.insert('ExecutionTypes', {'types': dataAsJson});
      //int response = await mydb!.insert(sql);
      // print(response);
      // print('----------------');
      return response;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<int?> getRowCountOFExecutionTypesTbl() async {
    try {
      String sql = 'SELECT COUNT(*) FROM ExecutionTypes';
      Database? mydb = await db;
      int? count = Sqflite.firstIntValue(await mydb!.rawQuery(sql));
      return count;
    } catch (e) {
      print(e.toString());
    }
  }
}
