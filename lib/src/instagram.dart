import 'dart:async';
import 'dart:convert';
import 'package:http/src/base_client.dart' as http;
import 'package:http/src/request.dart' as http;
import 'package:http/src/response.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'api/api.dart';
import 'impl/instagram.dart';
import 'models/impl_models.dart';
import 'models/models.dart';
import 'endpoints.dart';
import 'requestor.dart';
import 'scopes.dart';

/// Manages authentication against the Instagram API.
class InstagramApiAuth {
  oauth2.AuthorizationCodeGrant _grant;
  final String clientId, clientSecret;
  final Uri redirectUri;
  final List<InstagramApiScope> scopes = [];

  InstagramApiAuth(this.clientId, this.clientSecret,
      {this.redirectUri, Iterable<InstagramApiScope> scopes: const []}) {
    this.scopes.addAll(scopes ?? []);
  }

  /// Creates or returns an OAuth2 grant that will be used to authenticate against the API.
  oauth2.AuthorizationCodeGrant get grant =>
      _grant ??= new oauth2.AuthorizationCodeGrant(
          clientId, authorizationEndpoint, tokenEndpoint,
          secret: clientSecret);

  /// Returns a redirect URI that users can use to authenticate with the current application.
  ///
  /// You may optionally pass a [state] that will be forwarded back to your server. Use this
  /// to mitigate CSRF issues.
  Uri getRedirectUri({String state}) {
    if (redirectUri == null)
      throw new StateError(
          'You have not provided a `redirectUri` to this InstagramApiAuth instance.');
    return grant.getAuthorizationUrl(redirectUri,
        scopes: scopes.map((s) => s.scope), state: state);
  }

  /// Returns a URI that users can be redirected to to authenticate via applications with no server-side component.
  Uri getImplicitRedirectUri({String state}) {
    if (redirectUri == null)
      throw new StateError(
          'You have not provided a `redirectUri` to this InstagramApiAuth instance.');
    return authorizationEndpoint.replace(queryParameters: {
      'client_id': clientId,
      'redirect_uri': redirectUri.toString(),
      'response_type': 'token'
    });
  }

  static AuthorizationResponse parseAuthorizationResponse(
      http.Response response) {
    if (response.headers['content-type']?.contains('application/json') != true)
      throw new FormatException('The response is not formatted as JSON.');
    var untyped = JSON.decode(response.body);

    if (untyped is! Map)
      throw new FormatException('Expected the response to be a JSON object.');

    if (!untyped.containsKey('access_token') || !untyped.containsKey('user'))
      throw new FormatException(
          'Expected both an "access_token" and a "user".');

    return new AuthorizationResponse.fromJson(new Map.from(untyped));
  }

  static InstagramApi authorizeViaAccessToken(
      String accessToken, http.BaseClient httpClient,
      {User user}) {
    return new InstagramApiImpl(
        accessToken, user, new _RequestorImpl(accessToken, httpClient));
  }

  static InstagramApi authorize(
      AuthorizationResponse authorizationResponse, http.BaseClient httpClient) {
    return authorizeViaAccessToken(
        authorizationResponse.accessToken, httpClient);
  }

  static InstagramApi handleAuthorizationResponse(
      http.Response response, http.BaseClient httpClient) {
    return authorize(parseAuthorizationResponse(response), httpClient);
  }

  Future<InstagramApi> handleAuthorizationCode(
      String code, http.BaseClient httpClient) async {
    Map<String, String> data = {
      'client_id': clientId,
      'client_secret': clientSecret,
      'grant_type': 'authorization_code',
      'redirect_uri': redirectUri.toString(),
      'code': code
    };
    var response = await httpClient.post(tokenEndpoint,
        body: JSON.encode(data),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json'
        });
    return handleAuthorizationResponse(response, httpClient);
  }
}

class _RequestorImpl extends Requestor {
  static final Uri _root = Uri.parse('https://api.instagram.com/v1');
  final String accessToken;
  final http.BaseClient client;

  _RequestorImpl(this.accessToken, this.client);

  @override
  Future<InstagramResponse> send(http.Request request) {
    return client
        .send(request)
        .then<http.Response>(http.Response.fromStream)
        .then((response) {
      if (response.headers['content-type']?.contains('application/json') !=
          true)
        throw new FormatException(
            'The response is not formatted as JSON: "${response.body}"');
      var untyped = JSON.decode(response.body);

      if (untyped is! Map)
        throw new FormatException('Expected the response to be a JSON object.');

      var r = new InstagramResponse.fromJson(untyped);

      if (r.meta.code != 200) throw r.meta;

      return r;
    });
  }

  @override
  Uri buildUri(String path,
      {Map<String, String> queryParameters, String method}) {
    Map<String, String> q =
        method == 'POST' ? {} : {'access_token': accessToken}
          ..addAll(queryParameters ?? {});
    return _root.replace(path: path, queryParameters: q);
  }

  @override
  Map<String, String> buildBody(Map<String, String> body) {
    return new Map<String, String>.from(body)..['access_token'] = accessToken;
  }
}
