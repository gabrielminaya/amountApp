import 'package:animations/animations.dart';
import 'package:consent_amount/modules/concepts/business_logic/export_cubit/export_cubit.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/error_page_widget.dart';
import '../../../../core/show_scaffold_messenger.dart';
import '../../business_logic/brightness_mode_cubit/brightness_mode_cubit.dart';
import '../../business_logic/concept_cubit/concept_cubit.dart';

class ConceptPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di<ExportCubit>(),
          child: ConceptView(),
        ),
        BlocProvider(
          create: (context) => di<ConceptCubit>()..fetchAll(),
          child: ConceptView(),
        ),
      ],
      child: ConceptView(),
    );
  }
}

class ConceptView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MONTOS"),
        actions: [
          // IconButton(
          //   onPressed: () => context.read<ConceptCubit>().fetchAll(),
          //   icon: const Icon(Icons.autorenew_rounded),
          // ),
          IconButton(
            onPressed: () => context.read<BrightnessModeCubit>().changeMode(),
            icon: BlocBuilder<BrightnessModeCubit, brightnessModeState>(
              builder: (context, state) {
                switch (state) {
                  case brightnessModeState.lightMode:
                    return const Icon(Icons.light_mode);
                  case brightnessModeState.darkMode:
                    return const Icon(Icons.dark_mode);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload_rounded),
            onPressed: () async {
              showModal(
                context: context,
                builder: (ctx) {
                  var optionSelected = 1;

                  return AlertDialog(
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Divider(),
                        Text("SELECCIONA FORMATO"),
                        Divider(),
                      ],
                    ),
                    content: StatefulBuilder(builder: (statefulContext, setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<int>(
                            value: optionSelected,
                            items: const [
                              DropdownMenuItem(
                                value: 1,
                                child: Text("PDF"),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text("Excel"),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                optionSelected = value;
                                setState(() {});
                              }
                            },
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text("Cancelar"),
                              ),
                              const VerticalDivider(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).errorColor,
                                ),
                                onPressed: () {
                                  if (optionSelected == 1) {
                                    context.read<ExportCubit>().exportToPdf(
                                        context.read<ConceptCubit>().conceptFiltered);
                                  } else {
                                    context.read<ExportCubit>().exportToExcel(
                                        context.read<ConceptCubit>().conceptFiltered);
                                  }

                                  Navigator.of(ctx).pop();
                                },
                                child: const Text("Exportar"),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  );
                },
              );
            },
          ),
          IconButton(
            onPressed: () => filterConcept(mainContext: context),
            icon: const Icon(Icons.filter_list_rounded),
          ),
          IconButton(
            onPressed: () => createOrUpdateConcept(mainContext: context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: BlocConsumer<ConceptCubit, ConceptState>(
        listener: (context, state) {
          if (state is ConceptLoadFailure) {
            showScaffoldMessenger(
              context: context,
              message: state.failure.message,
            );
          }
        },
        builder: (context, state) {
          if (state is ConceptLoadInProgress) {
            return const CircularProgressIndicator();
          } else if (state is ConceptLoaded) {
            var totalNegativeAmount = 0.0;
            var totalPositiveAmount = 0.0;
            var totalAmount = 0.0;

            for (final item in state.concepts) {
              if (double.parse(item["amount"].toString()) > 0) {
                totalPositiveAmount += double.parse(item["amount"].toString());
              }
              if (double.parse(item["amount"].toString()) < 0) {
                totalNegativeAmount += double.parse(item["amount"].toString());
              }
              totalAmount += double.parse(item["amount"].toString());
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  PaginatedDataTable(
                    columns: const [
                      DataColumn(label: Text("FECHA")),
                      DataColumn(label: Text("CONCEPTO")),
                      DataColumn(label: Text("MONTO")),
                      DataColumn(label: Text("ACCIONES")),
                    ],
                    source: ConceptDataSource(context: context, concepts: state.concepts),
                  ),
                  FittedBox(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * .9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("MONTO POSITIVO TOTAL:    $totalPositiveAmount"),
                          Text("MONTO NEGATIVO TOTAL:    $totalNegativeAmount"),
                          Text("MONTO TOTAL:    $totalAmount"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return ErrorPage();
          }
        },
      ),
    );
  }
}

class ConceptDataSource extends DataTableSource {
  final List<Map<String, dynamic>> concepts;
  final BuildContext context;

  ConceptDataSource({required this.context, required this.concepts});

  @override
  DataRow? getRow(int index) {
    final concept = concepts[index];
    final date = DateTime.fromMicrosecondsSinceEpoch(
      int.parse(concept["effective_date"].toString()),
    );

    return DataRow(cells: [
      DataCell(Text("${date.day}/${date.month}/${date.year}")),
      DataCell(Text(concept["description"].toString())),
      DataCell(Text(
        concept["amount"].toString(),
        style: TextStyle(
          color: concept["amount_type"] == 1 ? Colors.green : Colors.red,
        ),
      )),
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => createOrUpdateConcept(
                mainContext: context,
                concept: concept,
              ),
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).accentColor,
              ),
            ),
            IconButton(
              onPressed: () {
                context
                    .read<ConceptCubit>()
                    .delete(id: int.parse(concept["id"].toString()));
              },
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).errorColor,
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => concepts.length;

  @override
  int get selectedRowCount => concepts.length;
}

Future<void> filterConcept({required BuildContext mainContext}) {
  final formKey = GlobalKey<FormState>();
  var amountType = 3;
  var firstDate = DateTime.now().subtract(const Duration(days: 30));
  var lastDate = DateTime.now();

  return showModal(
    context: mainContext,
    builder: (context) {
      return AlertDialog(
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DateTimeFormField(
                initialEntryMode: DatePickerEntryMode.calendarOnly,
                lastDate: DateTime.now().add(const Duration(days: 365)),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                initialValue: firstDate,
                mode: DateTimeFieldPickerMode.date,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: "FECHA INICIAL",
                ),
                onDateSelected: (newValue) {
                  firstDate = newValue;
                },
              ),
              const Divider(),
              DateTimeFormField(
                initialEntryMode: DatePickerEntryMode.calendarOnly,
                lastDate: DateTime.now().add(const Duration(days: 365)),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                initialValue: lastDate,
                mode: DateTimeFieldPickerMode.date,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: "FECHA FINAL",
                ),
                onDateSelected: (newValue) {
                  lastDate = newValue;
                },
              ),
              const Divider(),
              DropdownButtonFormField<int>(
                value: amountType,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: "TIPO DE MONTO",
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text("Positivo"),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text("Negativo"),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text("Ambos"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    amountType = value;
                  }
                },
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.cancel),
                    label: const Text("Cancelar"),
                  ),
                  const VerticalDivider(),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (formKey.currentState != null) {
                        formKey.currentState!.validate();

                        mainContext.read<ConceptCubit>().fetchAllFiltered(
                            firstDate: firstDate,
                            lastDate: lastDate,
                            amountType: amountType);

                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.download),
                    label: const Text("Filtrar"),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).errorColor,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}

Future<void> createOrUpdateConcept({
  required BuildContext mainContext,
  Map<String, dynamic>? concept,
}) {
  final formKey = GlobalKey<FormState>();
  final descriptionController = concept == null
      ? TextEditingController()
      : TextEditingController(text: concept["description"].toString());
  final amountController = concept == null
      ? TextEditingController()
      : TextEditingController(text: concept["amount"].toString());
  var effectiveDate = concept == null
      ? DateTime.now()
      : DateTime.fromMicrosecondsSinceEpoch(
          int.parse(concept["effective_date"].toString()),
        );

  return showModal(
    context: mainContext,
    builder: (context) {
      return AlertDialog(
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DateTimeFormField(
                initialEntryMode: DatePickerEntryMode.calendarOnly,
                lastDate: DateTime.now().add(const Duration(days: 365)),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                initialValue: effectiveDate,
                mode: DateTimeFieldPickerMode.date,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: "FECHA EFECTIVA",
                ),
                onDateSelected: (newValue) {
                  effectiveDate = newValue;
                },
              ),
              const Divider(),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: "CONCEPTO",
                ),
                maxLength: 50,
                validator: (value) => value!.isEmpty ? "CAMPO NECESARIO" : null,
              ),
              const Divider(),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: "MONTO",
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "CAMPO NECESARIO" : null,
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.cancel),
                    label: const Text("Cancelar"),
                  ),
                  const VerticalDivider(),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (formKey.currentState != null) {
                        formKey.currentState!.validate();

                        final description = descriptionController.text;
                        final amount = amountController.text;

                        if (concept == null) {
                          mainContext.read<ConceptCubit>().create(
                              effectiveDate: effectiveDate.microsecondsSinceEpoch,
                              amount: double.parse(amount),
                              description: description);
                        } else {
                          mainContext.read<ConceptCubit>().update(
                              id: int.parse(concept["id"].toString()),
                              effectiveDate: effectiveDate.microsecondsSinceEpoch,
                              description: description,
                              amount: double.parse(amount));
                        }

                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.download),
                    label:
                        concept == null ? const Text("Agregar") : const Text("Corregir"),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).errorColor,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
