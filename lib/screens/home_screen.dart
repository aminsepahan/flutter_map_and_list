import 'package:flutter/material.dart';
import 'camp_list_view.dart';
import 'camp_map_screen.dart';
import '../models/camp_site.dart';

class HomeScreen extends StatefulWidget {
  final List<CampSite> allCamps;
  const HomeScreen({Key? key, required this.allCamps}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  CampSite? _selectedCamp;

  void _onCampSelected(CampSite camp) {
    setState(() {
      _selectedCamp = camp;
      _currentIndex = 1; // switch to map tab
    });
  }

  @override
  Widget build(BuildContext context) {
    // Two “pages”: list (0) and map (1)
    final pages = <Widget>[
      CampListView(
        camps: widget.allCamps,
        onCampTap: _onCampSelected,
      ),
      CampMapScreen(
        campItems: widget.allCamps
            .map((c) => c.toCampItemMarker())
            .toList(),
        selectedCamp: _selectedCamp?.toCampItemMarker(),
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        onTap: (idx) {
          setState(() {
            _currentIndex = idx;
            if (idx == 0) _selectedCamp = null;  // clear selection when you go back
          });
        },
      ),
    );
  }
}
