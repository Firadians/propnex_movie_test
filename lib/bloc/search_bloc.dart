// search_bloc.dart
import 'package:bloc/bloc.dart';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/strings.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchMovie>(_onSearchMovie);
  }

  Future<void> _onSearchMovie(
      SearchMovie event, Emitter<SearchState> emit) async {
    emit(SearchLoading());

    try {
      // Encode the query to handle spaces and special characters
      final encodedQuery = Uri.encodeQueryComponent(event.query);
      final url = '$baseUrl/search/movie?query=$encodedQuery&api_key=$apiKey';

      print('Searching for: ${event.query}');
      print('Encoded Query: $encodedQuery');
      print('Request URL: $url');

      final response = await http.get(Uri.parse(url));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null || data['results'] == null) {
          emit(SearchError(message: 'Invalid response from server.'));
          return;
        }
        List<Movie> movies = (data['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
        emit(SearchLoaded(movies: movies));
      } else {
        emit(SearchError(
            message:
                'Failed to load movies. Status Code: ${response.statusCode}'));
      }
    } catch (e) {
      emit(SearchError(message: 'An error occurred: ${e.toString()}'));
    }
  }
}
