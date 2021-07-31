import 'dart:convert';
import 'package:http/http.dart' as http;

const String howManyPeopleInSpaceUrl =
    'https://www.howmanypeopleareinspacerightnow.com/peopleinspace.json';
const Map<String, String> header = {
  "Host": "www.howmanypeopleareinspacerightnow.com",
  "Cache-Control": "max-age=0",
};

Future<PeopleInSpace> fetchPeopleInSpace() async {
  final response = await http.get(
    Uri.parse(howManyPeopleInSpaceUrl),
    headers: header,
  );

  if (response.statusCode == 200 || response.statusCode == 304) {
    // If the server did return a 200 OK / 304 Not Modified (cached) response,
    // then parse the JSON.
    return peopleInSpaceFromJson(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to retrieve data');
  }
}

PeopleInSpace peopleInSpaceFromJson(String str) {
  return PeopleInSpace.fromJson(json.decode(str));
}

String peopleInSpaceToJson(PeopleInSpace data) => json.encode(data.toJson());

class PeopleInSpace {
  PeopleInSpace({
    required this.number,
    required this.people,
  });

  final int number;
  final List<Person> people;

  factory PeopleInSpace.fromJson(Map<String, dynamic> json) => PeopleInSpace(
        number: json["number"],
        people:
            List<Person>.from(json["people"].map((x) => Person.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "people": List<dynamic>.from(people.map((x) => x.toJson())),
      };
}

class Person {
  Person({
    required this.name,
    required this.biophoto,
    required this.biophotowidth,
    required this.biophotoheight,
    required this.country,
    required this.countryflag,
    required this.launchdate,
    required this.careerdays,
    required this.title,
    required this.location,
    required this.bio,
    required this.biolink,
    required this.twitter,
  });

  final String name;
  final String biophoto;
  final int biophotowidth;
  final int biophotoheight;
  final String country;
  final String countryflag;
  final DateTime launchdate;
  final int careerdays;
  final String title;
  final String location;
  final String bio;
  final String biolink;
  final String twitter;

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        name: json["name"],
        biophoto: json["biophoto"],
        biophotowidth: json["biophotowidth"],
        biophotoheight: json["biophotoheight"],
        country: json["country"],
        countryflag: json["countryflag"],
        launchdate: DateTime.parse(json["launchdate"]),
        careerdays: json["careerdays"],
        title: json["title"],
        location: json["location"],
        bio: json["bio"],
        biolink: json["biolink"],
        twitter: json["twitter"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "biophoto": biophoto,
        "biophotowidth": biophotowidth,
        "biophotoheight": biophotoheight,
        "country": country,
        "countryflag": countryflag,
        "launchdate":
            "${launchdate.year.toString().padLeft(4, '0')}-${launchdate.month.toString().padLeft(2, '0')}-${launchdate.day.toString().padLeft(2, '0')}",
        "careerdays": careerdays,
        "title": title,
        "location": location,
        "bio": bio,
        "biolink": biolink,
        "twitter": twitter,
      };

  int daysInSpace() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dayOneInSpace =
        DateTime(launchdate.year, launchdate.month, launchdate.day);

    return (today.difference(dayOneInSpace).inDays);
  }
}
