import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_example/Contact.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'ContactCreate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(ContactAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Tutorial',
      home: MyHomePage(),
      routes: {
        '/new':(context)=>ContactCreate()
      },
    );
  }

}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: Hive.openBox('contacts'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError)
            return Text(snapshot.error.toString());
          else{

            return Stack(
              children: [
                WatchBoxBuilder(
                  box: Hive.box('contacts'),
                  builder: (context, contactsBox) {
                    return ListView.builder(
                      itemCount: contactsBox.length,
                      itemBuilder: (BuildContext context, int index) {
                        final contact = contactsBox.getAt(index) as Contact;

                        return ListTile(
                          title: Text(contact.name),
                          subtitle: Text(contact.age.toString()),
                        );
                      },
                    );
                  },
                ),
                FloatingActionButton(onPressed: (){
                  Navigator.pushNamed(context,'/new');
                })

              ],
            );
          }
        }
        // Although opening a Box takes a very short time,
        // we still need to return something before the Future completes.
        else
          return Scaffold();
      },
    );
  }
}
