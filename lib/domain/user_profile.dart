/// Broad, optional profile facts. `null` means not answered.
enum ProfileAgeRange {
  under18,
  age18To24,
  age25To34,
  age35To44,
  age45To54,
  age55Plus,
  preferNotToSay,
}

enum ProfileWorkStudyStatus { working, studying, both, neither, preferNotToSay }

enum ProfileOccupationCategory {
  healthcare,
  education,
  office,
  serviceHospitality,
  creative,
  technical,
  trades,
  selfEmployed,
  retired,
  other,
  preferNotToSay,
}

enum ProfileYesNo { yes, no, preferNotToSay }

enum ProfileRelationshipStatus {
  single,
  inRelationship,
  married,
  preferNotToSay,
}

/// A current-visit fact is deliberately separate from the saved profile.
enum CurrentVisitResponsibility {
  childcare,
  anotherCaregivingResponsibility,
  existingCommitment,
  needingRest,
}

class CurrentVisitContext {
  const CurrentVisitContext({this.responsibility});

  const CurrentVisitContext.skip() : responsibility = null;

  final CurrentVisitResponsibility? responsibility;

  bool get isConfirmed => responsibility != null;
}

/// Optional local facts used only as a relevance signal.
///
/// This model never stores situation text, names, employer details, or current
/// events. Null and every `preferNotToSay` value are unknown to the engine.
class UserProfile {
  const UserProfile({
    this.ageRange,
    this.workStudyStatus,
    this.occupationCategory,
    this.hasChildren,
    this.caregiving,
    this.relationshipStatus,
  });

  const UserProfile.empty()
    : ageRange = null,
      workStudyStatus = null,
      occupationCategory = null,
      hasChildren = null,
      caregiving = null,
      relationshipStatus = null;

  static const storageVersion = 1;
  static const Object _notProvided = Object();

  final ProfileAgeRange? ageRange;
  final ProfileWorkStudyStatus? workStudyStatus;
  final ProfileOccupationCategory? occupationCategory;
  final ProfileYesNo? hasChildren;
  final ProfileYesNo? caregiving;
  final ProfileRelationshipStatus? relationshipStatus;

  bool get isEmpty =>
      !hasKnownFacts &&
      ageRange == null &&
      workStudyStatus == null &&
      occupationCategory == null &&
      hasChildren == null &&
      caregiving == null &&
      relationshipStatus == null;

  bool get hasKnownFacts =>
      ageRangeIsKnown ||
      workStudyStatusIsKnown ||
      occupationCategoryIsKnown ||
      hasChildrenIsKnown ||
      caregivingIsKnown ||
      relationshipStatusIsKnown;

  bool get ageRangeIsKnown =>
      ageRange != null && ageRange != ProfileAgeRange.preferNotToSay;
  bool get workStudyStatusIsKnown =>
      workStudyStatus != null &&
      workStudyStatus != ProfileWorkStudyStatus.preferNotToSay;
  bool get occupationCategoryIsKnown =>
      occupationCategory != null &&
      occupationCategory != ProfileOccupationCategory.preferNotToSay;
  bool get hasChildrenIsKnown =>
      hasChildren != null && hasChildren != ProfileYesNo.preferNotToSay;
  bool get caregivingIsKnown =>
      caregiving != null && caregiving != ProfileYesNo.preferNotToSay;
  bool get relationshipStatusIsKnown =>
      relationshipStatus != null &&
      relationshipStatus != ProfileRelationshipStatus.preferNotToSay;

  /// Only facts that currently have an explicit engine interpretation are
  /// included. Unknown and unused profile fields do not affect selection.
  String get relevanceKey => [
    if (workStudyStatusIsKnown) 'work:$workStudyStatus',
    if (hasChildrenIsKnown) 'children:$hasChildren',
    if (caregivingIsKnown) 'caregiving:$caregiving',
  ].join('|');

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'version': storageVersion};
    void add(String key, Enum? value) {
      if (value != null) data[key] = value.name;
    }

    add('ageRange', ageRange);
    add('workStudyStatus', workStudyStatus);
    add('occupationCategory', occupationCategory);
    add('hasChildren', hasChildren);
    add('caregiving', caregiving);
    add('relationshipStatus', relationshipStatus);
    return data;
  }

  factory UserProfile.fromJson(Map<String, dynamic> data) {
    final version = data['version'];
    if (version != storageVersion) {
      throw FormatException('Unsupported profile version: $version');
    }

    T? read<T extends Enum>(String key, List<T> values) {
      final raw = data[key];
      if (raw == null) return null;
      if (raw is! String) {
        throw FormatException('Profile field $key must be a string');
      }
      for (final value in values) {
        if (value.name == raw) return value;
      }
      throw FormatException('Unknown profile value for $key: $raw');
    }

    return UserProfile(
      ageRange: read('ageRange', ProfileAgeRange.values),
      workStudyStatus: read('workStudyStatus', ProfileWorkStudyStatus.values),
      occupationCategory: read(
        'occupationCategory',
        ProfileOccupationCategory.values,
      ),
      hasChildren: read('hasChildren', ProfileYesNo.values),
      caregiving: read('caregiving', ProfileYesNo.values),
      relationshipStatus: read(
        'relationshipStatus',
        ProfileRelationshipStatus.values,
      ),
    );
  }

  UserProfile copyWith({
    Object? ageRange = _notProvided,
    Object? workStudyStatus = _notProvided,
    Object? occupationCategory = _notProvided,
    Object? hasChildren = _notProvided,
    Object? caregiving = _notProvided,
    Object? relationshipStatus = _notProvided,
  }) {
    return UserProfile(
      ageRange: identical(ageRange, _notProvided)
          ? this.ageRange
          : ageRange as ProfileAgeRange?,
      workStudyStatus: identical(workStudyStatus, _notProvided)
          ? this.workStudyStatus
          : workStudyStatus as ProfileWorkStudyStatus?,
      occupationCategory: identical(occupationCategory, _notProvided)
          ? this.occupationCategory
          : occupationCategory as ProfileOccupationCategory?,
      hasChildren: identical(hasChildren, _notProvided)
          ? this.hasChildren
          : hasChildren as ProfileYesNo?,
      caregiving: identical(caregiving, _notProvided)
          ? this.caregiving
          : caregiving as ProfileYesNo?,
      relationshipStatus: identical(relationshipStatus, _notProvided)
          ? this.relationshipStatus
          : relationshipStatus as ProfileRelationshipStatus?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.ageRange == ageRange &&
      other.workStudyStatus == workStudyStatus &&
      other.occupationCategory == occupationCategory &&
      other.hasChildren == hasChildren &&
      other.caregiving == caregiving &&
      other.relationshipStatus == relationshipStatus;

  @override
  int get hashCode => Object.hash(
    ageRange,
    workStudyStatus,
    occupationCategory,
    hasChildren,
    caregiving,
    relationshipStatus,
  );
}
