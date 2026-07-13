import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthStudentRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String academicProgram;
  final String bio;
  final List<String> skills;
  final String phoneNumber;

  const AuthStudentRegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.academicProgram,
    required this.bio,
    required this.skills,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [email, password, fullName, academicProgram, bio, skills, phoneNumber];
}

class AuthStartupRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String companyName;
  final String description;
  final String website;
  final String industry;
  final String phoneNumber;
  final String? filePath;
  final Uint8List? fileBytes;

  const AuthStartupRegisterRequested({
    required this.email,
    required this.password,
    required this.companyName,
    required this.description,
    required this.website,
    required this.industry,
    required this.phoneNumber,
    this.filePath,
    this.fileBytes,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        companyName,
        description,
        website,
        industry,
        phoneNumber,
        filePath,
        fileBytes,
      ];
}

class AuthCheckVerificationStatus extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}
