import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/core/theme/incident_visuals.dart';
import 'package:campusfix/models/incident_category.dart';
import 'package:campusfix/models/incident_filter.dart';
import 'package:campusfix/models/incident_status.dart';
import 'package:campusfix/providers/incident_provider.dart';

class IncidentSearchField extends StatefulWidget {
  const IncidentSearchField({super.key});

  @override
  State<IncidentSearchField> createState() => _IncidentSearchFieldState();
}

class _IncidentSearchFieldState extends State<IncidentSearchField> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<IncidentProvider>().filter.query,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) context.read<IncidentProvider>().setQuery(value);
    });
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    context.read<IncidentProvider>().setQuery('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search title, location or description',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close),
                onPressed: _clear,
              ),
      ),
    );
  }
}

class IncidentFilterBar extends StatelessWidget {
  const IncidentFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final filter = provider.filter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _chip(
                label: 'All categories',
                selected: filter.category == null,
                onTap: () => provider.setCategory(null),
              ),
              for (final category in IncidentCategory.values)
                _chip(
                  label: category.label,
                  icon: category.icon,
                  selected: filter.category == category,
                  onTap: () => provider.setCategory(
                    filter.category == category ? null : category,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _chip(
                label: 'Any status',
                selected: filter.status == null,
                onTap: () => provider.setStatus(null),
              ),
              for (final status in IncidentStatus.values)
                _chip(
                  label: status.label,
                  icon: status.icon,
                  selected: filter.status == status,
                  onTap: () => provider.setStatus(
                    filter.status == status ? null : status,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
      child: FilterChip(
        label: Text(label),
        avatar: icon == null
            ? null
            : Icon(
                icon,
                size: 16,
                color: selected ? AppColors.matchaDeep : AppColors.inkMuted,
              ),
        showCheckmark: false,
        selected: selected,
        onSelected: (_) => onTap(),
        side: BorderSide(
          color: selected ? AppColors.matcha : AppColors.border,
        ),
        labelStyle: TextStyle(
          color: selected ? AppColors.matchaDeep : AppColors.ink,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}

class SortMenuButton extends StatelessWidget {
  const SortMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    return PopupMenuButton<IncidentSort>(
      tooltip: 'Sort reports',
      icon: const Icon(Icons.sort),
      initialValue: provider.filter.sort,
      onSelected: provider.setSort,
      itemBuilder: (context) => [
        for (final sort in IncidentSort.values)
          PopupMenuItem(
            value: sort,
            child: Row(
              children: [
                Icon(
                  sort == provider.filter.sort
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                  color: AppColors.matcha,
                ),
                const SizedBox(width: 10),
                Text(sort.label),
              ],
            ),
          ),
      ],
    );
  }
}
