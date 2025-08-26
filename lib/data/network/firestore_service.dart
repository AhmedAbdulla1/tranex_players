// import 'dart:developer';
//
// import 'package:firesport_users/app/app_prefs.dart';
// import 'package:firesport_users/app/di.dart';
// import 'package:firesport_users/data/network/requests.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class FirestoreService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final AppPreferences _appPreferences = instance<AppPreferences>();
//
//   // Get all categories and exercises in a single read operation.
//   Future<List<Map<String, dynamic>>> getExercises() async {
//     try {
//       print('Fetching exercises... ${_appPreferences.getToken()}');
//       CollectionReference categoriesRef = _firestore
//           .collection('trainers')
//           .doc(_appPreferences.getToken())
//           .collection('categories');
//       QuerySnapshot snapshot = await categoriesRef.get();
//
//       // Map categories and their exercises in a single operation.
//       List<Map<String, dynamic>> categoryData = snapshot.docs.map((doc) {
//         return {
//           'id': doc.id,
//           'name': doc['name'],
//           'exercises': (doc['exercises'] as List<dynamic>).map((exercise) {
//             return {
//               'id': exercise['id'],
//               'name': exercise['name'],
//               'image': exercise['image'],
//               'deviceId': exercise['deviceId'],
//             };
//           }).toList(),
//         };
//       }).toList();
//
//       return categoryData;
//     } catch (e) {
//       debugPrint('Error fetching exercises: $e');
//       return [];
//     }
//   }
//
//   // Add a new exercise, creating a category if necessary.
//   Future<String> addExercise(
//       AddNewExerciseRequest addNewExerciseRequest) async {
//     try {
//       CollectionReference categoriesRef = _firestore
//           .collection('trainers')
//           .doc(_appPreferences.getToken())
//           .collection('categories');
//       DocumentReference categoryDocRef;
//
//       // Check if the category is new or existing.
//       if (addNewExerciseRequest.categoryId == "new") {
//         // Create a new category with exercises stored in the same document.
//         categoryDocRef = await categoriesRef.add({
//           'name': addNewExerciseRequest.categoryName,
//           'exercises': [],
//         });
//         debugPrint('Created new category: ${categoryDocRef.id}');
//       } else {
//         // Use the existing category ID.
//         categoryDocRef = categoriesRef.doc(addNewExerciseRequest.categoryId.toString());
//         DocumentSnapshot categorySnapshot = await categoryDocRef.get();
//
//         if (!categorySnapshot.exists) {
//           throw Exception('Category does not exist.');
//         }
//       }
//
//       // Add the exercise to the existing or new category document.
//       await categoryDocRef.update({
//         'exercises': FieldValue.arrayUnion([
//           {
//             'id': _firestore.collection('random').doc().id,
//             'name': addNewExerciseRequest.exerciseName,
//             'image': addNewExerciseRequest.image,
//             'deviceId': addNewExerciseRequest.deviceId,
//           }
//         ]),
//       });
//
//       return categoryDocRef.id;
//     } catch (e) {
//       debugPrint('Failed to add exercise: $e');
//       throw Exception('Failed to add exercise: $e');
//     }
//   }
//
//   // Delete an exercise from a category.
//   Future<void> deleteExercise(String categoryId, String exerciseId) async {
//     try {
//       CollectionReference categoriesRef = _firestore
//           .collection('trainers')
//           .doc(_appPreferences.getToken())
//           .collection('categories');
//       // Reference the specific category document.
//       DocumentReference categoryDocRef = categoriesRef.doc(categoryId);
//
//       // Remove the exercise from the category's exercise array.
//       await categoryDocRef.update({
//         'exercises': FieldValue.arrayRemove([
//           {'id': exerciseId},
//         ]),
//       });
//     } catch (e) {
//       debugPrint('Failed to delete exercise: $e');
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> getDevices() async {
//     List<Map<String, dynamic>> devicesWithAccessories = [];
//
//     try {
//       // Step 1: Try to fetch from cache
//       bool isUpdateCache = _appPreferences.isUpdateCache();
//       QuerySnapshot devicesSnapshot =
//           await _firestore.collection('devices').get(GetOptions(
//                 source: isUpdateCache ? Source.serverAndCache : Source.cache,
//               ));
//       if (!devicesSnapshot.metadata.isFromCache) {
//         print('Updating cache');
//         _appPreferences.setUpdateCache(false);
//       }
//       if (devicesSnapshot.docs.isNotEmpty) {
//         print('Devices loaded from cache');
//         devicesWithAccessories = _parseDevices(devicesSnapshot);
//       } else {
//         print('Cache is empty, fetching devices from server');
//
//         // Step 2: Fetch from the server if cache is empty
//         devicesSnapshot =
//             await _firestore.collection('devices').get(const GetOptions(
//                   source: Source.server,
//                 ));
//
//         devicesWithAccessories = _parseDevices(devicesSnapshot);
//       }
//     } catch (e) {
//       throw Exception("Error fetching devices and accessories: $e");
//     }
//
//     return devicesWithAccessories;
//   }
//
// // Helper function to parse the devices
//   List<Map<String, dynamic>> _parseDevices(QuerySnapshot devicesSnapshot) {
//     return devicesSnapshot.docs.map((doc) {
//       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//       return {
//         'deviceId': doc.id,
//         'name': data['name'],
//         'accessories': (data['accessories'] as List<dynamic>).map((accessory) {
//           return {
//             'displayName': accessory['displayName'],
//             'min': accessory['min'],
//             'max': accessory['max'],
//             'interval': accessory['interval'],
//             'weight': accessory['weight'],
//           };
//         }).toList(),
//       };
//     }).toList();
//   }
//
//   ////////////////////////////////////////////////////////////////////////
//
// // Function to get all trainees categorized by team name for a specific trainer.
//   Future<List<Map<String, dynamic>>> getTrainees() async {
//     try {
//       debugPrint('Fetching trainees...');
//       // Reference to the teams sub-collection for the specified trainer.
//       CollectionReference teamsRef = FirebaseFirestore.instance
//           .collection('trainers')
//           .doc(_appPreferences.getToken())
//           .collection('teams');
//
//       // Fetch all teams.
//       QuerySnapshot teamsSnapshot = await teamsRef.get();
//
//       // Map to hold the trainees grouped by team name.
//       List<Map<String, dynamic>> traineesByTeam = [];
//
//       // Iterate through each team.
//       for (QueryDocumentSnapshot teamDoc in teamsSnapshot.docs) {
//         String teamName = teamDoc['name'];
//
//         // Reference to the trainees sub-collection under this team.
//         CollectionReference traineesRef =
//             teamsRef.doc(teamDoc.id).collection('trainees');
//
//         // Fetch all trainees for the current team.
//         QuerySnapshot traineesSnapshot = await traineesRef.get();
//
//         // Map each trainee with its details.
//         List<Map<String, dynamic>> trainees =
//             traineesSnapshot.docs.map((traineeDoc) {
//           return {
//             'id': traineeDoc.id,
//             'name': traineeDoc['name'],
//           };
//         }).toList();
//         Map<String, dynamic> team = {
//           'id': teamDoc.id,
//           'name': teamName,
//           'trainees': trainees
//         };
//         // Add to the map with the team name as the key.
//         traineesByTeam.add(team);
//       }
//
//       return traineesByTeam;
//     } catch (e) {
//       debugPrint('Failed to get trainees categorized by team: $e');
//       return [];
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> getTrainerTraineesData() async {
//     final firestore = FirebaseFirestore.instance;
//
//     try {
//       // Fetch the trainer's document
//       DocumentSnapshot trainerSnapshot = await firestore
//           .collection('trainers')
//           .doc(_appPreferences.getToken())
//           .get();
//
//       if (trainerSnapshot.exists) {
//         // Extract the trainees' IDs from the trainer's data
//         List<dynamic> traineeIds = trainerSnapshot['trainees'] ?? [];
//
//         // Fetch each trainee's data using their IDs
//         List<Map<String, dynamic>> traineesData = [];
//
//         for (String traineeId in traineeIds) {
//           DocumentSnapshot traineeSnapshot =
//               await firestore.collection('trainees').doc(traineeId).get();
//
//           if (traineeSnapshot.exists) {
//             Map<String, dynamic> data =
//                 traineeSnapshot.data() as Map<String, dynamic>;
//             data['id'] = traineeId;
//             traineesData.add(data);
//           }
//         }
//
//         return traineesData;
//       } else {
//         debugPrint('Trainer does not exist.');
//         return [];
//       }
//     } catch (e) {
//       // Handle errors
//       debugPrint('Error fetching trainees data: $e');
//       return [];
//     }
//   }
//
//   Future<Map<String, dynamic>> checkTraineeExistence(String traineeId) async {
//     // Reference to the Firestore instance
//     final firestore = FirebaseFirestore.instance;
//
//     try {
//       // Attempt to retrieve the document with the specified ID
//       print(traineeId);
//       DocumentSnapshot docSnapshot =
//           await firestore.collection('trainees').doc(traineeId).get();
//       print(docSnapshot.exists);
//       if (docSnapshot.exists) {
//         // If the document exists, convert it to a map and add the 'exist' key
//         Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
//         data['exist'] = true;
//         data['id'] = traineeId;
//
//         DocumentReference docRef = FirebaseFirestore.instance
//             .collection('trainers')
//             .doc(_appPreferences.getToken());
//
//         DocumentSnapshot snapshot = await docRef.get();
//
//         if (snapshot.exists) {
//           await docRef.update({
//             'trainees': FieldValue.arrayUnion([traineeId]),
//           });
//         } else {
//           await docRef.set({
//             'trainees': [traineeId],
//           });
//         }
//         return data;
//       } else {
//         // If the document does not exist, return a map with 'exist': false
//         return {'exist': false};
//       }
//     } catch (e) {
//       // Handle any errors that occur during the process
//       return {'exist': false, 'error': e.toString()};
//     }
//   }
//
//   // Delete a trainee from a team
//   Future<void> deleteTrainee(String traineeId) async {
//     await _firestore.collection('trainees').doc(traineeId).delete();
//   }
//
//   // Delete an exercise from a category
//
//   // Get all training data for a trainee
//   Future<List<Map<String, dynamic>>> getAllTrainingForTrainee(
//       String traineeId) async {
//     final trainingSnapshot = await _firestore
//         .collection('trainees')
//         .doc(traineeId)
//         .collection('training')
//         .get();
//
//     return trainingSnapshot.docs
//         .map((doc) => {
//               'exerciseId': doc.id,
//               ...doc.data(),
//             })
//         .toList();
//   }
//
//   Future<void> addTrainingData(AddTrainingRequest addTrainingRequest) async {
//     // try {
//     debugPrint(addTrainingRequest.traineeId);
//     if (addTrainingRequest.traineeId.isEmpty) {
//       throw Exception('Trainee ID is invalid.');
//     }
//     if (addTrainingRequest.exerciseId==0) {
//       throw Exception('Exercise ID is invalid.');
//     }
//     // Reference to the specific trainee's training document for the exercise
//     DocumentReference trainingRef = FirebaseFirestore.instance
//         .collection('trainees')
//         .doc(addTrainingRequest.traineeId)
//         .collection('training')
//         .doc(addTrainingRequest.exerciseId.toString());
//
//     // Set the overall data for this exercise if not already set
//     DocumentSnapshot trainingSnapshot = await trainingRef.get();
//     if (!trainingSnapshot.exists) {
//
//       await trainingRef.set({
//         'name': addTrainingRequest.exerciseName,
//         'image': addTrainingRequest.exerciseImage,
//       }, SetOptions(merge: true));
//     } else {
//       // int overAllReps = await trainingSnapshot
//       //     .get('overAllReps')
//       //     .then((onValue) => onValue + 1);
//       // int overAllSets = await trainingSnapshot
//       //     .get('overAllSets')
//       //     .then((onValue) => onValue + addTrainingRequest.data.numOfSets);
//       // await trainingRef.set({
//       //   'overAllSets': overAllSets,
//       //   'overAllReps': overAllReps,
//       // }, SetOptions(merge: true));
//     }
//     // Add the data entry (new set) in the data sub-collection
//     await trainingRef.collection('data').add({
//       "numOfSets": addTrainingRequest.data.numOfSets,
//       "eccentricSpeed": addTrainingRequest.data.eccentricSpeed,
//       "concentricSpeed": addTrainingRequest.data.concentricSpeed,
//       "eccentricAcc": addTrainingRequest.data.eccentricAcc,
//       "concentricAcc": addTrainingRequest.data.concentricAcc,
//       "avgEccSpeed": addTrainingRequest.data.avgEccSpeed,
//       "avgConSpeed": addTrainingRequest.data.avgConSpeed,
//       "avgEccAcc": addTrainingRequest.data.avgEccAcc,
//       "avgConAcc": addTrainingRequest.data.avgConAcc,
//       "maxEccSpeed": addTrainingRequest.data.maxEccSpeed,
//       "maxConSpeed": addTrainingRequest.data.maxConSpeed,
//       "maxEccAcc": addTrainingRequest.data.maxEccAcc,
//       "maxConAcc": addTrainingRequest.data.maxConAcc,
//       "weight": addTrainingRequest.data.weight,
//       "timeBySeconds": addTrainingRequest.data.timeBySeconds,
//       "date": FieldValue.serverTimestamp(),
//     });
//     debugPrint('Training added successfully.');
//     // } catch (e) {
//     //   debugPrint('Failed to add training: $e');
//     // }
//   }
//
//   // Retrieve specific set data for a trainee's training
//   Future<Map<String, dynamic>> getLastTrainingData(
//       GetTrainingRequest request) async {
//     try {
//       // Reference to the data sub-collection
//       CollectionReference dataRef = FirebaseFirestore.instance
//           .collection('trainees')
//           .doc(request.traineeId.toString())
//           .collection('training')
//           .doc(request.exerciseId.toString())
//           .collection('data');
//
//       // Get the latest set by ordering by 'date' in descending order and limiting to 1 document
//       QuerySnapshot snapshot =
//           await dataRef.orderBy('date', descending: true).limit(1).get();
//
//       if (snapshot.docs.isNotEmpty) {
//         // Return the data of the latest set
//         return snapshot.docs.first.data() as Map<String, dynamic>;
//       } else {
//         debugPrint('No sets found for this training.');
//         return {"empty": true};
//       }
//     } catch (e) {
//       debugPrint('Failed to get the last set: $e');
//       return {'error': true,
//         'message': 'Failed to get the last set: $e'};
//     }
//   }
//
//   Future<Map<String, dynamic>> getTrainingData(
//       GetTrainingRequest request) async {
//     try {
//       // Reference to the specific training document for the exercise
//       DocumentReference trainingRef = FirebaseFirestore.instance
//           .collection('trainees')
//           .doc(request.traineeId.toString())
//           .collection('training')
//           .doc(request.exerciseId.toString());
//
//       // Get the main training document
//       DocumentSnapshot trainingSnapshot = await trainingRef.get();
//       if (!trainingSnapshot.exists) {
//         debugPrint('No training found for exercise ${request.exerciseId}.');
//         return {};
//       }
//
//       // Calculate the date threshold based on the requested period
//       DateTime now = DateTime.now();
//       DateTime startDate;
//
//       if (request.weakly) {
//         startDate = now.subtract(const Duration(days: 7 * 4)); // Last 4 weeks
//       } else if (!request.weakly) {
//         startDate = DateTime(now.year, now.month - 3, now.day); // Last 4 months
//       } else {
//         debugPrint('Invalid period specified');
//         return {};
//       }
//
//       // Fetch only data within the given date range
//       QuerySnapshot dataSnapshot = await trainingRef
//           .collection('data')
//           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
//           .orderBy('date', descending: true)
//           .get();
//
//       List<Map<String, dynamic>> sets = dataSnapshot.docs.map((doc) {
//         return doc.data() as Map<String, dynamic>;
//       }).toList();
//
//       log(sets.toString());
//
//       // Combine the main training info with all sets
//       return {
//         'data': sets,
//       };
//     } catch (e) {
//       debugPrint('Failed to get training data: $e');
//       return {};
//     }
//   }
//
//   // Future<Map<String, dynamic>> getTrainingData(
//   //     GetTrainingRequest request) async {
//   //   try {
//   //     // Reference to the specific training document for the exercise
//   //     DocumentReference trainingRef = FirebaseFirestore.instance
//   //         .collection('trainees')
//   //         .doc(request.traineeId)
//   //         .collection('training')
//   //         .doc(request.exerciseId);
//   //
//   //     // Get the main training document
//   //     DocumentSnapshot trainingSnapshot = await trainingRef.get();
//   //     if (trainingSnapshot.exists) {
//   //       // Get the data sub-collection (individual sets)
//   //       QuerySnapshot dataSnapshot = await trainingRef
//   //           .collection('data')
//   //           .orderBy('date', descending: true)
//   //           .get();
//   //       List<Map<String, dynamic>> sets = dataSnapshot.docs.map((doc) {
//   //         return doc.data() as Map<String, dynamic>;
//   //       }).toList();
//   //       log(sets.toString());
//   //       // Combine the main training info with all sets
//   //       return {
//   //         'overAllSets': trainingSnapshot.get('overAllSets'),
//   //         'overAllReps': trainingSnapshot.get('overAllReps'),
//   //         'data': sets,
//   //       };
//   //     } else {
//   //       debugPrint('No training found for exercise ${request.exerciseId}.');
//   //       return {};
//   //     }
//   //   } catch (e) {
//   //     debugPrint('Failed to get training data: $e');
//   //     return {};
//   //   }
//   // }
//
//   // Calculate average metrics for training
//   Future<Map<String, double>> calculateAverageMetrics(
//       String traineeId, String exerciseId) async {
//     final setDataSnapshot = await _firestore
//         .collection('trainees')
//         .doc(traineeId)
//         .collection('training')
//         .doc(exerciseId)
//         .collection('data')
//         .get();
//
//     double totalDrafting = 0.0;
//     double totalDistress = 0.0;
//     int count = setDataSnapshot.size;
//
//     for (var doc in setDataSnapshot.docs) {
//       totalDrafting += doc.data()['averageDrafting'] ?? 0.0;
//       totalDistress += doc.data()['averageDistress'] ?? 0.0;
//     }
//
//     return {
//       'averageDrafting': count > 0 ? totalDrafting / count : 0.0,
//       'averageDistress': count > 0 ? totalDistress / count : 0.0,
//     };
//   }
// }
