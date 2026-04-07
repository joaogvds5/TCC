class Event {
  final String titleEvent;
  final String descriptionEvent;
  final String dateEvent;
  final String hourEvent;
  final String interestEventId;
  final String placeEventId;
  final String creatorEventId;
  final String photoEventUrl;

  Event({
    required this.titleEvent,
    required this.descriptionEvent,
    required this.dateEvent,
    required this.hourEvent,
    required this.interestEventId,
    required this.placeEventId,
    required this.creatorEventId,
    required this.photoEventUrl,
  });

  void createEvent() {
    // Lógica para criar um evento
  }

  void editEvent() {
    // Lógica para editar um evento
  }

  void deleteEvent() {
    // Lógica para excluir um evento
  }
}
