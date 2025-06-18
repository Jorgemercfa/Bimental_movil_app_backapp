// // Create a new user with a first and last name
// import 'package:cloud_firestore/cloud_firestore.dart';

// void agregarUsuario() {
//   Map<String, dynamic> usuarios = {
//     'nombre': "",
//     'email': "",
//     'password': "",
//     'celular': ""
//   };

//   FirebaseFirestore.instance
//       .collection("usuario")
//       .add(usuarios)
//       .then((DocumentReference doc) {
//     print('DocumentSnapshot added with ID: ${doc.id}');
//   }).catchError((error) {
//     print('Error adding document: $error');
//   });
// }
