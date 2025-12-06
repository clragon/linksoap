import 'package:flutter/material.dart';

/// A rule for cleaning URLs.
@immutable
class Detergent {
  /// Creates a new [Detergent] with the given [name], [domain], and [rule].
  const Detergent({
    required this.name,
    required this.domain,
    required this.rule,
    this.enabled = true,
  });

  /// Parses a [Detergent] from JSON.
  factory Detergent.fromJson(Map<String, dynamic> json) {
    return Detergent(
      name: json['name'] as String,
      domain: json['domain'] as String,
      rule: json['rule'] as String,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  /// Converts this [Detergent] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'domain': domain,
      'rule': rule,
      'enabled': enabled,
    };
  }

  /// The name of this detergent.
  final String name;

  /// A regex that matches the host name of the URL.
  final String domain;

  /// A regex that matches the query parameters of the URL.
  /// Any matching parameters will be removed.
  final String rule;

  /// Whether this detergent is enabled.
  final bool enabled;

  @override
  String toString() => 'Detergent($name, $domain, $rule, enabled: $enabled)';

  @override
  bool operator ==(Object other) {
    return other is Detergent &&
        name == other.name &&
        domain == other.domain &&
        rule == other.rule &&
        enabled == other.enabled;
  }

  @override
  int get hashCode => Object.hash(name, domain, rule, enabled);

  Detergent copyWith({
    String? name,
    String? domain,
    String? rule,
    bool? enabled,
  }) {
    return Detergent(
      name: name ?? this.name,
      domain: domain ?? this.domain,
      rule: rule ?? this.rule,
      enabled: enabled ?? this.enabled,
    );
  }
}
