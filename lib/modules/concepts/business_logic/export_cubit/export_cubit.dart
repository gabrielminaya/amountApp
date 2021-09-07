import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart' as openfile;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

enum ExportState {
  exportInital,
  exportSuccess,
  exportError,
}

class ExportCubit extends Cubit<ExportState> {
  ExportCubit() : super(ExportState.exportInital);

  Future<void> exportToExcel(List<Map<String, dynamic>> concepts) async {
    await Permission.storage.request();

    final excel = Excel.createExcel();
    final directory = await getApplicationDocumentsDirectory();
    var totalNegativeAmount = 0.0;
    var totalPositiveAmount = 0.0;
    var totalAmount = 0.0;

    for (final item in concepts) {
      if (double.parse(item["amount"].toString()) > 0) {
        totalPositiveAmount += double.parse(item["amount"].toString());
      }
      if (double.parse(item["amount"].toString()) < 0) {
        totalNegativeAmount += double.parse(item["amount"].toString());
      }
      totalAmount += double.parse(item["amount"].toString());
    }

    excel.rename("Sheet1", "DUMP");

    excel.appendRow("DUMP", ["FECHA", "CONCEPTO", "MONTO"]);
    for (final item in concepts) {
      final effetiveDate = DateTime.fromMicrosecondsSinceEpoch(
          int.parse(item["effective_date"].toString()));
      excel.appendRow(
        "DUMP",
        [
          "${effetiveDate.day}/${effetiveDate.month}/${effetiveDate.year}",
          item["description"],
          item["amount"],
        ],
      );
    }
    excel.appendRow("DUMP", ["", "MONTO POSITIVO TOTAL", totalPositiveAmount]);
    excel.appendRow("DUMP", ["", "MONTO NEGATIVO TOTAL", totalNegativeAmount]);
    excel.appendRow("DUMP", ["", "MONTO TOTAL", totalAmount]);

    final fileBytes = excel.save();

    if (fileBytes != null) {
      File(join(directory.path, "data.xls"))
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }

    await openfile.OpenFile.open(join(directory.path, "data.xls"));
  }

  Future<void> exportToPdf(List<Map<String, dynamic>> concepts) async {
    final pdf = pw.Document();
    final directory = await getApplicationDocumentsDirectory();
    final dateNow = DateTime.now();
    var totalNegativeAmount = 0.0;
    var totalPositiveAmount = 0.0;
    var totalAmount = 0.0;

    for (final item in concepts) {
      if (double.parse(item["amount"].toString()) > 0) {
        totalPositiveAmount += double.parse(item["amount"].toString());
      }
      if (double.parse(item["amount"].toString()) < 0) {
        totalNegativeAmount += double.parse(item["amount"].toString());
      }
      totalAmount += double.parse(item["amount"].toString());
    }

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(children: [
            pw.Text(
              "Desarrollado por Gabriel Minaya",
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey400),
            ),
            pw.SizedBox(height: 20),
            pw.Text("REPORTE EMITIDO EL ${dateNow.day}/${dateNow.month}/${dateNow.year}"),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(data: [
              ["FECHA", "CONCEPTO", "MONTO"],
              for (var item in concepts) ...[
                [
                  "${DateTime.fromMicrosecondsSinceEpoch(int.parse(item["effective_date"].toString())).day}/${DateTime.fromMicrosecondsSinceEpoch(int.parse(item["effective_date"].toString())).month}/${DateTime.fromMicrosecondsSinceEpoch(int.parse(item["effective_date"].toString())).year}",
                  item["description"].toString(),
                  item["amount"].toString()
                ]
              ],
              ["", "MONTO POSITIVO TOTAL", totalPositiveAmount],
              ["", "MONTO NEGATIVO TOTAL", totalNegativeAmount],
              ["", "MONTO TOTAL", totalAmount]
            ]),
          ]);
          // Center
        }));

    final fileBytes = await pdf.save();

    File(join(directory.path, "data.pdf"))
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes);
    await openfile.OpenFile.open(join(directory.path, "data.pdf"));
  }
}
