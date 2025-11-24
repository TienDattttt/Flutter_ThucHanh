import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../models/user/delivery_info_model.dart';

abstract class FirestoreDeliveryInfoDataSource {
  Future<DeliveryInfoModel> addDeliveryInfo(DeliveryInfoModel deliveryInfo);
  Future<DeliveryInfoModel> editDeliveryInfo(DeliveryInfoModel deliveryInfo);
  Future<List<DeliveryInfoModel>> getDeliveryInfo();
}

class FirestoreDeliveryInfoDataSourceImpl implements FirestoreDeliveryInfoDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  FirestoreDeliveryInfoDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<DeliveryInfoModel> addDeliveryInfo(DeliveryInfoModel deliveryInfo) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationFailure();
      }

      // Tạo document reference với auto-generated ID
      final deliveryInfoRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('deliveryInfo')
          .doc();

      // Tạo delivery info model với ID từ Firestore
      final deliveryInfoModel = DeliveryInfoModel(
        id: deliveryInfoRef.id,
        firstName: deliveryInfo.firstName,
        lastName: deliveryInfo.lastName,
        addressLineOne: deliveryInfo.addressLineOne,
        addressLineTwo: deliveryInfo.addressLineTwo,
        city: deliveryInfo.city,
        zipCode: deliveryInfo.zipCode,
        contactNumber: deliveryInfo.contactNumber,
      );

      // Lưu vào Firestore
      await deliveryInfoRef.set({
        'firstName': deliveryInfoModel.firstName,
        'lastName': deliveryInfoModel.lastName,
        'addressLineOne': deliveryInfoModel.addressLineOne,
        'addressLineTwo': deliveryInfoModel.addressLineTwo,
        'city': deliveryInfoModel.city,
        'zipCode': deliveryInfoModel.zipCode,
        'contactNumber': deliveryInfoModel.contactNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return deliveryInfoModel;
    } on FirebaseException catch (e) {
      throw ServerException();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<DeliveryInfoModel> editDeliveryInfo(DeliveryInfoModel deliveryInfo) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationFailure();
      }

      // Cập nhật document
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('deliveryInfo')
          .doc(deliveryInfo.id)
          .update({
        'firstName': deliveryInfo.firstName,
        'lastName': deliveryInfo.lastName,
        'addressLineOne': deliveryInfo.addressLineOne,
        'addressLineTwo': deliveryInfo.addressLineTwo,
        'city': deliveryInfo.city,
        'zipCode': deliveryInfo.zipCode,
        'contactNumber': deliveryInfo.contactNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return deliveryInfo;
    } on FirebaseException catch (e) {
      throw ServerException();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<DeliveryInfoModel>> getDeliveryInfo() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationFailure();
      }

      final querySnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('deliveryInfo')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return DeliveryInfoModel(
          id: doc.id,
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          addressLineOne: data['addressLineOne'] ?? '',
          addressLineTwo: data['addressLineTwo'] ?? '',
          city: data['city'] ?? '',
          zipCode: data['zipCode'] ?? '',
          contactNumber: data['contactNumber'] ?? '',
        );
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException();
    } catch (e) {
      throw ServerException();
    }
  }
}
