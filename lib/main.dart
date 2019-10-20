import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:spacex_gql/launchModels.dart';

void main() {
  // For some reason I was getting error
  // Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before
  // the binding was initialized. Thats why I used WidgetsFlutterBinding.ensureInitialized();
  // See : https://stackoverflow.com/questions/57689492/flutter-unhandled-exception-servicesbinding-defaultbinarymessenger-was-accesse
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static HttpLink httpLink = HttpLink(
    uri: 'https://api.spacex.land/graphql/',
  );

//  uncomment this if you need authentication
//  static AuthLink authLink = AuthLink(
//    getToken: () async => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
//    // OR
//    // getToken: () => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
//  );
//
//  final Link link = authLink.concat(httpLink);

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: InMemoryCache(),
      link: httpLink as Link,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'SpaceX Launches Graphql'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String getLaunches = """
    query fetchLaunches {
      launchesPast(limit: 10) {
        id
        links {
          flickr_images
          mission_patch
        }
        mission_name
        details
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Query(
          options: QueryOptions(
            document: getLaunches,
            pollInterval: 10,
          ),
          builder: (QueryResult result,
              {VoidCallback refetch, FetchMore fetchMore}) {
            if (result.errors != null) {
              return Text(result.errors.toString());
            }

            if (result.loading) {
              return Center(child: new CircularProgressIndicator());
            }

            if (result.data != null) {
              final launchesData = result.data["launchesPast"]
                  .map((i) => new LaunchObj.fromJson(i))
                  .toList();
              final List<LaunchObj> launches =
                  List<LaunchObj>.from(launchesData);
              return GridView.builder(
                itemCount: launches.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      child: new GestureDetector(
                    onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailScreen(id: launches[index].id),
                            ),
                          );
                    },
                    child: Card(
                      child: new Stack(
                        alignment: Alignment.bottomLeft,
                        children: <Widget>[
                          Container(
                            color: Colors.grey,
                            child: new Image.network(
                              launches[index].img ??
                                  'https://via.placeholder.com/100',
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.5),
                            padding: const EdgeInsets.all(8.0),
                            width: 200,
                            child: Text(launches[index].mission_name,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                        ],
                      ),
                      elevation: 2,
                      margin: EdgeInsets.all(10),
                    ),
                  ));
                },
              );
            }

            return Container(
              child: Text("No data"),
            );
          }),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String id;

  DetailScreen({Key key, @required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Lauch Details"),
        ),
        body: LaunchDetailPage(id: id));
  }
}

class LaunchDetailPage extends StatefulWidget {
  LaunchDetailPage({Key key, this.id}) : super(key: key);

  final String id;

  @override
  _LaunchDetailPageState createState() => _LaunchDetailPageState();
}

class _LaunchDetailPageState extends State<LaunchDetailPage> {
  String getSingleLaunch = """
    query fetchLaunch (\$flight_number: ID!) {
      launch(id: \$flight_number) {
        details
        mission_name
        links {
          flickr_images
          mission_patch
        }
        id
      }
    }
    
  """;

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          document: getSingleLaunch,
          variables: {
            'flight_number': widget.id,
          },
          pollInterval: 10,
        ),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.errors != null) {
            return Text(result.errors.toString());
          }

          if (result.loading) {
            return Center(child: new CircularProgressIndicator());
          }

          if (result.data != null) {
            LaunchDetailsObj launch =  new LaunchDetailsObj.fromJson(result.data['launch']) ;
             return Center(
               child: SingleChildScrollView(
                 child: Card(
                   child: Padding(
                     padding: EdgeInsets.all(20.0),
                     child: Column(
                       children: <Widget>[
                         Container(
                           child: Padding(
                             padding: EdgeInsets.all(10.0),
                             child: Text(
                               launch.launchObj.mission_name,
                               style: TextStyle(fontSize: 22),
                             ),
                           ),
                         ),
                         Container(
                           color: Colors.grey,
                           child: new Image.network(
                             launch.launchObj.img ?? 'https://via.placeholder.com/100',
                             width: 300,
                             height: 300,
                             fit: BoxFit.cover,
                           ),
                         ),
                         Container(
                           child: Padding(
                             padding: EdgeInsets.all(10.0),
                             child: Text(
                               launch.details,
                               style: TextStyle(fontSize: 18),
                             ),
                           ),
                         ),
                         Container(
                           child: new Image.network(
                             launch.mission_patch ??
                                 'https://via.placeholder.com/100',
                             width: 100,
                             height: 100,
                             fit: BoxFit.cover,
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
               ),
             );
          }

          return Container(
            child: Text("No data"),
          );

        });
  }
}
