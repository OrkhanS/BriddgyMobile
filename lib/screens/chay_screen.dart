import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "Chay isteyirem ",
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
          generated
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: ListView.builder(
                      itemCount: loxlar.length,
                      itemBuilder: (context, index) {
                        var wid;
                        wid = Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                (index + 1).toString() + ". " + loxlar[index].toString(),
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        );

                        return wid;
                      },
                    ),
                  ),
                )
              : Expanded(child: Text("Press the button to generate lox")),
          RaisedButton(
            onPressed: () {
              setState(() {
                loxlar.shuffle();
                generated = true;
              });
            },
            color: Colors.red,
            child: Text(
              "Generate Lox",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ));
  }
}
