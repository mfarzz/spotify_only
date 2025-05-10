class SpotifyAuthModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime expireTime;

  SpotifyAuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.expireTime,
  });

  factory SpotifyAuthModel.fromJson(Map<String, dynamic> json) {
    return SpotifyAuthModel(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
      expireTime: DateTime.now().add(Duration(seconds: json['expires_in'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'expire_time': expireTime.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expireTime);
}