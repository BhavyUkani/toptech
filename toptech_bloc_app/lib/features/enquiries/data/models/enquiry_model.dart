class EnquiryModel {
  final int id;
  final String client;
  final String number;
  final String product;
  final String status;
  final String priority;
  final String date;
  final String notes;
  final int? assignedToId;
  final String assignedEmployeeName;

  const EnquiryModel({
    required this.id,
    required this.client,
    required this.number,
    required this.product,
    required this.status,
    required this.priority,
    required this.date,
    required this.notes,
    this.assignedToId,
    required this.assignedEmployeeName,
  });

  factory EnquiryModel.fromJson(Map<String, dynamic> json) {
    String empName = 'Unassigned';
    if (json['assignedEmployee'] != null && json['assignedEmployee']['name'] != null) {
      empName = json['assignedEmployee']['name'] as String;
    }

    return EnquiryModel(
      id: json['id'] as int? ?? 0,
      client: json['client'] as String? ?? '',
      number: json['number'] as String? ?? '',
      product: json['product'] as String? ?? (json['service']?['serviceName'] as String? ?? 'General'),
      status: json['status'] as String? ?? 'New',
      priority: json['priority'] as String? ?? 'Medium',
      date: json['date'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      assignedToId: json['assignedToId'] as int?,
      assignedEmployeeName: empName,
    );
  }
}
