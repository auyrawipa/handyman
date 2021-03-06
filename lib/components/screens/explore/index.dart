import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hdman/components/screens/explore/detail.dart';
import 'package:hdman/config/index.dart';
import 'package:hdman/function/alert.dart';
import 'package:hdman/provider/model/checked.dart';
import 'package:hdman/provider/model/user.dart';
import 'package:hdman/widget/TextFix.dart';
import 'package:provider/provider.dart';

class ExploreScreen extends StatefulWidget {
  ExploreScreen({Key key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List Stores = []; //ร้านค้า
  bool loadingChecked = true;
  List productChecked = [];

  didChangeDependencies() {
    super.didChangeDependencies();
    actionMarket();
    actionCheckedProduct();
  }

  Future<void> actionCheckedProduct() async {
    // เรียกข้อมูลร้านที่เปิดทำการ

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      Dio dio = new Dio();
      Response response =
          await dio.get("${api}/history/doprocess/${userProvider.data['id']}");

      // CheckedProvider checkedProvider =
      //     Provider.of<CheckedProvider>(context, listen: false);

      setState(() {
        productChecked = response.data["data"];
        //checkedProvider.setProduct(productChecked.length);
      });

      print(productChecked);
    } catch (e) {
      //เกิด error ระหว่างโหลด

    }
  }

  Future<void> actionMarket() async {
    // เรียกข้อมูลร้านที่เปิดทำการ

    try {
      Dio dio = new Dio();
      Response response = await dio.get("${api}/market");

      setState(() {
        Stores = response.data["data"];
        loadingChecked = false;
      });

      //print(Stores.length);
    } catch (e) {
      //เกิด error ระหว่างโหลด

    }
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: Stores.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildCards(index);
      },
    );
  }

  Widget _buildCards(index) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Card(
        elevation: 3,
        child: GestureDetector(
          onTap: () {
            if (productChecked.length > 0) {
              getAlertWarning(context,
                  "ไม่สามารถทำรายการได้ มีรายการที่กำลังดำเนินการอยู่ กรุณาดูที่เมนู `รายการ` ");
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailStoreScreen(
                  idStore: Stores[index]["id"],
                  nameStroe: Stores[index]["name"],
                ),
              ),
            );
          },
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              child: FloatingActionButton(
                heroTag: null,
                key: Key(index.toString()),
                backgroundColor: Colors.redAccent,
                elevation: 0,
                child: Icon(
                  Icons.store,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
            title: TextFix(
              title: Stores[index]["name"],
            ),
            subtitle: TextFix(
              title: "ประเภทร้านค้า ${Stores[index]["category"]}",
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrenns() {
    if (loadingChecked) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[CircularProgressIndicator()],
      ));
    } else {
      if (Stores.length == 0) {
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.cloud_off,
              size: MediaQuery.of(context).size.width / 3,
            ),
            TextFix(
              title: "ไม่พบข้อมูลร้านค้า !",
              sizefont: 18,
            )
          ],
        ));
      } else {
        return _buildListView();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //actionMarket();
    return Scaffold(
      appBar: AppBar(
        title: TextFix(
          title: 'สำรวจ',
          sizefont: sizeFontHeader,
        ),
      ),
      body: _buildScrenns(),
    );
  }
}
