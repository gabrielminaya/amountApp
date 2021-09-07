import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure/failure.dart';
import '../../data_access/repositories/concept_repository.dart';

part 'concept_state.dart';

class ConceptCubit extends Cubit<ConceptState> {
  final ConceptRepository _conceptRepository;
  List<Map<String, dynamic>> conceptFiltered = [];

  ConceptCubit(this._conceptRepository) : super(ConceptInitial());

  Future<void> fetchAll() async {
    emit(ConceptLoadInProgress());

    final conceptsOrFailure = await _conceptRepository.getAllConcept(
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      amountType: 3,
    );

    return conceptsOrFailure.fold(
      (failure) => emit(ConceptLoadFailure(failure: failure)),
      (concepts) {
        conceptFiltered.clear();
        conceptFiltered.addAll(concepts);
        emit(ConceptLoaded(concepts: concepts));
      },
    );
  }

  Future<void> fetchAllFiltered({
    required DateTime firstDate,
    required DateTime lastDate,
    required int amountType,
  }) async {
    emit(ConceptLoadInProgress());

    final conceptsOrFailure = await _conceptRepository.getAllConcept(
      firstDate: firstDate,
      lastDate: lastDate,
      amountType: amountType,
    );

    return conceptsOrFailure.fold(
      (failure) => emit(ConceptLoadFailure(failure: failure)),
      (concepts) {
        conceptFiltered.clear();
        conceptFiltered.addAll(concepts);
        emit(ConceptLoaded(concepts: concepts));
      },
    );
  }

  Future<void> create({
    required int effectiveDate,
    required String description,
    required double amount,
  }) async {
    final successOrFailure = await _conceptRepository.createConcept(
      effectiveDate: effectiveDate,
      description: description,
      amount: amount,
    );

    return successOrFailure.fold(
      (failure) async {
        emit(ConceptLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) => fetchAll(),
    );
  }

  Future<void> update({
    required int id,
    required int effectiveDate,
    required String description,
    required double amount,
  }) async {
    final successOrFailure = await _conceptRepository.updateConcept(
      id: id,
      effectiveDate: effectiveDate,
      description: description,
      amount: amount,
    );

    return successOrFailure.fold(
      (failure) async {
        emit(ConceptLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) => fetchAll(),
    );
  }

  Future<void> delete({required int id}) async {
    final successOrFailure = await _conceptRepository.deleteConcept(id: id);

    return successOrFailure.fold(
      (failure) async {
        emit(ConceptLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) => fetchAll(),
    );
  }
}
