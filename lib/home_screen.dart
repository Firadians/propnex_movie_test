import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/recommendation_bloc.dart';
import 'bloc/popular_state.dart';
import 'bloc/movie_bloc.dart';
import 'bloc/movie_event.dart';
import 'bloc/movie_state.dart';
import 'bloc/popular_bloc.dart';
import 'bloc/search_bloc.dart';
import 'models/movie_model.dart';
import 'search_screen.dart';
import 'movie_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isDialogShowing = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      _handleConnectivityChange(result);
    });

    _tabController = TabController(length: 3, vsync: this);
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _showNoConnectionDialog();
    } else {
      _closeNoConnectionDialog();
    }
  }

  void _showNoConnectionDialog() {
    if (!_isDialogShowing) {
      _isDialogShowing = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text("No Internet Connection"),
            content:
                Text("Please check your internet connection and try again."),
            actions: <Widget>[
              TextButton(
                child: Text("Retry"),
                onPressed: () {
                  _checkConnection();
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  void _closeNoConnectionDialog() {
    if (_isDialogShowing) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogShowing = false;
    }
  }

  void _checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      _closeNoConnectionDialog();
    } else {
      _showNoConnectionDialog();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: SafeArea(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => MovieBloc()..add(FetchNowPlaying())),
            BlocProvider(create: (_) => PopularBloc()..add(FetchPopular())),
            BlocProvider(
                create: (_) => RecommendationBloc()
                  ..add(FetchRecommendation(movieId: 300))),
            BlocProvider(create: (_) => SearchBloc()),
          ],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(context),
                SizedBox(height: 20),
                _buildTabBar(),
                SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCurrentCodePage(),
                      _buildMovieGrid('Playing Now'),
                      _buildMovieGrid('Popular'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => SearchBloc(),
              child: SearchScreen(),
            ),
          ),
        );
      },
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[850],
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Find movies...',
          hintStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(25.0),
        ),
        tabs: [
          Tab(text: 'All'),
          Tab(text: 'Playing Now'),
          Tab(text: 'Popular'),
        ],
      ),
    );
  }

  Widget _buildCurrentCodePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          _buildMovieSection('Playing Now'),
          SizedBox(height: 20),
          _buildMovieSection('Popular'),
          SizedBox(height: 20),
          _buildMovieSection('Recommendation'),
        ],
      ),
    );
  }

  Widget _buildMovieSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 150,
          child: _getBlocBuilder(title),
        ),
      ],
    );
  }

  Widget _buildMovieGrid(String title) {
    if (title == 'Playing Now') {
      return BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state is MovieLoading) {
            return _buildShimmerLoading();
          } else if (state is MovieNowPlayingLoaded) {
            final movies = state.movies;
            return _buildMovieGridContent(movies);
          } else if (state is MovieError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );
    } else if (title == 'Popular') {
      return BlocBuilder<PopularBloc, PopularState>(
        builder: (context, state) {
          if (state is PopularLoading) {
            return _buildShimmerLoading();
          } else if (state is PopularLoaded) {
            final movies = state.movies;
            return _buildMovieGridContent(movies);
          } else if (state is PopularError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );
    } else {
      return Center(
        child: Text(
          'Invalid Tab',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  Widget _buildMovieGridContent(List<Movie> movies) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(movie: movie),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: CachedNetworkImage(
                imageUrl: 'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildShimmerLoading(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getBlocBuilder(String title) {
    switch (title) {
      case "Playing Now":
        return BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            if (state is MovieLoading) {
              return _buildShimmerLoading();
            } else if (state is MovieNowPlayingLoaded) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.movies.length,
                itemBuilder: (context, index) {
                  Movie movie = state.movies[index];
                  return _buildMovieCard(movie, context);
                },
              );
            } else if (state is MovieError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        );
      case "Popular":
        return BlocBuilder<PopularBloc, PopularState>(
          builder: (context, state) {
            if (state is PopularLoading) {
              return _buildShimmerLoading();
            } else if (state is PopularLoaded) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.movies.length,
                itemBuilder: (context, index) {
                  Movie movie = state.movies[index];
                  return _buildMovieCard(movie, context);
                },
              );
            } else if (state is PopularError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return Center(
              child: Text(
                'No data available Popular',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        );
      case "Recommendation":
        return BlocBuilder<RecommendationBloc, RecommendationState>(
          builder: (context, state) {
            if (state is RecommendationLoading) {
              return _buildShimmerLoading();
            } else if (state is RecommendationLoaded) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.movies.length,
                itemBuilder: (context, index) {
                  Movie movie = state.movies[index];
                  return _buildMovieCard(movie, context);
                },
              );
            } else if (state is RecommendationError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return Center(
              child: Text(
                'No data available Recommend',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        );
      default:
        return Container();
    }
  }

  Widget _buildMovieCard(Movie movie, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke MovieDetailScreen saat kartu film ditekan
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: CachedNetworkImageProvider(
                'https://image.tmdb.org/t/p/w500${movie.posterPath ?? ""}'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading({double width = 100, double height = 150}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[600]!,
      highlightColor: Colors.grey[400]!,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
