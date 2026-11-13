/**
 * Fiber Track - SLA Utility
 *
 * Rules from CONTEXT.md section 13:
 * - sla_due_at = created_at + sla_hours
 * - On unresolved tickets (resolved_at is null or status !== 'resolved'):
 *   - overdue: now > sla_due_at
 *   - at_risk: remaining time <= 25% of total SLA duration
 *   - on_track: remaining time > 25% of total SLA duration
 * - On resolved tickets (resolved_at is set):
 *   - met: resolved_at <= sla_due_at
 *   - breached: resolved_at > sla_due_at
 */

export function calculateSlaDueAt(createdAt, slaHours) {
  const createdDate = new Date(createdAt);
  const dueAt = new Date(createdDate.getTime() + slaHours * 60 * 60 * 1000);
  return dueAt;
}

export function getSlaStatus({ createdAt, slaDueAt, resolvedAt = null, now = new Date() }) {
  const createdTime = new Date(createdAt).getTime();
  const dueTime = new Date(slaDueAt).getTime();
  const totalDuration = dueTime - createdTime;

  // If ticket is resolved
  if (resolvedAt) {
    const resolvedTime = new Date(resolvedAt).getTime();
    if (resolvedTime <= dueTime) {
      return {
        status: 'met',
        remainingSeconds: 0,
        isOverdue: false,
      };
    }
    return {
      status: 'breached',
      remainingSeconds: Math.floor((dueTime - resolvedTime) / 1000), // negative indicates breached duration
      isOverdue: true,
    };
  }

  // If ticket is active/unresolved
  const currentTime = new Date(now).getTime();
  const remainingMs = dueTime - currentTime;
  const remainingSeconds = Math.floor(remainingMs / 1000);

  if (currentTime > dueTime) {
    return {
      status: 'overdue',
      remainingSeconds,
      isOverdue: true,
    };
  }

  // 25% threshold
  const threshold25Percent = totalDuration * 0.25;

  if (remainingMs <= threshold25Percent) {
    return {
      status: 'at_risk',
      remainingSeconds,
      isOverdue: false,
    };
  }

  return {
    status: 'on_track',
    remainingSeconds,
    isOverdue: false,
  };
}
