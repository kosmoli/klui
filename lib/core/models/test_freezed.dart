import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_freezed.freezed.dart';
part 'test_freezed.g.dart';

/// Freezed 3.0.0 测试模型
/// 验证 abstract class 要求是否正常工作
@freezed
abstract class TestUser with _$TestUser {
  const factory TestUser({
    required String id,
    required String name,
    required int age,
    String? email,
    @Default(false) bool isActive,
  }) = _TestUser;

  factory TestUser.fromJson(Map<String, dynamic> json) =>
      _$TestUserFromJson(json);
}
