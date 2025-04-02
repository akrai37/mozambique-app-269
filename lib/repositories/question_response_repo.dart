import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:mozambique_app/model/question.dart';

/*Class: Question and Response Repository
  Gets, adds, and deletes data in database for Question & Response exercises
  getters:
    - all questions
    - all responses
    - all questions for certain category
    - all responses for certain category + emotion

  adders:
    - add a question given a question object
    - add a response given a response object

  deleters:
    - delete a question (and associated responses) given a question
    - delete a response given a categoryName
*/

class QuestionResponseRepo {
  final Box<Question> _qBox = Hive.box<Question>('questions');
  final Box<Response> _rBox = Hive.box<Response>('responses');

  //for populating front end and conflict detection for syncing

  //get all questions
  List<Question> getAllQs(){
    return _qBox.values.toList();
  }

  //get all responses
  List<Response> getAllRs(){
    return _rBox.values.toList();
  }

  //get all questions of certain category
  List<Question> getQsOfCat(String catName){
    return _qBox.values.where((q)=>q.categoryName == catName).toList();
  }

  //get all responses of certain question id + emotion
  List<Response> getAllRsOfCat(String id, String emote){
    return _rBox.values.where((a)=>a.questionId == id && a.emotion == emote).toList();
  }

  //to use for conflict resolution for syncing
  void addQuestion(Question question) {
    _qBox.put(question.id, question);
  }

  void addResponse(Response response) {
    _rBox.put(response.responseText, response);
  }

  void deleteQuestion(String questionId) { //question being the question id
    if(_qBox.get(questionId)==null){
      log("\"$questionId\" not found");
    }else{
      deleteResponses(_qBox.get(questionId)!.id);
      _qBox.delete(questionId);
      log("\"$questionId\" deleted");
    }
  }

  void deleteResponses(String id){
    _rBox.values.where((r)=>r.questionId == id).forEach((r)=>_rBox.delete(r.responseText));
  }
}