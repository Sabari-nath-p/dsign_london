class updateProfile {
  int? id;
  String? name;
  Profile? profile;

  updateProfile({this.id, this.name, this.profile});

  updateProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profile =
        json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    return data;
  }
}

class Profile {
  int? id;
  String? bio;
  Avatar? avatar;

  Profile({this.id, this.bio, this.avatar});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bio = json['bio'];
    avatar =
        json['avatar'] != null ? new Avatar.fromJson(json['avatar']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['bio'] = this.bio;
    if (this.avatar != null) {
      data['avatar'] = this.avatar!.toJson();
    }
    return data;
  }
}

class Avatar {
  String? thumbnail;
  String? original;
  int? id;

  Avatar({this.thumbnail, this.original, this.id});

  Avatar.fromJson(Map<String, dynamic> json) {
    thumbnail = json['thumbnail'];
    original = json['original'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['thumbnail'] = this.thumbnail;
    data['original'] = this.original;
    data['id'] = this.id;
    return data;
  }
}