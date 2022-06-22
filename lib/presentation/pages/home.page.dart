import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:search_box_widget/data/model/persona.dart';
import 'package:search_box_widget/presentation/cubit/people_cubit.dart';
import 'package:search_box_widget/presentation/widgets/searchbox.widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController textEditingController;
  late final TextEditingController textEditingControllerApellido;
  late final TextEditingController textEditingControllerEdad;

  @override
  void initState() {
    textEditingController = TextEditingController();
    textEditingControllerApellido = TextEditingController();
    textEditingControllerEdad = TextEditingController();
    textEditingController.addListener(() {
      if (textEditingController.text != '') {
        BlocProvider.of<PeopleCubit>(context).onGetPeople();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    BlocProvider.of<PeopleCubit>(context).close();
    textEditingController.dispose();
    super.dispose();
  }

  static String _displayForOption(Persona persona) => persona.name;

  _getStateForSearchbox(StateCubit state) {
    switch (state) {
      case StateCubit.loading:
        return StateOfSearchbox.loading;
      case StateCubit.success:
        return StateOfSearchbox.success;
      case StateCubit.error:
        return StateOfSearchbox.error;
      default:
        return StateOfSearchbox.initial;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Searchbox'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<PeopleCubit, PeopleState>(
              builder: (context, state) {
                return SearchboxWidget<Persona>(
                  textEditingController: textEditingController,
                  displayStringForOption: _displayForOption,
                  customClassHelper: CustomClass(
                    data: state.status == StateCubit.success
                        ? state.persona
                        : null,
                    stateOfSearchbox: _getStateForSearchbox(state.status),
                  ),
                  textStyle: const TextStyle(fontSize: 24.0),
                  label: const Text('Nombre'),
                  onSelected: (Persona persona) {
                    textEditingControllerApellido.text = persona.apellido;
                    textEditingControllerEdad.text = persona.edad.toString();
                    log('Nombre de la Persona ${persona.name}');
                    log('Apellido de la Persona ${persona.apellido}');
                    log('Edad de la Persona ${persona.edad}');
                  },
                );
              },
            ),
            TextFormField(
              decoration: const InputDecoration(label: Text('Apellido')),
              controller: textEditingControllerApellido,
            ),
            TextFormField(
              decoration: const InputDecoration(label: Text('Edad')),
              controller: textEditingControllerEdad,
            ),
          ],
        ),
      ),
    );
  }
}
