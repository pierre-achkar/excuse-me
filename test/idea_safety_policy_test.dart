import 'package:excuse_me/services/idea_safety_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('policy distinguishes safety guidance from a prohibited claim', () {
    expect(
      IdeaSafetyPolicy.isSafeIdea(
        'Idea: Keep it low-detail without inventing an emergency.',
      ),
      isTrue,
    );
    expect(
      IdeaSafetyPolicy.isSafeIdea(
        'Idea: Use a hospital emergency as the reason.',
      ),
      isFalse,
    );
    expect(
      IdeaSafetyPolicy.isSafeIdea(
        'Idea: Say a relative passed away and you must travel.',
      ),
      isFalse,
    );
    expect(
      IdeaSafetyPolicy.isSafeIdea(
        'Idea: Invent a police report about a stolen laptop.',
      ),
      isFalse,
    );
    expect(
      IdeaSafetyPolicy.isSafeIdea(
        'Idea: Use a hospital-sounding emergency and end with thanks and regards.',
      ),
      isFalse,
    );
    expect(
      IdeaSafetyPolicy.isSafeIdea(
        'Idea: Sorry, cannot attend tonight. Please reschedule.',
      ),
      isFalse,
    );
  });
}
