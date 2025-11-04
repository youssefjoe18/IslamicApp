import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/preferences_service.dart';

class TasbihState extends Equatable {
  final int count;
  final int preset;
  const TasbihState({required this.count, required this.preset});

  TasbihState copyWith({int? count, int? preset}) =>
      TasbihState(count: count ?? this.count, preset: preset ?? this.preset);

  @override
  List<Object?> get props => [count, preset];
}

class TasbihCubit extends Cubit<TasbihState> {
  final PreferencesService preferencesService;

  TasbihCubit({required this.preferencesService})
      : super(TasbihState(
          count: preferencesService.getTasbihCount(),
          preset: preferencesService.getTasbihPreset(),
        ));

  Future<void> increment() async {
    final next = state.count + 1;
    emit(state.copyWith(count: next));
    await preferencesService.setTasbihCount(next);
  }

  Future<void> decrement() async {
    final next = state.count > 0 ? state.count - 1 : 0;
    emit(state.copyWith(count: next));
    await preferencesService.setTasbihCount(next);
  }

  Future<void> reset() async {
    emit(state.copyWith(count: 0));
    await preferencesService.setTasbihCount(0);
  }

  Future<void> setPreset(int value) async {
    emit(state.copyWith(preset: value));
    await preferencesService.setTasbihPreset(value);
  }
}


