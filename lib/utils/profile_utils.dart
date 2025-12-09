import '../models/user_profile.dart';

String generateProfileHtml(UserProfile profile) {
  final buffer = StringBuffer();
  buffer.writeln("<!DOCTYPE html>");
  buffer.writeln("<html>");
  buffer.writeln("<head>");
  buffer.writeln("<meta charset='UTF-8'>");
  buffer.writeln("<title>${profile.displayName} - Profile</title>");
  buffer.writeln("<style>");
  buffer.writeln("""
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; line-height: 1.6; color: #333; }
    .user-profile { background: #fff; border-radius: 8px; padding: 30px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
    h1 { margin: 0 0 8px 0; font-size: 32px; color: #1a1a1a; }
    h2 { margin: 0 0 20px 0; font-size: 18px; color: #666; font-weight: 500; }
    h3 { margin: 30px 0 12px 0; font-size: 20px; color: #1a1a1a; font-weight: 600; }
    p { margin: 0 0 20px 0; color: #444; }
    ul { list-style: none; padding: 0; margin: 0 0 20px 0; }
    li { padding: 8px 0; padding-left: 24px; position: relative; color: #444; }
    li:before { content: '•'; position: absolute; left: 8px; color: #5B7FFF; font-size: 20px; }
    a { color: #5B7FFF; text-decoration: none; }
    a:hover { text-decoration: underline; }
    .last-updated { margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; font-size: 14px; color: #999; }
  """);
  buffer.writeln("</style>");
  buffer.writeln("</head>");
  buffer.writeln("<body>");
  buffer.writeln("<div class='user-profile'>");
  buffer.writeln("<h1>${profile.displayName}</h1>");

  if (profile.headline != null && profile.headline!.isNotEmpty) {
    buffer.writeln("<h2>${profile.headline}</h2>");
  }

  if (profile.aiSummary != null && profile.aiSummary!.isNotEmpty) {
    buffer.writeln("<p>${profile.aiSummary}</p>");
  }

  if (profile.currentFocus.isNotEmpty) {
    buffer.writeln("<h3>Current Focus</h3><ul>");
    for (final f in profile.currentFocus) {
      buffer.writeln("<li>$f</li>");
    }
    buffer.writeln("</ul>");
  }

  if (profile.strengths.isNotEmpty) {
    buffer.writeln("<h3>Strengths & Highlights</h3><ul>");
    for (final s in profile.strengths) {
      buffer.writeln("<li>$s</li>");
    }
    buffer.writeln("</ul>");
  }

  if (profile.docs.isNotEmpty) {
    buffer.writeln("<h3>Docs & Links</h3><ul>");
    for (final d in profile.docs) {
      buffer.writeln(
          "<li><a href='${d.urlOrPath}' target='_blank'>${d.title}</a>");
      if (d.description != null && d.description!.isNotEmpty) {
        buffer.writeln(" - ${d.description}");
      }
      buffer.writeln("</li>");
    }
    buffer.writeln("</ul>");
  }

  buffer.writeln(
      "<div class='last-updated'>Last updated: ${_formatDate(profile.lastUpdated)}</div>");
  buffer.writeln("</div>");
  buffer.writeln("</body>");
  buffer.writeln("</html>");

  return buffer.toString();
}

String _formatDate(DateTime date) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// Applies chat transcript to update profile (placeholder for AI logic)
UserProfile applyChatToProfile(UserProfile current, String chatTranscript) {
  // In future, this uses AI to extract facts.
  // For now, just simulate an update based on mock analysis.

  final updatedStrengths = List<String>.from(current.strengths)
    ..add(
        "Discussed fundraising strategy and product-market fit in recent chat");

  final focusString = current.currentFocus.join(", ").toLowerCase();
  final updatedSummary =
      "${current.displayName} is an experienced founder focused on ${focusString}. "
      "Based on recent conversations, they are actively working on refining their pitch, "
      "building relationships with potential investors, and onboarding pilot customers. "
      "They have demonstrated strong product thinking and a clear vision for their AI-powered solution.";

  return current.copyWith(
    strengths: updatedStrengths,
    aiSummary: updatedSummary,
    lastUpdated: DateTime.now(),
  );
}
