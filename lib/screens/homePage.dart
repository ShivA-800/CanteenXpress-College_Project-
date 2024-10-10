import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_food_order_app/apis/foodAPIs.dart';
import 'package:online_food_order_app/models/food.dart';
import 'package:online_food_order_app/notifiers/authNotifier.dart';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> cartIds = [];
  List<Food> _foodItems = [];
  String name = '';

  @override
  void initState() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    getUserDetails(authNotifier);
    // getCart(authNotifier.userDetails!.uuid!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(255, 63, 111, 1),
          title: const Text('CanteeXpress'),
        ),
        // ignore: unrelated_type_equality_checks
        body: authNotifier.userDetails == null
            ? const Center(child: Text("No Items to display"))
            : userHome(context));
  }

  Widget userHome(context) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
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
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('total_qty', isGreaterThan: 0)
                .snapshots(),
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
                              trailing: IconButton(
                                icon: cartIds.contains(suggestionList[i].id)
                                    ? const Icon(Icons.remove)
                                    : const Icon(Icons.add),
                                onPressed: () async {
                                  // cartIds.contains(suggestionList[i].id)
                                  //     ? await removeFromCart(
                                  //         suggestionList[i], context)
                                  //     : await addToCart(
                                  //         suggestionList[i], context);
                                  // setState(() {
                                  //   getCart(
                                  //       authNotifier.userDetails.uuid ?? "");
                                  // });
                                },
                              ));
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

  void getCart(String uuid) async {
    List<String> ids = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('carts')
        .doc(uuid)
        .collection('items')
        .get();
    var data = snapshot.docs;
    for (var i = 0; i < data.length; i++) {
      ids.add(data[i].id);
    }
    setState(() {
      cartIds = ids;
    });
  }
}
