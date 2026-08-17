import 'package:equatable/equatable.dart';

abstract class EnquiryEvent extends Equatable {
  const EnquiryEvent();

  @override
  List<Object?> get props => [];
}

class FetchEnquiries extends EnquiryEvent {
  final String token;
  final String userRole; // 'Admin' or 'Employee'
  final int userEmployeeId;
  final String userEmployeeName;

  const FetchEnquiries({
    required this.token,
    required this.userRole,
    required this.userEmployeeId,
    required this.userEmployeeName,
  });

  @override
  List<Object?> get props => [token, userRole, userEmployeeId, userEmployeeName];
}

class SearchQueryChanged extends EnquiryEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateEnquiry extends EnquiryEvent {
  final String token;
  final String client;
  final String number;
  final String product;
  final String priority;
  final String notes;
  final int assignedToId;
  final String userRole;
  final int userEmployeeId;
  final String userEmployeeName;

  const CreateEnquiry({
    required this.token,
    required this.client,
    required this.number,
    required this.product,
    required this.priority,
    required this.notes,
    required this.assignedToId,
    required this.userRole,
    required this.userEmployeeId,
    required this.userEmployeeName,
  });

  @override
  List<Object?> get props => [
        token,
        client,
        number,
        product,
        priority,
        notes,
        assignedToId,
        userRole,
        userEmployeeId,
        userEmployeeName,
      ];
}

class UpdateEnquiry extends EnquiryEvent {
  final String token;
  final int enquiryId;
  final String client;
  final String number;
  final String product;
  final String priority;
  final String notes;
  final int assignedToId;
  final String userRole;
  final int userEmployeeId;
  final String userEmployeeName;

  const UpdateEnquiry({
    required this.token,
    required this.enquiryId,
    required this.client,
    required this.number,
    required this.product,
    required this.priority,
    required this.notes,
    required this.assignedToId,
    required this.userRole,
    required this.userEmployeeId,
    required this.userEmployeeName,
  });

  @override
  List<Object?> get props => [
        token,
        enquiryId,
        client,
        number,
        product,
        priority,
        notes,
        assignedToId,
        userRole,
        userEmployeeId,
        userEmployeeName,
      ];
}

class DeleteEnquiry extends EnquiryEvent {
  final String token;
  final int enquiryId;
  final String userRole;
  final int userEmployeeId;
  final String userEmployeeName;

  const DeleteEnquiry({
    required this.token,
    required this.enquiryId,
    required this.userRole,
    required this.userEmployeeId,
    required this.userEmployeeName,
  });

  @override
  List<Object?> get props => [token, enquiryId, userRole, userEmployeeId, userEmployeeName];
}
