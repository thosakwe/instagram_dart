import 'package:owl/annotation/json.dart';
import 'models.g.dart';

@JsonClass()
class AuthorizationResponse {
  @JsonField(key: 'access_token')
  String accessToken;

  User user;

  AuthorizationResponse({this.accessToken, this.user});
  factory AuthorizationResponse.fromJson(Map map) =>
      AuthorizationResponseMapper.parse(map);
  Map<String, dynamic> toJson() => AuthorizationResponseMapper.map(this);
}

@JsonClass()
class User {
  String id, username, bio, website;
  UserCounts counts;

  @JsonField(key: 'full_name')
  String fullName;

  @JsonField(key: 'profile_picture')
  String profilePicture;

  User(
      {this.id,
      this.username,
      this.fullName,
      this.bio,
      this.website,
      this.counts});
  factory User.fromJson(Map map) => UserMapper.parse(map);
  Map<String, dynamic> toJson() => UserMapper.map(this);
}

@JsonClass()
class UserCounts {
  int media, follows;

  @JsonField(key: 'followed_by')
  int followedBy;

  UserCounts({this.media, this.follows, this.followedBy});
  factory UserCounts.fromJson(Map map) => UserCountsMapper.parse(map);
  Map<String, dynamic> toJson() => UserCountsMapper.map(this);
}

@JsonClass()
class Media {
  String id, type, filter;

  MediaCaption caption;

  @JsonField(key: 'users_in_photo')
  List<UserInPhoto> usersInPhoto;

  @JsonField(native: true)
  List<String> tags;

  CommentOrLikeCount comments, likes;

  User user;

  Location location;

  MediaImages images;

  @Transient()
  DateTime createdTime;

  Media(
      {this.id,
      this.type,
      this.filter,
      this.caption,
      this.usersInPhoto: const [],
      this.tags: const [],
      this.comments,
      this.likes,
      this.user,
      this.location,
      this.images,
      this.createdTime});
  factory Media.fromJson(Map map) {
    var m = MediaMapper.parse(map);
    if (map['created_time'] is String)
      m.createdTime = new DateTime.fromMillisecondsSinceEpoch(
          int.parse(map['created_time']));
    return m;
  }

  Map<String, dynamic> toJson() {
    return MediaMapper.map(this)
      ..['created_time'] = createdTime?.millisecondsSinceEpoch?.toString();
  }
}

@JsonClass()
class MediaCaption {
  String id, text;
  User from;

  @Transient()
  DateTime createdTime;

  MediaCaption({this.id, this.text, this.from});
  
  factory MediaCaption.fromJson(Map map) {
    var m = MediaCaptionMapper.parse(map);
    if (map['created_time'] is String)
      m.createdTime = new DateTime.fromMillisecondsSinceEpoch(
          int.parse(map['created_time']));
    return m;
  }

  Map<String, dynamic> toJson() {
    return MediaCaptionMapper.map(this)
      ..['created_time'] = createdTime?.millisecondsSinceEpoch?.toString();
  }
}

@JsonClass()
class MediaImages {
  @JsonField(key: 'low_resolution')
  MediaImage lowResolution;

  MediaImage thumbnail;

  @JsonField(key: 'standard_resolution')
  MediaImage standardResolution;

  MediaImages({this.lowResolution, this.thumbnail, this.standardResolution});
  factory MediaImages.fromJson(Map map) => MediaImagesMapper.parse(map);
  Map<String, dynamic> toJson() => MediaImagesMapper.map(this);
}

@JsonClass()
class MediaImage {
  String url;
  int width, height;

  MediaImage({this.url, this.width, this.height});
  factory MediaImage.fromJson(Map map) => MediaImageMapper.parse(map);
  Map<String, dynamic> toJson() => MediaImageMapper.map(this);
}

@JsonClass()
class CommentOrLikeCount {
  int count;
  CommentOrLikeCount({this.count});
  factory CommentOrLikeCount.fromJson(Map map) =>
      CommentOrLikeCountMapper.parse(map);
  Map<String, dynamic> toJson() => CommentOrLikeCountMapper.map(this);
}

/// Represents the various types of media in Instagram.
abstract class MediaType {
  /// An image on Instagram.
  static const String image = 'image';

  /// An video on Instagram.
  static const String video = 'video';
}

@JsonClass()
class UserInPhoto {
  User user;
  UserInPhotoPosition position;
  UserInPhoto({this.user, this.position});
  factory UserInPhoto.fromJson(Map map) => UserInPhotoMapper.parse(map);
  Map<String, dynamic> toJson() => UserInPhotoMapper.map(this);
}

@JsonClass()
class UserInPhotoPosition {
  num x, y;
  UserInPhotoPosition({this.x, this.y});
  factory UserInPhotoPosition.fromJson(Map map) =>
      UserInPhotoPositionMapper.parse(map);
  Map<String, dynamic> toJson() => UserInPhotoPositionMapper.map(this);
}

@JsonClass()
class Comment {
  String id, text;
  User from;

  @Transient()
  DateTime createdTime;

  Comment({this.id, this.text, this.from, this.createdTime});

  factory Comment.fromJson(Map map) {
    var c = CommentMapper.parse(map);
    if (map['created_time'] is String)
      c.createdTime = new DateTime.fromMillisecondsSinceEpoch(
          int.parse(map['created_time']));
    return c;
  }

  Map<String, dynamic> toJson() {
    return CommentMapper.map(this)
      ..['created_time'] = createdTime?.millisecondsSinceEpoch?.toString();
  }
}

@JsonClass()
class Tag {
  String name;

  @JsonField(key: 'media_count')
  int mediaCount;

  Tag({this.name, this.mediaCount});
  factory Tag.fromJson(Map map) => TagMapper.parse(map);
  Map<String, dynamic> toJson() => TagMapper.map(this);
}

@JsonClass()
class Location {
  int id;
  String name;
  num latitude, longitude;

  Location({this.id, this.name, this.latitude, this.longitude});
  factory Location.fromJson(Map map) => LocationMapper.parse(map);
  Map<String, dynamic> toJson() => LocationMapper.map(this);
}
