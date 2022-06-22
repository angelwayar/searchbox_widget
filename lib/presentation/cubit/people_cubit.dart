import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:search_box_widget/data/mock/persona.mock.dart';
import 'package:search_box_widget/data/model/persona.dart';
part 'people_state.dart';

class PeopleCubit extends Cubit<PeopleState> {
  PeopleCubit() : super(PeopleState(status: StateCubit.initial));

  onGetPeople() async {
    emit(PeopleState(status: StateCubit.loading));
    await Future.delayed(const Duration(seconds: 2));
    emit(
      PeopleState(
        status: StateCubit.success,
        persona: peopleMock,
      ),
    );
  }
}
