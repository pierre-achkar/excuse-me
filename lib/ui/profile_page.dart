import 'package:flutter/material.dart';

import '../domain/user_profile.dart';
import '../services/idea_client.dart';
import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Theme(
      data: ShopTheme.theme,
      child: Scaffold(
        backgroundColor: const Color(0xFF241B30),
        appBar: AppBar(
          title: Text(l10n.profileTitle),
          actions: [
            IconButton(
              key: const ValueKey('profile-retry-load'),
              tooltip: l10n.profileRetryTooltip,
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null && _draft.isEmpty
            ? _buildLoadError(l10n)
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                children: [
                  Text(
                    l10n.profileHeading,
                    style: const TextStyle(
                      color: ShopTheme.pixelGlow,
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.profileNote,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: ShopTheme.paperBody, height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  _choiceFieldFor<ProfileAgeRange>(
                    l10n: l10n,
                    keyPrefix: 'profile-age',
                    title: l10n.profileAgeTitle,
                    value: _draft.ageRange,
                    values: ProfileAgeRange.values,
                    labelFor: (value) => _ageLabel(l10n, value),
                    onChanged: (value) =>
                        _update(_draft.copyWith(ageRange: value)),
                  ),
                  _choiceFieldFor<ProfileWorkStudyStatus>(
                    l10n: l10n,
                    keyPrefix: 'profile-work-study',
                    title: l10n.profileWorkStudyTitle,
                    value: _draft.workStudyStatus,
                    values: ProfileWorkStudyStatus.values,
                    labelFor: (value) => _workLabel(l10n, value),
                    onChanged: (value) =>
                        _update(_draft.copyWith(workStudyStatus: value)),
                  ),
                  _choiceFieldFor<ProfileOccupationCategory>(
                    l10n: l10n,
                    keyPrefix: 'profile-occupation',
                    title: l10n.profileOccupationTitle,
                    value: _draft.occupationCategory,
                    values: ProfileOccupationCategory.values,
                    labelFor: (value) => _occupationLabel(l10n, value),
                    onChanged: (value) =>
                        _update(_draft.copyWith(occupationCategory: value)),
                  ),
                  _choiceFieldFor<ProfileYesNo>(
                    l10n: l10n,
                    keyPrefix: 'profile-children',
                    title: l10n.profileChildrenTitle,
                    value: _draft.hasChildren,
                    values: ProfileYesNo.values,
                    labelFor: (value) => _yesNoLabel(l10n, value),
                    onChanged: (value) =>
                        _update(_draft.copyWith(hasChildren: value)),
                  ),
                  _choiceFieldFor<ProfileYesNo>(
                    l10n: l10n,
                    keyPrefix: 'profile-caregiving',
                    title: l10n.profileCaregivingTitle,
                    value: _draft.caregiving,
                    values: ProfileYesNo.values,
                    labelFor: (value) => _yesNoLabel(l10n, value),
                    onChanged: (value) =>
                        _update(_draft.copyWith(caregiving: value)),
                  ),
                  _choiceFieldFor<ProfileRelationshipStatus>(
                    l10n: l10n,
                    keyPrefix: 'profile-relationship',
                    title: l10n.profileRelationshipTitle,
                    value: _draft.relationshipStatus,
                    values: ProfileRelationshipStatus.values,
                    labelFor: (value) => _relationshipLabel(l10n, value),
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
                        title: Text(
                          l10n.profileSaveError,
                          style: const TextStyle(color: ShopTheme.paperBody),
                        ),
                        trailing: TextButton(
                          key: const ValueKey('profile-retry-save'),
                          onPressed: _saving ? null : _save,
                          child: Text(l10n.retryAction),
                        ),
                      ),
                    ),
                  if (_saved)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        l10n.profileSaved,
                        key: const ValueKey('profile-saved'),
                        style: const TextStyle(
                          color: ShopTheme.pixelGlow,
                          fontFamily: 'PressStart2P',
                          fontSize: 9,
                        ),
                      ),
                    ),
                  FilledButton(
                    key: const ValueKey('profile-save'),
                    onPressed: _saving ? null : _save,
                    child: Text(
                      _saving ? l10n.profileSaving : l10n.profileSaveAction,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    key: const ValueKey('profile-clear'),
                    onPressed: _saving ? null : _clear,
                    child: Text(l10n.profileClearAction),
                  ),
                  const SizedBox(height: 28),
                  _buildCollectionPreview(context, l10n),
                ],
              ),
      ),
    );
  }

  Widget _buildLoadError(AppLocalizations l10n) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 44, color: ShopTheme.pixelGlow),
          const SizedBox(height: 16),
          Text(
            l10n.profileLoadError,
            style: const TextStyle(color: ShopTheme.paperBody, fontSize: 20),
          ),
          const SizedBox(height: 14),
          FilledButton(
            key: const ValueKey('profile-retry-load-body'),
            onPressed: _load,
            child: Text(l10n.retryAction),
          ),
        ],
      ),
    ),
  );

  Widget _buildCollectionPreview(BuildContext context, AppLocalizations l10n) {
    final preview = widget.cards.take(3).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.profileCollectionHeading,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: ShopTheme.pixelGlow,
                fontFamily: 'PressStart2P',
                fontSize: 9,
              ),
            ),
            TextButton(
              key: const ValueKey('profile-view-collection'),
              onPressed: widget.onViewCollection,
              child: Text(l10n.profileViewCollection),
            ),
          ],
        ),
        if (preview.isEmpty)
          Text(
            l10n.profileNoCards,
            style: const TextStyle(color: ShopTheme.paperBody, height: 1.4),
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
                  label: l10n.profileCardPreviewSemantics(
                    card.playfulName ?? l10n.cardViewerRevealTitle,
                  ),
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

  Widget _choiceFieldFor<T extends Enum>({
    required AppLocalizations l10n,
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
                label: Text(l10n.profileNotAnswered),
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

  String _ageLabel(AppLocalizations l10n, ProfileAgeRange value) =>
      switch (value) {
        ProfileAgeRange.under18 => l10n.profileAgeUnder18,
        ProfileAgeRange.age18To24 => l10n.profileAge18To24,
        ProfileAgeRange.age25To34 => l10n.profileAge25To34,
        ProfileAgeRange.age35To44 => l10n.profileAge35To44,
        ProfileAgeRange.age45To54 => l10n.profileAge45To54,
        ProfileAgeRange.age55Plus => l10n.profileAge55Plus,
        ProfileAgeRange.preferNotToSay => l10n.profilePreferNotToSay,
      };

  String _workLabel(AppLocalizations l10n, ProfileWorkStudyStatus value) =>
      switch (value) {
        ProfileWorkStudyStatus.working => l10n.profileWorking,
        ProfileWorkStudyStatus.studying => l10n.profileStudying,
        ProfileWorkStudyStatus.both => l10n.profileBoth,
        ProfileWorkStudyStatus.neither => l10n.profileNeither,
        ProfileWorkStudyStatus.preferNotToSay => l10n.profilePreferNotToSay,
      };

  String _occupationLabel(
    AppLocalizations l10n,
    ProfileOccupationCategory value,
  ) => switch (value) {
    ProfileOccupationCategory.healthcare => l10n.profileOccupationHealthcare,
    ProfileOccupationCategory.education => l10n.profileOccupationEducation,
    ProfileOccupationCategory.office => l10n.profileOccupationOffice,
    ProfileOccupationCategory.serviceHospitality =>
      l10n.profileOccupationService,
    ProfileOccupationCategory.creative => l10n.profileOccupationCreative,
    ProfileOccupationCategory.technical => l10n.profileOccupationTechnical,
    ProfileOccupationCategory.trades => l10n.profileOccupationTrades,
    ProfileOccupationCategory.selfEmployed =>
      l10n.profileOccupationSelfEmployed,
    ProfileOccupationCategory.retired => l10n.profileOccupationRetired,
    ProfileOccupationCategory.other => l10n.profileOccupationOther,
    ProfileOccupationCategory.preferNotToSay => l10n.profilePreferNotToSay,
  };

  String _yesNoLabel(AppLocalizations l10n, ProfileYesNo value) =>
      switch (value) {
        ProfileYesNo.yes => l10n.profileYes,
        ProfileYesNo.no => l10n.profileNo,
        ProfileYesNo.preferNotToSay => l10n.profilePreferNotToSay,
      };

  String _relationshipLabel(
    AppLocalizations l10n,
    ProfileRelationshipStatus value,
  ) => switch (value) {
    ProfileRelationshipStatus.single => l10n.profileSingle,
    ProfileRelationshipStatus.inRelationship => l10n.profileInRelationship,
    ProfileRelationshipStatus.married => l10n.profileMarried,
    ProfileRelationshipStatus.preferNotToSay => l10n.profilePreferNotToSay,
  };
}
