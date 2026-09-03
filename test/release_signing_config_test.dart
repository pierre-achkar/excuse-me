import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android release signing config invariants', () {
    final androidGitignore = File('android/.gitignore').readAsStringSync();
    final rootGitignore = File('.gitignore').readAsStringSync();

    test('key.properties is ignored and never committed from source', () {
      expect(androidGitignore, contains('key.properties'));
      expect(rootGitignore, contains('key.properties'));
    });

    test('keystore and certificate extensions are ignored', () {
      expect(androidGitignore, contains('*.keystore'));
      expect(androidGitignore, contains('*.jks'));
      expect(androidGitignore, contains('*.p12'));
      expect(androidGitignore, contains('*.cer'));
      expect(androidGitignore, contains('*.crt'));
      expect(androidGitignore, contains('*.pem'));
    });

    test('generated release artifacts are ignored', () {
      expect(androidGitignore, contains('*.apk'));
      expect(androidGitignore, contains('*.aab'));
    });

    test('local.properties (with env/sdk paths) is ignored', () {
      expect(androidGitignore, contains('local.properties'));
    });

    test('a fake placeholders-only key.properties template is provided', () {
      final examplePath = 'android/key.properties.example';
      expect(
        File(examplePath).existsSync(),
        isTrue,
        reason: '$examplePath should exist as the safe template',
      );

      final content = File(examplePath).readAsStringSync();
      // Every value must be a clearly fake placeholder, never a real secret.
      expect(content, contains('CHANGE_ME'), reason: 'must be clearly fake');
      final values = RegExp(
        r'=\s*(\S+)\s*$',
        multiLine: true,
      ).allMatches(content).map((m) => m.group(1)!).toList();
      expect(
        values,
        everyElement(startsWith('CHANGE_ME')),
        reason: 'template values must all be fake CHANGE_ME placeholders',
      );
    });

    test('release build fails closed: gradle requires all signing properties', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();
      // Each property must be read from key.properties.
      for (final key in [
        'storeFile',
        'storePassword',
        'keyAlias',
        'keyPassword',
      ]) {
        expect(
          gradle,
          contains(key),
          reason: 'release build must read signing property: $key',
        );
      }
      // A release signing only applies to the release build type, never debug.
      expect(
        gradle.contains('signingConfig = signingConfigs.getByName("debug")'),
        isFalse,
        reason: 'release must no longer reuse the debug signing config',
      );
      expect(
        gradle,
        contains('extensions.getByType<ApplicationExtension>()'),
        reason: 'the AGP application extension must be captured explicitly',
      );
      expect(
        gradle,
        contains(
          'fun configureReleaseSigning(signingConfig: ApkSigningConfig)',
        ),
        reason: 'the top-level signing helper must receive the explicit release config',
      );
      expect(
        gradle,
        contains('configureReleaseSigning(releaseSigningConfig)'),
        reason:
            'release build must pass the captured release config explicitly',
      );
      expect(
        gradle,
        contains('it.substringAfterLast(\':\').lowercase()'),
        reason: 'release detection must inspect the Gradle task name',
      );
      expect(
        gradle,
        contains('setOf("assemble", "build")'),
        reason: 'aggregate Gradle tasks must also require release signing',
      );
    });

    test('no checked-in Android source embeds a secret value', () {
      final files = [
        'android/app/build.gradle.kts',
        'android/.gitignore',
        'android/key.properties.example',
        'android/gradle.properties',
      ];
      for (final path in files) {
        final content = File(path).readAsStringSync();
        // No base64-encoded keystore blobs or long hex/secret fixtures.
        expect(
          content,
          isNot(contains('MIIC')),
          reason: '$path must not contain a base64-encoded keystore/cert',
        );
        // Release signing reads only property NAMES / expressions into
        // variables. There must be no quoted literal secret value anywhere
        // in source.
        expect(
          RegExp(
            r'(storePassword|keyPassword|password)\s*=\s*"[^"]+"',
            caseSensitive: false,
          ).hasMatch(content),
          isFalse,
          reason: '$path must not assign a literal quoted secret value',
        );
      }
    });
  });

  group('iOS signing boundary invariants', () {
    test('signing material extensions are never committed to source', () {
      final iosGitignore = File('ios/.gitignore').readAsStringSync();
      expect(iosGitignore, contains('TeamID.xcconfig'));
      expect(iosGitignore, contains('*.mobileprovision'));
      expect(iosGitignore, contains('*.p12'));
      expect(iosGitignore, contains('*.cer'));
      expect(iosGitignore, contains('*.pem'));
    });

    test('no team identifier is hardcoded in committed iOS config', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      final pbx = File('ios/Runner.xcodeproj/project.pbxproj')
          .readAsStringSync();
      expect(plist, isNot(contains('DEVELOPMENT_TEAM')));
      expect(
        pbx,
        isNot(contains('DEVELOPMENT_TEAM = ')),
        reason: 'project.pbxproj must not set a concrete team id',
      );
    });

    test('iOS signing helper fails closed and contains no credentials', () {
      final script = File('scripts/ios-sign.sh').readAsStringSync();
      expect(
        script,
        contains(':?'),
        reason: 'helper must fail closed when secrets are unset',
      );
      expect(
        script,
        contains('CHANGE_ME'),
        reason: 'helper must guard against placeholder leakage',
      );
      expect(
        script,
        isNot(contains('MIIC')),
        reason: 'helper must not contain a base64 certificate',
      );
    });

    test('a fake TeamID template exists and the real one is ignored', () {
      final examplePath = 'ios/TeamID.xcconfig.example';
      expect(
        File(examplePath).existsSync(),
        isTrue,
        reason: '$examplePath should exist as the safe template',
      );
      final content = File(examplePath).readAsStringSync();
      expect(content, contains('CHANGE_ME'));
    });
  });
}
