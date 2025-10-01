import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:french_stream_downloader/src/logic/models/search_result.dart';
import 'package:french_stream_downloader/src/logic/models/uqvideo.dart';
import 'package:french_stream_downloader/src/logic/repos/uq_repo.dart';

part 'uq_state.dart';

class UqCubit extends Cubit<UqState> {
  final UqRepo _uqRepo;

  UqCubit(this._uqRepo) : super(UqInitial());

  Future<void> search(String query) async {
    if (isClosed) return;
    emit(UqLoading());
    try {
      final results = await _uqRepo.search(query);
      if (!isClosed) {
        emit(UqSearchLoaded(results));
      }
    } catch (e) {
      if (!isClosed) {
        emit(UqError(e.toString()));
      }
    }
  }

  Future<void> getUqVideos({required String htmlUrl}) async {
    if (isClosed) return;
    emit(UqLoading());
    try {
      final results = await _uqRepo.getUqVideos(htmlUrl: htmlUrl);
      if (!isClosed) {
        emit(UqVideosLoaded(results));
      }
    } catch (e) {
      if (!isClosed) {
        emit(UqError(e.toString()));
      }
    }
  }
}
