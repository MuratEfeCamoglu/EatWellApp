// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FoodLogEntriesTable extends FoodLogEntries
    with TableInfo<$FoodLogEntriesTable, FoodLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealMeta = const VerificationMeta('meal');
  @override
  late final GeneratedColumn<String> meal = GeneratedColumn<String>(
    'meal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _servingLabelMeta = const VerificationMeta(
    'servingLabel',
  );
  @override
  late final GeneratedColumn<String> servingLabel = GeneratedColumn<String>(
    'serving_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<int> kcal = GeneratedColumn<int>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceRefMeta = const VerificationMeta(
    'sourceRef',
  );
  @override
  late final GeneratedColumn<String> sourceRef = GeneratedColumn<String>(
    'source_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<int> loggedAt = GeneratedColumn<int>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
    serverUpdatedAt,
    date,
    meal,
    foodName,
    brand,
    servingLabel,
    amount,
    kcal,
    proteinG,
    carbsG,
    fatG,
    source,
    sourceRef,
    loggedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('meal')) {
      context.handle(
        _mealMeta,
        meal.isAcceptableOrUnknown(data['meal']!, _mealMeta),
      );
    } else if (isInserting) {
      context.missing(_mealMeta);
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('serving_label')) {
      context.handle(
        _servingLabelMeta,
        servingLabel.isAcceptableOrUnknown(
          data['serving_label']!,
          _servingLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_servingLabelMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinGMeta);
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsGMeta);
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    } else if (isInserting) {
      context.missing(_fatGMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('source_ref')) {
      context.handle(
        _sourceRefMeta,
        sourceRef.isAcceptableOrUnknown(data['source_ref']!, _sourceRefMeta),
      );
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      meal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal'],
      )!,
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      servingLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_label'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kcal'],
      )!,
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      )!,
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      )!,
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ref'],
      ),
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}logged_at'],
      )!,
    );
  }

  @override
  $FoodLogEntriesTable createAlias(String alias) {
    return $FoodLogEntriesTable(attachedDatabase, alias);
  }
}

class FoodLogRow extends DataClass implements Insertable<FoodLogRow> {
  /// UUID v4 generated on the device.
  final String id;
  final int createdAt;

  /// Refreshed on every change; the future sync's "last write wins" key.
  final int updatedAt;

  /// Soft-delete marker: rows are hidden rather than removed so a delete
  /// can still be propagated to other devices.
  final int? deletedAt;

  /// When this version of the row last reached the cloud (UTC ms); null
  /// or older than [updatedAt] means it still has to be pushed.
  final int? syncedAt;

  /// The server's own timestamp for this row (schema v2). Pull cursors use
  /// it instead of the phone's clock, which may be wrong (CLAUDE.md §13.1).
  final int? serverUpdatedAt;

  /// Local day, `yyyy-MM-dd`.
  final String date;

  /// `MealType.name`.
  final String meal;
  final String foodName;
  final String brand;
  final String servingLabel;

  /// Multiplier of the serving described by [servingLabel].
  final double amount;

  /// Totals for [amount] servings, frozen at log time.
  final int kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;

  /// `catalog` / `recipe` / `barcode` / `photo` / `custom`.
  final String source;

  /// Barcode number or `custom_foods.id`, depending on [source].
  final String? sourceRef;

  /// When the food was added, UTC ms; orders entries within a day.
  final int loggedAt;
  const FoodLogRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
    this.serverUpdatedAt,
    required this.date,
    required this.meal,
    required this.foodName,
    required this.brand,
    required this.servingLabel,
    required this.amount,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.source,
    this.sourceRef,
    required this.loggedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    map['date'] = Variable<String>(date);
    map['meal'] = Variable<String>(meal);
    map['food_name'] = Variable<String>(foodName);
    map['brand'] = Variable<String>(brand);
    map['serving_label'] = Variable<String>(servingLabel);
    map['amount'] = Variable<double>(amount);
    map['kcal'] = Variable<int>(kcal);
    map['protein_g'] = Variable<double>(proteinG);
    map['carbs_g'] = Variable<double>(carbsG);
    map['fat_g'] = Variable<double>(fatG);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceRef != null) {
      map['source_ref'] = Variable<String>(sourceRef);
    }
    map['logged_at'] = Variable<int>(loggedAt);
    return map;
  }

  FoodLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return FoodLogEntriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      date: Value(date),
      meal: Value(meal),
      foodName: Value(foodName),
      brand: Value(brand),
      servingLabel: Value(servingLabel),
      amount: Value(amount),
      kcal: Value(kcal),
      proteinG: Value(proteinG),
      carbsG: Value(carbsG),
      fatG: Value(fatG),
      source: Value(source),
      sourceRef: sourceRef == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRef),
      loggedAt: Value(loggedAt),
    );
  }

  factory FoodLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodLogRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      date: serializer.fromJson<String>(json['date']),
      meal: serializer.fromJson<String>(json['meal']),
      foodName: serializer.fromJson<String>(json['foodName']),
      brand: serializer.fromJson<String>(json['brand']),
      servingLabel: serializer.fromJson<String>(json['servingLabel']),
      amount: serializer.fromJson<double>(json['amount']),
      kcal: serializer.fromJson<int>(json['kcal']),
      proteinG: serializer.fromJson<double>(json['proteinG']),
      carbsG: serializer.fromJson<double>(json['carbsG']),
      fatG: serializer.fromJson<double>(json['fatG']),
      source: serializer.fromJson<String>(json['source']),
      sourceRef: serializer.fromJson<String?>(json['sourceRef']),
      loggedAt: serializer.fromJson<int>(json['loggedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'date': serializer.toJson<String>(date),
      'meal': serializer.toJson<String>(meal),
      'foodName': serializer.toJson<String>(foodName),
      'brand': serializer.toJson<String>(brand),
      'servingLabel': serializer.toJson<String>(servingLabel),
      'amount': serializer.toJson<double>(amount),
      'kcal': serializer.toJson<int>(kcal),
      'proteinG': serializer.toJson<double>(proteinG),
      'carbsG': serializer.toJson<double>(carbsG),
      'fatG': serializer.toJson<double>(fatG),
      'source': serializer.toJson<String>(source),
      'sourceRef': serializer.toJson<String?>(sourceRef),
      'loggedAt': serializer.toJson<int>(loggedAt),
    };
  }

  FoodLogRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    Value<int?> syncedAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    String? date,
    String? meal,
    String? foodName,
    String? brand,
    String? servingLabel,
    double? amount,
    int? kcal,
    double? proteinG,
    double? carbsG,
    double? fatG,
    String? source,
    Value<String?> sourceRef = const Value.absent(),
    int? loggedAt,
  }) => FoodLogRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    date: date ?? this.date,
    meal: meal ?? this.meal,
    foodName: foodName ?? this.foodName,
    brand: brand ?? this.brand,
    servingLabel: servingLabel ?? this.servingLabel,
    amount: amount ?? this.amount,
    kcal: kcal ?? this.kcal,
    proteinG: proteinG ?? this.proteinG,
    carbsG: carbsG ?? this.carbsG,
    fatG: fatG ?? this.fatG,
    source: source ?? this.source,
    sourceRef: sourceRef.present ? sourceRef.value : this.sourceRef,
    loggedAt: loggedAt ?? this.loggedAt,
  );
  FoodLogRow copyWithCompanion(FoodLogEntriesCompanion data) {
    return FoodLogRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      date: data.date.present ? data.date.value : this.date,
      meal: data.meal.present ? data.meal.value : this.meal,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      brand: data.brand.present ? data.brand.value : this.brand,
      servingLabel: data.servingLabel.present
          ? data.servingLabel.value
          : this.servingLabel,
      amount: data.amount.present ? data.amount.value : this.amount,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      source: data.source.present ? data.source.value : this.source,
      sourceRef: data.sourceRef.present ? data.sourceRef.value : this.sourceRef,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodLogRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('date: $date, ')
          ..write('meal: $meal, ')
          ..write('foodName: $foodName, ')
          ..write('brand: $brand, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('amount: $amount, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('loggedAt: $loggedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
    serverUpdatedAt,
    date,
    meal,
    foodName,
    brand,
    servingLabel,
    amount,
    kcal,
    proteinG,
    carbsG,
    fatG,
    source,
    sourceRef,
    loggedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodLogRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.date == this.date &&
          other.meal == this.meal &&
          other.foodName == this.foodName &&
          other.brand == this.brand &&
          other.servingLabel == this.servingLabel &&
          other.amount == this.amount &&
          other.kcal == this.kcal &&
          other.proteinG == this.proteinG &&
          other.carbsG == this.carbsG &&
          other.fatG == this.fatG &&
          other.source == this.source &&
          other.sourceRef == this.sourceRef &&
          other.loggedAt == this.loggedAt);
}

class FoodLogEntriesCompanion extends UpdateCompanion<FoodLogRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int?> syncedAt;
  final Value<int?> serverUpdatedAt;
  final Value<String> date;
  final Value<String> meal;
  final Value<String> foodName;
  final Value<String> brand;
  final Value<String> servingLabel;
  final Value<double> amount;
  final Value<int> kcal;
  final Value<double> proteinG;
  final Value<double> carbsG;
  final Value<double> fatG;
  final Value<String> source;
  final Value<String?> sourceRef;
  final Value<int> loggedAt;
  final Value<int> rowid;
  const FoodLogEntriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.date = const Value.absent(),
    this.meal = const Value.absent(),
    this.foodName = const Value.absent(),
    this.brand = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.amount = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodLogEntriesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    required String date,
    required String meal,
    required String foodName,
    this.brand = const Value.absent(),
    required String servingLabel,
    required double amount,
    required int kcal,
    required double proteinG,
    required double carbsG,
    required double fatG,
    required String source,
    this.sourceRef = const Value.absent(),
    required int loggedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       date = Value(date),
       meal = Value(meal),
       foodName = Value(foodName),
       servingLabel = Value(servingLabel),
       amount = Value(amount),
       kcal = Value(kcal),
       proteinG = Value(proteinG),
       carbsG = Value(carbsG),
       fatG = Value(fatG),
       source = Value(source),
       loggedAt = Value(loggedAt);
  static Insertable<FoodLogRow> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? syncedAt,
    Expression<int>? serverUpdatedAt,
    Expression<String>? date,
    Expression<String>? meal,
    Expression<String>? foodName,
    Expression<String>? brand,
    Expression<String>? servingLabel,
    Expression<double>? amount,
    Expression<int>? kcal,
    Expression<double>? proteinG,
    Expression<double>? carbsG,
    Expression<double>? fatG,
    Expression<String>? source,
    Expression<String>? sourceRef,
    Expression<int>? loggedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (date != null) 'date': date,
      if (meal != null) 'meal': meal,
      if (foodName != null) 'food_name': foodName,
      if (brand != null) 'brand': brand,
      if (servingLabel != null) 'serving_label': servingLabel,
      if (amount != null) 'amount': amount,
      if (kcal != null) 'kcal': kcal,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (fatG != null) 'fat_g': fatG,
      if (source != null) 'source': source,
      if (sourceRef != null) 'source_ref': sourceRef,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodLogEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int?>? syncedAt,
    Value<int?>? serverUpdatedAt,
    Value<String>? date,
    Value<String>? meal,
    Value<String>? foodName,
    Value<String>? brand,
    Value<String>? servingLabel,
    Value<double>? amount,
    Value<int>? kcal,
    Value<double>? proteinG,
    Value<double>? carbsG,
    Value<double>? fatG,
    Value<String>? source,
    Value<String?>? sourceRef,
    Value<int>? loggedAt,
    Value<int>? rowid,
  }) {
    return FoodLogEntriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      date: date ?? this.date,
      meal: meal ?? this.meal,
      foodName: foodName ?? this.foodName,
      brand: brand ?? this.brand,
      servingLabel: servingLabel ?? this.servingLabel,
      amount: amount ?? this.amount,
      kcal: kcal ?? this.kcal,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      source: source ?? this.source,
      sourceRef: sourceRef ?? this.sourceRef,
      loggedAt: loggedAt ?? this.loggedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (meal.present) {
      map['meal'] = Variable<String>(meal.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (servingLabel.present) {
      map['serving_label'] = Variable<String>(servingLabel.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<int>(kcal.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceRef.present) {
      map['source_ref'] = Variable<String>(sourceRef.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<int>(loggedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodLogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('date: $date, ')
          ..write('meal: $meal, ')
          ..write('foodName: $foodName, ')
          ..write('brand: $brand, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('amount: $amount, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WaterLogsTable extends WaterLogs
    with TableInfo<$WaterLogsTable, WaterLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _glassesMeta = const VerificationMeta(
    'glasses',
  );
  @override
  late final GeneratedColumn<int> glasses = GeneratedColumn<int>(
    'glasses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
    serverUpdatedAt,
    date,
    glasses,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaterLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('glasses')) {
      context.handle(
        _glassesMeta,
        glasses.isAcceptableOrUnknown(data['glasses']!, _glassesMeta),
      );
    } else if (isInserting) {
      context.missing(_glassesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WaterLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      glasses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}glasses'],
      )!,
    );
  }

  @override
  $WaterLogsTable createAlias(String alias) {
    return $WaterLogsTable(attachedDatabase, alias);
  }
}

class WaterLogRow extends DataClass implements Insertable<WaterLogRow> {
  /// UUID v4 generated on the device.
  final String id;
  final int createdAt;

  /// Refreshed on every change; the future sync's "last write wins" key.
  final int updatedAt;

  /// Soft-delete marker: rows are hidden rather than removed so a delete
  /// can still be propagated to other devices.
  final int? deletedAt;

  /// When this version of the row last reached the cloud (UTC ms); null
  /// or older than [updatedAt] means it still has to be pushed.
  final int? syncedAt;

  /// The server's own timestamp for this row (schema v2). Pull cursors use
  /// it instead of the phone's clock, which may be wrong (CLAUDE.md §13.1).
  final int? serverUpdatedAt;
  final String date;
  final int glasses;
  const WaterLogRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
    this.serverUpdatedAt,
    required this.date,
    required this.glasses,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    map['date'] = Variable<String>(date);
    map['glasses'] = Variable<int>(glasses);
    return map;
  }

  WaterLogsCompanion toCompanion(bool nullToAbsent) {
    return WaterLogsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      date: Value(date),
      glasses: Value(glasses),
    );
  }

  factory WaterLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterLogRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      date: serializer.fromJson<String>(json['date']),
      glasses: serializer.fromJson<int>(json['glasses']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'date': serializer.toJson<String>(date),
      'glasses': serializer.toJson<int>(glasses),
    };
  }

  WaterLogRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    Value<int?> syncedAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    String? date,
    int? glasses,
  }) => WaterLogRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    date: date ?? this.date,
    glasses: glasses ?? this.glasses,
  );
  WaterLogRow copyWithCompanion(WaterLogsCompanion data) {
    return WaterLogRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      date: data.date.present ? data.date.value : this.date,
      glasses: data.glasses.present ? data.glasses.value : this.glasses,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterLogRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('date: $date, ')
          ..write('glasses: $glasses')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
    serverUpdatedAt,
    date,
    glasses,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterLogRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.date == this.date &&
          other.glasses == this.glasses);
}

class WaterLogsCompanion extends UpdateCompanion<WaterLogRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int?> syncedAt;
  final Value<int?> serverUpdatedAt;
  final Value<String> date;
  final Value<int> glasses;
  final Value<int> rowid;
  const WaterLogsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.date = const Value.absent(),
    this.glasses = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WaterLogsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    required String date,
    required int glasses,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       date = Value(date),
       glasses = Value(glasses);
  static Insertable<WaterLogRow> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? syncedAt,
    Expression<int>? serverUpdatedAt,
    Expression<String>? date,
    Expression<int>? glasses,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (date != null) 'date': date,
      if (glasses != null) 'glasses': glasses,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WaterLogsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int?>? syncedAt,
    Value<int?>? serverUpdatedAt,
    Value<String>? date,
    Value<int>? glasses,
    Value<int>? rowid,
  }) {
    return WaterLogsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      date: date ?? this.date,
      glasses: glasses ?? this.glasses,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (glasses.present) {
      map['glasses'] = Variable<int>(glasses.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterLogsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('date: $date, ')
          ..write('glasses: $glasses, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightEntriesTable extends WeightEntries
    with TableInfo<$WeightEntriesTable, WeightRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kgMeta = const VerificationMeta('kg');
  @override
  late final GeneratedColumn<double> kg = GeneratedColumn<double>(
    'kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<int> measuredAt = GeneratedColumn<int>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
    serverUpdatedAt,
    date,
    kg,
    measuredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('kg')) {
      context.handle(_kgMeta, kg.isAcceptableOrUnknown(data['kg']!, _kgMeta));
    } else if (isInserting) {
      context.missing(_kgMeta);
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      kg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kg'],
      )!,
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}measured_at'],
      )!,
    );
  }

  @override
  $WeightEntriesTable createAlias(String alias) {
    return $WeightEntriesTable(attachedDatabase, alias);
  }
}

class WeightRow extends DataClass implements Insertable<WeightRow> {
  /// UUID v4 generated on the device.
  final String id;
  final int createdAt;

  /// Refreshed on every change; the future sync's "last write wins" key.
  final int updatedAt;

  /// Soft-delete marker: rows are hidden rather than removed so a delete
  /// can still be propagated to other devices.
  final int? deletedAt;

  /// When this version of the row last reached the cloud (UTC ms); null
  /// or older than [updatedAt] means it still has to be pushed.
  final int? syncedAt;

  /// The server's own timestamp for this row (schema v2). Pull cursors use
  /// it instead of the phone's clock, which may be wrong (CLAUDE.md §13.1).
  final int? serverUpdatedAt;
  final String date;
  final double kg;
  final int measuredAt;
  const WeightRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
    this.serverUpdatedAt,
    required this.date,
    required this.kg,
    required this.measuredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    map['date'] = Variable<String>(date);
    map['kg'] = Variable<double>(kg);
    map['measured_at'] = Variable<int>(measuredAt);
    return map;
  }

  WeightEntriesCompanion toCompanion(bool nullToAbsent) {
    return WeightEntriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      date: Value(date),
      kg: Value(kg),
      measuredAt: Value(measuredAt),
    );
  }

  factory WeightRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      date: serializer.fromJson<String>(json['date']),
      kg: serializer.fromJson<double>(json['kg']),
      measuredAt: serializer.fromJson<int>(json['measuredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'date': serializer.toJson<String>(date),
      'kg': serializer.toJson<double>(kg),
      'measuredAt': serializer.toJson<int>(measuredAt),
    };
  }

  WeightRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    Value<int?> syncedAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    String? date,
    double? kg,
    int? measuredAt,
  }) => WeightRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    date: date ?? this.date,
    kg: kg ?? this.kg,
    measuredAt: measuredAt ?? this.measuredAt,
  );
  WeightRow copyWithCompanion(WeightEntriesCompanion data) {
    return WeightRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      date: data.date.present ? data.date.value : this.date,
      kg: data.kg.present ? data.kg.value : this.kg,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('date: $date, ')
          ..write('kg: $kg, ')
          ..write('measuredAt: $measuredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
    serverUpdatedAt,
    date,
    kg,
    measuredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.date == this.date &&
          other.kg == this.kg &&
          other.measuredAt == this.measuredAt);
}

class WeightEntriesCompanion extends UpdateCompanion<WeightRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int?> syncedAt;
  final Value<int?> serverUpdatedAt;
  final Value<String> date;
  final Value<double> kg;
  final Value<int> measuredAt;
  final Value<int> rowid;
  const WeightEntriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.date = const Value.absent(),
    this.kg = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightEntriesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    required String date,
    required double kg,
    required int measuredAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       date = Value(date),
       kg = Value(kg),
       measuredAt = Value(measuredAt);
  static Insertable<WeightRow> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? syncedAt,
    Expression<int>? serverUpdatedAt,
    Expression<String>? date,
    Expression<double>? kg,
    Expression<int>? measuredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (date != null) 'date': date,
      if (kg != null) 'kg': kg,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int?>? syncedAt,
    Value<int?>? serverUpdatedAt,
    Value<String>? date,
    Value<double>? kg,
    Value<int>? measuredAt,
    Value<int>? rowid,
  }) {
    return WeightEntriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      date: date ?? this.date,
      kg: kg ?? this.kg,
      measuredAt: measuredAt ?? this.measuredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (kg.present) {
      map['kg'] = Variable<double>(kg.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<int>(measuredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('date: $date, ')
          ..write('kg: $kg, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomFoodsTable extends CustomFoods
    with TableInfo<$CustomFoodsTable, CustomFoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _servingLabelMeta = const VerificationMeta(
    'servingLabel',
  );
  @override
  late final GeneratedColumn<String> servingLabel = GeneratedColumn<String>(
    'serving_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalPerServingMeta = const VerificationMeta(
    'kcalPerServing',
  );
  @override
  late final GeneratedColumn<int> kcalPerServing = GeneratedColumn<int>(
    'kcal_per_serving',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
    serverUpdatedAt,
    name,
    brand,
    servingLabel,
    kcalPerServing,
    proteinG,
    carbsG,
    fatG,
    category,
    barcode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomFoodRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('serving_label')) {
      context.handle(
        _servingLabelMeta,
        servingLabel.isAcceptableOrUnknown(
          data['serving_label']!,
          _servingLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_servingLabelMeta);
    }
    if (data.containsKey('kcal_per_serving')) {
      context.handle(
        _kcalPerServingMeta,
        kcalPerServing.isAcceptableOrUnknown(
          data['kcal_per_serving']!,
          _kcalPerServingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kcalPerServingMeta);
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinGMeta);
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsGMeta);
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    } else if (isInserting) {
      context.missing(_fatGMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomFoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomFoodRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      servingLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_label'],
      )!,
      kcalPerServing: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kcal_per_serving'],
      )!,
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      )!,
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      )!,
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
    );
  }

  @override
  $CustomFoodsTable createAlias(String alias) {
    return $CustomFoodsTable(attachedDatabase, alias);
  }
}

class CustomFoodRow extends DataClass implements Insertable<CustomFoodRow> {
  /// UUID v4 generated on the device.
  final String id;
  final int createdAt;

  /// Refreshed on every change; the future sync's "last write wins" key.
  final int updatedAt;

  /// Soft-delete marker: rows are hidden rather than removed so a delete
  /// can still be propagated to other devices.
  final int? deletedAt;

  /// When this version of the row last reached the cloud (UTC ms); null
  /// or older than [updatedAt] means it still has to be pushed.
  final int? syncedAt;

  /// The server's own timestamp for this row (schema v2). Pull cursors use
  /// it instead of the phone's clock, which may be wrong (CLAUDE.md §13.1).
  final int? serverUpdatedAt;
  final String name;
  final String brand;
  final String servingLabel;
  final int kcalPerServing;
  final double proteinG;
  final double carbsG;
  final double fatG;

  /// `FoodCategory.name`.
  final String category;

  /// Set when the food was saved from an unrecognised barcode scan.
  final String? barcode;
  const CustomFoodRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
    this.serverUpdatedAt,
    required this.name,
    required this.brand,
    required this.servingLabel,
    required this.kcalPerServing,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.category,
    this.barcode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    map['name'] = Variable<String>(name);
    map['brand'] = Variable<String>(brand);
    map['serving_label'] = Variable<String>(servingLabel);
    map['kcal_per_serving'] = Variable<int>(kcalPerServing);
    map['protein_g'] = Variable<double>(proteinG);
    map['carbs_g'] = Variable<double>(carbsG);
    map['fat_g'] = Variable<double>(fatG);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    return map;
  }

  CustomFoodsCompanion toCompanion(bool nullToAbsent) {
    return CustomFoodsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      name: Value(name),
      brand: Value(brand),
      servingLabel: Value(servingLabel),
      kcalPerServing: Value(kcalPerServing),
      proteinG: Value(proteinG),
      carbsG: Value(carbsG),
      fatG: Value(fatG),
      category: Value(category),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
    );
  }

  factory CustomFoodRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomFoodRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String>(json['brand']),
      servingLabel: serializer.fromJson<String>(json['servingLabel']),
      kcalPerServing: serializer.fromJson<int>(json['kcalPerServing']),
      proteinG: serializer.fromJson<double>(json['proteinG']),
      carbsG: serializer.fromJson<double>(json['carbsG']),
      fatG: serializer.fromJson<double>(json['fatG']),
      category: serializer.fromJson<String>(json['category']),
      barcode: serializer.fromJson<String?>(json['barcode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String>(brand),
      'servingLabel': serializer.toJson<String>(servingLabel),
      'kcalPerServing': serializer.toJson<int>(kcalPerServing),
      'proteinG': serializer.toJson<double>(proteinG),
      'carbsG': serializer.toJson<double>(carbsG),
      'fatG': serializer.toJson<double>(fatG),
      'category': serializer.toJson<String>(category),
      'barcode': serializer.toJson<String?>(barcode),
    };
  }

  CustomFoodRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    Value<int?> syncedAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    String? name,
    String? brand,
    String? servingLabel,
    int? kcalPerServing,
    double? proteinG,
    double? carbsG,
    double? fatG,
    String? category,
    Value<String?> barcode = const Value.absent(),
  }) => CustomFoodRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    name: name ?? this.name,
    brand: brand ?? this.brand,
    servingLabel: servingLabel ?? this.servingLabel,
    kcalPerServing: kcalPerServing ?? this.kcalPerServing,
    proteinG: proteinG ?? this.proteinG,
    carbsG: carbsG ?? this.carbsG,
    fatG: fatG ?? this.fatG,
    category: category ?? this.category,
    barcode: barcode.present ? barcode.value : this.barcode,
  );
  CustomFoodRow copyWithCompanion(CustomFoodsCompanion data) {
    return CustomFoodRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      servingLabel: data.servingLabel.present
          ? data.servingLabel.value
          : this.servingLabel,
      kcalPerServing: data.kcalPerServing.present
          ? data.kcalPerServing.value
          : this.kcalPerServing,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      category: data.category.present ? data.category.value : this.category,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomFoodRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('kcalPerServing: $kcalPerServing, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('category: $category, ')
          ..write('barcode: $barcode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
    serverUpdatedAt,
    name,
    brand,
    servingLabel,
    kcalPerServing,
    proteinG,
    carbsG,
    fatG,
    category,
    barcode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomFoodRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.servingLabel == this.servingLabel &&
          other.kcalPerServing == this.kcalPerServing &&
          other.proteinG == this.proteinG &&
          other.carbsG == this.carbsG &&
          other.fatG == this.fatG &&
          other.category == this.category &&
          other.barcode == this.barcode);
}

class CustomFoodsCompanion extends UpdateCompanion<CustomFoodRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int?> syncedAt;
  final Value<int?> serverUpdatedAt;
  final Value<String> name;
  final Value<String> brand;
  final Value<String> servingLabel;
  final Value<int> kcalPerServing;
  final Value<double> proteinG;
  final Value<double> carbsG;
  final Value<double> fatG;
  final Value<String> category;
  final Value<String?> barcode;
  final Value<int> rowid;
  const CustomFoodsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.kcalPerServing = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.category = const Value.absent(),
    this.barcode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomFoodsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    required String servingLabel,
    required int kcalPerServing,
    required double proteinG,
    required double carbsG,
    required double fatG,
    required String category,
    this.barcode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       servingLabel = Value(servingLabel),
       kcalPerServing = Value(kcalPerServing),
       proteinG = Value(proteinG),
       carbsG = Value(carbsG),
       fatG = Value(fatG),
       category = Value(category);
  static Insertable<CustomFoodRow> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? syncedAt,
    Expression<int>? serverUpdatedAt,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? servingLabel,
    Expression<int>? kcalPerServing,
    Expression<double>? proteinG,
    Expression<double>? carbsG,
    Expression<double>? fatG,
    Expression<String>? category,
    Expression<String>? barcode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (servingLabel != null) 'serving_label': servingLabel,
      if (kcalPerServing != null) 'kcal_per_serving': kcalPerServing,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (fatG != null) 'fat_g': fatG,
      if (category != null) 'category': category,
      if (barcode != null) 'barcode': barcode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomFoodsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int?>? syncedAt,
    Value<int?>? serverUpdatedAt,
    Value<String>? name,
    Value<String>? brand,
    Value<String>? servingLabel,
    Value<int>? kcalPerServing,
    Value<double>? proteinG,
    Value<double>? carbsG,
    Value<double>? fatG,
    Value<String>? category,
    Value<String?>? barcode,
    Value<int>? rowid,
  }) {
    return CustomFoodsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      servingLabel: servingLabel ?? this.servingLabel,
      kcalPerServing: kcalPerServing ?? this.kcalPerServing,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (servingLabel.present) {
      map['serving_label'] = Variable<String>(servingLabel.value);
    }
    if (kcalPerServing.present) {
      map['kcal_per_serving'] = Variable<int>(kcalPerServing.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomFoodsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('kcalPerServing: $kcalPerServing, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('category: $category, ')
          ..write('barcode: $barcode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pulledUntilMeta = const VerificationMeta(
    'pulledUntil',
  );
  @override
  late final GeneratedColumn<int> pulledUntil = GeneratedColumn<int>(
    'pulled_until',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entity, pulledUntil];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('pulled_until')) {
      context.handle(
        _pulledUntilMeta,
        pulledUntil.isAcceptableOrUnknown(
          data['pulled_until']!,
          _pulledUntilMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pulledUntilMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      pulledUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pulled_until'],
      )!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  /// Name of the synced table, e.g. `food_log_entries` or `profiles`.
  final String entity;
  final int pulledUntil;
  const SyncStateRow({required this.entity, required this.pulledUntil});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['pulled_until'] = Variable<int>(pulledUntil);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      entity: Value(entity),
      pulledUntil: Value(pulledUntil),
    );
  }

  factory SyncStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      entity: serializer.fromJson<String>(json['entity']),
      pulledUntil: serializer.fromJson<int>(json['pulledUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'pulledUntil': serializer.toJson<int>(pulledUntil),
    };
  }

  SyncStateRow copyWith({String? entity, int? pulledUntil}) => SyncStateRow(
    entity: entity ?? this.entity,
    pulledUntil: pulledUntil ?? this.pulledUntil,
  );
  SyncStateRow copyWithCompanion(SyncStateCompanion data) {
    return SyncStateRow(
      entity: data.entity.present ? data.entity.value : this.entity,
      pulledUntil: data.pulledUntil.present
          ? data.pulledUntil.value
          : this.pulledUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('entity: $entity, ')
          ..write('pulledUntil: $pulledUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, pulledUntil);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.entity == this.entity &&
          other.pulledUntil == this.pulledUntil);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> entity;
  final Value<int> pulledUntil;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.entity = const Value.absent(),
    this.pulledUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String entity,
    required int pulledUntil,
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       pulledUntil = Value(pulledUntil);
  static Insertable<SyncStateRow> custom({
    Expression<String>? entity,
    Expression<int>? pulledUntil,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (pulledUntil != null) 'pulled_until': pulledUntil,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? entity,
    Value<int>? pulledUntil,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      entity: entity ?? this.entity,
      pulledUntil: pulledUntil ?? this.pulledUntil,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (pulledUntil.present) {
      map['pulled_until'] = Variable<int>(pulledUntil.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('entity: $entity, ')
          ..write('pulledUntil: $pulledUntil, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoodLogEntriesTable foodLogEntries = $FoodLogEntriesTable(this);
  late final $WaterLogsTable waterLogs = $WaterLogsTable(this);
  late final $WeightEntriesTable weightEntries = $WeightEntriesTable(this);
  late final $CustomFoodsTable customFoods = $CustomFoodsTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final Index foodLogDateMeal = Index(
    'food_log_date_meal',
    'CREATE INDEX food_log_date_meal ON food_log_entries (date, meal)',
  );
  late final Index foodLogDate = Index(
    'food_log_date',
    'CREATE INDEX food_log_date ON food_log_entries (date)',
  );
  late final FoodLogDao foodLogDao = FoodLogDao(this as AppDatabase);
  late final WaterDao waterDao = WaterDao(this as AppDatabase);
  late final WeightDao weightDao = WeightDao(this as AppDatabase);
  late final CustomFoodDao customFoodDao = CustomFoodDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    foodLogEntries,
    waterLogs,
    weightEntries,
    customFoods,
    syncState,
    foodLogDateMeal,
    foodLogDate,
  ];
}

typedef $$FoodLogEntriesTableCreateCompanionBuilder =
    FoodLogEntriesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int?> syncedAt,
      Value<int?> serverUpdatedAt,
      required String date,
      required String meal,
      required String foodName,
      Value<String> brand,
      required String servingLabel,
      required double amount,
      required int kcal,
      required double proteinG,
      required double carbsG,
      required double fatG,
      required String source,
      Value<String?> sourceRef,
      required int loggedAt,
      Value<int> rowid,
    });
typedef $$FoodLogEntriesTableUpdateCompanionBuilder =
    FoodLogEntriesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int?> syncedAt,
      Value<int?> serverUpdatedAt,
      Value<String> date,
      Value<String> meal,
      Value<String> foodName,
      Value<String> brand,
      Value<String> servingLabel,
      Value<double> amount,
      Value<int> kcal,
      Value<double> proteinG,
      Value<double> carbsG,
      Value<double> fatG,
      Value<String> source,
      Value<String?> sourceRef,
      Value<int> loggedAt,
      Value<int> rowid,
    });

class $$FoodLogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FoodLogEntriesTable> {
  $$FoodLogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodLogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodLogEntriesTable> {
  $$FoodLogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodLogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodLogEntriesTable> {
  $$FoodLogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get meal =>
      $composableBuilder(column: $table.meal, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceRef =>
      $composableBuilder(column: $table.sourceRef, builder: (column) => column);

  GeneratedColumn<int> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);
}

class $$FoodLogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodLogEntriesTable,
          FoodLogRow,
          $$FoodLogEntriesTableFilterComposer,
          $$FoodLogEntriesTableOrderingComposer,
          $$FoodLogEntriesTableAnnotationComposer,
          $$FoodLogEntriesTableCreateCompanionBuilder,
          $$FoodLogEntriesTableUpdateCompanionBuilder,
          (
            FoodLogRow,
            BaseReferences<_$AppDatabase, $FoodLogEntriesTable, FoodLogRow>,
          ),
          FoodLogRow,
          PrefetchHooks Function()
        > {
  $$FoodLogEntriesTableTableManager(
    _$AppDatabase db,
    $FoodLogEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodLogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodLogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodLogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> meal = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> servingLabel = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> kcal = const Value.absent(),
                Value<double> proteinG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceRef = const Value.absent(),
                Value<int> loggedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodLogEntriesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                serverUpdatedAt: serverUpdatedAt,
                date: date,
                meal: meal,
                foodName: foodName,
                brand: brand,
                servingLabel: servingLabel,
                amount: amount,
                kcal: kcal,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                source: source,
                sourceRef: sourceRef,
                loggedAt: loggedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                required String date,
                required String meal,
                required String foodName,
                Value<String> brand = const Value.absent(),
                required String servingLabel,
                required double amount,
                required int kcal,
                required double proteinG,
                required double carbsG,
                required double fatG,
                required String source,
                Value<String?> sourceRef = const Value.absent(),
                required int loggedAt,
                Value<int> rowid = const Value.absent(),
              }) => FoodLogEntriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                serverUpdatedAt: serverUpdatedAt,
                date: date,
                meal: meal,
                foodName: foodName,
                brand: brand,
                servingLabel: servingLabel,
                amount: amount,
                kcal: kcal,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                source: source,
                sourceRef: sourceRef,
                loggedAt: loggedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodLogEntriesTable, FoodLogRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FoodLogEntriesTable,
                    FoodLogRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodLogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodLogEntriesTable,
      FoodLogRow,
      $$FoodLogEntriesTableFilterComposer,
      $$FoodLogEntriesTableOrderingComposer,
      $$FoodLogEntriesTableAnnotationComposer,
      $$FoodLogEntriesTableCreateCompanionBuilder,
      $$FoodLogEntriesTableUpdateCompanionBuilder,
      (
        FoodLogRow,
        BaseReferences<_$AppDatabase, $FoodLogEntriesTable, FoodLogRow>,
      ),
      FoodLogRow,
      PrefetchHooks Function()
    >;
typedef $$WaterLogsTableCreateCompanionBuilder =
    WaterLogsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int?> syncedAt,
      Value<int?> serverUpdatedAt,
      required String date,
      required int glasses,
      Value<int> rowid,
    });
typedef $$WaterLogsTableUpdateCompanionBuilder =
    WaterLogsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int?> syncedAt,
      Value<int?> serverUpdatedAt,
      Value<String> date,
      Value<int> glasses,
      Value<int> rowid,
    });

class $$WaterLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get glasses => $composableBuilder(
    column: $table.glasses,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WaterLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get glasses => $composableBuilder(
    column: $table.glasses,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WaterLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get glasses =>
      $composableBuilder(column: $table.glasses, builder: (column) => column);
}

class $$WaterLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WaterLogsTable,
          WaterLogRow,
          $$WaterLogsTableFilterComposer,
          $$WaterLogsTableOrderingComposer,
          $$WaterLogsTableAnnotationComposer,
          $$WaterLogsTableCreateCompanionBuilder,
          $$WaterLogsTableUpdateCompanionBuilder,
          (
            WaterLogRow,
            BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLogRow>,
          ),
          WaterLogRow,
          PrefetchHooks Function()
        > {
  $$WaterLogsTableTableManager(_$AppDatabase db, $WaterLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaterLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaterLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> glasses = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WaterLogsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                serverUpdatedAt: serverUpdatedAt,
                date: date,
                glasses: glasses,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                required String date,
                required int glasses,
                Value<int> rowid = const Value.absent(),
              }) => WaterLogsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                serverUpdatedAt: serverUpdatedAt,
                date: date,
                glasses: glasses,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WaterLogsTable, WaterLogRow>(table),
                  BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLogRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WaterLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WaterLogsTable,
      WaterLogRow,
      $$WaterLogsTableFilterComposer,
      $$WaterLogsTableOrderingComposer,
      $$WaterLogsTableAnnotationComposer,
      $$WaterLogsTableCreateCompanionBuilder,
      $$WaterLogsTableUpdateCompanionBuilder,
      (
        WaterLogRow,
        BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLogRow>,
      ),
      WaterLogRow,
      PrefetchHooks Function()
    >;
typedef $$WeightEntriesTableCreateCompanionBuilder =
    WeightEntriesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int?> syncedAt,
      Value<int?> serverUpdatedAt,
      required String date,
      required double kg,
      required int measuredAt,
      Value<int> rowid,
    });
typedef $$WeightEntriesTableUpdateCompanionBuilder =
    WeightEntriesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int?> syncedAt,
      Value<int?> serverUpdatedAt,
      Value<String> date,
      Value<double> kg,
      Value<int> measuredAt,
      Value<int> rowid,
    });

class $$WeightEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kg => $composableBuilder(
    column: $table.kg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kg => $composableBuilder(
    column: $table.kg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get kg =>
      $composableBuilder(column: $table.kg, builder: (column) => column);

  GeneratedColumn<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );
}

class $$WeightEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightEntriesTable,
          WeightRow,
          $$WeightEntriesTableFilterComposer,
          $$WeightEntriesTableOrderingComposer,
          $$WeightEntriesTableAnnotationComposer,
          $$WeightEntriesTableCreateCompanionBuilder,
          $$WeightEntriesTableUpdateCompanionBuilder,
          (
            WeightRow,
            BaseReferences<_$AppDatabase, $WeightEntriesTable, WeightRow>,
          ),
          WeightRow,
          PrefetchHooks Function()
        > {
  $$WeightEntriesTableTableManager(_$AppDatabase db, $WeightEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<double> kg = const Value.absent(),
                Value<int> measuredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightEntriesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                serverUpdatedAt: serverUpdatedAt,
                date: date,
                kg: kg,
                measuredAt: measuredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                required String date,
                required double kg,
                required int measuredAt,
                Value<int> rowid = const Value.absent(),
              }) => WeightEntriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                serverUpdatedAt: serverUpdatedAt,
                date: date,
                kg: kg,
                measuredAt: measuredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeightEntriesTable, WeightRow>(table),
                  BaseReferences<_$AppDatabase, $WeightEntriesTable, WeightRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightEntriesTable,
      WeightRow,
      $$WeightEntriesTableFilterComposer,
      $$WeightEntriesTableOrderingComposer,
      $$WeightEntriesTableAnnotationComposer,
      $$WeightEntriesTableCreateCompanionBuilder,
      $$WeightEntriesTableUpdateCompanionBuilder,
      (
        WeightRow,
        BaseReferences<_$AppDatabase, $WeightEntriesTable, WeightRow>,
      ),
      WeightRow,
      PrefetchHooks Function()
    >;
typedef $$CustomFoodsTableCreateCompanionBuilder =
    CustomFoodsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int?> syncedAt,
      Value<int?> serverUpdatedAt,
      required String name,
      Value<String> brand,
      required String servingLabel,
      required int kcalPerServing,
      required double proteinG,
      required double carbsG,
      required double fatG,
      required String category,
      Value<String?> barcode,
      Value<int> rowid,
    });
typedef $$CustomFoodsTableUpdateCompanionBuilder =
    CustomFoodsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int?> syncedAt,
      Value<int?> serverUpdatedAt,
      Value<String> name,
      Value<String> brand,
      Value<String> servingLabel,
      Value<int> kcalPerServing,
      Value<double> proteinG,
      Value<double> carbsG,
      Value<double> fatG,
      Value<String> category,
      Value<String?> barcode,
      Value<int> rowid,
    });

class $$CustomFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomFoodsTable> {
  $$CustomFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kcalPerServing => $composableBuilder(
    column: $table.kcalPerServing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomFoodsTable> {
  $$CustomFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kcalPerServing => $composableBuilder(
    column: $table.kcalPerServing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomFoodsTable> {
  $$CustomFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get kcalPerServing => $composableBuilder(
    column: $table.kcalPerServing,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);
}

class $$CustomFoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomFoodsTable,
          CustomFoodRow,
          $$CustomFoodsTableFilterComposer,
          $$CustomFoodsTableOrderingComposer,
          $$CustomFoodsTableAnnotationComposer,
          $$CustomFoodsTableCreateCompanionBuilder,
          $$CustomFoodsTableUpdateCompanionBuilder,
          (
            CustomFoodRow,
            BaseReferences<_$AppDatabase, $CustomFoodsTable, CustomFoodRow>,
          ),
          CustomFoodRow,
          PrefetchHooks Function()
        > {
  $$CustomFoodsTableTableManager(_$AppDatabase db, $CustomFoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> servingLabel = const Value.absent(),
                Value<int> kcalPerServing = const Value.absent(),
                Value<double> proteinG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomFoodsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                serverUpdatedAt: serverUpdatedAt,
                name: name,
                brand: brand,
                servingLabel: servingLabel,
                kcalPerServing: kcalPerServing,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                category: category,
                barcode: barcode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                required String name,
                Value<String> brand = const Value.absent(),
                required String servingLabel,
                required int kcalPerServing,
                required double proteinG,
                required double carbsG,
                required double fatG,
                required String category,
                Value<String?> barcode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomFoodsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                serverUpdatedAt: serverUpdatedAt,
                name: name,
                brand: brand,
                servingLabel: servingLabel,
                kcalPerServing: kcalPerServing,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                category: category,
                barcode: barcode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomFoodsTable, CustomFoodRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CustomFoodsTable,
                    CustomFoodRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomFoodsTable,
      CustomFoodRow,
      $$CustomFoodsTableFilterComposer,
      $$CustomFoodsTableOrderingComposer,
      $$CustomFoodsTableAnnotationComposer,
      $$CustomFoodsTableCreateCompanionBuilder,
      $$CustomFoodsTableUpdateCompanionBuilder,
      (
        CustomFoodRow,
        BaseReferences<_$AppDatabase, $CustomFoodsTable, CustomFoodRow>,
      ),
      CustomFoodRow,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String entity,
      required int pulledUntil,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> entity,
      Value<int> pulledUntil,
      Value<int> rowid,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pulledUntil => $composableBuilder(
    column: $table.pulledUntil,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pulledUntil => $composableBuilder(
    column: $table.pulledUntil,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<int> get pulledUntil => $composableBuilder(
    column: $table.pulledUntil,
    builder: (column) => column,
  );
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateRow,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateRow,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>,
          ),
          SyncStateRow,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<int> pulledUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                entity: entity,
                pulledUntil: pulledUntil,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                required int pulledUntil,
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                entity: entity,
                pulledUntil: pulledUntil,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStateTable, SyncStateRow>(table),
                  BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateRow,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateRow,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>,
      ),
      SyncStateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoodLogEntriesTableTableManager get foodLogEntries =>
      $$FoodLogEntriesTableTableManager(_db, _db.foodLogEntries);
  $$WaterLogsTableTableManager get waterLogs =>
      $$WaterLogsTableTableManager(_db, _db.waterLogs);
  $$WeightEntriesTableTableManager get weightEntries =>
      $$WeightEntriesTableTableManager(_db, _db.weightEntries);
  $$CustomFoodsTableTableManager get customFoods =>
      $$CustomFoodsTableTableManager(_db, _db.customFoods);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
}
