import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:IT20076566/screens/sign_in_screen.dart';
import 'package:IT20076566/screens/sign_up_screen.dart';
import 'package:IT20076566/model/recipe.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IT20076566 - In Lab Activity',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'My Recipe List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignUpScreen(),
          ),
        );
      } else {}
    });
  }

  //create list to store todo list
  int recipeList = 0;

  final db = FirebaseFirestore.instance;

  // create controllers to handle inputs
  TextEditingController taskController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController ingredientsController = TextEditingController();

  // create a boolean variable to handle input fields
  bool viewInputfields = false;

  // create a function to add new todo
  void _addNewRecipe(
      String title, String description, List<dynamic> ingredients) async {
    final docRef = db.collection('recipies').doc();
    docRef
        .set(RecipeModel(recipeList, title, description, ingredients).toJson())
        .then(
            (value) =>
                Fluttertoast.showToast(msg: "Recipe added successfully!"),
            onError: (e) => print("Error adding Recipe: $e"));
    setState(() {});
  }

  // create a function to remove todo
  void _removeRecipe(dynamic docID, RecipeModel todo) {
    db.collection('recipies').doc(docID.toString()).delete().then(
        (value) => Fluttertoast.showToast(msg: "Recipe deleted Successfully!"),
        onError: (e) => print("Error deleting Recipe: $e"));
    setState(() {
      recipeList--;
    });
  }

  Future getRecepieLists() async {
    return db.collection("recipies").get();
  }

  Future<String?> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Fluttertoast.showToast(msg: "Sign Out Successfull");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ),
      );
      return null;
    } on FirebaseAuthException catch (ex) {
      return "${ex.code}: ${ex.message}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
                onPressed: () {
                  signOut();
                },
                tooltip: 'Sign Out',
                icon: const Icon(Icons.logout_outlined)),
          ],
        ),
        body: Center(
          child: Stack(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //show and hide input fields according to the variable value
              if (viewInputfields)
                Container(
                  padding: const EdgeInsets.all(20),
                  height: 100,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          'Add New Recipe',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextField(
                        controller: taskController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Title',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Description',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: ingredientsController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Ingredients, separated by comma',
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              _addNewRecipe(
                                  taskController.text,
                                  nameController.text,
                                  ingredientsController.text.split(','));
                              taskController.clear();
                              nameController.clear();
                              ingredientsController.clear();
                              setState(() {
                                viewInputfields = false;
                              });
                            },
                            child: const Text('Add')),
                      )
                    ],
                  ),
                ),
              if (!viewInputfields)
                FutureBuilder(
                  future: getRecepieLists(),
                  builder: ((context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data == null) {
                      return const SizedBox();
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const SizedBox(
                        child: Center(child: Text("No Recipies")),
                      );
                    }

                    if (snapshot.hasData) {
                      List<Map<dynamic, dynamic>> recipieList = [];

                      for (var doc in snapshot.data!.docs) {
                        final recipe = RecipeModel.fromJson(
                            doc.data() as Map<String, dynamic>);
                        Map<dynamic, dynamic> map = {
                          "docId": doc.id,
                          "recipe": recipe
                        };
                        recipieList.add(map);
                      }

                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: recipieList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(recipieList[index]["recipe"].title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(recipieList[index]["recipe"]
                                      .description!),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Ingredients: ${recipieList[index]["recipe"].ingredients.join(", ")}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: "Press to delete Task",
                                    onPressed: () {
                                      _removeRecipe(
                                        recipieList[index]["docId"],
                                        recipieList[index]["recipe"],
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox();
                  }),
                )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              viewInputfields = true;
            });
          },
          tooltip: 'Add Recipe',
          child: const Icon(Icons.add),
        ));
  }
}
