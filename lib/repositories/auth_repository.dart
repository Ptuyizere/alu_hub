import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user ID
  String? get currentUid => _firebaseAuth.currentUser?.uid;

  // Sign in with Email and Password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] ?? '';
      }
      return '';
    } catch (e) {
      rethrow;
    }
  }

  // Get Student Profile
  Future<StudentProfile> getStudentProfile(String uid) async {
    try {
      final doc = await _firestore.collection('students').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return StudentProfile.fromMap(doc.data()!);
      }
      throw Exception('Student profile not found');
    } catch (e) {
      rethrow;
    }
  }

  // Get Startup Profile
  Future<StartupProfile> getStartupProfile(String uid) async {
    try {
      final doc = await _firestore.collection('startups').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return StartupProfile.fromMap(doc.data()!);
      }
      throw Exception('Startup profile not found');
    } catch (e) {
      rethrow;
    }
  }

  // Register Student
  Future<void> registerStudent({
    required String email,
    required String password,
    required String fullName,
    required String academicProgram,
    required String bio,
    required List<String> skills,
    required String phoneNumber,
  }) async {
    try {
      //Create Auth User
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      //Create User role metadata
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });

      //Create Student profile document
      final profile = StudentProfile(
        uid: uid,
        fullName: fullName,
        email: email,
        academicProgram: academicProgram,
        bio: bio,
        skills: skills,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('students').doc(uid).set(profile.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Register Startup with PDF Certificate
  Future<void> registerStartup({
    required String email,
    required String password,
    required String companyName,
    required String description,
    required String website,
    required String industry,
    required String phoneNumber,
    required String? filePath,
    required Uint8List? fileBytes,
  }) async {
    try {
      // Create Auth User
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      //Upload RDB Certificate PDF
      String certificateUrl = '';
      if (filePath != null || fileBytes != null) {
        final ref = _storage.ref().child('rdb_certificates').child('$uid.pdf');
        
        UploadTask uploadTask;
        if (fileBytes != null) {
          uploadTask = ref.putData(
            fileBytes,
            SettableMetadata(contentType: 'application/pdf'),
          );
        } else {
          uploadTask = ref.putFile(
            File(filePath!),
            SettableMetadata(contentType: 'application/pdf'),
          );
        }
        
        final snapshot = await uploadTask;
        certificateUrl = await snapshot.ref.getDownloadURL();
      } else {
        throw Exception('RDB registration certificate PDF is required.');
      }

      //Create User role
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'role': 'startup',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create Startup profile document
      final profile = StartupProfile(
        uid: uid,
        companyName: companyName,
        email: email,
        description: description,
        website: website,
        industry: industry,
        rdbCertificateUrl: certificateUrl,
        phoneNumber: phoneNumber,
        isVerified: false, // Default before admin verification
        createdAt: DateTime.now(),
      );

      await _firestore.collection('startups').doc(uid).set(profile.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Check if Startup is verified
  Future<bool> checkStartupVerification(String uid) async {
    try {
      final doc = await _firestore.collection('startups').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()?['isVerified'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
