import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firesport_users/data/network/error_handler.dart';

String cacheHomeKey = 'CACHE HOME KEY';
String cacheTeamsKey = 'CACHE Teams KEY';

abstract class LocalDataSource {

  // Future<DocumentSnapshot> homeResponse(bool internet);
  // Future<void> saveHomeToCache(User user);
  //
  // Future<DocumentSnapshot> teamsResponse(bool internet);
  // Future<void> saveTeamsToCache(DocumentSnapshot documentSnapshot);

  // Future<void> saveStoreDetailsToCache(StoresDetailsResponse storesDetailsResponse);

  void clearCache();

  void removeFromCache(String key);
}


class LocalDataSourceImpl extends LocalDataSource {
  Map<String, CachedItem> cacheMap = {};

  // @override
  // Future<DocumentSnapshot> homeResponse(bool internet) async {
  //   CachedItem? cachedItem = cacheMap[cacheHomeKey];
  //   if (internet) {
  //     if (cachedItem != null && cachedItem.isValid(1000)) {
  //       return cachedItem.data;
  //     } else {
  //       throw ErrorHandler.handle(DataSource.cacheError);
  //     }
  //   } else {
  //     if (cachedItem != null) {
  //       return cachedItem.data;
  //     } else {
  //       throw ErrorHandler.handle(DataSource.cacheError);
  //     }
  //   }
  // }



  @override
  Future<void> saveHomeToCache(User user) async {
    cacheMap[cacheHomeKey] = CachedItem(data: user);
  }

  @override
  void clearCache() {
    cacheMap.clear();
  }

  @override
  void removeFromCache(String key) {
    cacheMap.remove(key);
  }

  // @override
  // Future<DocumentSnapshot> teamsResponse(bool internet) async {
  //   // Box<UserDataObject> teams = Hive.box<UserDataObject>(Constant.userData);
  //   CachedItem? cachedItem = cacheMap[cacheHomeKey];
  //   if (internet) {
  //     if (cachedItem != null && cachedItem.isValid(6000)) {
  //       return cachedItem.data;
  //     } else {
  //       throw ErrorHandler.handle(DataSource.cacheError);
  //     }
  //   } else {
  //     if (cachedItem != null) {
  //       return cachedItem.data;
  //     } else {
  //       throw ErrorHandler.handle(DataSource.cacheError);
  //     }
  //   }
  // }
  // @override
  // Future<void> saveTeamsToCache(DocumentSnapshot<Object?> documentSnapshot) async {
  //   cacheMap[cacheTeamsKey] = CachedItem(data: documentSnapshot);
  // }
}




class CachedItem {
  dynamic data;
  int cacheTime = DateTime.now().millisecondsSinceEpoch;

  CachedItem({required this.data});
}

extension CachedItemExtension on CachedItem {
  bool isValid(int expirationTime) {
    int checkTime = DateTime.now().millisecondsSinceEpoch;
    bool isValid = checkTime - cacheTime < expirationTime;
    return isValid;
  }
}


