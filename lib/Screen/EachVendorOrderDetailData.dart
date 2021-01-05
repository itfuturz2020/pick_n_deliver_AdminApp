import 'package:flutter/material.dart';

class EachVendorOrderDetailData extends StatefulWidget {

  var eachVendorData;

  EachVendorOrderDetailData({this.eachVendorData});

  @override
  _EachVendorOrderDetailDataState createState() => _EachVendorOrderDetailDataState();
}

class _EachVendorOrderDetailDataState extends State<EachVendorOrderDetailData> {
  var courierCharge,vendorBill;

  @override
  void initState() {
    super.initState();
    courierCharge = widget.eachVendorData["CourierCharge"].round();
    vendorBill = widget.eachVendorData["VendorBill"].round();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:8.0,left:8,right: 8),
      child: Container(
        width: MediaQuery.of(context).size.width*0.8,
        height: MediaQuery.of(context).size.height*0.3,
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
                                  "${widget.eachVendorData["DeliveryData"]["completeAddress"]}",
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
                      'Amount\nCollection',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Courier\nCharge',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Vendor\nBill',
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
                          "${widget.eachVendorData["VendorAmountCollect"]}" + " /-",
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
                          "${courierCharge}" + " /-",
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
                          "${vendorBill}" + " /-",
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
