part of 'people_cubit.dart';

enum StateCubit { initial, loading, success, error }

class PeopleState {
  final List<Persona>? persona;
  final StateCubit status;

  PeopleState copyWith({
    List<Persona>? persona,
    StateCubit? status,
  }) {
    return PeopleState(
      status: status ?? this.status,
      persona: persona ?? this.persona,
    );
  }

  PeopleState({this.persona, required this.status});
}
