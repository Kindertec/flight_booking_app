import 'package:flight_booking_app/features/flight/domain/usecases/filter_flights.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/flight_bloc.dart';
import '../bloc/flight_event.dart';
import '../bloc/flight_state.dart';
import '../widgets/flight_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'flight_detail_screen.dart';

class FlightsListScreen extends StatelessWidget {
  const FlightsListScreen({Key? key}) : super(key: key);

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _showSortOptions(BuildContext context, FlightBloc bloc) {
    final currentState = bloc.state;
    if (currentState is! FlightLoaded) return;

    final sortBy = _sortTypeToString(currentState.filterParams.sortBy);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _SortOption(
              title: 'Price: Low to High',
              value: 'price_low',
              groupValue: sortBy,
              onChanged: (value) {
                bloc.add(UpdateSortingEvent(value!));
                Navigator.pop(context);
              },
            ),
            _SortOption(
              title: 'Price: High to Low',
              value: 'price_high',
              groupValue: sortBy,
              onChanged: (value) {
                bloc.add(UpdateSortingEvent(value!));
                Navigator.pop(context);
              },
            ),
            _SortOption(
              title: 'Duration',
              value: 'duration',
              groupValue: sortBy,
              onChanged: (value) {
                bloc.add(UpdateSortingEvent(value!));
                Navigator.pop(context);
              },
            ),
            _SortOption(
              title: 'Departure Time',
              value: 'departure',
              groupValue: sortBy,
              onChanged: (value) {
                bloc.add(UpdateSortingEvent(value!));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _sortTypeToString(SortType sortType) {
    switch (sortType) {
      case SortType.priceLowToHigh:
        return 'price_low';
      case SortType.priceHighToLow:
        return 'price_high';
      case SortType.duration:
        return 'duration';
      case SortType.departureTime:
        return 'departure';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              context.read<FlightBloc>().add(const RefreshFlightsEvent());
            },
            icon: const Icon(Icons.refresh)),
        title: const Text('Available Flights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(
              context,
              context.read<FlightBloc>(),
            ),
          ),
          BlocBuilder<FlightBloc, FlightState>(
            builder: (context, state) {
              final activeFilters =
                  state is FlightLoaded ? state.activeFiltersCount : 0;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFilterSheet(context),
                  ),
                  if (activeFilters > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$activeFilters',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<FlightBloc, FlightState>(
        builder: (context, state) {
          if (state is FlightLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FlightError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FlightBloc>().add(const LoadFlightsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is FlightLoaded) {
            if (state.filteredFlights.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flight_outlined,
                        size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No flights found',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your filters',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 16),
                    if (state.activeFiltersCount > 0)
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<FlightBloc>()
                              .add(const ResetFiltersEvent());
                        },
                        child: const Text('Reset Filters'),
                      ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.blue[50],
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${state.filteredFlights.length} flights found • AMS → LON',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      if (state.activeFiltersCount > 0)
                        TextButton(
                          onPressed: () {
                            context
                                .read<FlightBloc>()
                                .add(const ResetFiltersEvent());
                          },
                          child: const Text('Clear filters'),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<FlightBloc>()
                          .add(const RefreshFlightsEvent());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: state.filteredFlights.length,
                      itemBuilder: (context, index) {
                        final enrichedFlight = state.filteredFlights[index];
                        return FlightCard(
                          enrichedFlight: enrichedFlight,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FlightDetailScreen(
                                  enrichedFlight: enrichedFlight,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('Unknown state'),
          );
        },
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _SortOption({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
