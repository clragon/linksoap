/// A hostname replacement rule.
class Softener {
  /// Creates a new [Softener] with the given [name], [domain], and [replacement].
  const Softener({
    required this.name,
    required this.domain,
    required this.replacement,
    this.enabled = true,
  });

  /// The name of this softener.
  final String name;

  /// A regex pattern matching the domain to replace.
  final String domain;

  /// The replacement hostname.
  final String replacement;

  /// Whether this softener is enabled.
  final bool enabled;

  factory Softener.fromJson(Map<String, dynamic> json) {
    return Softener(
      name: json['name'] as String,
      domain: json['domain'] as String,
      replacement: json['replacement'] as String,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'domain': domain,
      'replacement': replacement,
      'enabled': enabled,
    };
  }

  Softener copyWith({
    String? name,
    String? domain,
    String? replacement,
    bool? enabled,
  }) {
    return Softener(
      name: name ?? this.name,
      domain: domain ?? this.domain,
      replacement: replacement ?? this.replacement,
      enabled: enabled ?? this.enabled,
    );
  }
}
