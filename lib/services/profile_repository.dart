import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class ProfileRepository extends ChangeNotifier {
  UserProfile _profile = UserProfile(
    userId: "demo-user",
    displayName: "John Davidson",
    headline: "AI founder building tools for B2B networking",
    aiSummary:
        "John is an experienced entrepreneur focused on leveraging AI to transform professional networking. "
        "He has over 10 years of experience in product development and engineering, with a track record of building successful SaaS products. "
        "Currently working on an AI-powered networking assistant that helps founders connect with the right investors and partners.",
    currentFocus: [
      "Raising pre-seed round (\$500K-\$1M)",
      "Looking for 10-15 pilot partners in B2B SaaS",
      "Building MVP with early beta users",
    ],
    strengths: [
      "Built TrackSense.ai - acquired in 2022",
      "10+ years in product & engineering",
      "Strong network in AI/ML community",
      "Experience scaling products 0→1M users",
    ],
    docs: [
      ProfileDoc(
        id: 'doc_1',
        title: 'Pitch Deck v2.1',
        type: 'pdf',
        urlOrPath: 'https://example.com/pitch-deck.pdf',
        description: 'Latest pitch deck with traction metrics',
      ),
      ProfileDoc(
        id: 'doc_2',
        title: 'Product Demo Video',
        type: 'link',
        urlOrPath: 'https://youtube.com/watch?v=demo',
        description: '3-min product walkthrough',
      ),
    ],
    lastUpdated: DateTime.now(),
  );

  UserProfile getProfile() => _profile;

  void updateProfile(UserProfile updated) {
    _profile = updated;
    notifyListeners();
  }

  void addDoc(ProfileDoc doc) {
    final updatedDocs = List<ProfileDoc>.from(_profile.docs)..add(doc);
    updateProfile(_profile.copyWith(
      docs: updatedDocs,
      lastUpdated: DateTime.now(),
    ));
  }

  void removeDoc(String docId) {
    final updatedDocs = _profile.docs.where((d) => d.id != docId).toList();
    updateProfile(_profile.copyWith(
      docs: updatedDocs,
      lastUpdated: DateTime.now(),
    ));
  }
}
