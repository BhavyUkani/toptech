import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/auth_service.dart';

class FollowUpTimelineScreen extends StatefulWidget {
  final Map<String, dynamic> enquiry;

  const FollowUpTimelineScreen({super.key, required this.enquiry});

  @override
  State<FollowUpTimelineScreen> createState() => _FollowUpTimelineScreenState();
}

class _FollowUpTimelineScreenState extends State<FollowUpTimelineScreen> {
  late Map<String, dynamic> _enquiryMap;
  final List<dynamic> _followupsList = [];
  bool _isLoading = false;
  DateTime? _selectedReminderDateTime;

  Future<void> _pickReminderDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;
    if (!mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    setState(() {
      _selectedReminderDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  final List<dynamic> _masterStatuses = [];

  @override
  void initState() {
    super.initState();
    _enquiryMap = Map<String, dynamic>.from(widget.enquiry);
    _parseInitialFollowups();
    _fetchMasterStatuses();
  }

  Future<void> _fetchMasterStatuses() async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/followup-statuses');
      if (response.status.isOk && response.body != null) {
        setState(() {
          _masterStatuses.clear();
          _masterStatuses.addAll(response.body as List<dynamic>);
        });
      }
    } catch (e) {
      debugPrint('Error fetching master followup statuses: $e');
    }
  }

  void _parseInitialFollowups() {
    final existingJson = _enquiryMap['followups'] as String?;
    if (existingJson != null &&
        existingJson.isNotEmpty &&
        existingJson != '[]') {
      try {
        final parsed = jsonDecode(existingJson) as List<dynamic>;
        setState(() {
          _followupsList.clear();
          _followupsList.addAll(parsed);
        });
      } catch (e) {
        debugPrint('Error parsing initial followups: $e');
      }
    }
  }

  // Reload logs from server to stay up-to-date
  Future<void> _refreshFollowups() async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/enquiries/${_enquiryMap['id']}');
      if (response.status.isOk && response.body != null) {
        final data = response.body as Map<String, dynamic>;
        final existingJson = data['followups'] as String?;
        if (mounted) {
          setState(() {
            _enquiryMap = data;
            _followupsList.clear();
            if (existingJson != null && existingJson.isNotEmpty) {
              _followupsList.addAll(jsonDecode(existingJson) as List<dynamic>);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error refreshing followups: $e');
    }
  }

  // Toggle checklist checkbox (adds follow-up log or clears it)
  Future<void> _toggleFollowupStatus(String statusName, bool isChecked) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<dynamic> updatedList = List.from(_followupsList);

      if (isChecked) {
        // Mark as completed: add to the logs list
        final now = DateTime.now();
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        final dateStr =
            "${now.day} ${months[now.month - 1]} ${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        
        final empName = Get.find<AuthService>().employee.value?.name ?? 'System';
        
        // Remove existing item if any, then add fresh
        updatedList.removeWhere((item) => item['note'] == statusName);
        updatedList.add({
          'date': dateStr,
          'note': statusName,
          'completed': true,
          'by': empName,
        });
      } else {
        // Unchecked: remove from logs list
        updatedList.removeWhere((item) => item['note'] == statusName);
      }

      final updatedJson = jsonEncode(updatedList);
      final apiClient = Get.find<ApiClient>();

      // Update Enquiry in database
      final response = await apiClient.patch('/enquiries/${_enquiryMap['id']}', {
        'status': isChecked ? statusName : 'Follow-up',
        'followups': updatedJson,
        'assignedToId': _enquiryMap['assignedToId'],
      });

      if (response.status.isOk) {
        setState(() {
          _enquiryMap['followups'] = updatedJson;
          if (isChecked) {
            _enquiryMap['status'] = statusName;
          }
          _followupsList.clear();
          _followupsList.addAll(updatedList);
        });
      }
    } catch (e) {
      debugPrint('Error toggling followup checklist: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF080B16)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          (_enquiryMap['client'] ?? 'Enquiry').toUpperCase(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF0C1020) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C2452),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top enquiry details card
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: Hero(
              tag: 'enquiry_card_${_enquiryMap['id']}',
              child: Material(
                type: MaterialType.transparency,
                child: Card(
                  color: isDark ? const Color(0xFF13192F) : Colors.white,
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isDark
                          ? const Color(0x33FFFFFF)
                          : const Color(0x26000000),
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                (_enquiryMap['client'] ?? 'N/A').toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x1FFE6420),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _enquiryMap['status'] ?? 'New',
                                style: const TextStyle(
                                  color: Color(0xFFFE6420),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${(_enquiryMap['date'] ?? 'Today').toLowerCase()}  |  To: ${_enquiryMap['assignedEmployee']?['name'] ?? _enquiryMap['assigned'] ?? 'Unassigned'}  |  By: ${_enquiryMap['creatorEmployee']?['name'] ?? _enquiryMap['assignedBy'] ?? 'System'}",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 15,
                              color: isDark
                                  ? const Color(0xFFFF9E73)
                                  : const Color(0xFFFE6420),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _enquiryMap['product'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 15,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _enquiryMap['number'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        if (_enquiryMap['notes'] != null &&
                            (_enquiryMap['notes'] as String).isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.notes_rounded,
                                size: 15,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _enquiryMap['notes'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Unified Scrollable Timeline checklist view
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFFFE6420),
              onRefresh: () async {
                await _refreshFollowups();
                await _fetchMasterStatuses();
              },
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFE6420)),
                    )
                  : _masterStatuses.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(
                                child: Text(
                                  'No follow-up statuses added in settings.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24.0),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _masterStatuses.length,
                          itemBuilder: (context, index) {
                            final status = _masterStatuses[index];
                            final name = status['name'] as String;
                            final isLast = index == _masterStatuses.length - 1;

                            // Check if this status exists in the completed followups list
                            final completedLog = _followupsList.firstWhereOrNull(
                              (log) => log['note'] == name,
                            );
                            final isDone = completedLog != null;
                            final completionDate = completedLog != null ? completedLog['date'] as String? : null;
                            final completedBy = completedLog != null ? completedLog['by'] as String? : null;

                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Timeline line and Checkbox
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: isDone,
                                          activeColor: const Color(0xFFFE6420),
                                          onChanged: (val) {
                                            if (val != null) {
                                              _toggleFollowupStatus(name, val);
                                            }
                                          },
                                        ),
                                      ),
                                      if (!isLast)
                                        Expanded(
                                          child: Container(
                                            width: 1.5,
                                            margin: const EdgeInsets.only(top: 4, bottom: 4),
                                            color: isDark
                                                ? const Color(0x33FFFFFF)
                                                : const Color(0x26000000),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  // Status details
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 20.0, top: 2.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                                              color: isDone
                                                  ? (isDark ? Colors.white : const Color(0xFF1C2452))
                                                  : (isDark ? Colors.white60 : Colors.black54),
                                            ),
                                          ),
                                          if (isDone && completionDate != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Completed on: $completionDate${completedBy != null ? " by $completedBy" : ""}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? Colors.white38 : Colors.black38,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
