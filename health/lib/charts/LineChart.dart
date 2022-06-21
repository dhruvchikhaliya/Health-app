import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:health/pages/FullChart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

Widget LineChart(String userUID) {
  List<Map<dynamic, dynamic>> lists = [];
  return StreamBuilder(
      stream: FirebaseDatabase.instance
          .reference()
          .child("Userbodydata")
          .child("$userUID")
          .onValue,
      builder: (context, AsyncSnapshot<Event> snapshot) {
        if (snapshot.hasData) {
          DataSnapshot dataValues = snapshot.data.snapshot;
          if (dataValues.value.toString().contains("Data")) {
            Map<dynamic, dynamic> values = (dataValues.value)["Data"];
            values.forEach((key, values) {
              lists.add(values);
            });
            lists.sort((a, b) {
              return a['Timestamp'].compareTo(b['Timestamp']);
            });
            return new ListView(children: [
              _emergency(
                  dataValues.value["Freefall"] ?? 1, "Free Fall detected"),
              _emergency(
                  dataValues.value["tinyMLans1"] ?? 1, "Artial Premature"),
              _emergency(dataValues.value["tinyMLans2"] ?? 1,
                  "Premature ventricular conraction"),
              _emergency(dataValues.value["tinyMLans3"] ?? 1,
                  "Fusion of ventricular and normal"),
              _emergency(dataValues.value["tinyMLans4"] ?? 1,
                  "Fusion of paced and normal"),
              Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                width: double.maxFinite,
                child: Card(
                    elevation: 5,
                    color: Color(0xff009688),
                    child: ListTile(
                      title: Text("Battery",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          (DateTime.now().millisecondsSinceEpoch / 1000 -
                                      lists[(lists.length) - 1]["Timestamp"] <=
                                  60)
                              ? "${dataValues.value["Battery"].toString()}%"
                              : "Not Connected",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      trailing: new Icon(Icons.battery_charging_full, size: 30),
                    )),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                height: 250,
                width: double.maxFinite,
                child: Card(
                    elevation: 5,
                    color: Colors.white,
                    child: Padding(
                        padding: EdgeInsets.all(7),
                        child: Stack(children: <Widget>[
                          Align(
                              alignment: Alignment.centerRight,
                              child: Stack(children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 7, top: 5),
                                  child: InkWell(
                                    splashColor: Colors.blue.withAlpha(30),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FullChart(
                                                lists, "Heartbeat", 0)),
                                      );
                                    },
                                    child: Column(children: <Widget>[
                                      Row(children: <Widget>[
                                        heartIcon(),
                                        NameSymbol('Heart Rate', 'BPM'),
                                        Spacer(),
                                        liveChange('0', lists),
                                      ]),
                                      Expanded(
                                          child: Row(children: <Widget>[
                                        Expanded(
                                          child: new charts.TimeSeriesChart(
                                            _heartGraph(lists),
                                            animate: true,
                                            selectionModels: [
                                              charts.SelectionModelConfig(
                                                type: charts
                                                    .SelectionModelType.info,
                                                // changedListener: _onSelectionChanged
                                              )
                                            ],
                                            behaviors: [
                                              new charts.SlidingViewport(),
                                            ],
                                            primaryMeasureAxis: new charts
                                                    .NumericAxisSpec(
                                                tickProviderSpec: new charts
                                                        .BasicNumericTickProviderSpec(
                                                    zeroBound: false)),
                                            domainAxis:
                                                DateTimeAxisSpecWorkaround(
                                                    tickFormatterSpec: new charts
                                                        .AutoDateTimeTickFormatterSpec(
                                                      minute: new charts
                                                          .TimeFormatterSpec(
                                                        format:
                                                            'hh:mm', // or even HH:mm here too
                                                        transitionFormat:
                                                            'hh:mm',
                                                      ),
                                                      hour: new charts
                                                          .TimeFormatterSpec(
                                                        format:
                                                            'hh:mm', // or even HH:mm here too
                                                        transitionFormat:
                                                            'ddMMM hh:mm',
                                                      ),
                                                      day: new charts
                                                          .TimeFormatterSpec(
                                                        format:
                                                            'hh:mm', // or even HH:mm here too
                                                        transitionFormat:
                                                            'ddMMM hh:mm',
                                                      ),
                                                    ),
                                                    viewport:
                                                        charts.DateTimeExtents(
                                                      start: DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              lists[0][
                                                                      "Timestamp"] *
                                                                  1000),
                                                      end: DateTime.fromMillisecondsSinceEpoch(((lists[
                                                                      lists.length -
                                                                          1][
                                                                  "Timestamp"]) +
                                                              ((lists[lists.length - 1]
                                                                              [
                                                                              "Timestamp"] -
                                                                          lists[0]
                                                                              [
                                                                              "Timestamp"]) /
                                                                      4)
                                                                  .toInt()) *
                                                          1000),
                                                    )),
                                          ),
                                        ),
                                      ]))
                                    ]),
                                  ),
                                )
                              ]))
                        ]))),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                height: 250,
                width: double.maxFinite,
                child: Card(
                    elevation: 5,
                    color: Colors.white,
                    child: Padding(
                        padding: EdgeInsets.all(7),
                        child: Stack(children: <Widget>[
                          Align(
                              alignment: Alignment.centerRight,
                              child: Stack(children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 7, top: 5),
                                  child: InkWell(
                                    splashColor: Colors.blue.withAlpha(30),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FullChart(lists, "Spo2", 2)),
                                      );
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Row(children: <Widget>[
                                          spoIcon(),
                                          NameSymbol('Sp02', '%'),
                                          Spacer(),
                                          liveChange('2', lists),
                                        ]),
                                        Expanded(
                                            child: Row(children: <Widget>[
                                          Expanded(
                                            child: new charts.TimeSeriesChart(
                                              _spo2(lists),
                                              animate: true,
                                              selectionModels: [
                                                charts.SelectionModelConfig(
                                                  type: charts
                                                      .SelectionModelType.info,
                                                  // changedListener: _onSelectionChanged
                                                )
                                              ],
                                              behaviors: [
                                                new charts.SlidingViewport(),
                                              ],
                                              primaryMeasureAxis: new charts
                                                      .NumericAxisSpec(
                                                  tickProviderSpec: new charts
                                                          .BasicNumericTickProviderSpec(
                                                      zeroBound: false)),
                                              domainAxis:
                                                  DateTimeAxisSpecWorkaround(
                                                      tickFormatterSpec: new charts
                                                          .AutoDateTimeTickFormatterSpec(
                                                        minute: new charts
                                                            .TimeFormatterSpec(
                                                          format:
                                                              'hh:mm', // or even HH:mm here too
                                                          transitionFormat:
                                                              'hh:mm',
                                                        ),
                                                        hour: new charts
                                                            .TimeFormatterSpec(
                                                          format:
                                                              'hh:mm', // or even HH:mm here too
                                                          transitionFormat:
                                                              'ddMMM hh:mm',
                                                        ),
                                                        day: new charts
                                                            .TimeFormatterSpec(
                                                          format:
                                                              'hh:mm', // or even HH:mm here too
                                                          transitionFormat:
                                                              'ddMMM hh:mm',
                                                        ),
                                                      ),
                                                      viewport: charts
                                                          .DateTimeExtents(
                                                        start: DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                                lists[0][
                                                                        "Timestamp"] *
                                                                    1000),
                                                        end: DateTime.fromMillisecondsSinceEpoch(((lists[
                                                                        lists.length -
                                                                            1][
                                                                    "Timestamp"]) +
                                                                ((lists[lists.length -
                                                                                1]["Timestamp"] -
                                                                            lists[0]["Timestamp"]) /
                                                                        4)
                                                                    .toInt()) *
                                                            1000),
                                                      )),
                                            ),
                                          )
                                        ]))
                                      ],
                                    ),
                                  ),
                                )
                              ]))
                        ]))),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                height: 250,
                width: double.maxFinite,
                child: Card(
                    elevation: 5,
                    color: Colors.white,
                    child: Padding(
                        padding: EdgeInsets.all(7),
                        child: Stack(children: <Widget>[
                          Align(
                              alignment: Alignment.centerRight,
                              child: Stack(children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 7, top: 5),
                                  child: InkWell(
                                    splashColor: Colors.blue.withAlpha(30),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FullChart(
                                                lists, "Body Temperature", 1)),
                                      );
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Row(children: <Widget>[
                                          bodyIcon(),
                                          NameSymbol(
                                              'Body Temperature', "\u2109"),
                                          Spacer(),
                                          liveChange('1', lists),
                                        ]),
                                        Expanded(
                                          child: new charts.TimeSeriesChart(
                                            _bodyTemperature(lists),
                                            animate: true,
                                            selectionModels: [
                                              charts.SelectionModelConfig(
                                                type: charts
                                                    .SelectionModelType.info,
                                                // changedListener: _onSelectionChanged
                                              )
                                            ],
                                            behaviors: [
                                              new charts.SlidingViewport(),
                                            ],
                                            primaryMeasureAxis: new charts
                                                    .NumericAxisSpec(
                                                tickProviderSpec: new charts
                                                        .BasicNumericTickProviderSpec(
                                                    zeroBound: false)),
                                            domainAxis:
                                                DateTimeAxisSpecWorkaround(
                                                    tickFormatterSpec: new charts
                                                        .AutoDateTimeTickFormatterSpec(
                                                      minute: new charts
                                                          .TimeFormatterSpec(
                                                        format:
                                                            'hh:mm', // or even HH:mm here too
                                                        transitionFormat:
                                                            'hh:mm',
                                                      ),
                                                      hour: new charts
                                                          .TimeFormatterSpec(
                                                        format:
                                                            'hh:mm', // or even HH:mm here too
                                                        transitionFormat:
                                                            'ddMMM hh:mm',
                                                      ),
                                                      day: new charts
                                                          .TimeFormatterSpec(
                                                        format:
                                                            'hh:mm', // or even HH:mm here too
                                                        transitionFormat:
                                                            'ddMMM hh:mm',
                                                      ),
                                                    ),
                                                    viewport:
                                                        charts.DateTimeExtents(
                                                      start: DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              lists[0][
                                                                      "Timestamp"] *
                                                                  1000),
                                                      end: DateTime.fromMillisecondsSinceEpoch(((lists[
                                                                      lists.length -
                                                                          1][
                                                                  "Timestamp"]) +
                                                              ((lists[lists.length - 1]
                                                                              [
                                                                              "Timestamp"] -
                                                                          lists[0]
                                                                              [
                                                                              "Timestamp"]) /
                                                                      4)
                                                                  .toInt()) *
                                                          1000),
                                                    )),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ]))
                        ]))),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                height: 250,
                width: double.maxFinite,
                child: Card(
                    elevation: 5,
                    color: Colors.white,
                    child: Padding(
                        padding: EdgeInsets.all(7),
                        child: Stack(children: <Widget>[
                          Align(
                              alignment: Alignment.centerRight,
                              child: Stack(children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 7, top: 5),
                                  child: InkWell(
                                    splashColor: Colors.blue.withAlpha(30),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FullChart(
                                                lists, "Surround Temp.", 4)),
                                      );
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Row(children: <Widget>[
                                          tempIcon(),
                                          NameSymbol(
                                              'Surround Temperature', "\u2103"),
                                          Spacer(),
                                          liveChange('4', lists),
                                        ]),
                                        Expanded(
                                          child: new charts.TimeSeriesChart(
                                            _surTemperature(lists),
                                            animate: true,
                                            selectionModels: [
                                              charts.SelectionModelConfig(
                                                type: charts
                                                    .SelectionModelType.info,
                                                // changedListener: _onSelectionChanged
                                              )
                                            ],
                                            behaviors: [
                                              new charts.SlidingViewport(),
                                            ],
                                            primaryMeasureAxis: new charts
                                                    .NumericAxisSpec(
                                                tickProviderSpec: new charts
                                                        .BasicNumericTickProviderSpec(
                                                    zeroBound: false)),
                                            domainAxis:
                                                DateTimeAxisSpecWorkaround(
                                                    tickFormatterSpec: new charts
                                                        .AutoDateTimeTickFormatterSpec(
                                                      minute: new charts
                                                          .TimeFormatterSpec(
                                                        format:
                                                            'hh:mm', // or even HH:mm here too
                                                        transitionFormat:
                                                            'hh:mm',
                                                      ),
                                                      hour: new charts
                                                          .TimeFormatterSpec(
                                                        format:
                                                            'hh:mm', // or even HH:mm here too
                                                        transitionFormat:
                                                            'ddMMM hh:mm',
                                                      ),
                                                      day: new charts
                                                          .TimeFormatterSpec(
                                                        format:
                                                            'hh:mm', // or even HH:mm here too
                                                        transitionFormat:
                                                            'ddMMM hh:mm',
                                                      ),
                                                    ),
                                                    viewport:
                                                        charts.DateTimeExtents(
                                                      start: DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              lists[0][
                                                                      "Timestamp"] *
                                                                  1000),
                                                      end: DateTime.fromMillisecondsSinceEpoch(((lists[
                                                                      lists.length -
                                                                          1][
                                                                  "Timestamp"]) +
                                                              ((lists[lists.length - 1]
                                                                              [
                                                                              "Timestamp"] -
                                                                          lists[0]
                                                                              [
                                                                              "Timestamp"]) /
                                                                      4)
                                                                  .toInt()) *
                                                          1000),
                                                    )),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ]))
                        ]))),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                height: 250,
                width: double.maxFinite,
                child: Card(
                    elevation: 5,
                    color: Colors.white,
                    child: Padding(
                        padding: EdgeInsets.all(7),
                        child: Stack(children: <Widget>[
                          Align(
                              alignment: Alignment.centerRight,
                              child: Stack(children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 7, top: 5),
                                  child: InkWell(
                                    splashColor: Colors.blue.withAlpha(30),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FullChart(
                                                lists, "Altitude", 3)),
                                      );
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Row(children: <Widget>[
                                          altitudeIcon(),
                                          NameSymbol('Altitude', 'Meter'),
                                          Spacer(),
                                          liveChange('3', lists),
                                        ]),
                                        Expanded(
                                          child: new charts.TimeSeriesChart(
                                            _altitude(lists),
                                            animate: true,
                                            selectionModels: [
                                              charts.SelectionModelConfig(
                                                type: charts
                                                    .SelectionModelType.info,
                                                // changedListener: _onSelectionChanged
                                              )
                                            ],
                                            behaviors: [
                                              new charts.SlidingViewport(),
                                            ],
                                            primaryMeasureAxis: new charts
                                                    .NumericAxisSpec(
                                                tickProviderSpec: new charts
                                                        .BasicNumericTickProviderSpec(
                                                    zeroBound: false)),
                                            domainAxis:
                                                DateTimeAxisSpecWorkaround(
                                                    tickFormatterSpec: new charts
                                                        .AutoDateTimeTickFormatterSpec(
                                                      minute: new charts
                                                          .TimeFormatterSpec(
                                                        format:
                                                            'hh:mm', // or even HH:mm here too
                                                        transitionFormat:
                                                            'hh:mm',
                                                      ),
                                                      hour: new charts
                                                          .TimeFormatterSpec(
                                                        format:
                                                            'hh:mm', // or even HH:mm here too
                                                        transitionFormat:
                                                            'ddMMM hh:mm',
                                                      ),
                                                      day: new charts
                                                          .TimeFormatterSpec(
                                                        format:
                                                            'hh:mm', // or even HH:mm here too
                                                        transitionFormat:
                                                            'ddMMM hh:mm',
                                                      ),
                                                    ),
                                                    viewport:
                                                        charts.DateTimeExtents(
                                                      start: DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              lists[0][
                                                                      "Timestamp"] *
                                                                  1000),
                                                      end: DateTime.fromMillisecondsSinceEpoch(((lists[
                                                                      lists.length -
                                                                          1][
                                                                  "Timestamp"]) +
                                                              ((lists[lists.length - 1]
                                                                              [
                                                                              "Timestamp"] -
                                                                          lists[0]
                                                                              [
                                                                              "Timestamp"]) /
                                                                      4)
                                                                  .toInt()) *
                                                          1000),
                                                    )),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ]))
                        ]))),
              ),
              Container(
                height: 25.0,
                width: 0.0,
              )
            ]);
          } else {
            return new Container(
                alignment: Alignment.center,
                child: Text("No Data",
                    style: TextStyle(
                      color: Colors.black26,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    )));
          }
        }
        return LinearProgressIndicator();
      });
}

Widget _emergency(_data, String name) {
  if (_data != 1) {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        width: double.maxFinite,
        child: Card(
            elevation: 5,
            color: Colors.black,
            child: ListTile(
              title: Text(name,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              subtitle: Text(
                  DateFormat("hh:mm:ss dd MMM,yyyy")
                      .format(DateTime.fromMillisecondsSinceEpoch(_data))
                      .toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              trailing: Text("Emergency",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            )));
  } else
    return Container(
      height: 0.0,
      width: 0.0,
    );
}

Widget heartIcon() {
  return Padding(
    padding: const EdgeInsets.only(left: 0),
    child: Align(
        alignment: Alignment.centerLeft,
        child: Icon(
          Icons.favorite,
          color: Colors.grey,
          size: 30,
        )),
  );
}

Widget tempIcon() {
  return Padding(
    padding: const EdgeInsets.only(left: 0),
    child: Align(
        alignment: Alignment.centerLeft,
        child: Icon(
          Icons.thermostat_rounded,
          color: Colors.grey,
          size: 30,
        )),
  );
}

Widget spoIcon() {
  return Padding(
    padding: const EdgeInsets.only(left: 0),
    child: Align(
        alignment: Alignment.centerLeft,
        child: Icon(
          Icons.favorite_border,
          color: Colors.grey,
          size: 30,
        )),
  );
}

Widget bodyIcon() {
  return Padding(
    padding: const EdgeInsets.only(left: 0),
    child: Align(
        alignment: Alignment.centerLeft,
        child: Icon(
          Icons.thermostat_rounded,
          color: Colors.grey,
          size: 30,
        )),
  );
}

Widget altitudeIcon() {
  return Padding(
    padding: const EdgeInsets.only(left: 0),
    child: Align(
        alignment: Alignment.centerLeft,
        child: Icon(
          Icons.pin_drop,
          color: Colors.grey,
          size: 30,
        )),
  );
}

Widget NameSymbol(String main, String unit) {
  return Align(
    alignment: Alignment.centerLeft,
    child: RichText(
      text: TextSpan(
        text: main,
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
        children: <TextSpan>[
          TextSpan(
              text: '\n$unit',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

Widget liveChange(String i, List data) {
  return Align(
    alignment: Alignment.topRight,
    child: RichText(
      text: TextSpan(
        text: data[data.length - 1][i].toString(),
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 20),
      ),
    ),
  );
}

_heartGraph(List data) {
  List<Heartbeat> heartbeat_ = [];
  for (var i = (data.length) - 1; i >= 0; i--) {
    heartbeat_.add(Heartbeat(
        new DateTime.fromMillisecondsSinceEpoch(data[i]["Timestamp"] * 1000),
        data[i]["0"]));
  }
  List<charts.Series<Heartbeat, DateTime>> series = [
    charts.Series(
        id: "Heartbeat",
        data: heartbeat_,
        domainFn: (Heartbeat series, _) => series.timestamp,
        measureFn: (Heartbeat series, _) => series.heartbeat,
        colorFn: (Heartbeat series, _) =>
            charts.MaterialPalette.teal.shadeDefault)
  ];
  return series;
}

_spo2(List data) {
  List<Spo2> spo_ = [];
  for (var i = (data.length) - 1; i >= 0; i--) {
    spo_.add(Spo2(
        new DateTime.fromMillisecondsSinceEpoch(data[i]["Timestamp"] * 1000),
        data[i]["2"].toDouble()));
  }
  List<charts.Series<Spo2, DateTime>> series = [
    charts.Series(
        id: "Spo2",
        data: spo_,
        domainFn: (Spo2 series, _) => series.timestamp,
        measureFn: (Spo2 series, _) => series.spo2,
        colorFn: (Spo2 series, _) => charts.MaterialPalette.teal.shadeDefault)
  ];
  return series;
}

_bodyTemperature(List data) {
  List<BodyTemp> bodyTemp_ = [];
  for (var i = (data.length) - 1; i >= 0; i--) {
    bodyTemp_.add(BodyTemp(
        new DateTime.fromMillisecondsSinceEpoch(data[i]["Timestamp"] * 1000),
        data[i]["1"].toDouble()));
  }
  List<charts.Series<BodyTemp, DateTime>> series = [
    charts.Series(
        id: "Spo2",
        data: bodyTemp_,
        domainFn: (BodyTemp series, _) => series.timestamp,
        measureFn: (BodyTemp series, _) => series.bodyTemp,
        colorFn: (BodyTemp series, _) =>
            charts.MaterialPalette.teal.shadeDefault)
  ];
  return series;
}

_surTemperature(List data) {
  List<SurroundTemp> surroundTemp_ = [];
  for (var i = (data.length) - 1; i >= 0; i--) {
    surroundTemp_.add(SurroundTemp(
        new DateTime.fromMillisecondsSinceEpoch(data[i]["Timestamp"] * 1000),
        data[i]["4"].toDouble()));
  }
  List<charts.Series<SurroundTemp, DateTime>> series = [
    charts.Series(
        id: "SurroundTemp",
        data: surroundTemp_,
        domainFn: (SurroundTemp series, _) => series.timestamp,
        measureFn: (SurroundTemp series, _) => series.surroundTemp,
        colorFn: (SurroundTemp series, _) =>
            charts.MaterialPalette.teal.shadeDefault)
  ];
  return series;
}

_altitude(List data) {
  List<Altitude> altitude_ = [];
  for (var i = (data.length) - 1; i >= 0; i--) {
    altitude_.add(Altitude(
        new DateTime.fromMillisecondsSinceEpoch(data[i]["Timestamp"] * 1000),
        data[i]["3"].toDouble()));
  }
  List<charts.Series<Altitude, DateTime>> series = [
    charts.Series(
        id: "Spo2",
        data: altitude_,
        domainFn: (Altitude series, _) => series.timestamp,
        measureFn: (Altitude series, _) => series.altitude,
        colorFn: (Altitude series, _) =>
            charts.MaterialPalette.teal.shadeDefault)
  ];
  return series;
}

class DateTimeAxisSpecWorkaround extends charts.DateTimeAxisSpec {
  const DateTimeAxisSpecWorkaround(
      {charts.RenderSpec<DateTime> renderSpec,
      charts.DateTimeTickProviderSpec tickProviderSpec,
      charts.DateTimeTickFormatterSpec tickFormatterSpec,
      bool showAxisLine,
      viewport})
      : super(
            renderSpec: renderSpec,
            tickProviderSpec: tickProviderSpec,
            tickFormatterSpec: tickFormatterSpec,
            showAxisLine: showAxisLine,
            viewport: viewport);

  @override
  configure(charts.Axis<DateTime> axis, charts.ChartContext context,
      charts.GraphicsFactory graphicsFactory) {
    super.configure(axis, context, graphicsFactory);
    axis.autoViewport = false;
  }
}

class Heartbeat {
  final DateTime timestamp;
  final int heartbeat;
  Heartbeat(this.timestamp, this.heartbeat);
}

class Spo2 {
  final DateTime timestamp;
  final double spo2;
  Spo2(this.timestamp, this.spo2);
}

class BodyTemp {
  final DateTime timestamp;
  final double bodyTemp;
  BodyTemp(this.timestamp, this.bodyTemp);
}

class SurroundTemp {
  final DateTime timestamp;
  final double surroundTemp;
  SurroundTemp(this.timestamp, this.surroundTemp);
}

class Altitude {
  final DateTime timestamp;
  final double altitude;
  Altitude(this.timestamp, this.altitude);
}
