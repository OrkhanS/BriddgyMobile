import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optisend/widgets/order_widget.dart';
import 'package:optisend/widgets/trip_widget.dart';

class NewContactScreen extends StatefulWidget {
  @override
  _NewContactScreenState createState() => _NewContactScreenState();
}

class _NewContactScreenState extends State<NewContactScreen> {
  int currentStep = 1;
  bool iAmOrderer = true;
  bool complete = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: AppBar(
                backgroundColor: Colors.white,
                centerTitle: true,
                leading: IconButton(
                  color: Theme.of(context).primaryColor,
                  icon: Icon(
                    Icons.chevron_left,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  "New Contact ",
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
                elevation: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: currentStep >= 1 ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Center(
                      child: Text(
                        "1",
                        style: TextStyle(
                            color: currentStep >= 1 ? Colors.white : Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  customDivider(),
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: currentStep >= 2 ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Center(
                      child: Text(
                        "2",
                        style: TextStyle(
                            color: currentStep >= 2 ? Colors.white : Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  customDivider(),
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: currentStep >= 3 ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Center(
                      child: Text(
                        "3",
                        style: TextStyle(
                            color: currentStep >= 3 ? Colors.white : Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  customDivider(),
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: currentStep >= 4 ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Center(
                      child: Text(
                        "4",
                        style: TextStyle(
                            color: currentStep >= 4 ? Colors.white : Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (currentStep == 1) Step1(stepIncrement, setOrderer),
            if (currentStep == 2) Step2(),
            if (currentStep == 4) Step4(),
          ],
        ),
      ),
    );
  }

  Container customDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: 25,
      height: 1,
      color: Colors.black26,
    );
  }

  void stepIncrement() {
    setState(() {
      //todo Rasul fix
      currentStep = 4;
    });
  }

  void setOrderer(bool me) {
    setState(() {
      iAmOrderer = me;
    });
  }
}

class Step1 extends StatelessWidget {
  Function next, setOrderer;

  Step1(this.next, this.setOrderer);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(200)),
                  child: Icon(
                    MdiIcons.packageVariantClosed,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text("I am orderer"),
              ],
            ),
            onPressed: () {
              next();
              setOrderer(true);
            },
          ),
          RaisedButton(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(200)),
                  child: Icon(
                    MdiIcons.roadVariant,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text("I am traveler"),
              ],
            ),
            onPressed: () {
              next();
              setOrderer(false);
            },
          ),
        ],
      ),
    );
  }
}

class Step2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Select Trip"),
          ),
          Expanded(
              child: ListView(
            children: <Widget>[
              for (var i = 0; i < 10; i++) TripFadeWidget(),
            ],
          )
//            Provider.of(context).notLoaded != false
//                ? ListView(
//                    children: <Widget>[
//                      for (var i = 0; i < 10; i++) TripFadeWidget(),
//                    ],
//                  )
//                : ListView.builder(
//                    itemBuilder: (context, int i) {
//                      return TripWidget(trip: _trips[i], i: i);
//                    },
//                    itemCount: _trips == null ? 0 : _trips.length,
//                  ),
              )
        ],
      ),
    );
  }
}

class Step4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
//        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Summary"),
          ),
          TripFadeWidget(),
          OrderFadeWidget(),
          Expanded(
            child: SizedBox(
              width: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: RaisedButton.icon(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                            color: Theme.of(context).scaffoldBackgroundColor,
              color: Colors.green,

              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              icon: Icon(
                MdiIcons.textBoxCheckOutline,
                color: Colors.white,
//                              color: Theme.of(context).primaryColor,
                size: 18,
              ),
              label: Text(
                "Confirm & Propose",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
//                                    color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}
