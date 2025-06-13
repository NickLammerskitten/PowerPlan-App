import 'package:flutter/cupertino.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() {
    return _SettingsTabState();
  }
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: const <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text('Einstellungen'),
        ),
      ],
    );
  }
}