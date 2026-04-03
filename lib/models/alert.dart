import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  static const String collectionName = 'alerts';

  static const String severitySafe = 'safe';
  static const String severityWarning = 'warning';
  static const String severityDanger = 'danger';

  static const String statusActive = 'active';
  static const String statusResolved = 'resolved';

  final String id;
  final String title;
  final String description;
  final String severity;
  final String nodeId;
  final String nodeName;
  final String location;
  final DateTime triggeredAt;
  final String status;
  final DateTime? resolvedAt;
  final String? explanation;
  final String? createdBy;
  final String? resolvedBy;
  final DateTime? updatedAt;

  const Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.nodeId,
    required this.nodeName,
    required this.location,
    required this.triggeredAt,
    required this.status,
    this.resolvedAt,
    this.explanation,
    this.createdBy,
    this.resolvedBy,
    this.updatedAt,
  });

  bool get isActive => status == statusActive;

  bool get isResolved => status == statusResolved;

  factory Alert.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? <String, dynamic>{};

    return Alert(
      id: document.id,
      title: data['title'] as String? ?? 'Alert',
      description: data['description'] as String? ?? 'Sensor reading exceeded threshold.',
      severity: data['severity'] as String? ?? severityWarning,
      nodeId: data['nodeId'] as String? ?? '',
      nodeName: data['nodeName'] as String? ?? 'Unknown Node',
      location: data['location'] as String? ?? 'Unknown',
      triggeredAt: _parseDateTime(data['triggeredAt']) ?? DateTime.now(),
      status: data['status'] as String? ?? statusActive,
      resolvedAt: _parseDateTime(data['resolvedAt']),
      explanation: data['explanation'] as String?,
      createdBy: data['createdBy'] as String?,
      resolvedBy: data['resolvedBy'] as String?,
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'severity': severity,
      'nodeId': nodeId,
      'nodeName': nodeName,
      'location': location,
      'triggeredAt': Timestamp.fromDate(triggeredAt),
      'status': status,
      'resolvedAt': resolvedAt == null ? null : Timestamp.fromDate(resolvedAt!),
      'explanation': explanation,
      'createdBy': createdBy,
      'resolvedBy': resolvedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Alert copyWith({
    String? id,
    String? title,
    String? description,
    String? severity,
    String? nodeId,
    String? nodeName,
    String? location,
    DateTime? triggeredAt,
    String? status,
    DateTime? resolvedAt,
    String? explanation,
    String? createdBy,
    String? resolvedBy,
    DateTime? updatedAt,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      nodeId: nodeId ?? this.nodeId,
      nodeName: nodeName ?? this.nodeName,
      location: location ?? this.location,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      status: status ?? this.status,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      explanation: explanation ?? this.explanation,
      createdBy: createdBy ?? this.createdBy,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
