import 'package:flutter/material.dart';

class EachEmployeeDeliveryDetailData extends StatefulWidget {

  List Employeedataone = [];
  int index;

  EachEmployeeDeliveryDetailData({this.index,this.Employeedataone});

  @override
  _EachEmployeeDeliveryDetailDataState createState() => _EachEmployeeDeliveryDetailDataState();
}

class _EachEmployeeDeliveryDetailDataState extends State<EachEmployeeDeliveryDetailData> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:8.0,left:8,right: 8),
      child: Container(
        width: MediaQuery.of(context).size.width*0.8,
        height: MediaQuery.of(context).size.height*0.4,
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left:5.0,top: 10),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width*0.9,
                      height: MediaQuery.of(context).size.height*0.09,
                      child: Card(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                "Pick Up",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.green
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left:8.0),
                                child: Text(
                                  "C-401 Nest Orchid Althan-Bhimrad Road Surat - 395007",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,

                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 14,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.9,
                      height: MediaQuery.of(context).size.height*0.09,
                      child: Card(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                "Drop",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.redAccent
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left:8.0),
                                child: Text(
                                  "C-401 Nest Orchid Althan-Bhimrad Road Surat - 395007",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,

                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Amount\nRecieved',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Total\nAmount',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      '3rd Party\nPayment',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ),
                ],
                rows: <DataRow>[
                  DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(
                          "${widget.Employeedataone[widget.index]["totalamountcollected"]}" + " /-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // onTap: () => Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => SingleEmployeeDeliveryDetail(
                        //       EmployeeData: EmployeeData,
                        //       index: i,
                        //       srNo: srNo,
                        //     ),
                        //   ),
                        // ),
                      ),
                      DataCell(
                        Text(
                          "${widget.Employeedataone[widget.index]["totalamountcollected"]}" + " /-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // onTap: () => Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => SingleEmployeeDeliveryDetail(
                        //       EmployeeData: EmployeeData,
                        //       index: i,
                        //       srNo: srNo,
                        //
                        //     ),
                        //   ),
                        // ),
                      ),
                      DataCell(
                        Text(
                          "${widget.Employeedataone[widget.index]["totalamountcollected"]}" + " /-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // onTap: () => Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => SingleEmployeeDeliveryDetail(
                        //       EmployeeData: EmployeeData,
                        //       index: i,
                        //       srNo: srNo,
                        //     ),
                        //   ),
                        // ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

  }
}
