import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String? id;
  final String name;
  final String imageUrl;
  final int diet;
  final String time;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final Timestamp createdAt;
  final String? authorId;
  final String? authorEmail;
  final bool isPublic;
  final String status; // 'pending', 'approved', 'rejected'
  final List<Comment> comments;
  final String youtubeLink;
  final List<String> likes;
  final List<String> dislikes;
  final int views;

  RecipeModel({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.diet,
    required this.time,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.createdAt,
    this.authorId,
    this.authorEmail,
    this.isPublic = false,
    this.status = 'pending',
    this.comments = const [],
    this.youtubeLink = '',
    this.likes = const [],
    this.dislikes = const [],
    this.views = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'diet': diet,
      'time': time,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'createdAt': createdAt,
      'authorId': authorId,
      'authorEmail': authorEmail,
      'isPublic': isPublic,
      'status': status,
      'comments': comments.map((c) => c.toMap()).toList(),
      'youtubeLink': youtubeLink,
      'likes': likes,
      'dislikes': dislikes,
      'views': views,
    };
  }

  factory RecipeModel.fromMap(String id, Map<String, dynamic> map) {
    return RecipeModel(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      diet: map['diet'] ?? 0,
      time: map['time'] ?? '00:00',
      description: map['description'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      authorId: map['authorId'],
      authorEmail: map['authorEmail'],
      isPublic: map['isPublic'] ?? false,
      status: map['status'] ?? 'pending',
      comments: (map['comments'] as List<dynamic>?)
              ?.map((c) => Comment.fromMap(c as Map<String, dynamic>))
              .toList() ??
          [],
      youtubeLink: map['youtubeLink'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      dislikes: List<String>.from(map['dislikes'] ?? []),
      views: map['views'] ?? 0,
    );
  }
}

class Comment {
  final String userId;
  final String userEmail;
  final String content;
  final Timestamp createdAt;

  Comment({
    required this.userId,
    required this.userEmail,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'content': content,
      'createdAt': createdAt,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
