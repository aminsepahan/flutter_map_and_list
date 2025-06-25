import 'package:equatable/equatable.dart';

import '../models/camp_site.dart';

abstract class CampListState extends Equatable {
  const CampListState();

  @override
  List<Object> get props => [];
}

class CampListStateNotStarted extends CampListState {}

class CampListStateLoading extends CampListState {}

class CampListStateSuccess extends CampListState {
  List<CampSite> campList;

  CampListStateSuccess(this.campList);

  @override
  String toString() => 'CampListStateSuccess { list : $campList }';
}

class CampListStateFailed extends CampListState {
  String errorMessage;

  CampListStateFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];

  @override
  String toString() => 'CampListStateFailed { errorMessage : $errorMessage }';
}
