part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class FetchSearch extends SearchEvent {}

class SearchMovie extends SearchEvent {
  final String query;

  SearchMovie(this.query);
}
