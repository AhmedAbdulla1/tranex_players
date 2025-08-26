import 'package:firebase_core/firebase_core.dart';
import 'package:firesport_users/app/app.dart';
import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/data/network/network_info.dart';
import 'package:firesport_users/firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppModule();
  await Supabase.initialize(
    url: 'https://vglkhiirjgiyarjebqpl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZnbGtoaWlyamdpeWFyamVicXBsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI2MDMyOTEsImV4cCI6MjA1ODE3OTI5MX0.hp7KtDL7nZ_g9F_tjfqBQw0FKwk-G-tLtCLRG1r8PqE',
  );
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  await instance<NetworkInfo>().ensureInitialized();

  runApp(MyApp());
}

