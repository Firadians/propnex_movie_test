import 'package:equatable/equatable.dart';
import 'package:movie_app/models/movie_model.dart';

sealed class PopularState extends Equatable {
  const PopularState();

  @override
  List<Object> get props => [];
}

final class PopularInitial extends PopularState {}

class PopularLoading extends PopularState {}

class PopularLoaded extends PopularState {
  final List<Movie> movies;

  const PopularLoaded({required this.movies});

  @override
  List<Object> get props => [movies];
}

class PopularError extends PopularState {
  final String message;

  const PopularError({required this.message});

  @override
  List<Object> get props => [message];
}
