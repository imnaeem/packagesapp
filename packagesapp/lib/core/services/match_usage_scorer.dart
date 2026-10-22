import '../../models/package_model.dart';

enum MatchNetworkScope { all, mySims, single }

enum ValidityPreference { any, daily, weekly, monthly }

class MatchUsageCriteria {
  final MatchNetworkScope scope;
  final String? singleNetworkId;
  final double minDataMb;
  final int minSms;
  final int minTotalMinutes;
  final ValidityPreference validity;

  const MatchUsageCriteria({
    required this.scope,
    this.singleNetworkId,
    this.minDataMb = 0,
    this.minSms = 0,
    this.minTotalMinutes = 0,
    this.validity = ValidityPreference.any,
  });
}

class ScoredPackage {
  final PackageModel package;
  final double score;
  final String reason;

  ScoredPackage({
    required this.package,
    required this.score,
    required this.reason,
  });
}

double totalDataMb(PackageModel p) {
  final g = p.resources.dataGb;
  final m = p.resources.dataMb;
  if (g != null && g > 0) return g * 1024;
  if (m != null && m > 0) return m.toDouble();
  return 0;
}

int totalMinutes(PackageModel p) {
  final on = p.resources.onNetMinutes ?? 0;
  final off = p.resources.offNetMinutes ?? 0;
  return on + off;
}

int totalSms(PackageModel p) => p.resources.sms ?? 0;

bool _passesValidity(PackageModel p, ValidityPreference v) {
  final d = p.validityDays;
  switch (v) {
    case ValidityPreference.any:
      return true;
    case ValidityPreference.daily:
      return d >= 1 && d <= 2;
    case ValidityPreference.weekly:
      return d >= 3 && d <= 14;
    case ValidityPreference.monthly:
      return d >= 15;
  }
}

bool _passesNetwork(
  PackageModel p,
  MatchNetworkScope scope,
  String? singleId,
  Set<String> simIds,
) {
  if (p.networkId == 'ptcl') return false;
  switch (scope) {
    case MatchNetworkScope.all:
      return true;
    case MatchNetworkScope.mySims:
      if (simIds.isEmpty) return true;
      return simIds.contains(p.networkId);
    case MatchNetworkScope.single:
      return p.networkId == singleId;
  }
}

/// Higher score = better match (more resources per rupee, with floors applied).
List<ScoredPackage> matchPackages(
  List<PackageModel> all, {
  required MatchUsageCriteria c,
  Set<String> simNetworkIds = const {},
  int maxResults = 20,
}) {
  final simIds = simNetworkIds;
  final candidates = <PackageModel>[];

  for (final p in all) {
    if (!p.isActive) continue;
    if (!_passesNetwork(p, c.scope, c.singleNetworkId, simIds)) continue;
    if (!_passesValidity(p, c.validity)) continue;

    final data = totalDataMb(p);
    final mins = totalMinutes(p);
    final sms = totalSms(p);

    if (c.minDataMb > 0 && data < c.minDataMb) continue;
    if (c.minSms > 0 && sms < c.minSms) continue;
    if (c.minTotalMinutes > 0 && mins < c.minTotalMinutes) continue;

    candidates.add(p);
  }

  if (candidates.isEmpty) return [];

  double scoreFor(PackageModel p) {
    final data = totalDataMb(p);
    final mins = totalMinutes(p);
    final sms = totalSms(p);
    final price = p.price <= 0 ? 1.0 : p.price;
    // Value density: data weighted heavily, then minutes, then SMS
    final raw = (data * 0.8) + (mins * 12.0) + (sms * 2.0);
    var s = raw / price;
    // Slight bonus for longer validity when user didn't constrain heavily
    if (c.validity == ValidityPreference.any && p.validityDays >= 28) {
      s *= 1.05;
    }
    return s;
  }

  String reasonFor(PackageModel p, int rank) {
    if (rank == 0) return 'Top pick';
    final data = totalDataMb(p);
    final mins = totalMinutes(p);
    if (data >= 5120 && mins >= 100) return 'Strong data & calls';
    if (data >= 2048) return 'Good data';
    if (mins >= 300) return 'Heavy minutes';
    if (p.price / p.validityDays.clamp(1, 365) < 50) return 'Low Rs/day';
    return 'Good fit';
  }

  candidates.sort((a, b) => scoreFor(b).compareTo(scoreFor(a)));

  final out = <ScoredPackage>[];
  for (var i = 0; i < candidates.length && i < maxResults; i++) {
    final p = candidates[i];
    out.add(ScoredPackage(
      package: p,
      score: scoreFor(p),
      reason: reasonFor(p, i),
    ));
  }
  return out;
}
