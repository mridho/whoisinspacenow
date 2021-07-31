import 'dart:async';
import 'package:flutter/material.dart';
import 'package:whoisinspacenow/fetch_people_in_space.dart';

void main() {
  runApp(MyApp());
}

const String mainTitle = 'Who is in Space Now?';
const String subPageTitle = 'Favorite Astronouts';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: mainTitle,
      theme: ThemeData(
        primaryColor: Colors.black,
        brightness: Brightness.dark,
      ),
      home: AstronoutsInSpace(),
    );
  }
}

class AstronoutsInSpace extends StatefulWidget {
  const AstronoutsInSpace({Key? key}) : super(key: key);

  @override
  _AstronoutsInSpaceState createState() => _AstronoutsInSpaceState();
}

class _AstronoutsInSpaceState extends State<AstronoutsInSpace>
    with TickerProviderStateMixin {
  final _favorite = <Person>{};
  final _biggerFont = const TextStyle(fontSize: 18);

  late Future<PeopleInSpace> futurePeopleInSpace;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    futurePeopleInSpace = fetchPeopleInSpace();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PeopleInSpace>(
      future: futurePeopleInSpace,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          PeopleInSpace data = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Column(children: [
                Text(
                  mainTitle,
                  textAlign: TextAlign.left,
                ),
                Text(
                  '${data.number} people are in space right now',
                  style: Theme.of(context).textTheme.subtitle2,
                )
              ]),
              actions: [
                IconButton(
                  onPressed: _pushFavorited,
                  icon: Icon(Icons.list),
                ),
              ],
            ),
            body: _buildList(data.people),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircularProgressIndicator(
                value: controller.value,
                semanticsLabel: 'Loading...',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(List<Person> astronouts) {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: (astronouts.length * 2 - 1),
        itemBuilder: (BuildContext _context, int i) {
          // Add a one-pixel-high divider widget before each row
          // in the ListView.
          if (i.isOdd) {
            return Divider();
          }

          final int index = i ~/ 2;
          return _buildRow(astronouts[index]);
        });
  }

  Widget _buildRow(Person person) {
    final alreadyFavorited = _favorite.contains(person);

    return ListTile(
      title: Text(
        person.name,
        style: _biggerFont,
      ),
      subtitle: Text(
        person.country,
      ),
      trailing: Icon(
        alreadyFavorited ? Icons.favorite : Icons.favorite_border,
        color: alreadyFavorited ? Colors.lightBlue : null,
      ),
      onTap: () {
        setState(
          () {
            if (alreadyFavorited) {
              _favorite.remove(person);
            } else {
              _favorite.add(person);
            }
          },
        );
      },
    );
  }

  void _pushFavorited() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _favorite.map(
            (Person person) {
              return ListTile(
                leading: _loadImage(person.countryflag),
                title: Text(
                  person.name,
                  style: _biggerFont,
                ),
                subtitle: Text(
                  "${person.title} at the ${person.location}, ${person.daysInSpace()} days in space",
                  textAlign: TextAlign.justify,
                ),
                isThreeLine: true,
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: _loadImage(person.biophoto),
                    ),
                  );
                },
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: Text(subPageTitle),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  Widget _loadImage(String imageURL) {
    return Image.network(
      imageURL,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.black,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/image-not-available.png',
          semanticLabel: "unable to fetch image",
        );
      },
    );
  }
}
