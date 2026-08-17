import 'package:equatable/equatable.dart';
import '../../data/models/enquiry_model.dart';

enum EnquiryStatus { initial, loading, success, failure }

class EnquiryState extends Equatable {
  final EnquiryStatus status;
  final List<EnquiryModel> allEnquiries;
  final List<EnquiryModel> displayedEnquiries;
  final List<Map<String, dynamic>> employeesList;
  final List<Map<String, dynamic>> servicesList;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  const EnquiryState({
    this.status = EnquiryStatus.initial,
    this.allEnquiries = const [],
    this.displayedEnquiries = const [],
    this.employeesList = const [],
    this.servicesList = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  EnquiryState copyWith({
    EnquiryStatus? status,
    List<EnquiryModel>? allEnquiries,
    List<EnquiryModel>? displayedEnquiries,
    List<Map<String, dynamic>>? employeesList,
    List<Map<String, dynamic>>? servicesList,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
  }) {
    return EnquiryState(
      status: status ?? this.status,
      allEnquiries: allEnquiries ?? this.allEnquiries,
      displayedEnquiries: displayedEnquiries ?? this.displayedEnquiries,
      employeesList: employeesList ?? this.employeesList,
      servicesList: servicesList ?? this.servicesList,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allEnquiries,
        displayedEnquiries,
        employeesList,
        servicesList,
        searchQuery,
        errorMessage,
        successMessage,
      ];
}
