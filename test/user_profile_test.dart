import 'package:flutter_test/flutter_test.dart';
import 'package:excuse_me/domain/user_profile.dart';

void main() {
  test('empty profile has no known facts and serializes as version 1', () {
    const profile = UserProfile.empty();

    expect(profile.isEmpty, isTrue);
    expect(profile.hasKnownFacts, isFalse);
    expect(profile.toJson(), {'version': 1});
  });

  test('partial profile round-trips without adding absent fields', () {
    const profile = UserProfile(
      ageRange: ProfileAgeRange.age25To34,
      workStudyStatus: ProfileWorkStudyStatus.working,
    );

    final restored = UserProfile.fromJson(profile.toJson());

    expect(restored.ageRange, ProfileAgeRange.age25To34);
    expect(restored.workStudyStatus, ProfileWorkStudyStatus.working);
    expect(restored.occupationCategory, isNull);
    expect(restored.hasChildren, isNull);
    expect(restored.toJson(), profile.toJson());
  });

  test('prefer not to say is preserved but is unknown to the engine', () {
    const profile = UserProfile(
      ageRange: ProfileAgeRange.preferNotToSay,
      workStudyStatus: ProfileWorkStudyStatus.preferNotToSay,
      hasChildren: ProfileYesNo.preferNotToSay,
      caregiving: ProfileYesNo.preferNotToSay,
      relationshipStatus: ProfileRelationshipStatus.preferNotToSay,
    );

    expect(profile.ageRangeIsKnown, isFalse);
    expect(profile.workStudyStatusIsKnown, isFalse);
    expect(profile.hasChildrenIsKnown, isFalse);
    expect(profile.caregivingIsKnown, isFalse);
    expect(profile.relationshipStatusIsKnown, isFalse);
    expect(UserProfile.fromJson(profile.toJson()), profile);
  });

  test('unsupported storage version fails closed', () {
    expect(
      () => UserProfile.fromJson({'version': 99}),
      throwsA(isA<FormatException>()),
    );
  });
}
