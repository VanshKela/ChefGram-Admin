import 'package:chef_gram_admin/models/orderModel.dart';
import 'package:chef_gram_admin/models/profile_model.dart';
import 'package:chef_gram_admin/screens/Dashboard/place_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../database_service.dart';

class ChooseFromCatalog extends StatefulWidget {
  ChooseFromCatalog({Key? key, this.shopDetails}) : super(key: key);
  var shopDetails;
  @override
  _ChooseFromCatalogState createState() => _ChooseFromCatalogState();
}

class _ChooseFromCatalogState extends State<ChooseFromCatalog> {
  late Order order;

  @override
  void initState() {
    order = new Order(
        customerName: widget.shopDetails['shopOwner'],
        shopName: widget.shopDetails['shopName'],
        orderTakenBy: Provider.of<Profile>(context, listen: false).name,
        shopRef: widget.shopDetails["shopRef"].toString(),
        state: widget.shopDetails["state"],
        city: widget.shopDetails["city"],
        beat: widget.shopDetails["beat"],
        address: widget.shopDetails['address']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: Text("Order From Catalog"),
        actions: [
          ElevatedButton(
            style: ButtonStyle(elevation: MaterialStateProperty.all(0.0)),
            child: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<DatabaseService>(context, listen: false)
                  .catalog
                  .clear();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ChooseFromCatalog(shopDetails: widget.shopDetails)));
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: Provider.of<DatabaseService>(context).getCatalog(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            var document = snapshot.data[index];
                            OrderItem item = OrderItem(
                              name: document['name'],
                              price: document['price'],
                              itemsOrdered: 0,
                              quantity: document['quantity'],
                            );
                            order.addToOrder(item);
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 1.h),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 1.h, horizontal: 1.w),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          document['image'],
                                          height: 20.h,
                                          width: 30.w,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 2.w),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                document['name'],
                                                style: TextStyle(
                                                    fontSize: 18.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              Text(
                                                "${document['quantity']} g",
                                                style:
                                                    TextStyle(fontSize: 16.sp),
                                              ),
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              Text(
                                                "₹ ${document['price']}",
                                                style:
                                                    TextStyle(fontSize: 16.sp),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 6.h,
                                        width: 8.w,
                                        child: TextFormField(
                                          decoration:
                                              InputDecoration(hintText: "0"),
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          onChanged: (value) {
                                            item.itemsOrdered =
                                                double.parse(value).toInt();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    order.viewOrder();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PlaceOrder(order: order);
                        },
                      ),
                    );
                  },
                  child: Text(
                    'Give Order',
                    style:
                        TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
