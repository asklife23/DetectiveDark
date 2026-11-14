import 'package:equatable/equatable.dart';

/// How serious a [ContentIssue] is.
enum ContentSeverity {
  /// The content is wrong: the content validation test fails.
  error,

  /// Probably a leftover or an oversight: reported, the test still passes.
  warning,
}

/// One problem found in the game content.
class ContentIssue extends Equatable {
  const ContentIssue(
    this.location,
    this.message, {
    this.severity = ContentSeverity.error,
  });

  /// Where it is, e.g. `scene villa_hall / hotspot desk_paper`.
  final String location;

  final String message;

  final ContentSeverity severity;

  bool get isError => severity == ContentSeverity.error;

  bool get isWarning => severity == ContentSeverity.warning;

  @override
  List<Object?> get props => [location, message, severity];

  @override
  String toString() =>
      isWarning ? 'warning: $location: $message' : '$location: $message';
}

extension ContentIssues on Iterable<ContentIssue> {
  /// The issues that make the content wrong.
  List<ContentIssue> get errors => [
    for (final issue in this)
      if (issue.isError) issue,
  ];

  /// The issues that are only reported.
  List<ContentIssue> get warnings => [
    for (final issue in this)
      if (issue.isWarning) issue,
  ];
}
