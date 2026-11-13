enum TicketStatus {
  newStatus('new'),
  forwarded('forwarded'),
  assigned('assigned'),
  inProgress('in_progress'),
  resolved('resolved');

  final String value;
  const TicketStatus(this.value);

  static TicketStatus fromString(String? val) {
    switch (val) {
      case 'new':
        return TicketStatus.newStatus;
      case 'forwarded':
        return TicketStatus.forwarded;
      case 'assigned':
        return TicketStatus.assigned;
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'resolved':
        return TicketStatus.resolved;
      default:
        return TicketStatus.newStatus;
    }
  }

  String get label {
    switch (this) {
      case TicketStatus.newStatus:
        return 'Baru';
      case TicketStatus.forwarded:
        return 'Diteruskan';
      case TicketStatus.assigned:
        return 'Ditugaskan';
      case TicketStatus.inProgress:
        return 'Dikerjakan';
      case TicketStatus.resolved:
        return 'Selesai';
    }
  }
}
