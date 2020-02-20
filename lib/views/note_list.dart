import 'package:flutter/material.dart';
import 'package:flutter_rest_api/models/api_response.dart';
import 'package:flutter_rest_api/models/note_for_listing.dart';
import 'package:flutter_rest_api/services/notes_service.dart';
import 'package:flutter_rest_api/views/note_delete.dart';
import 'package:get_it/get_it.dart';
import 'note_modify.dart';

class NoteList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    
    return _NoteListState();
  }
}


//state of NoteList
class _NoteListState extends State<NoteList>
{
  //we get all nodes through service method
  NotesService get service => GetIt.I<NotesService>();
  APIResponse<List<NoteForListing>> _apiResponse;
  bool _isLoading = false;

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  void initState() {
    //initialize service.get when state starts
    _fetchNotes();
    super.initState();
  }

  _fetchNotes() async {
    setState(() {
      _isLoading = true;
    });

    _apiResponse = await service.getNotesList();

    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: Text('List of notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => NoteModify()))
              //future will invoke the result when we pop the page 
              .then((_){
                _fetchNotes();
              });
        },
        child: Icon(Icons.add),
      ),

      //we encapsulate listview inside builder so that we can show errors all ath once and loading
      body: Builder(
        builder: (_){
          if (_isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (_apiResponse.error) {
            return Center(child: Text(_apiResponse.errorMessage));
          }

          return ListView.separated(
            //it builds a list with sepetaer and item builder with context and index
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.green),
            itemBuilder: (_, index) {

              //this return dimissible means we can swipe from start to delete a note it must have a value key which is a
              //key of a notes on dismissed we do nothing but on confirm dismiss we show a dialog box when we hit delete it
              //will return true which will dismiss our note showdialog is future it does not give boolean value but future so async and await

              return Dismissible(
                key: ValueKey(_apiResponse.data[index].noteID),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {
                  //on dismiss do nothing
                },
                confirmDismiss: (direction) async {
                  //on confirm show dialog which return true in result 
                  final result = await showDialog(
                      context: context,
                      builder: (_) => NoteDelete());

                  if(result){ //if result is true
                      var message;
                      final deleteResult = await service.deleteNote(_apiResponse.data[index].noteID);
                      if(deleteResult!=null && deleteResult.data == true){
                          message = 'the note was deleted successfully!';
                      }else{
                         message = deleteResult?.errorMessage ?? 'An error occured';
                      } 
                      showDialog(
                        context: context,
                        builder: (_) =>AlertDialog(
                            title: Text('Done'),
                            content: Text(message),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('ok'),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          )
                      );
                      return deleteResult?.data ?? false;
                      //Scaffold.of(context).showSnackBar(SnackBar(content: Text(message), duration: new Duration(milliseconds : 1000)));
                  }
                  print(result);
                  
                },
                background: Container(
                  color: Colors.red,
                  padding: EdgeInsets.only(left: 16),
                  child: Align(child: Icon(Icons.delete, color: Colors.white), alignment: Alignment.centerLeft,),
                ),
                child: ListTile(
                  title: Text(
                    _apiResponse.data[index].noteTitle,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  subtitle: Text(
                      'Last edited on ${formatDateTime(_apiResponse.data[index].latestEditDateTime
                          ?? _apiResponse.data[index].createDateTime)}'),
                  onTap: () {
                    Navigator.of(context)
                    //when we press an item we pass the noteId to NoteModify
                        .push(MaterialPageRoute(builder: (_) => NoteModify(noteID: _apiResponse.data[index].noteID))).then((onValue){
                          _fetchNotes();
                        });
                        
                  },
                ),
              );
            },
            itemCount: _apiResponse.data.length,
          );

        },
      )
    );

  }

}