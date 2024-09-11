import 'package:flutter_bloc/flutter_bloc.dart';
import 'movie_event.dart';
import 'movie_state.dart';
import 'package:movie_app/models/movie_model.dart';

import 'dart:convert';
import 'package:movie_app/strings.dart';
import 'package:http/http.dart' as http;

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  MovieBloc() : super(MovieInitial()) {
    on<FetchNowPlaying>(_onFetchNowPlaying);
  }

  Future<void> _onFetchNowPlaying(
      FetchNowPlaying event, Emitter<MovieState> emit) async {
    await _fetchMovies(
      emit,
      '/movie/now_playing',
      onSuccess: (movies) => MovieNowPlayingLoaded(movies: movies),
    );
  }

  Future<void> _fetchMovies(Emitter<MovieState> emit, String endpoint,
      {required MovieState Function(List<Movie>) onSuccess}) async {
    try {
      emit(MovieLoading());
      final response =
          await http.get(Uri.parse('$baseUrl$endpoint?api_key=$apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Movie> movies = (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
        emit(onSuccess(movies));
      } else {
        emit(MovieError(message: 'Failed to load movies'));
      }
    } catch (e) {
      emit(MovieError(message: e.toString()));
    }
  }
}

class NowPlayingBloc extends Bloc<MovieEvent, MovieState> {
  NowPlayingBloc() : super(MovieInitial()) {
    on<FetchNowPlaying>(_onFetchNowPlaying);
  }

  Future<void> _onFetchNowPlaying(
      FetchNowPlaying event, Emitter<MovieState> emit) async {
    await _fetchMovies(
      emit,
      '/movie/now_playing',
      onSuccess: (movies) => MovieNowPlayingLoaded(movies: movies),
    );
  }

  Future<void> _fetchMovies(Emitter<MovieState> emit, String endpoint,
      {required MovieState Function(List<Movie>) onSuccess}) async {
    try {
      emit(MovieLoading());
      final response =
          await http.get(Uri.parse('$baseUrl$endpoint?api_key=$apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Movie> movies = (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
        emit(onSuccess(movies));
      } else {
        emit(MovieError(message: 'Failed to load movies'));
      }
    } catch (e) {
      emit(MovieError(message: e.toString()));
    }
  }
}
