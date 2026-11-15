import 'package:equatable/equatable.dart';

/// One contact method of an opportunity's customer. Metadata only — no
/// client-side logic on `isPrimary`.
final class CustomerContact extends Equatable {
  const CustomerContact({
    required this.contactId,
    required this.name,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.isPrimary,
  });

  final int contactId;
  final String name;
  final String jobTitle;
  final String email;
  final String phone;
  final bool isPrimary;

  @override
  List<Object?> get props => [
    contactId,
    name,
    jobTitle,
    email,
    phone,
    isPrimary,
  ];
}
