import 'package:flutter/material.dart';

class OrderModel {
  final String id;
  final String userId;
  final double totalAmountKsh;
  final String status;
  final String? deliveryAddress;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.totalAmountKsh,
    required this.status,
    this.deliveryAddress,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      totalAmountKsh:
          double.tryParse(json['total_amount_ksh']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'pending',
      deliveryAddress: json['delivery_address']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  String get formattedTotal => 'KSh ${totalAmountKsh.toStringAsFixed(2)}';

  String get formattedDate {
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  Color get statusColor {
    switch (status) {
      case 'delivered':
        return const Color(0xFF2DD88A);
      case 'processing':
      case 'confirmed':
        return const Color(0xFF4F8EF7);
      case 'cancelled':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFFF39C12);
    }
  }
}
