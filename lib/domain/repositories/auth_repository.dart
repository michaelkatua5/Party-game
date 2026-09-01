class UserProfile {
  final String uid;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final bool isAnonymous;

  const UserProfile({
    required this.uid,
    required this.displayName,
    this.email,
    this.avatarUrl,
    this.isAnonymous = true,
  });
}

abstract class AuthRepository {
  Future<UserProfile> getCurrentUser();
  Future<UserProfile> signInAnonymously({String? nickname});
  Future<void> signOut();
  Stream<UserProfile?> get authStateChanges;
}
