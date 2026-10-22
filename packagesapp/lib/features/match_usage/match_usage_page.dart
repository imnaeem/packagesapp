import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/network_constants.dart';
import '../../core/providers/providers.dart';
import '../../core/services/match_usage_scorer.dart';
import '../../core/services/sim_service.dart' show SimCardDisplay, simCardDetailsProvider, simNetworkIdsProvider;
import '../../core/theme/app_text_styles.dart';
import '../../models/package_model.dart';
import '../packages/widgets/package_card.dart';

class MatchUsagePage extends ConsumerStatefulWidget {
  const MatchUsagePage({super.key});

  @override
  ConsumerState<MatchUsagePage> createState() => _MatchUsagePageState();
}

class _MatchUsagePageState extends ConsumerState<MatchUsagePage> {
  MatchNetworkScope _scope = MatchNetworkScope.all;
  String _singleNetworkId = 'jazz';
  double _minDataMb = 0;
  double _minSms = 0;
  double _minMins = 0;
  ValidityPreference _validity = ValidityPreference.any;
  List<ScoredPackage>? _results;

  void _find() {
    final packagesAsync = ref.read(packagesProvider(null));
    final packages = packagesAsync.when(
      data: (d) => d,
      loading: () => <PackageModel>[],
      error: (_, __) => <PackageModel>[],
    );
    final simIds = ref.read(simNetworkIdsProvider).maybeWhen(
          data: (s) => s,
          orElse: () => <String>{},
        );

    if (packages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Load packages first (pull to refresh on home).')),
      );
      return;
    }

    final c = MatchUsageCriteria(
      scope: _scope,
      singleNetworkId: _scope == MatchNetworkScope.single ? _singleNetworkId : null,
      minDataMb: _minDataMb,
      minSms: _minSms.round(),
      minTotalMinutes: _minMins.round(),
      validity: _validity,
    );

    setState(() {
      _results = matchPackages(
        packages,
        c: c,
        simNetworkIds: simIds,
        maxResults: 20,
      );
    });

    if (mounted && _results!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No packages match. Try lowering minimums or set validity to Any.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final packagesAsync = ref.watch(packagesProvider(null));
    final simDetailsAsync = ref.watch(simCardDetailsProvider);
    final networks = NetworkConstants.networks.where((n) => n.id != 'ptcl').toList();
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.tune_rounded, size: 18, color: cs.primary),
            ),
            const SizedBox(width: 10),
            const Text('Find me a Package'),
          ],
        ),
      ),
      body: packagesAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : packagesAsync.hasError
              ? Center(child: Text('Could not load packages', style: TextStyle(color: cs.error)))
              : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set what you need. We rank packages by value (data, minutes, SMS per rupee) within your limits.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('Network', style: AppTextStyles.labelLarge.copyWith(color: cs.onSurface)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _scope == MatchNetworkScope.all,
                            onSelected: (_) => setState(() => _scope = MatchNetworkScope.all),
                          ),
                          ChoiceChip(
                            label: const Text('My SIMs'),
                            selected: _scope == MatchNetworkScope.mySims,
                            onSelected: (_) => setState(() => _scope = MatchNetworkScope.mySims),
                          ),
                          ChoiceChip(
                            label: const Text('One network'),
                            selected: _scope == MatchNetworkScope.single,
                            onSelected: (_) => setState(() => _scope = MatchNetworkScope.single),
                          ),
                        ],
                      ),
                      if (_scope == MatchNetworkScope.mySims) ...[
                        const SizedBox(height: 12),
                        simDetailsAsync.when(
                              data: (List<SimCardDisplay> sims) {
                                if (sims.isEmpty) {
                                  return Text(
                                    'SIM networks not detected — search uses all networks.',
                                    style: AppTextStyles.caption.copyWith(color: cs.primary),
                                  );
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your SIMs',
                                      style: AppTextStyles.caption.copyWith(
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: sims.map((s) {
                                        final net = NetworkConstants.findById(s.networkId);
                                        final color = net?.brandColor ?? cs.primary;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(isDark ? 0.14 : 0.08),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: color.withOpacity(0.35)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.sim_card_rounded, size: 14, color: color),
                                              const SizedBox(width: 6),
                                              Text(
                                                s.carrierLabel,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                );
                              },
                              loading: () => Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                                ),
                              ),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                      ],
                      if (_scope == MatchNetworkScope.single) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Choose network',
                          style: AppTextStyles.caption.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: networks.map((n) {
                            final sel = _singleNetworkId == n.id;
                            return FilterChip(
                              selected: sel,
                              showCheckmark: false,
                              selectedColor: n.brandColor.withOpacity(isDark ? 0.22 : 0.14),
                              side: BorderSide(
                                color: sel ? n.brandColor.withOpacity(0.65) : cs.outline.withOpacity(0.35),
                              ),
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: n.brandColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    n.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                      color: sel ? n.brandColor : cs.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              onSelected: (_) => setState(() => _singleNetworkId = n.id),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 20),
                      Text('Validity', style: AppTextStyles.labelLarge.copyWith(color: cs.onSurface)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _ValidityChip(
                            label: 'Any',
                            selected: _validity == ValidityPreference.any,
                            onTap: () => setState(() => _validity = ValidityPreference.any),
                          ),
                          _ValidityChip(
                            label: 'Daily',
                            selected: _validity == ValidityPreference.daily,
                            onTap: () => setState(() => _validity = ValidityPreference.daily),
                          ),
                          _ValidityChip(
                            label: 'Weekly',
                            selected: _validity == ValidityPreference.weekly,
                            onTap: () => setState(() => _validity = ValidityPreference.weekly),
                          ),
                          _ValidityChip(
                            label: 'Monthly',
                            selected: _validity == ValidityPreference.monthly,
                            onTap: () => setState(() => _validity = ValidityPreference.monthly),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _SliderRow(
                        label: 'Min. data',
                        valueLabel: _minDataMb < 1 ? 'Any' : '${_minDataMb.round()} MB',
                        value: _minDataMb,
                        max: 10240,
                        divisions: 32,
                        onChanged: (v) => setState(() => _minDataMb = v),
                      ),
                      _SliderRow(
                        label: 'Min. SMS',
                        valueLabel: _minSms < 1 ? 'Any' : '${_minSms.round()}',
                        value: _minSms,
                        max: 500,
                        divisions: 25,
                        onChanged: (v) => setState(() => _minSms = v),
                      ),
                      _SliderRow(
                        label: 'Min. minutes (on + off net)',
                        valueLabel: _minMins < 1 ? 'Any' : '${_minMins.round()}',
                        value: _minMins,
                        max: 3000,
                        divisions: 30,
                        onChanged: (v) => setState(() => _minMins = v),
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _find,
                          icon: const Icon(Icons.search_rounded, size: 20),
                          label: const Text('Find matches'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                      if (_results != null) ...[
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Text(
                              'Top matches',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_results!.length} found',
                              style: AppTextStyles.caption.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_results!.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No matches — relax minimums or validity.',
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                            ),
                          )
                        else
                          ..._results!.asMap().entries.map((e) {
                            final sp = e.value;
                            final net = NetworkConstants.findById(sp.package.networkId);
                            final color = net?.brandColor ?? cs.primary;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            sp.reason,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          net?.name ?? sp.package.networkId,
                                          style: AppTextStyles.caption.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PackageCard(
                                    package: sp.package,
                                    networkColor: color,
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _ValidityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ValidityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: cs.primary.withOpacity(0.2),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final String valueLabel;
  final double value;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurface))),
            Text(valueLabel, style: AppTextStyles.caption.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
          ],
        ),
        Slider(
          value: value.clamp(0, max),
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
