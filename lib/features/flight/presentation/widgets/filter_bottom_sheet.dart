import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/flight_bloc.dart';
import '../bloc/flight_event.dart';
import '../bloc/flight_state.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;

  @override
  void initState() {
    super.initState();
    final state = context.read<FlightBloc>().state;
    if (state is FlightLoaded) {
      _minPrice = state.filterParams.minPrice ?? state.actualMinPrice;
      _maxPrice = state.filterParams.maxPrice ?? state.actualMaxPrice;
    } else {
      _minPrice = 0;
      _maxPrice = 1000;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return BlocBuilder<FlightBloc, FlightState>(
            builder: (context, state) {
              if (state is! FlightLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              // Get currency from first flight
              final currency = state.filteredFlights.isNotEmpty
                  ? state.filteredFlights.first.flight.currency
                  : 'USD';

              return Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            context
                                .read<FlightBloc>()
                                .add(const ResetFiltersEvent());
                            setState(() {
                              _minPrice = state.actualMinPrice;
                              _maxPrice = state.actualMaxPrice;
                            });
                          },
                          child: const Text('Reset All'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Filters content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Price Range
                        _FilterSection(
                          title: 'Price Range',
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$currency ${_minPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$currency ${_maxPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              RangeSlider(
                                values: RangeValues(_minPrice, _maxPrice),
                                min: state.actualMinPrice,
                                max: state.actualMaxPrice,
                                divisions: 20,
                                onChanged: (values) {
                                  setState(() {
                                    _minPrice = values.start;
                                    _maxPrice = values.end;
                                  });
                                },
                                onChangeEnd: (values) {
                                  context.read<FlightBloc>().add(
                                        UpdatePriceRangeEvent(
                                          minPrice: values.start,
                                          maxPrice: values.end,
                                        ),
                                      );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Airlines
                        if (state.availableAirlines.isNotEmpty)
                          _FilterSection(
                            title: 'Airlines',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: state.availableAirlines.map((airline) {
                                final isSelected =
                                    state.selectedAirlines.contains(airline);
                                return FilterChip(
                                  label: Text(airline),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    context.read<FlightBloc>().add(
                                          ToggleAirlineEvent(airline),
                                        );
                                  },
                                );
                              }).toList(),
                            ),
                          ),

                        // Cabin Class
                        if (state.availableCabinClasses.isNotEmpty)
                          _FilterSection(
                            title: 'Cabin Class',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  state.availableCabinClasses.map((cabinClass) {
                                final isSelected = state.selectedCabinClasses
                                    .contains(cabinClass);
                                return FilterChip(
                                  label: Text(cabinClass),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    context.read<FlightBloc>().add(
                                          ToggleCabinClassEvent(cabinClass),
                                        );
                                  },
                                );
                              }).toList(),
                            ),
                          ),

                        // Stops
                        _FilterSection(
                          title: 'Stops',
                          child: SwitchListTile(
                            title: const Text('Non-stop flights only'),
                            value: state.filterParams.nonStopOnly ?? false,
                            onChanged: (value) {
                              context.read<FlightBloc>().add(
                                    ToggleNonStopEvent(value),
                                  );
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),

                        // Refundable
                        _FilterSection(
                          title: 'Refund Policy',
                          child: SwitchListTile(
                            title: const Text('Refundable flights only'),
                            value: state.filterParams.refundableOnly ?? false,
                            onChanged: (value) {
                              context.read<FlightBloc>().add(
                                    ToggleRefundableEvent(value),
                                  );
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Apply button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Show ${state.filteredFlights.length} flights',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
        const SizedBox(height: 24),
      ],
    );
  }
}
