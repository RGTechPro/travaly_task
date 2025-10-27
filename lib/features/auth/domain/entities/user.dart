import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String email;
  final String name;
  final String photoUrl;

  const User({
    required this.email,
    required this.name,
    required this.photoUrl,
  });

  @override
  List<Object> get props => [email, name, photoUrl];
}
