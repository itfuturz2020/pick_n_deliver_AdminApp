class SaveDataClass {
  String Message;
  bool IsSuccess;
  String Data;
  List Content;

  SaveDataClass({this.Message, this.IsSuccess, this.Data, this.Content});

  factory SaveDataClass.fromJson(Map<String, dynamic> json) {
    return SaveDataClass(
      Message: json['Message'] as String,
      IsSuccess: json['IsSuccess'] as bool,
      Data: json['Data'] as String,
      Content: json['Data'] as List,
    );
  }
}

class SaveClassForPayment {
  String Message;
  bool IsSuccess;
  String Data;

  SaveClassForPayment({this.Message, this.IsSuccess, this.Data});

  factory SaveClassForPayment.fromJson(Map<String, dynamic> json) {
    return SaveClassForPayment(
      Message: json['Message'] as String,
      IsSuccess: json['IsSuccess'] as bool,
      Data: json['Data'] as String,
    );
  }
}

class DeliveryTypeData {
  List<DeliveryType> Data;

  DeliveryTypeData({
    this.Data,
  });

  factory DeliveryTypeData.fromJson(List json) {
    return DeliveryTypeData(
        Data: json
            .map<DeliveryType>((json) => DeliveryType.fromJson(json))
            .toList());
  }
}

class DeliveryType {
  String id;
  String title;
  String weightlimit;

  DeliveryType({this.id, this.title, this.weightlimit});

  factory DeliveryType.fromJson(Map<String, dynamic> json) {
    return DeliveryType(
      id: json['_id'] as String,
      title: json['title'] as String,
      weightlimit: json['weightlimit'] as String,
    );
  }
}