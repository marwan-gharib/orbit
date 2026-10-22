/// A closed, backend-driven role set with type-safe wire values; anything
/// unrecognized (including a missing or non-int `role`) falls back to
/// `unknown`, so a backend change can never crash the app (B9).
enum UserRole {
  admin(1),
  hrManager(2),
  accountant(3),
  salesRepresentative(4),
  regularStaff(5),
  projectManager(6),
  inventorySpecialist(7),
  unknown(-1);

  const UserRole(this.id);

  final int id;

  /// Maps a raw backend role id; falls back to [unknown] for null or any id
  /// outside the known set.
  static UserRole fromId(int? id) => id == null
      ? unknown
      : values.firstWhere((role) => role.id == id, orElse: () => unknown);
}
