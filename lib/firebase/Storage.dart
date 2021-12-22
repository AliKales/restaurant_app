import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:restaurant_app/firebase/Auth.dart';
import 'package:restaurant_app/funcs.dart';

class Storage {
  ///* [addPersonnelPhoto] this method upload thee photo onto database and it returns download URL
  ///* if there is a error it returns "" as String
  static Future addPersonnelPhoto({
    required File file,
    required String id,
    required Function(double) uploadedByte,
    required final context,
    required Function(String) onFinish,
  }) async {
    String isSuccess = "";
    try {
      firebase_storage.UploadTask task = firebase_storage
          .FirebaseStorage.instance
          .ref('personnels/${Auth().getEMail()}/$id')
          .putFile(file);

      task.snapshotEvents.listen(
          (firebase_storage.TaskSnapshot snapshot) async {
        uploadedByte((snapshot.bytesTransferred / snapshot.totalBytes) * 100);
        if (snapshot.state == firebase_storage.TaskState.success) {
          isSuccess = await firebase_storage.FirebaseStorage.instance
              .ref('personnels/${Auth().getEMail()}/$id')
              .getDownloadURL();
          onFinish.call(isSuccess);
        }
      }, onError: (e) {
        isSuccess = "";
        onFinish.call("");
      });
    } on FirebaseException catch (e) {
      Funcs().showSnackBar(context, e.message.toString());
      onFinish.call("");
    } catch (e) {
      Funcs().showSnackBar(context, e.toString());
      onFinish.call("");
    }
  }
}
