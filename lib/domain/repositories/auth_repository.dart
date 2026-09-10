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

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? avatarUrl,
    bool? isAnonymous,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}

abstract class AuthRepository {
  Future<UserProfile> getCurrentUser();
  Future<UserProfile> signInAnonymously({String? nickname});
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> signOut();
  Stream<UserProfile?> get authStateChanges;
}
