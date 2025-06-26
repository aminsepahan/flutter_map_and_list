import 'package:flutter/material.dart';
import '../models/camp_site.dart';
import 'camp_item.dart';

typedef CampTapCallback = void Function(CampSite camp);

class CampListView extends StatelessWidget {
  final List<CampSite> camps;
  final CampTapCallback onCampTap;

  const CampListView({
    Key? key,
    required this.camps,
    required this.onCampTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (camps.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: camps.length,
      itemBuilder: (ctx, i) {
        final camp = camps[i];
        return InkWell(
          onTap: () => onCampTap(camp),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: CampItem(camp: camp),
          ),
        );
      },
    );
  }
}
