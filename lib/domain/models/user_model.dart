import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart'; // ➔ important pour générer le fichier

@JsonSerializable()
class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime? birthDate;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.birthDate,
    this.photoUrl,
  });

  /// Convertir vers Map pour Firebase
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'birthDate': birthDate?.toIso8601String(),
      'photoUrl': photoUrl,
    };
  }

  /// Créer un User depuis une Map (Firebase)
  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      birthDate: map['birthDate'] != null ? DateTime.parse(map['birthDate']) : null,
      photoUrl: map['photoUrl'],
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
