import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/core/external_links.dart';

void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();

  test('release-сборка может ходить в интернет', () {
    expect(manifest, contains('android.permission.INTERNET'));
  });

  test('рекламный идентификатор убран из сборки', () {
    expect(
      manifest,
      matches(
        RegExp(
          r'com\.google\.android\.gms\.permission\.AD_ID"\s+tools:node="remove"',
        ),
      ),
    );
  });

  test('ссылка на подписки ведёт на наш пакет', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, contains('applicationId = "$androidPackage"'));
  });

  test('ключ подписи не попадает в репозиторий', () {
    final ignore = File('android/.gitignore').readAsStringSync();
    expect(ignore, contains('key.properties'));
    expect(ignore, contains('**/*.jks'));
  });
}
