import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database.dart';
import '../../../../core/error/exceptions/errors.dart';
import '../../../../core/error/failure/failure.dart';

class ConceptRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllConcept({
    required DateTime firstDate,
    required DateTime lastDate,
    required int amountType,
  }) async {
    try {
      final db = await AppDatabase.instance.database;

      final concepts = await db.rawQuery(
        """
        SELECT * FROM amounts 
        WHERE status_id != 3
        order by effective_date desc
      """,
      );

      final conceptsFiltered = <Map<String, dynamic>>[];

      for (final item in concepts) {
        final date = DateTime.fromMicrosecondsSinceEpoch(
          int.parse(item["effective_date"].toString()),
        );

        if (date.isAfter(firstDate)) {
          if (date.isBefore(lastDate)) {
            if (amountType == 3) {
              conceptsFiltered.add(item);
            } else {
              if (item["amount_type"] == amountType) {
                conceptsFiltered.add(item);
              }
            }
          }
        }
      }

      return right(conceptsFiltered);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> createConcept({
    required int effectiveDate,
    required String description,
    required double amount,
  }) async {
    try {
      final db = await AppDatabase.instance.database;

      //TODO: AGREGAR USUARIO

      final id = await db.rawInsert("""
        INSERT INTO amounts(
          amount_type,
          description,
          amount,
          effective_date,
          created_date,
          created_by,
          status_id
        ) VALUES(?,?,?,?,?,?,?);
      """, [
        if (amount > 0) 1 else 2,
        description,
        amount,
        effectiveDate,
        DateTime.now().microsecondsSinceEpoch,
        1,
        1
      ]);

      return right(id);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> updateConcept({
    required int id,
    required int effectiveDate,
    required String description,
    required double amount,
  }) async {
    try {
      final db = await AppDatabase.instance.database;

      final uid = await db.rawUpdate("""
          UPDATE amounts 
          SET amount_type = ?, 
              description = ?, 
              amount = ?, 
              effective_date = ?
          WHERE id = ?
      """, [if (amount > 0) 1 else 2, description, amount, effectiveDate, id]);

      return right(uid);
    } on SystemError catch (error) {
      return left(Failure(message: error.message));
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> deleteConcept({required int id}) async {
    try {
      final db = await AppDatabase.instance.database;

      final did = await db.rawUpdate("""
          UPDATE amounts SET status_id = 3
          WHERE id = ?
      """, [id]);

      return right(did);
    } on SystemError catch (error) {
      return left(Failure(message: error.message));
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }
}
