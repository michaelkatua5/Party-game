import 'dart:async';
import '../../core/services/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final StorageService storage;
  final _controller = StreamController<UserProfile?>.broadcast();

  AuthRepositoryImpl({required this.storage});

  static const _keyUserNickname = 'user_display_nickname';

  @override
  Future<UserProfile> getCurrentUser() async {
    final name = storage.getString(_keyUserNickname) ?? 'Guest Player';
    return UserProfile(
      uid: 'local_user_1',
      displayName: name,
      isAnonymous: true,
    );
  }

  @override
  Future<UserProfile> signInAnonymously({String? nickname}) async {
    final name = nickname ?? 'Guest Player';
    await storage.setString(_keyUserNickname, name);
    final user = UserProfile(
      uid: 'local_user_1',
      displayName: name,
      isAnonymous: true,
    );
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await storage.remove(_keyUserNickname);
    _controller.add(null);
  }

  @override
  Stream<UserProfile?> get authStateChanges => _controller.stream;
}
