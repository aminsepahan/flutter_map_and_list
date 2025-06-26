import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:road_surfer_task/bloc/camp_list_bloc.dart';
import 'package:road_surfer_task/bloc/camp_list_event.dart';
import 'package:road_surfer_task/bloc/camp_list_state.dart';
import 'package:road_surfer_task/models/camp_site.dart';
import 'package:road_surfer_task/resources/network/camp_list_repository.dart';
import 'package:road_surfer_task/screens/camp_item.dart';
import 'package:road_surfer_task/screens/camp_map_screen.dart';
import 'package:road_surfer_task/utils/network/dio_caller.dart';
import 'package:road_surfer_task/utils/network/dio_provider.dart';

import 'models/camp_item_marker.dart';

void setupDependencies() {
  GetIt.I.registerLazySingleton(() => DioProvider());
  GetIt.I.registerLazySingleton(() => DioCaller(dio: GetIt.I<DioProvider>().provideDio()));
}

void main() {
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CampListBloc(CampListRepository()),
      child: MaterialApp(
        title: 'Flutter Camping App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'camping'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum PriceSortOrder {
  lowToHigh,
  highToLow,
}

class _MyHomePageState extends State<MyHomePage> {
  List<CampSite> allCamps = [];
  List<String> campLabels = [];
  List<String> sortItems = ['Low to High', 'High to Low'];
  List<CampSite> filteredCamps = [];
  String? selectedCountry;
  bool filterOnlyCloseToWater = false;
  PriceSortOrder sortOrder = PriceSortOrder.lowToHigh;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCampList(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BlocConsumer<CampListBloc, CampListState>(
        builder: (context, state) {
          if (state is CampListStateSuccess) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      hint: const Text("filtered by label "),
                      value: selectedCountry,
                      isExpanded: true,
                      onChanged: filterByCountry,
                      items: campLabels.map((country) {
                        return DropdownMenuItem(
                          value: country,
                          child: Text(country),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<PriceSortOrder>(
                      value: sortOrder,
                      isExpanded: true,
                      hint: const Text("sort by price "),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            sortOrder = value;
                            sortCampsites(sortOrder);
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: PriceSortOrder.lowToHigh,
                          child: Text('Price: Low to High'),
                        ),
                        DropdownMenuItem(
                          value: PriceSortOrder.highToLow,
                          child: Text('Price: High to Low'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Show only camps close to water"),
                        Switch(
                          value: filterOnlyCloseToWater,
                          onChanged: (value) {
                            filterOnlyCloseToWater = value;
                            applyFilters(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: filteredCamps.length,
                    itemBuilder: (context, index) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            navigateToMap(filteredCamps[index]);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CampItem(
                                  camp: filteredCamps[index],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return const Text(
              'loading',
              style: TextStyle(fontSize: 20),
            );
          }
        },
        listener: (context, state) {
          if (state is CampListStateSuccess) {
            allCamps = state.campList;
            filteredCamps = allCamps;
            filteredCamps.sort((a, b) => a.label.compareTo(b.label));
            campLabels = allCamps.map((c) => c.label).toSet().toList();
            campLabels.add('none');
          }
        },
      ),
    );
  }

  void _fetchCampList(BuildContext context) {
    BlocProvider.of<CampListBloc>(context).add(const CampListEventFetch());
  }

  void filterByCountry(String? label) {
    setState(() {
      selectedCountry = label;
      if (label == null || label == 'none') {
        filteredCamps = allCamps;
      } else {
        filteredCamps = allCamps.where((c) => c.label == label).toList();
      }
    });
  }

  void sortCampsites(sortOrder) {
    if (sortOrder == PriceSortOrder.lowToHigh) {
      filteredCamps.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
    } else {
      filteredCamps.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
    }
  }

  void applyFilters(bool filterOnlyCloseToWater) {
    setState(() {
      filteredCamps = allCamps;
      filteredCamps =
          filterOnlyCloseToWater ? filteredCamps.where((camp) => camp.isCloseToWater).toList() : filteredCamps;
    });
  }

  navigateToMap(CampSite selectedCamp) {
    // 1) Convert all CampSite into CampItemMarker
    final campItemMarkers = allCamps.map((camp) {
      return CampItemMarker(
          id: camp.id.toString(),
          label: camp.label,
          lat: camp.geoLocation.lat,
          lng: camp.geoLocation.long
      );
    }).toList();

    // 2) Convert the single selected CampSite
    final selectedMarker = CampItemMarker(
        id: selectedCamp.id.toString(),
        label: selectedCamp.label,
        lat: selectedCamp.geoLocation.lat,
        lng: selectedCamp.geoLocation.long
    );

    // 3) Push the map screen with the correct types
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CampMapScreen(
              campItems: campItemMarkers,
              selectedCamp: selectedMarker,
            ),
      ),
    );
  }
}
