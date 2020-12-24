import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:pickndeliver/Common/ClassList.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;
import 'package:pickndeliver/Common/Constants.dart';

Dio dio = new Dio();

class Services {

  static Future<List> EmployeehistoryData(body) async {
    print(body.toString());
    String url = 'https://pick-and-delivery.herokuapp.com/admin/getAllEmployee';
    print("EmployeehistoryData data url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        print("EmployeehistoryData data Response: " + response.data.toString());
        return response.data["Data"];
      }else {
        throw Exception(response.data.toString());
      }
    }
    catch (e) {
      print("Process data Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<Map> Processing(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'admin/orders';
    print("Processing data url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        // SaveDataClass saveData =
        print("Process data Response: " + response.data.toString());
        // var memberDataClass = response.data;
        // saveData.Message = memberDataClass["Message"];
        // saveData.IsSuccess = memberDataClass["IsSuccess"];
        // saveData.Content = memberDataClass["Data"];

        return response.data;

      }else {
        throw Exception(response.data.toString());
      }
    }
    catch (e) {
      print("Process data Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> getEmployeeOrderDetails(body) async {
    print(body.toString());
    String url ='https://pick-and-delivery.herokuapp.com/couriers/getEmployeeOrderDetails';
    print("getEmployeeOrderDetails data url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
        new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("getEmployeeOrderDetails Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Content = memberDataClass["Data"];

        return saveData;
      }else {
        throw Exception(response.data.toString());
      }
    }
    catch (e) {
      print("getEmployeeOrderDetails data Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> SignUp(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'customers/signup2';
    print("SignUp url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("SignUp Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Content = memberDataClass["Data"];

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("SignUp Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> CustomerLogin(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'customers/signin';
    print("SignIn url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("SignIn Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Content = memberDataClass["Data"];

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("SignIn Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> SendVerficationCode(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'customers/sendotp';
    print("SendOTP url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("SendOTP Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Data = memberDataClass["Data"].toString();

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("SendOTP Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> OTVerification(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'customers/verify';
    print("OTPVerification url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("OTPVerification Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Data = memberDataClass["Data"].toString();

        return saveData;
      } else {

        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("OTPVerification Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  //save
  static Future<SaveDataClass> UpdateProfile(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'customers/updateprofile';
    print("UpdateProfile url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("UpdateProfile Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Data = memberDataClass["Data"].toString();

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("UpdateProfile Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> PlaceOrder(body) async {
    String url = cnst.API_URL + 'orders/newoder';
    print("NewOrder url : " + url);
    print(body);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("NewOrder Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Data = memberDataClass["Data"].toString();

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("NewOrder Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> ActiveOrder(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'orders/activeOrders';
    print("PromoCodesList url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("PromoCodesList Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Content = memberDataClass["Data"];

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("PromoCodesList Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> CompleteOrder(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'orders/completeOrders';
    print("Completeb Order url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("Completeb Order Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Content = memberDataClass["Data"];

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Completeb Order Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> AddPickUpAddress(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'customers/savePickupAddress';
    print("Add PickUp Address url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("Add PickUp Address Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Data = memberDataClass["Data"].toString();

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Add PickUp Address Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> GetPickUpAddress(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'customers/pickupAddress';
    print("Get PickUp Address url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("Get PickUp Address Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Content = memberDataClass["Data"];

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Get PickUp Address Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> AddDeliveryAddress(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'customers/saveDropAddress';
    print("Add Delivery Address url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("Add Delivery Address Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Data = memberDataClass["Data"].toString();

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Add Delivery Address Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> GetDeliveryAddress(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'customers/dropAddress';
    print("Get Delivery Address url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("Get Delivery Address Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Content = memberDataClass["Data"];

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Get Delivery Address Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> GetOrderSettings() async {
    String url = cnst.API_URL + 'orders/settings';
    print("Get orders/settings url : " + url);
    try {
      final response = await dio.post(url);
      if (response.statusCode == 200) {
        print(response);
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("Get orders/settings Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Content = memberDataClass["Data"];

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Get orders/settings Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> Banners() async {
    String url = cnst.API_URL + 'customers/banners';
    print("Get banners url : " + url);
    try {
      final response = await dio.post(url);
      if (response.statusCode == 200) {
        print(response);
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("Get banners Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Content = memberDataClass["Data"];

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Get banners Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> Couponoffers(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'customers/promocodes';
    print("Promocodes Order url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("Promocodes Order Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Content = memberDataClass["Data"];

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Promocodes Order Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveDataClass> AmountCal(body) async {
    String url = cnst.API_URL + 'orders/ordercalcV2';
    print("Get Amount cal url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        print(response);
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("Get Amount cal Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Content = memberDataClass["Data"];

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("Get Amount cal Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<SaveClassForPayment> GetOrderIDForPayment(
      int amount, String receiptNo) async {
    String url = API_URL_RazorPay_Order +
        'GetPickNDelieverePaymentOrderID?amount=$amount&receiptNo=$receiptNo';
    print("GetOrderIDForPayment URL: " + url);
    final response = await http.get(url);
    try {
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("Response " + jsonResponse.toString());
        SaveClassForPayment paymentOrderIdClass =
            new SaveClassForPayment.fromJson(jsonResponse);

        return paymentOrderIdClass;
      } else {
        throw Exception("Something Went Wrong");
      }
    } catch (e) {
      print("GetOrderIDForPayment Erorr : " + e.toString());
      throw Exception(MESSAGES.INTERNET_ERROR);
    }
  }

  static Future<SaveDataClass> CheckOtp() async {
    String url = cnst.API_URL + 'customers/getotp';
    print("GetOtp  url : " + url);
    try {
      final response = await dio.post(url);
      if (response.statusCode == 200) {
        SaveDataClass saveData =
            new SaveDataClass(Message: 'No Data', IsSuccess: false, Data: "0");
        print("GetOtp  Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.Message = memberDataClass["Message"];
        saveData.IsSuccess = memberDataClass["IsSuccess"];
        saveData.Data = memberDataClass["Data"].toString();

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("GetOtp  Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }
}
