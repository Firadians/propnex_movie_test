import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  MovieDetailScreen({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SlidingUpPanel(
        minHeight: 200,
        maxHeight: MediaQuery.of(context).size.height,
        panel: _buildPanelContent(),
        body: _buildHeroImage(context),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return Hero(
      tag: 'moviePoster_${movie.id}',
      child: Image.network(
        'https://image.tmdb.org/t/p/w500${movie.posterPath}',
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
      ),
    );
  }

  Widget _buildPanelContent() {
    return Container(
      color: Colors.black, // Set the panel color to black
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movie.title,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              'Release Date: ${movie.releaseDate}',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                RatingBarIndicator(
                  rating: (movie.voteAverage / 2),
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 24.0,
                  direction: Axis.horizontal,
                ),
                SizedBox(width: 8),
                Text(
                  '${movie.voteAverage.toStringAsFixed(1)} / 10',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(width: 16),
                Text(
                  '(${movie.voteCount} votes)',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Overview",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              movie.overview,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
