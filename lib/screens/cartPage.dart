import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_food_order_app/apis/foodAPIs.dart';
import 'package:online_food_order_app/models/cart.dart';
import 'package:online_food_order_app/notifiers/authNotifier.dart';
import 'package:online_food_order_app/widgets/customRaisedButton.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double sum = 0;
  int itemsCount = 0;

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
          backgroundColor: const Color.fromRGBO(255, 63, 111, 1),
          title: const Text('Cart'),
        ),
        // ignore: unrelated_type_equality_checks
        body: authNotifier.userDetails == null
            ? const Center(child: Text("No Items to display"))
            : cartList(context));
  }

  Widget cartList(context) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Column(
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('carts')
                .doc(authNotifier.userDetails!.uuid)
                .collection('items')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot1) {
              if (snapshot1.hasData && snapshot1.data!.docs.isNotEmpty) {
                List<String> foodIds = [];
                Map<String, int> count = <String, int>{};
                snapshot1.data?.docs.forEach((item) {
                  foodIds.add(item.id);
                  //  count[item.id] = item.data['count'];
                });
                return dataDisplay(
                    context, authNotifier.userDetails!.uuid!, foodIds, count);
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

  Widget dataDisplay(BuildContext context, String uid, List<String> foodIds,
      Map<String, int> count) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .where(FieldPath.documentId, whereIn: foodIds)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          List<Cart> cartItems = [];
          for (var item in snapshot.data!.docs) {
            // cartItems.add(Cart(item.id, count[item.id], item.data['item_name'],
            //     item.data['total_qty'], item.data['price']));
          }
          if (cartItems.isNotEmpty) {
            sum = 0;
            itemsCount = 0;
            for (var element in cartItems) {
              sum += element.price * element.count;
              itemsCount += element.count;
            }
            return Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, int i) {
                          return ListTile(
                            title: Text(cartItems[i].itemName ?? ''),
                            subtitle:
                                Text('cost: ${cartItems[i].price.toString()}'),
                            trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  (cartItems[i].count <= 1)
                                      ? IconButton(
                                          onPressed: () async {
                                            // setState(() {
                                            //   foodIds
                                            //       .remove(cartItems[i].itemId);
                                            // });
                                            // await editCartItem(
                                            //     cartItems[i].itemId,
                                            //     0,
                                            //     context);
                                          },
                                          icon: const Icon(Icons.delete),
                                        )
                                      : IconButton(
                                          onPressed: () async {
                                            // await editCartItem(
                                            //     cartItems[i].itemId,
                                            //     (cartItems[i].count - 1),
                                            //     context);
                                          },
                                          icon: const Icon(Icons.remove),
                                        ),
                                  Text(
                                    '${cartItems[i].count ?? 0}',
                                    style: const TextStyle(fontSize: 18.0),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () async {
                                      // await editCartItem(cartItems[i].itemId,
                                      //     (cartItems[i].count + 1), context);
                                    },
                                  )
                                ]),
                          );
                        }),
                    Text("Total ($itemsCount items): $sum INR"),
                    const SizedBox(
                      height: 40,
                    ),
                    GestureDetector(
                      onTap: () {
                        showAlertDialog(
                            context, "Total ($itemsCount items): $sum INR");
                      },
                      child: const CustomRaisedButton(
                          buttonText: 'Proceed to buy'),
                    ),
                    const SizedBox(
                      height: 70,
                    ),
                  ],
                ));
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
    );
  }

  showAlertDialog(BuildContext context, String data) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Place Order"),
      onPressed: () {
        //  placeOrder(context, sum);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Proceed to checkout?"),
      content: Text(data),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
