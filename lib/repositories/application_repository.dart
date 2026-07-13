import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';

class ApplicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // applications for a specific Student
  Stream<List<ApplicationModel>> getStudentApplications(String studentId) {
    return _firestore.collection('applications').where('studentId', isEqualTo: studentId).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => ApplicationModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<ApplicationModel>> getStartupApplications(String startupId) {
    return _firestore
        .collection('applications')
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => ApplicationModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // Submit a new application
  Future<void> submitApplication(ApplicationModel application) async {
    try {
      final docRef = _firestore.collection('applications').doc();
      final updatedApp = application.copyWith(id: docRef.id);
      await docRef.set(updatedApp.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Update application status and create notification if approved
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    required StartupProfile startupInfo,
  }) async {
    try {
      final batch = _firestore.batch();

      //Reference and fetch application details
      final appRef = _firestore.collection('applications').doc(applicationId);
      final appDoc = await appRef.get();
      if (!appDoc.exists) {
        throw Exception('Application not found');
      }
      final application = ApplicationModel.fromMap(appDoc.data()!, appDoc.id);

      //Update status of the application
      batch.update(appRef, {'status': status});

      //If approved, creat notification for the student
      if (status == 'approved') {
        final notifRef = _firestore.collection('notifications').doc();
        final notification = NotificationModel(
          id: notifRef.id,
          recipientId: application.studentId,
          senderId: startupInfo.uid,
          title: 'Application Approved!',
          message: 'Your application for "${application.internshipTitle}" has been approved by ${startupInfo.companyName}. You can reach them directly via email at ${startupInfo.email} or by phone at ${startupInfo.phoneNumber} to discuss the next steps!',
          startupContactEmail: startupInfo.email,
          startupContactPhone: startupInfo.phoneNumber,
          isRead: false,
          createdAt: DateTime.now(),
        );
        batch.set(notifRef, notification.toMap());
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
}
