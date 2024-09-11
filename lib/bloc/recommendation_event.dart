part of 'recommendation_bloc.dart';

sealed class RecommendationEvent extends Equatable {
  const RecommendationEvent();

  @override
  List<Object> get props => [];
}

class FetchRecommendation extends RecommendationEvent {
  final int movieId;

  const FetchRecommendation({required this.movieId});

  @override
  List<Object> get props => [movieId];
}
