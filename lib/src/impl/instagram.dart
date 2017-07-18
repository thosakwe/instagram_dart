import '../requestor.dart';
import '../api/api.dart';
import '../models/models.dart';
import 'comment.dart';
import 'like.dart';
import 'location.dart';
import 'tag.dart';
import 'user.dart';

class InstagramApiImpl implements InstagramApi {
  InstagramCommentsApiImpl _comments;
  InstagramLikesApiImpl _likes;
  InstagramLocationsApiImpl _locations;
  InstagramTagsApiImpl _tags;
  InstagramUsersApiImpl _users;

  @override
  final String accessToken;

  @override
  final User user;

  final Requestor requestor;

  InstagramApiImpl(this.accessToken, this.user, this.requestor);

  @override
  InstagramCommentsApi get comments =>
      _comments ??= new InstagramCommentsApiImpl(requestor);

  @override
  InstagramLikesApi get likes => _likes ??= new InstagramLikesApiImpl(requestor);

  @override
  InstagramLocationsApi get locations =>
      _locations ??= new InstagramLocationsApiImpl(requestor);

  @override
  InstagramTagsApi get tags => _tags ??= new InstagramTagsApiImpl(requestor);

  @override
  InstagramUsersApi get users =>
      _users ??= new InstagramUsersApiImpl(requestor);
}
