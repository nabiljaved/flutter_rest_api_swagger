import 'package:flutter/material.dart';
import 'package:flutter_rest_api/models/Note.dart';
import 'package:flutter_rest_api/models/note_insert.dart';
import 'package:flutter_rest_api/services/notes_service.dart';
import 'package:get_it/get_it.dart';

class NoteModify extends StatefulWidget {

  final String noteID;
  NoteModify({this.noteID});

  @override
  _NoteModifyState createState() => _NoteModifyState();
}

class _NoteModifyState extends State<NoteModify> {
  bool get isEditing => widget.noteID != null;

  NotesService get notesService => GetIt.I<NotesService>();

  String errorMessage;
  Note note;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    //if it is editing then we can fetch the note otherwise when it is false it wont fetch and crash loading indicator need to be false to inside 
    if(isEditing)
    {
      setState(() {
      _isLoading = true;
     });

        notesService.getNote(widget.noteID)
        .then((response) {
      setState(() {
        _isLoading = false;
      });

      if (response.error) {
        errorMessage = response.errorMessage ?? 'An error occurred';
      }
      note = response.data;
      _titleController.text = note.noteTitle;
      _contentController.text = note.noteContent;
    });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit note' : 'Create note')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  hintText: 'Note title'
              ),
            ),

            Container(height: 8),

            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                  hintText: 'Note content'
              ),
            ),

            Container(height: 16),

            SizedBox(
              width: double.infinity,
              height: 35,
              child: RaisedButton(
                child: Text('Submit', style: TextStyle(color: Colors.white)),
                color: Theme.of(context).primaryColor,
                onPressed: () async{  //it is async request therefore async keyword 
                  if(isEditing){
                    //update resources

                    setState(() {
                      _isLoading = true;     //show user loading so that he wont press submit again and again 
                    });

                    final note  = NoteInsert(
                      noteTitle: _titleController.text,
                      noteContent: _contentController.text
                    );
                    final result = await notesService.updateNote(widget.noteID, note);

                    //based on result we will show a dialog if it is successfull or not 

                    setState(() {
                      _isLoading = true;     //show user loading false when request is done
                    });


                    final title = 'Done';
                    final text = result.error ? (result.errorMessage ??'An error occured') : 'your note was updated';

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                          
                          title: Text(title),
                          content: Text(text),
                          actions: <Widget>[
                              FlatButton(
                                child: Text('ok'),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                              )
                          ],
                      )  
                    )
                    //when user get out of the dialog and done with creating a note we pop the stack 
                    //and refresh the list on tap method of listbuilder
                    .then((data){
                      if(result.data){
                        Navigator.of(context).pop();
                      }
                    });




                  }else{

                    setState(() {
                      _isLoading = true;     //show user loading so that he wont press submit again and again 
                    });

                    final note  = NoteInsert(
                      noteTitle: _titleController.text,
                      noteContent: _contentController.text
                    );
                    final result = await notesService.createNote(note);

                    //based on result we will show a dialog if it is successfull or not 

                    setState(() {
                      _isLoading = true;     //show user loading false when request is done
                    });


                    final title = 'Done';
                    final text = result.error ? (result.errorMessage ??'An error occured') : 'your note was created';

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                          
                          title: Text(title),
                          content: Text(text),
                          actions: <Widget>[
                              FlatButton(
                                child: Text('ok'),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                              )
                          ],
                      )  
                    )
                    //when user get out of the dialog and done with creating a note we pop the stack 
                    //and refresh the list when we go back to list page
                    .then((data){
                      if(result.data){
                        Navigator.of(context).pop();
                      }
                    });
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}