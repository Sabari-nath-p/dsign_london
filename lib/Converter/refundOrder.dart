class RefundOrderData {
  int? orderId;
  String? title;
  String? description;
  List<Images>? images;

  RefundOrderData({this.orderId, this.title, this.description, this.images});

  RefundOrderData.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    title = json['title'];
    description = json['description'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['\"order_id\"'] = this.orderId;
    data['\"title\"'] = "\"${this.title}\"";
    data['\"description\"'] = "\"${this.description}\"";
    if (this.images != null) {
      data['\"images\"'] = this.images!.map((v) => v.toJson()).toList();
    } else {
      data['\"images\"'] = "[]";
    }
    return data;
  }
}

class Images {
  String? thumbnail;
  String? original;
  int? id;

  Images({this.thumbnail, this.original, this.id});

  Images.fromJson(Map<String, dynamic> json) {
    thumbnail = json['thumbnail'];
    original = json['original'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['\"thumbnail\"'] = "\"${this.thumbnail}\"";
    data['\"original\"'] = "\"${this.original}\"";
    data['\"id\"'] = "\"${this.id}\"";
    return data;
  }
}
