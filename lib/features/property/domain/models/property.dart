import 'package:flutter/material.dart';

enum PropertyType { commercial, residential, buy, rent }

enum PropertyStatus { available, sold, rented, underContract }

extension PropertyStatusX on PropertyStatus {
  String get label {
    switch (this) {
      case PropertyStatus.available:
        return 'Available';
      case PropertyStatus.sold:
        return 'Sold';
      case PropertyStatus.rented:
        return 'Rented';
      case PropertyStatus.underContract:
        return 'Under Contract';
    }
  }
}

class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final PropertyType type;
  final PropertyStatus status;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final double area; // in sq ft
  final List<String> imageUrls;
  final String agentName;
  final String agentId;
  final DateTime createdAt;
  final bool isFeatured;
  final Map<String, dynamic> amenities;

  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
    required this.status,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.imageUrls,
    required this.agentName,
    required this.agentId,
    required this.createdAt,
    this.isFeatured = false,
    this.amenities = const {},
  });

  String get formattedPrice {
    if (price >= 1000000) {
      return 'Rs ${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return 'Rs ${(price / 1000).toStringAsFixed(0)}K';
    }
    return 'Rs ${price.toStringAsFixed(0)}';
  }

  String get timeAgo {
    final Duration d = DateTime.now().difference(createdAt);
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    if (d.inMinutes > 0) return '${d.inMinutes}m ago';
    return 'Just now';
  }

  String get typeLabel {
    switch (type) {
      case PropertyType.commercial:
        return 'Commercial';
      case PropertyType.residential:
        return 'Residential';
      case PropertyType.buy:
        return 'Buy';
      case PropertyType.rent:
        return 'Rent';
    }
  }

  String get statusLabel {
    switch (status) {
      case PropertyStatus.available:
        return 'Available';
      case PropertyStatus.sold:
        return 'Sold';
      case PropertyStatus.rented:
        return 'Rented';
      case PropertyStatus.underContract:
        return 'Under Contract';
    }
  }
}

extension PropertyTypeX on PropertyType {
  String get label {
    switch (this) {
      case PropertyType.commercial:
        return 'Commercial';
      case PropertyType.residential:
        return 'Residential';
      case PropertyType.buy:
        return 'Buy';
      case PropertyType.rent:
        return 'Rent';
    }
  }

  IconData get icon {
    switch (this) {
      case PropertyType.commercial:
        return Icons.business;
      case PropertyType.residential:
        return Icons.home;
      case PropertyType.buy:
        return Icons.shopping_cart;
      case PropertyType.rent:
        return Icons.key;
    }
  }
}
