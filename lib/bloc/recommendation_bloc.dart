import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:movie_app/models/movie_model.dart';
import 'dart:convert';
import 'package:movie_app/strings.dart';
import 'package:http/http.dart' as http;

part 'recommendation_event.dart';
part 'recommendation_state.dart';

class RecommendationBloc
    extends Bloc<RecommendationEvent, RecommendationState> {
  RecommendationBloc() : super(RecommendationInitial()) {
    on<FetchRecommendation>(_onFetchMovieRecommendations);
  }

  Future<void> _onFetchMovieRecommendations(
      FetchRecommendation event, Emitter<RecommendationState> emit) async {
    await _fetchMovies(
      emit,
      '/movie/${event.movieId}/recommendations',
      onSuccess: (movies) => RecommendationLoaded(movies: movies),
    );
  }

  Future<void> _fetchMovies(Emitter<RecommendationState> emit, String endpoint,
      {required RecommendationState Function(List<Movie>) onSuccess}) async {
    try {
      emit(RecommendationLoading());
      final response =
          await http.get(Uri.parse('$baseUrl$endpoint?api_key=$apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Movie> movies = (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
        emit(onSuccess(movies));
      } else {
        emit(RecommendationError(message: 'Failed to load recommendations'));
      }
    } catch (e) {
      emit(RecommendationError(message: e.toString()));
    }
  }
}
