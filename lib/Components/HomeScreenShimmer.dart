import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreenShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        direction: ShimmerDirection.ltr,
        period: Duration(seconds:1),
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [0, 1, 2, 3]
              .map((_) => Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 170.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 55,
                        width: 55,
                        color: Colors.grey[100],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 55,
                        width: 55,
                        color: Colors.grey[100],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 55,
                        width: 55,
                        color: Colors.grey[100],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 55,
                        width: 55,
                        color: Colors.grey[100],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ))
              .toList(),
        ),
        baseColor: Colors.grey[100],
        highlightColor: Colors.grey[200]);
  }
}