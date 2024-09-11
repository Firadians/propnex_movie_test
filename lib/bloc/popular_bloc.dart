import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'popular_state.dart';
import 'dart:convert';
import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/strings.dart';
import 'package:http/http.dart' as http;
part 'popular_event.dart';

class PopularBloc extends Bloc<PopularEvent, PopularState> {
  PopularBloc() : super(PopularInitial()) {
    on<FetchPopular>(_onFetchPopular);
  }

  Future<void> _onFetchPopular(
      FetchPopular event, Emitter<PopularState> emit) async {
    await _fetchMovies(
      emit,
      '/movie/popular',
      onSuccess: (movies) => PopularLoaded(movies: movies),
    );
  }

  Future<void> _fetchMovies(Emitter<PopularState> emit, String endpoint,
      {required PopularState Function(List<Movie>) onSuccess}) async {
    try {
      emit(PopularLoading());
      final response =
          await http.get(Uri.parse('$baseUrl$endpoint?api_key=$apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Movie> movies = (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
        emit(onSuccess(movies));
      } else {
        emit(PopularError(message: 'Failed to load movies'));
      }
    } catch (e) {
      emit(PopularError(message: e.toString()));
    }
  }
}
