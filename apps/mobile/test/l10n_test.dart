import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/app/providers.dart';
import 'package:lumi_kids/features/catalog/domain/development_area.dart';
import 'package:lumi_kids/features/content_library/domain/task_parser.dart';
import 'package:lumi_kids/features/parent_area/domain/parental_gate.dart';
import 'package:lumi_kids/features/parent_area/domain/progress_summary.dart';
import 'package:lumi_kids/features/settings/domain/app_settings.dart';
import 'package:lumi_kids/l10n/l10n.dart';

import 'support/fakes.dart';

Map<String, Object?> arb(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
        as Map<String, Object?>;

void main() {
  test('во всех языках одинаковый набор строк, без пустых', () {
    final keys = arb('ru').keys.where((k) => !k.startsWith('@')).toSet();
    for (final lang in supportedLanguages) {
      final strings = arb(lang)..removeWhere((k, _) => k.startsWith('@'));
      expect(strings.keys.toSet(), keys, reason: lang);
      for (final MapEntry(:key, :value) in strings.entries) {
        expect((value as String).trim(), isNotEmpty, reason: '$lang.$key');
      }
    }
  });

  test('вопрос барьера на каждом языке — словами, без цифр', () async {
    for (final lang in supportedLanguages) {
      final l10n = await AppLocalizations.delegate.load(Locale(lang));
      for (var a = 3; a <= 9; a++) {
        for (var b = 3; b <= 9; b++) {
          expect(
            l10n.gate(GateQuestion(a, b)),
            isNot(matches(RegExp(r'\d'))),
            reason: '$lang $a×$b',
          );
        }
      }
      for (final area in DevelopmentArea.values) {
        expect(l10n.area(area), isNotEmpty);
      }
    }
  });

  test('статусы для родителя — наблюдения, без оценок «отстаёт»', () async {
    const banned = {'ru': 'отста', 'uz': 'orqada', 'en': 'behind'};
    for (final lang in supportedLanguages) {
      final l10n = await AppLocalizations.delegate.load(Locale(lang));
      for (final s in AreaStatus.values) {
        expect(l10n.areaStatus(s).toLowerCase(), isNot(contains(banned[lang])));
      }
    }
  });

  test('выбор языка: выбранный, затем язык телефона, затем русский', () {
    String pick(String? chosen, String device) => effectiveLanguage(
      chosen: chosen,
      deviceLanguage: device,
      supported: supportedLanguages,
    );
    expect(pick('en', 'uz'), 'en');
    expect(pick(null, 'uz'), 'uz');
    expect(pick(null, 'de'), 'ru');
    expect(pick('xx', 'en'), 'en');
  });

  test('тексты заданий на языке приложения, без перевода — на русском', () {
    final pack = loadStarterPackJson();
    final tasks = pack['tasks']! as List;
    final first = tasks.first as Map<String, Object?>;
    final instruction = first['instruction']! as Map<String, Object?>;
    final text = {
      ...(instruction['text']! as Map<String, Object?>),
      'uz': 'Tarjima',
    };
    final withUz = {
      ...first,
      'instruction': {...instruction, 'text': text},
    };
    final parsed = TaskParser(appVersion: appVersion, language: 'uz').parsePack(
      {
        'tasks': [withUz, tasks[1]],
      },
    );
    expect(parsed.first.instruction, 'Tarjima');
    final second = (tasks[1] as Map<String, Object?>)['instruction']!;
    expect(
      parsed[1].instruction,
      ((second as Map<String, Object?>)['text']! as Map<String, Object?>)['ru'],
    );
  });
}
