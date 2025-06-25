import 'package:equatable/equatable.dart';

abstract class CampListEvent extends Equatable {
  const CampListEvent([List props = const []]);

  @override
  List<Object> get props => [];
}

class CampListEventFetch extends CampListEvent {
  const CampListEventFetch();

  @override
  String toString() => 'CampListEventFetch{}';
}
