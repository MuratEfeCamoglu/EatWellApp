/// Local drift rows → server rows (snake_case columns of
/// `supabase/migrations`). `user_id` is filled by the server from the
/// session and `server_updated_at` by its trigger, so neither is sent.
/// `synced_at` is local bookkeeping and never leaves the device.
library;

import 'package:flutter/foundation.dart';

import '../db/app_database.dart';

Map<String, Object?> foodLogToServer(FoodLogRow r) => {
      'id': r.id,
      'created_at': r.createdAt,
      'updated_at': r.updatedAt,
      'deleted_at': r.deletedAt,
      'date': r.date,
      'meal': r.meal,
      'food_name': r.foodName,
      'brand': r.brand,
      'serving_label': r.servingLabel,
      'amount': r.amount,
      'kcal': r.kcal,
      'protein_g': r.proteinG,
      'carbs_g': r.carbsG,
      'fat_g': r.fatG,
      'source': r.source,
      'source_ref': r.sourceRef,
      'logged_at': r.loggedAt,
    };

Map<String, Object?> waterToServer(WaterLogRow r) => {
      'id': r.id,
      'created_at': r.createdAt,
      'updated_at': r.updatedAt,
      'deleted_at': r.deletedAt,
      'date': r.date,
      'glasses': r.glasses,
    };

Map<String, Object?> weightToServer(WeightRow r) => {
      'id': r.id,
      'created_at': r.createdAt,
      'updated_at': r.updatedAt,
      'deleted_at': r.deletedAt,
      'date': r.date,
      'kg': r.kg,
      'measured_at': r.measuredAt,
    };

Map<String, Object?> customFoodToServer(CustomFoodRow r) => {
      'id': r.id,
      'created_at': r.createdAt,
      'updated_at': r.updatedAt,
      'deleted_at': r.deletedAt,
      'name': r.name,
      'brand': r.brand,
      'serving_label': r.servingLabel,
      'kcal_per_serving': r.kcalPerServing,
      'protein_g': r.proteinG,
      'carbs_g': r.carbsG,
      'fat_g': r.fatG,
      'category': r.category,
      'barcode': r.barcode,
    };

/// Arguments of the `upsert_water` RPC for a [waterToServer] row.
Map<String, Object?> waterRpcParams(Map<String, Object?> row) => {
      'p_id': row['id'],
      'p_date': row['date'],
      'p_glasses': row['glasses'],
      'p_created_at': row['created_at'],
      'p_updated_at': row['updated_at'],
      'p_deleted_at': row['deleted_at'],
    };

/// Server tables the push covers.
const pushedTables = [
  'food_log_entries',
  'water_logs',
  'weight_entries',
  'custom_foods',
];

/// Keys a pushed row of [table] carries; lets a test compare them with the
/// migration files so app and server can't silently drift apart.
@visibleForTesting
Set<String> sampleRowKeys(String table) => switch (table) {
      'food_log_entries' => foodLogToServer(const FoodLogRow(
              id: '', createdAt: 0, updatedAt: 0, date: '', meal: '',
              foodName: '', brand: '', servingLabel: '', amount: 1, kcal: 0,
              proteinG: 0, carbsG: 0, fatG: 0, source: '', loggedAt: 0))
          .keys
          .toSet(),
      'water_logs' => waterToServer(const WaterLogRow(
              id: '', createdAt: 0, updatedAt: 0, date: '', glasses: 0))
          .keys
          .toSet(),
      'weight_entries' => weightToServer(const WeightRow(
              id: '', createdAt: 0, updatedAt: 0, date: '', kg: 70,
              measuredAt: 0))
          .keys
          .toSet(),
      'custom_foods' => customFoodToServer(const CustomFoodRow(
              id: '', createdAt: 0, updatedAt: 0, name: '', brand: '',
              servingLabel: '', kcalPerServing: 0, proteinG: 0, carbsG: 0,
              fatG: 0, category: ''))
          .keys
          .toSet(),
      _ => throw ArgumentError.value(table),
    };
