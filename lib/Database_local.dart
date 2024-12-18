import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  // Ottieni il database, creando se non esiste
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  // Inizializza il database
  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/my_database.db';

    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute('CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)');
    });
  }

  // Inserisci un nuovo utente nel database
  Future<void> insertUser(String name, int age) async {
    final db = await database;
    await db.insert('users', {'name': name, 'age': age});
  }

  // Eliminazione utente da db
  Future<int> deleteUser(String name, int age) async{

    final db = await database;
    return await db.delete('users', where: 'name = ?', whereArgs: [name]);
  }

  // Recupera tutti gli utenti dal database
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();  // Inizializza i binding

//   // Chiamate asincrone che dipendono dal framework Flutter
//   final directory = await getApplicationDocumentsDirectory();
//   print('Document directory: ${directory.path}');
  
//   var dbHelper = DatabaseHelper();
//   await dbHelper.insertUser('Matteo', 18);
//   await dbHelper.insertUser('Mamma', 20);
//   await dbHelper.deleteUser('Test', 1);

//   runApp(MyApp(dbHelper: dbHelper));
// }

// class MyApp extends StatelessWidget {
//   final DatabaseHelper dbHelper;

//   MyApp({required this.dbHelper});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('Persistent Data Test')),
//         body: FutureBuilder<List<Map<String, dynamic>>>(
//           future: dbHelper.getUsers(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }

//             if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             }

//             final users = snapshot.data ?? [];
//             return ListView.builder(
//               itemCount: users.length,
//               itemBuilder: (context, index) {
//                 final user = users[index];
//                 return ListTile(
//                   title: Text(user['name']),
//                   subtitle: Text('Age: ${user['age']}'),
//                   trailing: Text('Id: ${user['id']}'),
                  
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
