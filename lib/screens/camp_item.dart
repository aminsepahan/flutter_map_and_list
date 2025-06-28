// lib/widgets/camp_item.dart

import 'package:flutter/material.dart';
import 'package:road_surfer_task/models/camp_site.dart';

class CampItem extends StatelessWidget {
  final CampSite camp;

  const CampItem({Key? key, required this.camp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) Image on the left
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              camp.photo ?? "http://loremflickr.com/640/480",
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 150,
                height: 150,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 40),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 2) Info on the right
          Expanded(
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
                  'Price per night: \$${camp.pricePerNight.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      camp.isCloseToWater ? ' 🌊 ' : ' 🏜 ',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      camp.isCampFireAllowed ? ' 🔥 ' : ' 🚒 ',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
