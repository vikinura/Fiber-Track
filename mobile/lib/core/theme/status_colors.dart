import 'package:flutter/material.dart';

@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  final Color statusNew;
  final Color statusForwarded;
  final Color statusAssigned;
  final Color statusInProgress;
  final Color statusResolved;

  final Color slaSafe;
  final Color slaAtRisk;
  final Color slaOverdue;
  final Color slaBreached;

  const StatusColors({
    required this.statusNew,
    required this.statusForwarded,
    required this.statusAssigned,
    required this.statusInProgress,
    required this.statusResolved,
    required this.slaSafe,
    required this.slaAtRisk,
    required this.slaOverdue,
    required this.slaBreached,
  });

  @override
  StatusColors copyWith({
    Color? statusNew,
    Color? statusForwarded,
    Color? statusAssigned,
    Color? statusInProgress,
    Color? statusResolved,
    Color? slaSafe,
    Color? slaAtRisk,
    Color? slaOverdue,
    Color? slaBreached,
  }) {
    return StatusColors(
      statusNew: statusNew ?? this.statusNew,
      statusForwarded: statusForwarded ?? this.statusForwarded,
      statusAssigned: statusAssigned ?? this.statusAssigned,
      statusInProgress: statusInProgress ?? this.statusInProgress,
      statusResolved: statusResolved ?? this.statusResolved,
      slaSafe: slaSafe ?? this.slaSafe,
      slaAtRisk: slaAtRisk ?? this.slaAtRisk,
      slaOverdue: slaOverdue ?? this.slaOverdue,
      slaBreached: slaBreached ?? this.slaBreached,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      statusNew: Color.lerp(statusNew, other.statusNew, t)!,
      statusForwarded: Color.lerp(statusForwarded, other.statusForwarded, t)!,
      statusAssigned: Color.lerp(statusAssigned, other.statusAssigned, t)!,
      statusInProgress: Color.lerp(
        statusInProgress,
        other.statusInProgress,
        t,
      )!,
      statusResolved: Color.lerp(statusResolved, other.statusResolved, t)!,
      slaSafe: Color.lerp(slaSafe, other.slaSafe, t)!,
      slaAtRisk: Color.lerp(slaAtRisk, other.slaAtRisk, t)!,
      slaOverdue: Color.lerp(slaOverdue, other.slaOverdue, t)!,
      slaBreached: Color.lerp(slaBreached, other.slaBreached, t)!,
    );
  }
}
