import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class OrderLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int offset = 0;
    int time = 1000;

    return SafeArea(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          offset += 5;
          time = 800 + offset;

          print(time);
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Shimmer.fromColors(
                highlightColor: Colors.white,
                baseColor: Colors.grey[200],
                child: ShimmerLayout(),
                period: Duration(milliseconds: time),
              ));
        },
      ),
    );
  }
}

class ShimmerLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width - 150;
    double containerHeight = 15;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 7.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }
}