import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_food_order_app/apis/foodAPIs.dart';
import 'package:online_food_order_app/models/food.dart';
import 'package:online_food_order_app/notifiers/authNotifier.dart';
import 'package:online_food_order_app/screens/login.dart';
import 'package:online_food_order_app/widgets/customRaisedButton.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyEdit = GlobalKey<FormState>();
  List<Food> _foodItems = [];
  String name = '';

  signOutUser() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    // signOut(authNotifier, context);
  }

  @override
  void initState() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    getUserDetails(authNotifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CanteeXpress'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              // signOutUser();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return const LoginPage();
              }));
            },
          )
        ],
      ),
      // ignore: unrelated_type_equality_checks
      body: (authNotifier.userDetails == null)
          ? const Center(child: Text("No Items to display"))
          : (authNotifier.userDetails!.role == 'admin')
              ? adminHome(context)
              : Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: const Text("No Items to display"),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return popupForm(context);
              });
        },
        backgroundColor: const Color.fromRGBO(255, 63, 111, 1),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget adminHome(context) {
    // AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Column(
        children: <Widget>[
          Card(
            child: TextField(
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search), hintText: 'Search...'),
              onChanged: (val) {
                setState(() {
                  name = val;
                });
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('items').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                _foodItems = [];
                for (var item in snapshot.data!.docs) {
                  _foodItems.add(Food(item.id, item['item_name'],
                      item['total_qty'], item['price']));
                }
                List<Food> suggestionList = (name == '')
                    ? _foodItems
                    : _foodItems
                        .where((element) => element.itemName
                            .toLowerCase()
                            .contains(name.toLowerCase()))
                        .toList();
                if (suggestionList.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: suggestionList.length,
                        itemBuilder: (context, int i) {
                          return ListTile(
                            title: Text(suggestionList[i].itemName ?? ''),
                            subtitle: Text(
                                'cost: ${suggestionList[i].price.toString()}'),
                            trailing: Text(
                                'Total Quantity: ${suggestionList[i].totalQty.toString()}'),
                            onLongPress: () {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return popupDeleteOrEmpty(
                                        context, suggestionList[i]);
                                  });
                            },
                            onTap: () {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return popupEditForm(
                                        context, suggestionList[i]);
                                  });
                            },
                          );
                        }),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: const Text("No Items to display"),
                  );
                }
              } else {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: const Text("No Items to display"),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget popupForm(context) {
    String itemName = "";
    int totalQty = 0;
    int price = 0;
    return AlertDialog(
        content: Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "New Food Item",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 63, 111, 1),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (value) {
                    if (value!.length < 3) {
                      return "Not a valid name";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  onSaved: (value) {
                    itemName = value ?? "";
                  },
                  cursorColor: const Color.fromRGBO(255, 63, 111, 1),
                  decoration: const InputDecoration(
                    hintText: 'Food Name',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                    icon: Icon(
                      Icons.fastfood,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (value) {
                    if (value!.length > 3) {
                      return "Not a valid price";
                    } else if (int.tryParse(value) == null)
                      return "Not a valid integer";
                    else
                      return null;
                  },
                  keyboardType: const TextInputType.numberWithOptions(),
                  onSaved: (value) {
                    if (value != null) {
                      price = int.parse(value);
                    }
                  },
                  cursorColor: const Color.fromRGBO(255, 63, 111, 1),
                  decoration: const InputDecoration(
                    hintText: 'Price in INR',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                    icon: Icon(
                      Icons.attach_money,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (value) {
                    if (value!.length > 4) {
                      return "QTY cannot be above 4 digits";
                    } else if (int.tryParse(value) == null)
                      return "Not a valid integer";
                    else
                      return null;
                  },
                  keyboardType: const TextInputType.numberWithOptions(),
                  onSaved: (value) {
                    if (value != null) {
                      totalQty = int.parse(value);
                    }
                  },
                  cursorColor: const Color.fromRGBO(255, 63, 111, 1),
                  decoration: const InputDecoration(
                    hintText: 'Total QTY',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                    icon: Icon(
                      Icons.add_shopping_cart,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // addNewItem(
                      //     itemName: itemName,
                      //     price: price,
                      //     totalQty: totalQty,
                      //     context: context);
                    }
                  },
                  child: const CustomRaisedButton(buttonText: 'Add Item'),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget popupEditForm(context, Food data) {
    String itemName = data.itemName;
    int totalQty = data.totalQty, price = data.price;
    return AlertDialog(
        content: Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKeyEdit,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Edit Food Item",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 63, 111, 1),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: itemName,
                  validator: (value) {
                    if (value!.length < 3) {
                      return "Not a valid name";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  onSaved: (value) {
                    itemName = value ?? "";
                  },
                  cursorColor: const Color.fromRGBO(255, 63, 111, 1),
                  decoration: const InputDecoration(
                    hintText: 'Food Name',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                    icon: Icon(
                      Icons.fastfood,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: price.toString(),
                  validator: (value) {
                    if (value!.length > 3) {
                      return "Not a valid price";
                    } else if (int.tryParse(value) == null)
                      return "Not a valid integer";
                    else
                      return null;
                  },
                  keyboardType: const TextInputType.numberWithOptions(),
                  onSaved: (value) {
                    price = int.parse(value!);
                  },
                  cursorColor: const Color.fromRGBO(255, 63, 111, 1),
                  decoration: const InputDecoration(
                    hintText: 'Price in INR',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                    icon: Icon(
                      Icons.attach_money,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: totalQty.toString(),
                  validator: (value) {
                    if (value!.length > 4) {
                      return "QTY cannot be above 4 digits";
                    } else if (int.tryParse(value) == null)
                      return "Not a valid integer";
                    else
                      return null;
                  },
                  keyboardType: const TextInputType.numberWithOptions(),
                  onSaved: (value) {
                    if (value != null) {
                      totalQty = int.parse(value);
                    }
                  },
                  cursorColor: const Color.fromRGBO(255, 63, 111, 1),
                  decoration: const InputDecoration(
                    hintText: 'Total QTY',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                    icon: Icon(
                      Icons.add_shopping_cart,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    if (_formKeyEdit.currentState!.validate()) {
                      _formKeyEdit.currentState!.save();
                      //   editItem(itemName, price, totalQty, context, data.id);
                    }
                  },
                  child: const CustomRaisedButton(buttonText: 'Edit Item'),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget popupDeleteOrEmpty(context, Food data) {
    return AlertDialog(
        content: Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  // deleteItem(data.id, context);
                },
                child: const CustomRaisedButton(buttonText: 'Delete Item'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  ///  editItem(data.itemName, data.price, 0, context, data.id);
                },
                child: const CustomRaisedButton(buttonText: 'Empty Item'),
              ),
            ),
          ],
        ),
      ],
    ));
  }
}
