import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class AddItemScreen extends StatelessWidget {
  static const routeName = '/orders/add_item';
  String _startDate = "Date";
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          color: Theme.of(context).primaryColor,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Add Item", //Todo: item name
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 20, bottom: 20),
                  child: Text(
                    "Item Information",
                    style: TextStyle(
                        fontSize: 25, color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
            Container(
//              alignment: Alignment.center,
              width: deviceWidth * 0.8,
              child: TextFormField(
//                          enabled: _authMode == AuthMode.Signup,
                decoration: InputDecoration(
                  labelText: 'Title:',
                  icon: Icon(Icons.markunread_mailbox),
                ),
                //validator: _authMode == AuthMode.Signup ? (value) {} : null,
                onSaved: (value) {},
              ),
            ),
            Container(
              width: deviceWidth * 0.8,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'From:',
                  icon: Icon(Icons.place),
                ),
                keyboardType: TextInputType.text,
//
                onSaved: (value) {
//                        _authData['email'] = value;
                },
              ),
            ),
            Container(
              width: deviceWidth * 0.8,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'To:',
                  icon: Icon(Icons.location_on),
                ),

                keyboardType: TextInputType.text,
//                      validator: (value) {
//                        if (value.isEmpty || !value.contains('@')) {
//                          return 'Invalid email!';
//                        } else
//                          return null; //Todo
//                      },
                onSaved: (value) {
//                        _authData['email'] = value;
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              width: deviceWidth * 0.4,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                elevation: 4.0,
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      theme: DatePickerTheme(
                        itemStyle: TextStyle(color: Colors.blue[800]),
                        containerHeight: 300.0,
                      ),
                      showTitleActions: true,
                      minTime: DateTime(2015, 1, 1),
                      maxTime: DateTime(2025, 12, 31), onConfirm: (date) {
                    print('confirm $date'); //todo: delete
                    _startDate = '${date.day}/${date.month}/${date.year}  ';
                  }, currentTime: DateTime.now(), locale: LocaleType.en);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 40.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
//                                            Icon(
//                                              Icons.date_range,
//                                              size: 18.0,
//                                              color: Theme.of(context)
//                                                  .primaryColor,
//                                            ),
                                Text(
                                  " $_startDate",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                color: Colors.white,
              ),
            ),
            Container(
              width: deviceWidth * 0.8,
              child: new ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 300.0,
                ),
                child: new Scrollbar(
                  child: new SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    reverse: true,
                    child: new TextField(
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: 'Description:',
                        icon: Icon(Icons.description),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: deviceWidth * 0.8,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price:',
                  icon: Icon(Icons.attach_money),
                ),

                keyboardType: TextInputType.number,
//                      validator: (value) {
//                        if (value.isEmpty || !value.contains('@')) {
//                          return 'Invalid email!';
//                        } else
//                          return null; //Todo
//                      },
                onSaved: (value) {
//                        _authData['email'] = value;
                },
              ),
            ),
            Container(
              width: deviceWidth * 0.8,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Weight:',
                  icon: Icon(Icons.attach_money),
                ),

                keyboardType: TextInputType.number,
//                      validator: (value) {
//                        if (value.isEmpty || !value.contains('@')) {
//                          return 'Invalid email!';
//                        } else
//                          return null; //Todo
//                      },
                onSaved: (value) {
//                        _authData['email'] = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,

                  elevation: 2,
//                            color: Theme.of(context).primaryColor,
                  child: Container(
                    width: deviceWidth * 0.7,
                    child: Center(
                      child: Text(
                        "Add Item",
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
//                                  fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
