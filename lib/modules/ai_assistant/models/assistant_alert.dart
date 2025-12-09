class AssistantAlert {
  final String id;
  final String title;
  final String? subtitle;
  final String? actionPrompt;

  AssistantAlert({
    required this.id,
    required this.title,
    this.subtitle,
    this.actionPrompt,
  });
}
