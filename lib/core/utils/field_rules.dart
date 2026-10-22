/// One validation rule of a field: a stable [id] plus the predicate that
/// decides whether the rule is violated by the raw field text.
///
/// Rules carry ids instead of copy, so the same set can drive a form
/// validator, a live checklist, and a strength meter while the UI layer owns
/// every user-facing string.
final class FieldRule {
  const FieldRule({required this.id, required this.isViolated});

  /// Stable identity of the rule (usually a feature enum value).
  final Object id;

  /// Whether [text] currently breaks this rule.
  final bool Function(String text) isViolated;
}

/// An ordered set of [FieldRule]s evaluated against one raw field value.
final class FieldRuleSet {
  const FieldRuleSet(this.rules);

  final List<FieldRule> rules;

  /// The id of the first violated rule in order, or `null` when all pass.
  Object? firstViolated(String text) {
    for (final rule in rules) {
      if (rule.isViolated(text)) return rule.id;
    }
    return null;
  }

  /// Every rule's current state, keyed by its id.
  Map<Object, bool> violations(String text) => <Object, bool>{
    for (final rule in rules) rule.id: rule.isViolated(text),
  };
}
