import 'idea_safety_policy.dart';

class IdeaGuardrails {
  static bool isSafeIdea(String value) => IdeaSafetyPolicy.isSafeIdea(value);
}
