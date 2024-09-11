part of 'popular_bloc.dart';

sealed class PopularEvent extends Equatable {
  const PopularEvent();

  @override
  List<Object> get props => [];
}

class FetchPopular extends PopularEvent {}
