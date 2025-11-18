import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/enriched_flight.dart';
import '../../domain/entities/baggage_service.dart';
import '../../domain/entities/flight.dart';
import '../widgets/airline_logo.dart';
import '../widgets/baggage_selection_bottom_sheet.dart';

class FlightDetailScreen extends StatefulWidget {
  final EnrichedFlight enrichedFlight;

  const FlightDetailScreen({
    Key? key,
    required this.enrichedFlight,
  }) : super(key: key);

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {
  List<SelectedBaggage> selectedBaggage = [];

  double _calculateTotalCost() {
    double total = widget.enrichedFlight.flight.totalFare;
    for (var baggage in selectedBaggage) {
      total += baggage.service.calculateCost(baggage.quantity);
    }
    return total;
  }

  void _showBaggageOptions() {
    if (!widget.enrichedFlight.hasBaggageOptions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No baggage options available')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BaggageSelectionBottomSheet(
        baggageOptions: widget.enrichedFlight.availableBaggageOptions,
        onSelect: (service, quantity) {
          setState(() {
            selectedBaggage.add(SelectedBaggage(
              service: service,
              quantity: quantity,
            ));
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $quantity x ${service.description}'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.enrichedFlight.flight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Airline Header with Real Logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    AirlineLogo(
                      airlineCode: flight.airlineCode,
                      logoUrl: widget.enrichedFlight.airlineLogoUrl,
                      size: 80,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.enrichedFlight.airlineFullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${flight.airlineCode} ${flight.flightNumber}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Flight Route
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Flight Route',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RouteTimeline(
                    departureAirport: flight.departureAirport,
                    departureTime: flight.departureTime,
                    arrivalAirport: flight.arrivalAirport,
                    arrivalTime: flight.arrivalTime,
                    duration: flight.duration,
                    stops: flight.stops,
                  ),
                ],
              ),
            ),

            const Divider(),

            // Fare Summary
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fare Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FareRow(
                    label: 'Base Fare',
                    value:
                        '${flight.currency} ${flight.baseFare.toStringAsFixed(2)}',
                  ),
                  _FareRow(
                    label: 'Taxes & Fees',
                    value:
                        '${flight.currency} ${flight.totalTax.toStringAsFixed(2)}',
                  ),
                  if (selectedBaggage.isNotEmpty) ...[
                    const Divider(),
                    for (var baggage in selectedBaggage)
                      _FareRow(
                        label:
                            '${baggage.quantity}x ${baggage.service.description}',
                        value:
                            '${flight.currency} ${baggage.service.calculateCost(baggage.quantity).toStringAsFixed(2)}',
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              selectedBaggage.remove(baggage);
                            });
                          },
                        ),
                      ),
                  ],
                  const Divider(),
                  _FareRow(
                    label: 'Total',
                    value:
                        '${flight.currency} ${_calculateTotalCost().toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ],
              ),
            ),

            const Divider(),

            // Add Baggage Button
            if (widget.enrichedFlight.hasBaggageOptions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton.icon(
                  onPressed: _showBaggageOptions,
                  icon: const Icon(Icons.luggage),
                  label: const Text('Add Checked Baggage'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Passenger Breakdown
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Passenger Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...flight.fareBreakdown
                      .map((fare) => _PassengerCard(fare: fare)),
                ],
              ),
            ),

            const Divider(),

            // Flight Information
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Flight Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.airline_seat_recline_normal,
                    label: 'Cabin Class',
                    value: flight.cabinClass,
                  ),
                  _InfoRow(
                    icon: Icons.event_seat,
                    label: 'Seats Available',
                    value: '${flight.seatsRemaining} seats',
                  ),
                  _InfoRow(
                    icon: Icons.flight_takeoff,
                    label: 'Stops',
                    value: flight.stops == 0
                        ? 'Non-stop'
                        : '${flight.stops} stop(s)',
                  ),
                  _InfoRow(
                    icon:
                        flight.isRefundable ? Icons.check_circle : Icons.cancel,
                    label: 'Refundable',
                    value: flight.isRefundable ? 'Yes' : 'No',
                    valueColor: flight.isRefundable ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),

            // Book Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking functionality coming soon!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Book for ${flight.currency} ${_calculateTotalCost().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectedBaggage {
  final BaggageService service;
  final int quantity;

  SelectedBaggage({required this.service, required this.quantity});
}

// Helper widgets (RouteTimeline, FareRow, PassengerCard, etc.)

class _RouteTimeline extends StatelessWidget {
  final String departureAirport;
  final DateTime departureTime;
  final String arrivalAirport;
  final DateTime arrivalTime;
  final String duration;
  final int stops;

  const _RouteTimeline({
    required this.departureAirport,
    required this.departureTime,
    required this.arrivalAirport,
    required this.arrivalTime,
    required this.duration,
    required this.stops,
  });

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('EEE, MMM d').format(dateTime);
  }

  String _formatDuration(String minutes) {
    final int totalMinutes = int.parse(minutes);
    final int hours = totalMinutes ~/ 60;
    final int mins = totalMinutes % 60;
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 60,
              color: Colors.blue,
            ),
            const Icon(Icons.flight, color: Colors.blue, size: 20),
            Container(
              width: 2,
              height: 60,
              color: Colors.blue,
            ),
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatTime(departureTime),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$departureAirport • ${_formatDate(departureTime)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_formatDuration(duration)} • ${stops == 0 ? "Non-stop" : stops == 1 ? "$stops stop" : "$stops stops"}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _formatTime(arrivalTime),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$arrivalAirport • ${_formatDate(arrivalTime)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Widget? trailing;

  const _FareRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _PassengerCard extends StatelessWidget {
  final FareBreakdown fare;

  const _PassengerCard({required this.fare});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${fare.quantity}x ${fare.passengerType}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'USD ${fare.totalFare.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Base Fare: USD ${fare.baseFare.toStringAsFixed(2)}'),
            Text('Taxes: USD ${fare.taxes.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(label: 'Baggage: ${fare.baggage.join(", ")}'),
                _Tag(label: 'Cabin: ${fare.cabinBaggage.join(", ")}'),
                if (fare.refundAllowed)
                  const _Tag(label: 'Refundable', color: Colors.green),
                if (fare.changeAllowed)
                  const _Tag(label: 'Changeable', color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color? color;

  const _Tag({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey[300])?.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color ?? Colors.grey[400]!),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color ?? Colors.grey[700],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
