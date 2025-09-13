import 'package:flutter_bloc/flutter_bloc.dart';

class SpeechCubit extends Cubit<String> {
  SpeechCubit() : super("");
  void change(String value) => emit(value);
}
