part of 'concept_cubit.dart';

abstract class ConceptState extends Equatable {
  const ConceptState();

  @override
  List<Object> get props => [];
}

class ConceptInitial extends ConceptState {}

class ConceptLoadInProgress extends ConceptState {}

class ConceptLoaded extends ConceptState {
  final List<Map<String, dynamic>> concepts;

  ConceptLoaded({required this.concepts});
}

class ConceptLoadFailure extends ConceptState {
  final Failure failure;

  ConceptLoadFailure({required this.failure});
}
