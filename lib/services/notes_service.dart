import 'dart:convert';
import 'package:flutter_rest_api/models/Note.dart';
import 'package:flutter_rest_api/models/note_for_listing.dart';
import 'package:flutter_rest_api/models/note_insert.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rest_api/models/api_response.dart';

class NotesService {
static const API = 'http://api.notes.programmingaddict.com';
static const headers = {
  'apiKey': '08d7b527-6289-01a6-95aa-3f2cdf01af5c',
  'Content-Type' : 'application/json'      //we need to send content-type with header otherwise api wont know on post method how interpret the data 
  
  };

  //get all notes
  Future<APIResponse<List<NoteForListing>>> getNotesList() {
  return http.get(API + '/notes', headers: headers).then((data) {
    if (data.statusCode == 200) {
      final jsonData = json.decode(data.body);
      final notes = <NoteForListing>[];
      for (var item in jsonData) {
        notes.add(NoteForListing.fromJson(item));
      }
      return APIResponse<List<NoteForListing>>(data: notes);
    }
    return APIResponse<List<NoteForListing>>(error: true, errorMessage: 'An error occured');
  })
      .catchError((_) => APIResponse<List<NoteForListing>>(error: true, errorMessage: 'An error occured'));
}

//get note by noteId
  Future<APIResponse<Note>> getNote(String noteID) {
  return http.get(API + '/notes/' + noteID, headers: headers).then((data) {
    if (data.statusCode == 200) {
      final jsonData = json.decode(data.body);
      return APIResponse<Note>(data: Note.fromJson(jsonData));
    }
    return APIResponse<Note>(error: true, errorMessage: 'An error occured');
  })
      .catchError((_) => APIResponse<Note>(error: true, errorMessage: 'An error occured'));
  }

  //post method 
Future<APIResponse<bool>> createNote(NoteInsert item) {
    return http.post(API + '/notes', headers: headers, body: json.encode(item.toJson())).then((data) {
      if (data.statusCode == 201) {
        return APIResponse<bool>(data: true);
      }
      return APIResponse<bool>(error: true, errorMessage: 'An error occured');
    })
    .catchError((_) => APIResponse<bool>(error: true, errorMessage: 'An error occured'));
  }

  //put note update
  Future<APIResponse<bool>> updateNote(String noteID, NoteInsert item) {
    return http.put(API + '/notes/' + noteID, headers: headers, body: json.encode(item.toJson())).then((data) {
      if (data.statusCode == 204) {
        return APIResponse<bool>(data: true);
      }
      return APIResponse<bool>(error: true, errorMessage: 'An error occured');
    })
    .catchError((_) => APIResponse<bool>(error: true, errorMessage: 'An error occured'));
  }

    //delete note update
  Future<APIResponse<bool>> deleteNote(String noteID) {
    return http.delete(API + '/notes/' + noteID, headers: headers).then((data) {
      if (data.statusCode == 204) {
        return APIResponse<bool>(data: true);
      }
      return APIResponse<bool>(error: true, errorMessage: 'An error occured');
    })
    .catchError((_) => APIResponse<bool>(error: true, errorMessage: 'An error occured'));
  }

}

//put / update note 





