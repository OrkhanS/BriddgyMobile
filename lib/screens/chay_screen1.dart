import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ChayScreen extends StatefulWidget {
  @override
  _ChayScreenState createState() => _ChayScreenState();
}

List<String> loxlar = ["Rasul", "Javid", "Rustam", "Orxan", "Zulfugar", "Ferhad"];

class _ChayScreenState extends State<ChayScreen> {
  bool generated;
  @override
  void initState() {
    generated = false;
    super.initState();
  }
  Future getProjectDetails() async {
    var result = await http.get('https://backend.briddgy.com/api/chayisteyirem/');
    return result;    
  }
  Widget projectWidget() {
  return FutureBuilder(
    builder: (context, projectSnap) {
      if (!projectSnap.hasData) {
        return Container();
      }
      var data = json.decode(projectSnap.data.body);
      return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          var project = data;
          var wid;
          wid = Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  (index + 1).toString() + ". " + project[index].toString(),
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          );
          return wid;
        },
      );
    },
    future: getProjectDetails(),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Text(
                "Chay gorek kim getirir :D ",
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SvgPicture.asset(
              "assets/photos/tea.svg",
              width: MediaQuery.of(context).size.width * 0.8,
            ),
          ),
         Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: projectWidget(), 
                  ),
                ),
        ],
      ),
    )),
  );
}

}
