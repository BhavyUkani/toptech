import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/enquiries_repository.dart';
import '../../data/models/enquiry_model.dart';
import 'enquiry_event.dart';
import 'enquiry_state.dart';

class EnquiryBloc extends Bloc<EnquiryEvent, EnquiryState> {
  final EnquiriesRepository _repository;

  EnquiryBloc({EnquiriesRepository? repository})
      : _repository = repository ?? EnquiriesRepository(),
        super(const EnquiryState()) {
    on<FetchEnquiries>(_onFetchEnquiries);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<CreateEnquiry>(_onCreateEnquiry);
    on<UpdateEnquiry>(_onUpdateEnquiry);
    on<DeleteEnquiry>(_onDeleteEnquiry);
  }

  Future<void> _onFetchEnquiries(
    FetchEnquiries event,
    Emitter<EnquiryState> emit,
  ) async {
    emit(state.copyWith(status: EnquiryStatus.loading, errorMessage: null, successMessage: null));

    try {
      final rawList = await _repository.fetchEnquiries(event.token);
      final employeesList = await _repository.fetchEmployees(event.token);
      final servicesList = await _repository.fetchServices(event.token);
      final isAdmin = event.userRole.toLowerCase() == 'admin';

      // Role-Based Filtering:
      // Admin -> Sees ALL enquiries
      // Employee -> Sees ONLY assigned enquiries (matching assignedToId or assignedEmployeeName)
      final roleFilteredList = isAdmin
          ? rawList
          : rawList.where((item) {
              final matchesId = item.assignedToId == event.userEmployeeId;
              final matchesName = item.assignedEmployeeName
                      .trim()
                      .toLowerCase() ==
                  event.userEmployeeName.trim().toLowerCase();
              return matchesId || matchesName;
            }).toList();

      final searchFilteredList = _applySearch(roleFilteredList, state.searchQuery);

      emit(state.copyWith(
        status: EnquiryStatus.success,
        allEnquiries: roleFilteredList,
        displayedEnquiries: searchFilteredList,
        employeesList: employeesList,
        servicesList: servicesList,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EnquiryStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<EnquiryState> emit,
  ) {
    final query = event.query.trim().toLowerCase();
    final searchFilteredList = _applySearch(state.allEnquiries, query);

    emit(state.copyWith(
      searchQuery: query,
      displayedEnquiries: searchFilteredList,
    ));
  }

  Future<void> _onCreateEnquiry(
    CreateEnquiry event,
    Emitter<EnquiryState> emit,
  ) async {
    emit(state.copyWith(status: EnquiryStatus.loading, errorMessage: null, successMessage: null));

    try {
      // Employee rule: can self assign ONLY
      final assignedId = event.userRole.toLowerCase() == 'admin'
          ? event.assignedToId
          : event.userEmployeeId;

      await _repository.createEnquiry(
        token: event.token,
        client: event.client,
        number: event.number,
        product: event.product,
        priority: event.priority,
        notes: event.notes,
        assignedToId: assignedId,
      );

      // Refresh list
      add(FetchEnquiries(
        token: event.token,
        userRole: event.userRole,
        userEmployeeId: event.userEmployeeId,
        userEmployeeName: event.userEmployeeName,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EnquiryStatus.failure,
        errorMessage: 'Failed to create enquiry: $e',
      ));
    }
  }

  Future<void> _onUpdateEnquiry(
    UpdateEnquiry event,
    Emitter<EnquiryState> emit,
  ) async {
    emit(state.copyWith(status: EnquiryStatus.loading, errorMessage: null, successMessage: null));

    try {
      await _repository.updateEnquiry(
        token: event.token,
        enquiryId: event.enquiryId,
        client: event.client,
        number: event.number,
        product: event.product,
        priority: event.priority,
        notes: event.notes,
        assignedToId: event.assignedToId,
      );

      // Refresh list
      add(FetchEnquiries(
        token: event.token,
        userRole: event.userRole,
        userEmployeeId: event.userEmployeeId,
        userEmployeeName: event.userEmployeeName,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EnquiryStatus.failure,
        errorMessage: 'Failed to update enquiry: $e',
      ));
    }
  }

  Future<void> _onDeleteEnquiry(
    DeleteEnquiry event,
    Emitter<EnquiryState> emit,
  ) async {
    emit(state.copyWith(status: EnquiryStatus.loading, errorMessage: null, successMessage: null));

    try {
      await _repository.deleteEnquiry(
        token: event.token,
        enquiryId: event.enquiryId,
      );

      // Refresh list
      add(FetchEnquiries(
        token: event.token,
        userRole: event.userRole,
        userEmployeeId: event.userEmployeeId,
        userEmployeeName: event.userEmployeeName,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EnquiryStatus.failure,
        errorMessage: 'Failed to delete enquiry: $e',
      ));
    }
  }

  List<EnquiryModel> _applySearch(List<EnquiryModel> list, String query) {
    if (query.isEmpty) return list;
    return list.where((item) {
      return item.client.toLowerCase().contains(query) ||
          item.number.toLowerCase().contains(query) ||
          item.product.toLowerCase().contains(query) ||
          item.notes.toLowerCase().contains(query);
    }).toList();
  }
}
