import 'dart:typed_data';
import 'package:db_project/viewer/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'modal/student.dart';

void main() {
  runApp(MaterialApp(
    routes: {
      '/': (context) => const MyApp(),
    },
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Student>> getAllStudents;

  GlobalKey<FormState> insertFormKey = GlobalKey();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController courseController = TextEditingController();

  String? name;
  int? age;
  String? course;
  Uint8List? image;

  @override
  void initState() {
    super.initState();
    getAllStudents = DBHelper.dbHelper.fetchAllStudents();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                "Home Page",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: Colors.indigo.shade900,
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.indigo.shade900,
              onPressed: () async {
                validateAndInsert(context);
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            body: Column(
              children: [
                Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            getAllStudents = DBHelper.dbHelper
                                .fetchSearchedStudents(data: val!);
                          });
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Search here....",
                            prefixIcon: Icon(Icons.search),
                            suffixIcon: Icon(Icons.mic)),
                      ),
                    )),
                Expanded(
                  flex: 25,
                  child: FutureBuilder(
                    future: getAllStudents,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "ERROR :- ${snapshot.error}",
                            style: TextStyle(color: Colors.indigo.shade900),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        List<Student>? data = snapshot.data;

                        return (data != null)
                            ? Padding(
                                padding: const EdgeInsets.all(10),
                                child: ListView.builder(
                                    itemCount: data.length,
                                    itemBuilder: (context, i) {
                                      return Card(
                                        elevation: 6,
                                        child: ListTile(
                                          isThreeLine: true,
                                          leading: CircleAvatar(
                                            radius: 30,
                                            backgroundImage: (data[i].image !=
                                                    null)
                                                ? MemoryImage(
                                                    data[i].image as Uint8List)
                                                : null,
                                          ),
                                          title: Text(data[i].name),
                                          subtitle: Text(
                                              "Age : ${data[i].age}\nCourse :${data[i].course}"),
                                          trailing: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    validateAndEdit(context,
                                                        data: data[i]);
                                                  },
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.blue,
                                                  )),
                                              IconButton(
                                                  onPressed: () async {
                                                    int res = await DBHelper
                                                        .dbHelper
                                                        .delete(
                                                            id: data[i].id!);

                                                    if (res == 1) {
                                                      setState(() {
                                                        getAllStudents = DBHelper
                                                            .dbHelper
                                                            .fetchAllStudents();
                                                      });

                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                            "Record Deleted successfully ...",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          backgroundColor:
                                                              Colors.indigo
                                                                  .shade900,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                        ),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "Record Deleted failed ...",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .indigo
                                                                    .shade900),
                                                          ),
                                                          backgroundColor:
                                                              Colors.white,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ))
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            : Center(
                                child: Text(
                                  "NO DATA....",
                                  style:
                                      TextStyle(color: Colors.indigo.shade900),
                                ),
                              );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                )
              ],
            )));
  }

  validateAndInsert(context) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Text(
                "Insert Record",
                style: TextStyle(
                    color: Colors.indigo.shade900, fontWeight: FontWeight.bold),
              ),
            ),
            content: Form(
              key: insertFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Name First....";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        name = val!;

                        nameController.text;
                      });
                    },
                    controller: nameController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Name"),
                        labelStyle: TextStyle(color: Color(0xff1A237A)),
                        hintText: "Enter First Name..."),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Age First....";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        age = int.parse(val!);

                        ageController.text;
                      });
                    },
                    controller: ageController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Age"),
                        labelStyle: TextStyle(color: Color(0xff1A237A)),
                        hintText: "Enter First Age..."),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter First Course....";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        course = val!;
                        courseController.text;
                      });
                    },
                    controller: courseController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Course"),
                        labelStyle: TextStyle(color: Color(0xff1A237A)),
                        hintText: "Enter First Course..."),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade900),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // XFile? qFile =
                        //     await picker.pickImage(source: ImageSource.camera);

                        XFile? xFile =
                            await picker.pickImage(source: ImageSource.gallery);

                        // image = await qFile!.readAsBytes();
                        image = await xFile!.readAsBytes();
                      },
                      child: const Text(
                        "PICK IMAGE",
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                  onPressed: () {
                    nameController.clear();
                    ageController.clear();
                    courseController.clear();

                    setState(() {
                      name = null;
                      age = null;
                      course = null;
                      image = null;
                    });

                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "CLEAR",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade900),
                  )),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade900),
                  onPressed: () async {
                    if (insertFormKey.currentState!.validate()) {
                      insertFormKey.currentState!.save();

                      Student s1 = Student(
                          name: name!,
                          age: age!,
                          course: course!,
                          image: image);
                      int res = await DBHelper.dbHelper.insert(data: s1);
                      if (res > 0) {
                        setState(() {
                          getAllStudents = DBHelper.dbHelper.fetchAllStudents();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.indigo.shade900,
                            content: const Text(
                              "Record inserted successfully...",
                              style: TextStyle(color: Colors.white),
                            )));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.white,
                            content: Text(
                              "Record insertion failed...",
                              style: TextStyle(color: Colors.indigo.shade900),
                            )));
                      }
                      print("save all");
                    }
                    nameController.clear();
                    ageController.clear();
                    courseController.clear();

                    setState(() {
                      name = null;
                      age = null;
                      course = null;
                      image = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "INSERT",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  )),
            ],
          );
        });
  }

  validateAndEdit(context, {required Student data}) async {
    nameController.text = data.name;
    ageController.text = data.age.toString();
    courseController.text = data.course;

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Text(
                "Update Record",
                style: TextStyle(
                    color: Colors.indigo.shade900, fontWeight: FontWeight.bold),
              ),
            ),
            content: Form(
              key: insertFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Name First....";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        nameController.text;
                        name = val;
                      });
                    },
                    controller: nameController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Name"),
                        labelStyle: TextStyle(color: Color(0xff1A237A)),
                        hintText: "Enter First Name..."),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Age First....";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        ageController.text;
                        age = int.parse(val!);
                      });
                    },
                    controller: ageController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Age"),
                        labelStyle: TextStyle(color: Color(0xff1A237A)),
                        hintText: "Enter First Age..."),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter First Course....";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        courseController.text;
                        course = val;
                      });
                    },
                    controller: courseController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Course"),
                        labelStyle: TextStyle(color: Color(0xff1A237A)),
                        hintText: "Enter First Course..."),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade900),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // XFile? qFile =
                        //     await picker.pickImage(source: ImageSource.camera);
                        XFile? xFile =
                            await picker.pickImage(source: ImageSource.gallery);

                        // image = await qFile!.readAsBytes();
                        image = await xFile!.readAsBytes();
                      },
                      child: const Text(
                        "EDIT IMAGE",
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                  onPressed: () {
                    nameController.clear();
                    ageController.clear();
                    courseController.clear();

                    setState(() {
                      name = null;
                      age = null;
                      course = null;
                      image = null;
                    });

                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "CLEAR",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade900),
                  )),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade900),
                  onPressed: () async {
                    if (insertFormKey.currentState!.validate()) {
                      insertFormKey.currentState!.save();

                      Student s1 = Student(
                          name: name!,
                          age: age!,
                          course: course!,
                          image: image);

                      int res = await DBHelper.dbHelper
                          .update(data: s1, id: data.id!);

                      if (res == 1) {
                        setState(() {
                          getAllStudents = DBHelper.dbHelper.fetchAllStudents();
                        });

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.indigo.shade900,
                            content: const Text(
                              "Record updated successfully...",
                              style: TextStyle(color: Colors.white),
                            )));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.white,
                            content: Text(
                              "Record updation failed...",
                              style: TextStyle(color: Colors.indigo.shade900),
                            )));
                      }
                      print("update all");
                    }
                    nameController.clear();
                    ageController.clear();
                    courseController.clear();

                    setState(() {
                      name = null;
                      age = null;
                      course = null;
                      image = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "UPDATE",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  )),
            ],
          );
        });
  }
}
