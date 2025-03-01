import 'dart:convert';

import 'package:flutter/material.dart';

class Question {
  int? id;
  String text;
  bool isFav;
  String mode;

  Question({
    this.id,
    required this.text,
    required this.isFav,
    required this.mode,
  });


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isFav': isFav,
      'mode': mode, // Convert list of times to a single string
    };
  }

  // Create an object from a JSON-compatible map
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      isFav: json['isFav'],
      mode: json['mode'],
    );
  }

  // Optional: Existing toMap method if you're using this for other purposes
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isFav': isFav,
      'mode': mode, // Convert list to string
    };
  }

  // Optional: Existing fromMap method for backward compatibility
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      text: map['text'],
      isFav: map['isFav']==1,
      mode: map['mode'],
    );
  }

  // Convert object to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Create object from JSON string
  factory Question.fromJsonString(String jsonString) {
    return Question.fromJson(jsonDecode(jsonString));
  }

  @override
  String toString() {
    return 'Question{id: $id, text: $text, isFav: $isFav, mode: $mode}';
  }


}

