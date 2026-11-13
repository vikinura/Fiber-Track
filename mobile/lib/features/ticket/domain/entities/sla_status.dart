enum SlaStatus {
  onTrack('on_track'),
  atRisk('at_risk'),
  overdue('overdue'),
  met('met'),
  breached('breached');

  final String value;
  const SlaStatus(this.value);

  static SlaStatus fromString(String? val) {
    switch (val) {
      case 'on_track':
        return SlaStatus.onTrack;
      case 'at_risk':
        return SlaStatus.atRisk;
      case 'overdue':
        return SlaStatus.overdue;
      case 'met':
        return SlaStatus.met;
      case 'breached':
        return SlaStatus.breached;
      default:
        return SlaStatus.onTrack;
    }
  }

  String get label {
    switch (this) {
      case SlaStatus.onTrack:
        return 'Tepat Waktu';
      case SlaStatus.atRisk:
        return 'Hampir Batas';
      case SlaStatus.overdue:
        return 'Terlambat';
      case SlaStatus.met:
        return 'SLA Terpenuhi';
      case SlaStatus.breached:
        return 'SLA Terlampaui';
    }
  }
}
