import 'package:equatable/equatable.dart';

/// Customer summary shown inside a note; sent as `customer_details` on the
/// notes endpoint and never serialized back.
final class NoteCustomerDetails extends Equatable {
  const NoteCustomerDetails({
    required this.customerId,
    required this.customerCode,
    required this.name,
    required this.companyName,
  });

  final int customerId;
  final String customerCode;
  final String name;
  final String companyName;

  @override
  List<Object?> get props => [customerId, customerCode, name, companyName];
}
