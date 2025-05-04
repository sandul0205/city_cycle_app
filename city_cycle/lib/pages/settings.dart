import 'package:city_cycle/pages/change_pw.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Change Password"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePw()));
            },
          ),
          
        ],
      ),
    );
  }
}