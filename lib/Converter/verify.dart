class checkoutVerify {
  int? shippingClassId;
  int? amount;
  List<Products>? products;
  BillingAddress? billingAddress;
  BillingAddress? shippingAddress;

  checkoutVerify(
      {this.shippingClassId,
      this.amount,
      this.products,
      this.billingAddress,
      this.shippingAddress});

  checkoutVerify.fromJson(Map<String, dynamic> json) {
    shippingClassId = json['shipping_class_id'];
    amount = json['amount'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(new Products.fromJson(v));
      });
    }
    billingAddress = json['billing_address'] != null
        ? new BillingAddress.fromJson(json['billing_address'])
        : null;
    shippingAddress = json['shipping_address'] != null
        ? new BillingAddress.fromJson(json['shipping_address'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['\"shipping_class_id\"'] = this.shippingClassId;
    data['\"amount\"'] = this.amount;
    if (this.products != null) {
      data['\"products\"'] = this.products!.map((v) => v.toJson()).toList();
    }
    if (this.billingAddress != null) {
      data['\"billing_address\"'] = this.billingAddress!.toJson();
    }
    if (this.shippingAddress != null) {
      data['\"shipping_address\"'] = this.shippingAddress!.toJson();
    }
    return data;
  }
}

class Products {
  int? orderQuantity;
  String? productId;
  int? unitPrice;
  int? subtotal;
  int? variationOptionId;

  Products(
      {this.orderQuantity,
      this.productId,
      this.unitPrice,
      this.subtotal,
      this.variationOptionId = 0});

  Products.fromJson(Map<String, dynamic> json) {
    orderQuantity = json['order_quantity'];
    productId = json['product_id'];
    unitPrice = json['unit_price'];
    subtotal = json['subtotal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['\"order_quantity\"'] = "\"${this.orderQuantity}\"";
    data['\"product_id\"'] = "\"${this.productId}\"";
    data['\"unit_price\"'] = "\"${this.unitPrice}\"";
    data['\"subtotal\"'] = "\"${this.subtotal}\"";
    if (variationOptionId != 0)
      data['\"variation_option_id\"'] = "\"${this.variationOptionId}\"";
    return data;
  }
}

class BillingAddress {
  String? country;
  String? state;
  String? zip;
  String? city;

  BillingAddress({this.country, this.state, this.zip, this.city});

  BillingAddress.fromJson(Map<String, dynamic> json) {
    country = json['country'];
    state = json['state'];
    zip = json['zip'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['\"country\"'] = "\"${this.country}\"";
    data['\"state\"'] = "\"${this.state}\"";
    data['\"zip\"'] = "\"${this.zip}\"";
    data['\"city\"'] = "\"${this.city}\"";
    return data;
  }
}
