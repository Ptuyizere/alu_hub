import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/internship_model.dart';

class InternshipRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // all active student internship opportunities
  Stream<List<InternshipModel>> getActiveInternships() {
    return _firestore.collection('internships').where('isActive', isEqualTo: true).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => InternshipModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<InternshipModel>> getStartupInternships(String startupId) {
    return _firestore.collection('internships').where('startupId', isEqualTo: startupId).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => InternshipModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // Create a new internship posting
  Future<void> createInternship(InternshipModel internship) async {
    try {
      final docRef = _firestore.collection('internships').doc();
      final updatedInternship = internship.copyWith(id: docRef.id);
      await docRef.set(updatedInternship.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing internship posting
  Future<void> updateInternship(InternshipModel internship) async {
    try {
      await _firestore.collection('internships').doc(internship.id).update(internship.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Toggle active status
  Future<void> toggleInternshipActiveStatus(String internshipId, bool isActive) async {
    try {
      await _firestore.collection('internships').doc(internshipId).update({'isActive': isActive});
    } catch (e) {
      rethrow;
    }
  }

  // Delete an internship posting
  Future<void> deleteInternship(String internshipId) async {
    try {
      await _firestore.collection('internships').doc(internshipId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
