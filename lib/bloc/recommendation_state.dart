part of 'recommendation_bloc.dart';

sealed class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object> get props => [];
}

final class RecommendationInitial extends RecommendationState {}

class RecommendationLoading extends RecommendationState {}

class RecommendationError extends RecommendationState {
  final String message;

  const RecommendationError({required this.message});

  @override
  List<Object> get props => [message];
}

class RecommendationLoaded extends RecommendationState {
  final List<Movie> movies;

  const RecommendationLoaded({required this.movies});

  @override
  List<Object> get props => [movies];
}
