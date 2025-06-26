import 'package:flutter/material.dart';
import 'package:road_surfer_task/models/camp_site.dart';

class CampItem extends StatelessWidget {
  CampSite camp;

  CampItem({super.key, required this.camp});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                camp.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Price per night: \$${camp.pricePerNight}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                camp.isCloseToWater ? 'Near water 💧' : 'Not near water',
                style: TextStyle(
                  fontSize: 14,
                  color: camp.isCloseToWater ? Colors.blueAccent : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
