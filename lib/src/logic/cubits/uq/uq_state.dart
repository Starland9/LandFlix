part of 'uq_cubit.dart';

sealed class UqState extends Equatable {
  const UqState();

  @override
  List<Object> get props => [];
}

final class UqInitial extends UqState {}

final class UqLoading extends UqState {}

final class UqError extends UqState {
  final String message;
  const UqError(this.message);
}

final class UqSearchLoaded extends UqState {
  final List<SearchResult> results;
  const UqSearchLoaded(this.results);
}

final class UqVideosLoaded extends UqState {
  final List<Uqvideo> results;
  const UqVideosLoaded(this.results);
}
