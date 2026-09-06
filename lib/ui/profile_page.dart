import 'package:flutter/material.dart';

import '../domain/user_profile.dart';
import '../services/idea_client.dart';
import '../services/user_profile_repository.dart';
import 'excuse_card.dart';
import 'shop_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.repository,
    this.cards = const [],
    this.onSaved,
    this.onViewCollection,
  });

  final UserProfileRepository repository;
  final List<GeneratedIdea> cards;
  final ValueChanged<UserProfile>? onSaved;
  final VoidCallback? onViewCollection;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile _draft = const UserProfile.empty();
  bool _loading = true;
  bool _saving = false;
  bool _saved = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await widget.repository.load();
      if (!mounted) return;
      setState(() {
        _draft = profile;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  void _update(UserProfile profile) {
    setState(() {
      _draft = profile;
      _saved = false;
      _error = null;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _saved = false;
      _error = null;
    });
    final submitted = _draft;
    try {
      await widget.repository.save(submitted);
      widget.onSaved?.call(submitted);
      if (!mounted) return;
      setState(() => _saved = _draft == submitted);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clear() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _saved = false;
      _error = null;
    });
    final submitted = const UserProfile.empty();
    final draftAtSubmit = _draft;
    try {
      await widget.repository.clear();
      widget.onSaved?.call(submitted);
      if (!mounted) return;
      setState(() {
        if (_draft == draftAtSubmit) _draft = submitted;
        _saved = _draft == submitted;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ShopTheme.theme,
      child: Scaffold(
        backgroundColor: const Color(0xFF241B30),
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              key: const ValueKey('profile-retry-load'),
              tooltip: 'Retry loading profile',
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null && _draft.isEmpty
            ? _buildLoadError()
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                children: [
                  const Text(
                    'OPTIONAL PROFILE',
                    style: TextStyle(
                      color: ShopTheme.pixelGlow,
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'A few broad details can help Excusee sort the shelves.\nLeave anything blank. Nothing here proves what happened today.',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: ShopTheme.paperBody, height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  _choiceField<ProfileAgeRange>(
                    keyPrefix: 'profile-age',
                    title: 'Age range',
                    value: _draft.ageRange,
                    values: ProfileAgeRange.values,
                    labelFor: _ageLabel,
                    onChanged: (value) =>
                        _update(_draft.copyWith(ageRange: value)),
                  ),
                  _choiceField<ProfileWorkStudyStatus>(
                    keyPrefix: 'profile-work-study',
                    title: 'Work / study status',
                    value: _draft.workStudyStatus,
                    values: ProfileWorkStudyStatus.values,
                    labelFor: _workLabel,
                    onChanged: (value) =>
                        _update(_draft.copyWith(workStudyStatus: value)),
                  ),
                  _choiceField<ProfileOccupationCategory>(
                    keyPrefix: 'profile-occupation',
                    title: 'Occupation category',
                    value: _draft.occupationCategory,
                    values: ProfileOccupationCategory.values,
                    labelFor: _occupationLabel,
                    onChanged: (value) =>
                        _update(_draft.copyWith(occupationCategory: value)),
                  ),
                  _choiceField<ProfileYesNo>(
                    keyPrefix: 'profile-children',
                    title: 'Has children',
                    value: _draft.hasChildren,
                    values: ProfileYesNo.values,
                    labelFor: _yesNoLabel,
                    onChanged: (value) =>
                        _update(_draft.copyWith(hasChildren: value)),
                  ),
                  _choiceField<ProfileYesNo>(
                    keyPrefix: 'profile-caregiving',
                    title: 'Other caregiving responsibilities',
                    value: _draft.caregiving,
                    values: ProfileYesNo.values,
                    labelFor: _yesNoLabel,
                    onChanged: (value) =>
                        _update(_draft.copyWith(caregiving: value)),
                  ),
                  _choiceField<ProfileRelationshipStatus>(
                    keyPrefix: 'profile-relationship',
                    title: 'Relationship status',
                    value: _draft.relationshipStatus,
                    values: ProfileRelationshipStatus.values,
                    labelFor: _relationshipLabel,
                    onChanged: (value) =>
                        _update(_draft.copyWith(relationshipStatus: value)),
                  ),
                  const SizedBox(height: 10),
                  if (_error != null)
                    Card(
                      color: const Color(0xFF5B2936),
                      child: ListTile(
                        leading: const Icon(
                          Icons.error_outline,
                          color: ShopTheme.paperBody,
                        ),
                        title: const Text(
                          'Profile was not saved. Try again.',
                          style: TextStyle(color: ShopTheme.paperBody),
                        ),
                        trailing: TextButton(
                          key: const ValueKey('profile-retry-save'),
                          onPressed: _saving ? null : _save,
                          child: const Text('RETRY'),
                        ),
                      ),
                    ),
                  if (_saved)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        'PROFILE SAVED ON THIS DEVICE',
                        key: ValueKey('profile-saved'),
                        style: TextStyle(
                          color: ShopTheme.pixelGlow,
                          fontFamily: 'PressStart2P',
                          fontSize: 9,
                        ),
                      ),
                    ),
                  FilledButton(
                    key: const ValueKey('profile-save'),
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'SAVING…' : 'SAVE PROFILE'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    key: const ValueKey('profile-clear'),
                    onPressed: _saving ? null : _clear,
                    child: const Text('CLEAR PROFILE'),
                  ),
                  const SizedBox(height: 28),
                  _buildCollectionPreview(context),
                ],
              ),
      ),
    );
  }

  Widget _buildLoadError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 44, color: ShopTheme.pixelGlow),
          const SizedBox(height: 16),
          const Text(
            'Could not load your profile.',
            style: TextStyle(color: ShopTheme.paperBody, fontSize: 20),
          ),
          const SizedBox(height: 14),
          FilledButton(
            key: const ValueKey('profile-retry-load-body'),
            onPressed: _load,
            child: const Text('RETRY'),
          ),
        ],
      ),
    ),
  );

  Widget _buildCollectionPreview(BuildContext context) {
    final preview = widget.cards.take(3).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'YOUR COLLECTION',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: ShopTheme.pixelGlow,
                fontFamily: 'PressStart2P',
                fontSize: 9,
              ),
            ),
            TextButton(
              key: const ValueKey('profile-view-collection'),
              onPressed: widget.onViewCollection,
              child: const Text('VIEW COLLECTION'),
            ),
          ],
        ),
        if (preview.isEmpty)
          const Text(
            'No cards yet. Keep one from the shop and it will appear here.',
            style: TextStyle(color: ShopTheme.paperBody, height: 1.4),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: preview.length,
              itemBuilder: (context, index) {
                final card = preview[index];
                return Semantics(
                  label:
                      'Collection preview: ${card.playfulName ?? "Your card"}',
                  child: SizedBox(
                    width: 112,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: ExcuseCard(idea: card),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _choiceField<T extends Enum>({
    required String keyPrefix,
    required String title,
    required T? value,
    required List<T> values,
    required String Function(T value) labelFor,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ShopTheme.paperBody,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                key: ValueKey('$keyPrefix-not-answered'),
                label: const Text('Not answered'),
                selected: value == null,
                onSelected: (_) => onChanged(null),
              ),
              ...values.map(
                (option) => ChoiceChip(
                  key: ValueKey('$keyPrefix-${option.name}'),
                  label: Text(labelFor(option)),
                  selected: value == option,
                  onSelected: (_) => onChanged(option),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _ageLabel(ProfileAgeRange value) => switch (value) {
    ProfileAgeRange.under18 => 'Under 18',
    ProfileAgeRange.age18To24 => '18–24',
    ProfileAgeRange.age25To34 => '25–34',
    ProfileAgeRange.age35To44 => '35–44',
    ProfileAgeRange.age45To54 => '45–54',
    ProfileAgeRange.age55Plus => '55+',
    ProfileAgeRange.preferNotToSay => 'Prefer not to say',
  };

  String _workLabel(ProfileWorkStudyStatus value) => switch (value) {
    ProfileWorkStudyStatus.working => 'Working',
    ProfileWorkStudyStatus.studying => 'Studying',
    ProfileWorkStudyStatus.both => 'Both',
    ProfileWorkStudyStatus.neither => 'Neither',
    ProfileWorkStudyStatus.preferNotToSay => 'Prefer not to say',
  };

  String _occupationLabel(ProfileOccupationCategory value) => switch (value) {
    ProfileOccupationCategory.healthcare => 'Healthcare',
    ProfileOccupationCategory.education => 'Education',
    ProfileOccupationCategory.office => 'Office',
    ProfileOccupationCategory.serviceHospitality => 'Service / hospitality',
    ProfileOccupationCategory.creative => 'Creative',
    ProfileOccupationCategory.technical => 'Technical',
    ProfileOccupationCategory.trades => 'Trades',
    ProfileOccupationCategory.selfEmployed => 'Self-employed',
    ProfileOccupationCategory.retired => 'Retired',
    ProfileOccupationCategory.other => 'Other',
    ProfileOccupationCategory.preferNotToSay => 'Prefer not to say',
  };

  String _yesNoLabel(ProfileYesNo value) => switch (value) {
    ProfileYesNo.yes => 'Yes',
    ProfileYesNo.no => 'No',
    ProfileYesNo.preferNotToSay => 'Prefer not to say',
  };

  String _relationshipLabel(ProfileRelationshipStatus value) => switch (value) {
    ProfileRelationshipStatus.single => 'Single',
    ProfileRelationshipStatus.inRelationship => 'In a relationship',
    ProfileRelationshipStatus.married => 'Married',
    ProfileRelationshipStatus.preferNotToSay => 'Prefer not to say',
  };
}
