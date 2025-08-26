import 'dart:convert';
import 'package:firesport_users/presentation/resources/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  Map<String, dynamic>? privacyPolicy;

  @override
  void initState() {
    super.initState();
    loadPrivacyPolicy();
  }

  Future<void> loadPrivacyPolicy() async {
    final String response =
    await rootBundle.loadString('assets/json/privacy_policy.json');
    setState(() {
      privacyPolicy = json.decode(response)['privacy_policy'];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (privacyPolicy == null) {
      return Scaffold(
        appBar:  AppBar(title:const Text("Privacy Policy")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(privacyPolicy!['title'] ,style: const  TextStyle(fontWeight:FontWeight.bold),),centerTitle: false,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: privacyPolicy!['content'].length,
          itemBuilder: (context, index) {
            final section = privacyPolicy!['content'][index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['heading'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorManager.black),
                  ),
                  const SizedBox(height: 8),
                  for (var detail in section['details'])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        detail,
                        style: TextStyle(fontSize: 16, color: ColorManager.simiBlack),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
