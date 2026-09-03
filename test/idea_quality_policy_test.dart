import 'package:excuse_me/services/idea_quality_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('policy distinguishes generic placeholders from specific ideas', () {
    expect(
      IdeaQualityPolicy.isGeneric('Idea: Say that something came up.'),
      isTrue,
    );
    expect(
      IdeaQualityPolicy.isGeneric(
        'Idea: Say something vague about the impact.',
      ),
      isTrue,
    );
    expect(
      IdeaQualityPolicy.isGeneric(
        'Idea: Use a scheduling conflict and offer a realistic alternative.',
      ),
      isFalse,
    );
  });
}
