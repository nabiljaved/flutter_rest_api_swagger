import 'package:flutter/material.dart';
import 'package:flutter_rest_api/services/notes_service.dart';
import 'package:get_it/get_it.dart';

import 'views/note_list.dart';

void setupLocator() {
  GetIt.I.registerLazySingleton(() => NotesService());
}

void main(){
  setupLocator();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: NoteList()
    );
  }
}

