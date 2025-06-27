// lib/screens/home_screen.dart

import 'package:flutter/material.dart';

import '../models/camp_item_marker.dart';
import '../models/camp_site.dart';
import 'camp_list_view.dart';
import 'camp_map_screen.dart';

extension CampSiteExtension on CampSite {
  CampItemMarker toMarker() => CampItemMarker(
    id: id.toString(),
    label: label,
    lat: geoLocation.lat,
    lng: geoLocation.long,
  );
}

/// Defines sorting options, with [popularity] preserving server order.
enum SortOption { popularity, lowToHigh, highToLow }

class HomeScreen extends StatefulWidget {
  final List<CampSite> allCamps;

  const HomeScreen({Key? key, required this.allCamps}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<CampSite> _filteredCamps;
  late List<String> _labels;
  String _selectedLabel = 'All';
  SortOption _sortOption = SortOption.popularity;
  bool _onlyCloseToWater = false;
  bool _fireAllowed = false;
  CampSite? _selectedCamp;

  @override
  void initState() {
    super.initState();
    _labels = ['All'] + widget.allCamps.map((c) => c.label).toSet().toList();
    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    // Filter: by label, preserving the original order from allCamps
    var filtered = _selectedLabel == 'All'
        ? List<CampSite>.from(widget.allCamps)
        : widget.allCamps.where((c) => c.label == _selectedLabel).toList();

    // Additional filters
    if (_onlyCloseToWater) {
      filtered = filtered.where((c) => c.isCloseToWater).toList();
    }
    if (_fireAllowed) {
      filtered = filtered.where((c) => c.isCampFireAllowed).toList();
    }

    // Sort: only if not popularity
    if (_sortOption == SortOption.lowToHigh) {
      filtered.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
    } else if (_sortOption == SortOption.highToLow) {
      filtered.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
    }

    setState(() {
      _filteredCamps = filtered;
      // clear selected if it's filtered out
      if (_selectedCamp != null && !_filteredCamps.contains(_selectedCamp)) {
        _selectedCamp = null;
      }
    });
  }

  void _onLabelChanged(String? newLabel) {
    if (newLabel == null) return;
    _selectedLabel = newLabel;
    _applyFilterAndSort();
  }

  void _onSortChanged(SortOption? option) {
    if (option == null) return;
    _sortOption = option;
    _applyFilterAndSort();
  }

  void _onCampTap(CampSite camp) {
    setState(() {
      _selectedCamp = camp;
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      CampListView(camps: _filteredCamps, onCampTap: _onCampTap),
      CampMapScreen(
        campItems: _filteredCamps.map((c) => c.toMarker()).toList(),
        selectedCamp: _selectedCamp?.toMarker(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Explorer')),
      body: Column(
        children: [
          // Filter & sort bar with elevation shadow
          Material(
            elevation: 4,
            shadowColor: Colors.black45,
            child: Column(
              children: [
                // Row for label filter and sort
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButton<String>(
                          value: _selectedLabel,
                          items: _labels
                              .map(
                                (label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label),
                                ),
                              )
                              .toList(),
                          onChanged: _onLabelChanged,
                          isExpanded: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: DropdownButton<SortOption>(
                          value: _sortOption,
                          items: const [
                            DropdownMenuItem(
                              value: SortOption.popularity,
                              child: Text('Popularity'),
                            ),
                            DropdownMenuItem(
                              value: SortOption.lowToHigh,
                              child: Text('Price: Low → High'),
                            ),
                            DropdownMenuItem(
                              value: SortOption.highToLow,
                              child: Text('Price: High → Low'),
                            ),
                          ],
                          onChanged: _onSortChanged,
                          isExpanded: true,
                        ),
                      ),
                    ],
                  ),
                ),
                // Row for switches: close to water and fire allowed
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Text('Close to water'),
                            const SizedBox(width: 4),
                            Switch(
                              value: _onlyCloseToWater,
                              onChanged: (val) {
                                setState(() => _onlyCloseToWater = val);
                                _applyFilterAndSort();
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const Text('Fire allowed'),
                            const SizedBox(width: 4),
                            Switch(
                              value: _fireAllowed,
                              onChanged: (val) {
                                setState(() => _fireAllowed = val);
                                _applyFilterAndSort();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) {
          setState(() {
            _currentIndex = idx;
            if (idx == 0) _selectedCamp = null;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        ],
      ),
    );
  }
}
