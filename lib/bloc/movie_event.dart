import 'package:equatable/equatable.dart';

abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object> get props => [];
}

class FetchNowPlaying extends MovieEvent {}

class FetchRecommendations extends MovieEvent {
  final int movieId;

  const FetchRecommendations({required this.movieId});

  @override
  List<Object> get props => [movieId];
}

class FetchMovieDetails extends MovieEvent {
  final int movieId;

  const FetchMovieDetails({required this.movieId});

  @override
  List<Object> get props => [movieId];
}
