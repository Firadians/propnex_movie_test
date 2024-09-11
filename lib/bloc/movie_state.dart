import 'package:equatable/equatable.dart';
import 'package:movie_app/models/movie_model.dart';

import 'package:movie_app/models/recommendation_model.dart';

abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List<Movie> movies;

  const MovieLoaded({required this.movies});

  @override
  List<Object> get props => [movies];
}

class MovieNowPlayingLoaded extends MovieState {
  final List<Movie> movies;

  const MovieNowPlayingLoaded({required this.movies});

  @override
  List<Object> get props => [movies];
}

class MoviePopularLoaded extends MovieState {
  final List<Movie> movies;

  const MoviePopularLoaded({required this.movies});

  @override
  List<Object> get props => [movies];
}

class MovieRecommendLoaded extends MovieState {
  final List<Recommendation> movies;

  const MovieRecommendLoaded({required this.movies});

  @override
  List<Object> get props => [movies];
}

class MovieError extends MovieState {
  final String message;

  const MovieError({required this.message});

  @override
  List<Object> get props => [message];
}
