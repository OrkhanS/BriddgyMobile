// To parse this JSON data, do
//
//     final city = cityFromJson(jsonString);

import 'dart:convert';

City cityFromJson(String str) => City.fromJson(json.decode(str));

String cityToJson(City data) => json.encode(data.toJson());

class City {
    City({
        this.cityAscii,
        this.country,
        this.id,
    });

    String cityAscii;
    String country;
    int id;

    factory City.fromJson(Map<String, dynamic> json) => City(
        cityAscii: json["city_ascii"],
        country: json["country"],
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "city_ascii": cityAscii,
        "country": country,
        "id": id,
    };
}
