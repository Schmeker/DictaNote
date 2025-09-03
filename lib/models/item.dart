import 'package:flutter/material.dart';


class ItemModel {
  final String? id;
  final String listId;
  final String title;
  final String? description;
  final bool completed;
  final int? amount;
  final DateTime? timeTill;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemModel({
    this.id,
    required this.listId,
    required this.title,
    this.description,
    this.completed = false,
    this.amount,
    this.timeTill,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      listId: json['list_id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'] ?? false,
      amount: json['amount'],
      timeTill: json['time_till'] != null ? DateTime.parse(json['time_till']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'list_id': listId,
      'title': title,
      'description': description,
      'completed': completed,
      'amount': amount,
      'time_till': timeTill?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
