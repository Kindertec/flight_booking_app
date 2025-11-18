import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AirlineLogo extends StatelessWidget {
  final String airlineCode;
  final String? logoUrl;
  final double size;

  const AirlineLogo({
    Key? key,
    required this.airlineCode,
    this.logoUrl,
    this.size = 40,
  }) : super(key: key);

  Color _getAirlineColor(String code) {
    switch (code.toUpperCase()) {
      case 'HV':
        return const Color(0xFF00A651); // Transavia green
      case 'BA':
        return const Color(0xFF075AAA);
      case 'LH':
        return const Color(0xFFF9B000);
      case 'AF':
        return const Color(0xFF002157);
      case 'KL':
        return const Color(0xFF00A1DE);
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we have a logo URL, display the actual logo
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: logoUrl!,
            width: size,
            height: size,
            fit: BoxFit.contain,
            placeholder: (context, url) => Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => _buildFallbackLogo(),
          ),
        ),
      );
    }

    // Fallback to colored logo with airline code
    return _buildFallbackLogo();
  }

  Widget _buildFallbackLogo() {
    final color = _getAirlineColor(airlineCode);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          airlineCode,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
