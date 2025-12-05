import 'dart:io';

import 'package:expense_wise/core/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBService{
  
  Database? database;


  Future<Database> getDB() async{
    database ??= await openDB();
    return database!;
  }
  
  Future<Database> openDB() async{
      Directory directory = await getApplicationDocumentsDirectory();
      String path = '${directory.path}/expense_data.db';
      return await openDatabase(path, version: 1, onCreate:(database,version){
        database.execute("create table ${Constants.tableName}(${Constants.id} integer primary key autoincrement,${Constants.title} text,${Constants.category} text,${Constants.amount} real,${Constants.currency} text,${Constants.dateTime} text)");
      });
  }

  Future<int> addExpense(Map<String,dynamic> data) async{
    Database db = await getDB();
    int id =  await db.insert(Constants.tableName, data);
    return id;
  }

  Future<List<Map<String,dynamic>>> getAllExpenses() async{
    final db = await getDB();
    List<Map<String,dynamic>> data = await db.query(Constants.tableName);
    return data;
  }

  Future<bool> updateExpense({required Map<String,dynamic> updatedExpense, required int id}) async{
    final db = await getDB();
    int rowsAffected = await db.update(Constants.tableName, updatedExpense, where: "${Constants.id} = $id");
    return rowsAffected>0;
  }

  Future<bool> deleteExpense({required int id}) async {
    final db = await getDB();
    int rowsAffected = await db.delete(Constants.tableName, where: "${Constants.id} = $id");
    return rowsAffected>0;
  }
}

final dbServiceProvider = Provider((ref) => DBService());