import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:lumi_kids/app/providers.dart';
import 'package:lumi_kids/features/content_library/data/content_repository.dart';
import 'package:lumi_kids/features/content_library/data/pack_store.dart';
import 'package:lumi_kids/features/content_library/domain/task.dart';
import 'package:lumi_kids/features/content_library/domain/task_parser.dart';
import 'package:lumi_kids/features/profiles/domain/child_profile.dart';
import 'package:lumi_kids/features/progress/domain/progress.dart';
import 'package:lumi_kids/features/settings/domain/app_settings.dart';
import 'package:lumi_kids/features/subscription/domain/entitlement.dart';
import 'package:lumi_kids/features/subscription/domain/subscription_store.dart';

Map<String, Object?> loadStarterPackJson() =>
    jsonDecode(File('assets/content/starter_pack.json').readAsStringSync())
        as Map<String, Object?>;

List<LearningTask> loadStarterTasks() =>
    TaskParser(appVersion: appVersion).parsePack(loadStarterPackJson());

class FileContentRepository implements ContentRepository {
  @override
  Future<LoadedContent> load({String language = 'ru'}) async => LoadedContent(
    tasks: TaskParser(
      appVersion: appVersion,
      language: language,
    ).parsePack(loadStarterPackJson()),
    source: ContentSource(
      downloaded: false,
      version: loadStarterPackJson()['packVersion']! as int,
    ),
  );
}

/// Хранилище пакета в памяти.
class InMemoryPackStore implements PackStore {
  StoredPack? pack;

  @override
  Future<StoredPack?> read() async => pack;

  @override
  Future<void> write(StoredPack pack) async => this.pack = pack;
}

class InMemoryProgressRepository implements ProgressRepository {
  final List<AttemptRecord> attempts = [];

  @override
  Future<void> saveAttempt(AttemptRecord attempt) async =>
      attempts.add(attempt);

  @override
  Future<Map<String, int>> bestStarsByTask(String childId) async {
    final best = <String, int>{};
    for (final a in attempts.where((a) => a.childId == childId)) {
      if ((best[a.taskId] ?? -1) < a.stars) best[a.taskId] = a.stars;
    }
    return best;
  }

  @override
  Future<List<AttemptRecord>> history(String childId, {int limit = 30}) async {
    final mine = attempts.where((a) => a.childId == childId).toList()
      ..sort((a, b) => b.finishedAt.compareTo(a.finishedAt));
    return mine.take(limit).toList();
  }
}

class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository(this.progress, [List<ChildProfile>? initial])
    : profiles = [...?initial],
      activeId = initial?.firstOrNull?.id;

  final InMemoryProgressRepository progress;
  final List<ChildProfile> profiles;
  String? activeId;

  @override
  Future<List<ChildProfile>> loadAll() async => [...profiles];

  @override
  Future<void> save(ChildProfile profile) async {
    final i = profiles.indexWhere((p) => p.id == profile.id);
    if (i >= 0) {
      profiles[i] = profile;
    } else {
      profiles.add(profile);
    }
  }

  @override
  Future<void> delete(String childId) async {
    profiles.removeWhere((p) => p.id == childId);
    progress.attempts.removeWhere((a) => a.childId == childId);
    if (activeId == childId) activeId = null;
  }

  @override
  Future<void> deleteEverything() async {
    profiles.clear();
    progress.attempts.clear();
    activeId = null;
  }

  @override
  Future<String?> activeChildId() async => activeId;

  @override
  Future<void> setActiveChild(String childId) async => activeId = childId;
}

class InMemoryAppSettings implements AppSettingsRepository {
  InMemoryAppSettings([this.chosen]);

  String? chosen;

  @override
  Future<String?> language() async => chosen;

  @override
  Future<void> setLanguage(String language) async => chosen = language;
}

/// Магазин без сети: цены заданы, покупки досылаются через [emit].
class FakeSubscriptionStore implements SubscriptionStore {
  FakeSubscriptionStore({this.available = true});

  final bool available;
  final List<StoreProduct> offered = [
    const StoreProduct(id: 'lumi_premium_monthly', price: '49 000 UZS'),
    const StoreProduct(id: 'lumi_premium_yearly', price: '399 000 UZS'),
  ];
  final _purchases = StreamController<List<StorePurchase>>.broadcast();
  final List<String> bought = [];
  final List<StorePurchase> completed = [];
  int restores = 0;

  /// Что магазин пришлёт после [buy]; null — ничего (окно закрыли).
  StorePurchase Function(String productId)? onBuy;

  void emit(List<StorePurchase> batch) => _purchases.add(batch);

  @override
  StorePlatform? get platform => StorePlatform.android;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<List<StoreProduct>> products(Set<String> ids) async =>
      offered.where((p) => ids.contains(p.id)).toList();

  @override
  Stream<List<StorePurchase>> get purchases => _purchases.stream;

  @override
  Future<void> buy(String productId) async {
    bought.add(productId);
    final purchase = onBuy?.call(productId);
    if (purchase != null) emit([purchase]);
  }

  @override
  Future<void> restore() async => restores++;

  @override
  Future<void> complete(StorePurchase purchase) async =>
      completed.add(purchase);
}

class FakePurchaseVerifier implements PurchaseVerifier {
  FakePurchaseVerifier([this.result]);

  VerificationResult? result;
  final List<(StorePlatform, String, String)> calls = [];

  @override
  Future<VerificationResult> verify({
    required StorePlatform platform,
    required String productId,
    required String token,
  }) async {
    calls.add((platform, productId, token));
    return result ?? const VerificationResult(VerificationStatus.notConfigured);
  }
}

class InMemoryEntitlementRepository implements EntitlementRepository {
  InMemoryEntitlementRepository([this.entitlement]);

  Entitlement? entitlement;

  @override
  Future<Entitlement?> load() async => entitlement;

  @override
  Future<void> save(Entitlement entitlement) async =>
      this.entitlement = entitlement;

  @override
  Future<void> clear() async => entitlement = null;
}
