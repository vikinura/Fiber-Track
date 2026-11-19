import 'package:fibertrack/features/ticket/domain/entities/sla_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SlaStatus Tests', () {
    test('fromString should map raw strings to correct enum', () {
      expect(SlaStatus.fromString('on_track'), SlaStatus.onTrack);
      expect(SlaStatus.fromString('at_risk'), SlaStatus.atRisk);
      expect(SlaStatus.fromString('overdue'), SlaStatus.overdue);
      expect(SlaStatus.fromString('met'), SlaStatus.met);
      expect(SlaStatus.fromString('breached'), SlaStatus.breached);
      expect(SlaStatus.fromString('unknown_val'), SlaStatus.onTrack);
      expect(SlaStatus.fromString(null), SlaStatus.onTrack);
    });

    test('label should return human readable Indonesian labels', () {
      expect(SlaStatus.onTrack.label, 'Tepat Waktu');
      expect(SlaStatus.atRisk.label, 'Hampir Batas');
      expect(SlaStatus.overdue.label, 'Terlambat');
      expect(SlaStatus.met.label, 'SLA Terpenuhi');
      expect(SlaStatus.breached.label, 'SLA Terlampaui');
    });

    test('value should match database strings', () {
      expect(SlaStatus.onTrack.value, 'on_track');
      expect(SlaStatus.atRisk.value, 'at_risk');
      expect(SlaStatus.overdue.value, 'overdue');
      expect(SlaStatus.met.value, 'met');
      expect(SlaStatus.breached.value, 'breached');
    });
  });
}
