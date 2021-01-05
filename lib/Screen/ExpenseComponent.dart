import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../Common/Constants.dart' as cnst;

class ExpenseComponent extends StatefulWidget {
  var expenseData;
  int index;

  ExpenseComponent(this.expenseData, this.index);

  @override
  _ExpenseComponentState createState() => _ExpenseComponentState();
}

class _ExpenseComponentState extends State<ExpenseComponent> {
  // String setDate(String date) {
  //   String final_date = "";
  //   var tempDate;
  //   if (date != "" || date != null) {
  //     tempDate = DateTime.now().toString().split("/");
  //     if (tempDate[2].toString().length == 1) {
  //       tempDate[2] = "0" + tempDate[2].toString();
  //     }
  //     if (tempDate[1].toString().length == 1) {
  //       tempDate[1] = "0" + tempDate[1].toString();
  //     }
  //   }
  //   final_date = date == "" || date == null
  //       ? ""
  //       : "${tempDate[2].toString().substring(0, 2)}\n${setMonth(DateTime.parse(date))}"
  //       .toString();
  //
  //   return final_date;
  // }

  // setMonth(DateTime date) {
  //   switch (date.month) {
  //     case 1:
  //       return "Jan";
  //       break;
  //     case 2:
  //       return "Feb";
  //       break;
  //     case 3:
  //       return "Mar";
  //       break;
  //     case 4:
  //       return "Apr";
  //       break;
  //     case 5:
  //       return "May";
  //       break;
  //     case 6:
  //       return "Jun";
  //       break;
  //     case 7:
  //       return "Jul";
  //       break;
  //     case 8:
  //       return "Aug";
  //       break;
  //     case 9:
  //       return "Sep";
  //       break;
  //     case 10:
  //       return "Oct";
  //       break;
  //     case 11:
  //       return "Nov";
  //       break;
  //     case 12:
  //       return "Dec";
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: widget.index,
      duration: const Duration(milliseconds: 450),
      child: FlipAnimation(
        flipAxis: FlipAxis.y,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9.0),
          ),
          child: Container(
            padding: EdgeInsets.only(left: 7, top: 10, bottom: 10, right: 7),
            child: Row(
              children: <Widget>[
                // Container(
                //   width: 50,
                //   padding: EdgeInsets.all(4),
                //   decoration: BoxDecoration(
                //       color: Colors.grey[300],
                //       borderRadius: BorderRadius.all(Radius.circular(4))),
                //   child: Text(
                //     "${setDate(widget.expenseData["date"])}",
                //     textAlign: TextAlign.center,
                //     style: TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.w600,
                //         color: Colors.grey[600]),
                //   ),
                // ),
                Padding(padding: EdgeInsets.only(left: 10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "${widget.expenseData["expenseCategory"]["name"]}",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${widget.expenseData["description"]}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        "${widget.expenseData["paymentType"]}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  "- ${cnst.Inr_Rupee}${double.parse(widget.expenseData["amount"].toString()).toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
