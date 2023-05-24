class placeOrder {
  List<placingproduct>? products;
  int? status = 1;
  int? amount;
  String? couponId;
  int? discount = 0;
  int? paidTotal;
  int? salesTax;
  int? deliveryFee;
  int? total;
  String? orderId;
  String? paymentId;
  String? signature;
  String? customerContact;
  String? paymentGateway;
  bool? useWalletPoints;
  String? deliveryTime;
  placingAddress? billingAddress;
  placingAddress? shippingAddress;
  String? language;

  placeOrder(
      {this.products,
      this.status,
      this.amount,
      this.couponId,
      this.signature,
      this.discount,
      this.paidTotal,
      this.orderId,
      this.paymentId,
      this.salesTax,
      this.deliveryTime,
      this.deliveryFee,
      this.total,
      this.customerContact,
      this.paymentGateway,
      this.useWalletPoints,
      this.billingAddress,
      this.shippingAddress,
      this.language});

  placeOrder.fromJson(Map<String, dynamic> json) {
    if (json['products'] != null) {
      products = <placingproduct>[];
      json['products'].forEach((v) {
        products!.add(new placingproduct.fromJson(v));
      });
    }
    status = json['status'];
    amount = json['amount'];
    couponId = json['coupon_id'];
    discount = json['discount'];
    paidTotal = json['paid_total'];
    salesTax = json['sales_tax'];
    deliveryFee = json['delivery_fee'];
    deliveryTime = json['delivery_time'];
    orderId = json["payment_gateway_order_id"];
    paymentId = json["payment_gateway_payment_id"];
    signature = json["payment_gateway_signature"];
    total = json['total'];
    customerContact = json['customer_contact'];
    paymentGateway = json['payment_gateway'];
    useWalletPoints = json['use_wallet_points'];
    billingAddress = json['billing_address'] != null
        ? new placingAddress.fromJson(json['billing_address'])
        : null;
    shippingAddress = json['shipping_address'] != null
        ? new placingAddress.fromJson(json['shipping_address'])
        : null;
    language = json['language'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['amount'] = this.amount;
    data['coupon_id'] = this.couponId;
    data['discount'] = this.discount;
    data['paid_total'] = this.paidTotal;
    data['sales_tax'] = this.salesTax;
    data['delivery_time'] = this.deliveryTime;
    data['delivery_fee'] = this.deliveryFee;
    data['total'] = this.total;
    if (orderId != null) data["payment_intent"] = this.orderId;
   
    data["customer_contact"] = this.customerContact;
    data["payment_gateway"] = paymentGateway;
    data["use_wallet_points"] = this.useWalletPoints;
    if (this.billingAddress != null) {
      data['billing_address'] = this.billingAddress!.toJson();
    }
    if (this.shippingAddress != null) {
      data['shipping_address'] = this.shippingAddress!.toJson();
    }
    data['language'] = this.language;
    return data;
  }
}

class placingproduct {
  int? productId;
  int? orderQuantity;
  int? unitPrice;
  int? subtotal;
  int? variationOptionId;

  placingproduct(
      {this.productId,
      this.orderQuantity,
      this.unitPrice,
      this.subtotal,
      this.variationOptionId = 0});

  placingproduct.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    orderQuantity = json['order_quantity'];
    unitPrice = json['unit_price'];
    subtotal = json['subtotal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['order_quantity'] = this.orderQuantity;
    data['unit_price'] = this.unitPrice;
    data['subtotal'] = this.subtotal;
    if (variationOptionId != 0)
      data['variation_option_id'] = "${this.variationOptionId}";
    return data;
  }
}

class placingAddress {
  String? zip;
  String? city;
  String? state;
  String? country;
  String? streetAddress;

  placingAddress(
      {this.zip, this.city, this.state, this.country, this.streetAddress});

  placingAddress.fromJson(Map<String, dynamic> json) {
    zip = json['zip'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    streetAddress = json['street_address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['zip'] = this.zip;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['street_address'] = this.streetAddress;
    return data;
  }
}
