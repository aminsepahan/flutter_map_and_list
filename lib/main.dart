import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:road_surfer_task/bloc/camp_list_bloc.dart';
import 'package:road_surfer_task/bloc/camp_list_event.dart';
import 'package:road_surfer_task/bloc/camp_list_state.dart';
import 'package:road_surfer_task/resources/network/camp_list_repository.dart';
import 'package:road_surfer_task/screens/home_screen.dart';
import 'package:road_surfer_task/utils/network/dio_caller.dart';
import 'package:road_surfer_task/utils/network/dio_provider.dart';

void setupDependencies() {
  GetIt.I.registerLazySingleton(() => DioProvider());
  GetIt.I.registerLazySingleton(
    () => DioCaller(dio: GetIt.I<DioProvider>().provideDio()),
  );
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
      // ← add the fetch event right when you instantiate the bloc
      create: (_) =>
          CampListBloc(CampListRepository())..add(const CampListEventFetch()),
      child: MaterialApp(
        title: 'Flutter Camping App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MainPageHost(),
      ),
    );
  }
}

class MainPageHost extends StatelessWidget {
  const MainPageHost({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CampListBloc, CampListState>(
      builder: (context, state) {
        if (state is CampListStateSuccess) {
          // Pass the loaded list into your bottom‐tab scaffold
          return HomeScreen(allCamps: state.campList);
        }

        // Show a full‐screen spinner while loading
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

enum PriceSortOrder { lowToHigh, highToLow }
