import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants.dart';
import 'package:flutter_chat_app/models/user_model.dart';
import 'package:flutter_chat_app/utilities/global_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  bool get isLoading => _isLoading;
  bool get isSuccessful => _isSuccessful;
  String? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  UserModel? get userModel => _userModel;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //check authentication state
  Future<bool> checkAuthenticationState() async {
    bool isSignedIn = false;
    await Future.delayed(const Duration(seconds: 2));
    if (_auth.currentUser != null) {
      _uid = _auth.currentUser!.uid;

      //get user data from firestore
      await getUserDataFromFireStore();

      //save user data to shared preferences
      await saveUserDataToSharedPreferences();
      notifyListeners();

      isSignedIn = true;
    } else {
      isSignedIn = false;
    }
    return isSignedIn;
  }

  //check if user exists
  Future<bool> checkUserExists() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  //get user data from firestore
  Future<void> getUserDataFromFireStore() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    _userModel =
        UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();
  }

  //save user data to shared preferences
  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
        Constants.userModel, jsonEncode(userModel!.toMap()));
  }

  //get user data from shared preferences
  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelString =
        sharedPreferences.getString(Constants.userModel) ?? '';
    _userModel = UserModel.fromMap(jsonDecode(userModelString));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  //sign in with phone number
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential).then((value) async {
          _uid = value.user!.uid;
          _phoneNumber = value.user!.phoneNumber;
          _isSuccessful = true;
          _isLoading = false;
          notifyListeners();
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        _isSuccessful = false;
        _isLoading = false;
        notifyListeners();
        showSnackBar(context, e.toString());
      },
      codeSent: (String verificationId, int? resendToken) async {
        _isLoading = false;
        notifyListeners();
        //navigate to otp screen
        Navigator.of(context).pushNamed(Constants.otpScreen, arguments: {
          Constants.verificationId: verificationId,
          Constants.phoneNumber: phoneNumber,
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  //verify otp code
  Future<void> verifyOTPCode({
    required String verificationId,
    required String otpCode,
    required BuildContext context,
    required Function onSuccessful,
  }) async {
    _isLoading = true;
    notifyListeners();

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );

    await _auth.signInWithCredential(credential).then((value) async {
      _uid = value.user!.uid;
      _phoneNumber = value.user!.phoneNumber;
      _isSuccessful = true;
      _isLoading = false;
      onSuccessful();
      notifyListeners();
    }).catchError((e) {
      _isSuccessful = false;
      _isLoading = false;
      notifyListeners();
      showSnackBar(context, e.toString());
    });
  }

  //save user data to firestore
  void saveUserDataToFireStore({
    required UserModel userModel,
    required File? fileImage,
    required Function onSuccess,
    required Function onFail,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (fileImage != null) {
        //upload image to firebase storage
        String imageUrl = await storeFileToStorage(
            file: fileImage,
            reference: '${Constants.userImages}/${userModel.uid}');
        userModel.image = imageUrl;
      }
      userModel.lastSeen = DateTime.now().microsecondsSinceEpoch.toString();
      userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();
      _userModel = userModel;
      _uid = userModel.uid;

      //save user data to firestore
      await _firestore
          .collection(Constants.users)
          .doc(userModel.uid)
          .set(userModel.toMap());
      _isLoading = false;
      onSuccess();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

  //store file to storage and return the file url
  Future<String> storeFileToStorage({
    required File file,
    required String reference,
  }) async {
    UploadTask uploadTask = _storage.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }

  //get user stream
  Stream<DocumentSnapshot> userStream({required String userID}) {
    return _firestore.collection(Constants.users).doc(userID).snapshots();
  }

  //get all users stream
  Stream<QuerySnapshot> getAllUsersStream({required String userID}) {
    return _firestore
        .collection(Constants.users)
        .where(Constants.uid, isNotEqualTo: userID)
        .snapshots();
  }

  //send friend request
  Future<void> sendFriendRequest({
    required String friendID,
  }) async {
    try {
      //add our uid to friend's request list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayUnion([_uid]),
      });
      //add friend's uid to our friend requests sent list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequestsUIDs: FieldValue.arrayUnion([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> cancelFriendRequest({required String friendID}) async {
    try {
      //remove our uid from friend's request list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayRemove([_uid]),
      });
      //remove friend's uid from our friend requests sent list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequestsUIDs: FieldValue.arrayRemove([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> acceptFriendRequest({required String friendID}) async {
    //add friend's uid to our friends list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsUIDs: FieldValue.arrayUnion([friendID]),
    });
    //add our uid to friends list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.friendsUIDs: FieldValue.arrayUnion([_uid]),
    });
    //remove friend's uid from our friend requests list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendRequestsUIDs: FieldValue.arrayRemove([friendID]),
    });
    //remove our uid from friend requests sent list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.sentFriendRequestsUIDs: FieldValue.arrayRemove([_uid]),
    });
  }

  //unfriend
  Future<void> unfriend({required String friendID}) async {
    //remove friend's uid from our friends list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsUIDs: FieldValue.arrayRemove([friendID]),
    });
    //remove our uid from friend's friends list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.friendsUIDs: FieldValue.arrayRemove([_uid]),
    });
  }

  //get a list of friends
  Future<List<UserModel>> getFriendsList(String uid) async {
    List<UserModel> friendsList = [];
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    List<dynamic> friendsUIDs = documentSnapshot.get(Constants.friendsUIDs);
    for (String friendID in friendsUIDs) {
      DocumentSnapshot friendDocumentSnapshot =
          await _firestore.collection(Constants.users).doc(friendID).get();
      UserModel friend = UserModel.fromMap(
          friendDocumentSnapshot.data() as Map<String, dynamic>);
      friendsList.add(friend);
    }
    return friendsList;
  }

  //get a list of friend requests
  Future<List<UserModel>> getFriendRequestsList(String uid) async {
    List<UserModel> friendRequestsList = [];
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    List<dynamic> friendRequestsUIDs =
        documentSnapshot.get(Constants.friendRequestsUIDs);
    for (String friendRequestsUID in friendRequestsUIDs) {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection(Constants.users)
          .doc(friendRequestsUID)
          .get();
      UserModel friendRequest =
          UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      friendRequestsList.add(friendRequest);
    }
    return friendRequestsList;
  }

  Future logout() async {
    await _auth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    notifyListeners();
  }
}
