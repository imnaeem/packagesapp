import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:sim_card_info/sim_info.dart';

const _operatorKeywords = <String, String>{
  'jazz': 'jazz',
  'mobilink': 'jazz',
  'warid': 'jazz',
  'zong': 'zong',
  'china mobile': 'zong',
  'cmpak': 'zong',
  'telenor': 'telenor',
  'ufone': 'ufone',
  'ptml': 'ufone',
  'u fone': 'ufone',
};

String? _matchNetwork(String carrier) {
  final lower = carrier.toLowerCase().trim();
  for (final entry in _operatorKeywords.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return null;
}

/// One row per physical SIM with resolved network id + carrier label from the device.
class SimCardDisplay {
  final String networkId;
  final String carrierLabel;

  const SimCardDisplay({
    required this.networkId,
    required this.carrierLabel,
  });
}

final simCardDetailsProvider = FutureProvider<List<SimCardDisplay>>((ref) async {
  try {
    final status = await Permission.phone.request();
    if (!status.isGranted) return [];

    final List<SimInfo>? sims = await SimCardInfo().getSimInfo();
    if (sims == null || sims.isEmpty) return [];

    final out = <SimCardDisplay>[];
    for (final sim in sims) {
      final id = _matchNetwork(sim.carrierName) ?? _matchNetwork(sim.displayName);
      if (id == null) continue;
      final label = sim.carrierName.trim().isNotEmpty
          ? sim.carrierName.trim()
          : sim.displayName.trim();
      if (label.isEmpty) continue;
      out.add(SimCardDisplay(networkId: id, carrierLabel: label));
    }
    return out;
  } catch (_) {
    return [];
  }
});

/// Set of network IDs for which a SIM is inserted (derived from [simCardDetailsProvider]).
final simNetworkIdsProvider = FutureProvider<Set<String>>((ref) async {
  final details = await ref.watch(simCardDetailsProvider.future);
  return details.map((e) => e.networkId).toSet();
});
