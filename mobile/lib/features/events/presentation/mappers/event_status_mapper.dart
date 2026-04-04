class EventStatusMapper {
  static String toDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'LIVE';
      case 'scheduled':
        return 'Soon';
      default:
        return status.toUpperCase();
    }
  }
}