import test from 'node:test';
import assert from 'node:assert/strict';
import { calculateSlaDueAt, getSlaStatus } from './sla.js';

test('calculateSlaDueAt adds sla_hours correctly', () => {
  const createdAt = new Date('2026-11-12T00:00:00Z');
  const dueAt = calculateSlaDueAt(createdAt, 4);
  assert.equal(dueAt.toISOString(), '2026-11-12T04:00:00.000Z');
});

test('getSlaStatus returns on_track when remaining > 25%', () => {
  const createdAt = '2026-11-12T00:00:00Z';
  const slaDueAt = '2026-11-12T04:00:00Z'; // 4 hours duration
  const now = '2026-11-12T01:00:00Z'; // 3 hours remaining (75% remaining)

  const result = getSlaStatus({ createdAt, slaDueAt, now });
  assert.equal(result.status, 'on_track');
  assert.equal(result.isOverdue, false);
  assert.equal(result.remainingSeconds, 3 * 3600);
});

test('getSlaStatus returns at_risk when remaining <= 25%', () => {
  const createdAt = '2026-11-12T00:00:00Z';
  const slaDueAt = '2026-11-12T04:00:00Z'; // 4 hours duration, 25% = 1 hour
  const now = '2026-11-12T03:30:00Z'; // 30 minutes remaining (12.5% remaining)

  const result = getSlaStatus({ createdAt, slaDueAt, now });
  assert.equal(result.status, 'at_risk');
  assert.equal(result.isOverdue, false);
  assert.equal(result.remainingSeconds, 30 * 60);
});

test('getSlaStatus returns overdue when now > slaDueAt', () => {
  const createdAt = '2026-11-12T00:00:00Z';
  const slaDueAt = '2026-11-12T04:00:00Z';
  const now = '2026-11-12T04:15:00Z'; // 15 mins late

  const result = getSlaStatus({ createdAt, slaDueAt, now });
  assert.equal(result.status, 'overdue');
  assert.equal(result.isOverdue, true);
  assert.equal(result.remainingSeconds, -15 * 60);
});

test('getSlaStatus returns met when resolved_at <= slaDueAt', () => {
  const createdAt = '2026-11-12T00:00:00Z';
  const slaDueAt = '2026-11-12T04:00:00Z';
  const resolvedAt = '2026-11-12T03:55:00Z';

  const result = getSlaStatus({ createdAt, slaDueAt, resolvedAt });
  assert.equal(result.status, 'met');
  assert.equal(result.isOverdue, false);
});

test('getSlaStatus returns breached when resolved_at > slaDueAt', () => {
  const createdAt = '2026-11-12T00:00:00Z';
  const slaDueAt = '2026-11-12T04:00:00Z';
  const resolvedAt = '2026-11-12T05:00:00Z'; // 1 hour after due

  const result = getSlaStatus({ createdAt, slaDueAt, resolvedAt });
  assert.equal(result.status, 'breached');
  assert.equal(result.isOverdue, true);
});
