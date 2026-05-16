// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rehabTargetMeta = const VerificationMeta(
    'rehabTarget',
  );
  @override
  late final GeneratedColumn<String> rehabTarget = GeneratedColumn<String>(
    'rehab_target',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finalGoalDistanceMeta = const VerificationMeta(
    'finalGoalDistance',
  );
  @override
  late final GeneratedColumn<double> finalGoalDistance =
      GeneratedColumn<double>(
        'final_goal_distance',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('standard'),
  );
  static const VerificationMeta _currentTargetDistanceMeta =
      const VerificationMeta('currentTargetDistance');
  @override
  late final GeneratedColumn<double> currentTargetDistance =
      GeneratedColumn<double>(
        'current_target_distance',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(500.0),
      );
  static const VerificationMeta _agreedDisclaimerAtMeta =
      const VerificationMeta('agreedDisclaimerAt');
  @override
  late final GeneratedColumn<DateTime> agreedDisclaimerAt =
      GeneratedColumn<DateTime>(
        'agreed_disclaimer_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    age,
    rehabTarget,
    finalGoalDistance,
    mode,
    currentTargetDistance,
    agreedDisclaimerAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    if (data.containsKey('rehab_target')) {
      context.handle(
        _rehabTargetMeta,
        rehabTarget.isAcceptableOrUnknown(
          data['rehab_target']!,
          _rehabTargetMeta,
        ),
      );
    }
    if (data.containsKey('final_goal_distance')) {
      context.handle(
        _finalGoalDistanceMeta,
        finalGoalDistance.isAcceptableOrUnknown(
          data['final_goal_distance']!,
          _finalGoalDistanceMeta,
        ),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('current_target_distance')) {
      context.handle(
        _currentTargetDistanceMeta,
        currentTargetDistance.isAcceptableOrUnknown(
          data['current_target_distance']!,
          _currentTargetDistanceMeta,
        ),
      );
    }
    if (data.containsKey('agreed_disclaimer_at')) {
      context.handle(
        _agreedDisclaimerAtMeta,
        agreedDisclaimerAt.isAcceptableOrUnknown(
          data['agreed_disclaimer_at']!,
          _agreedDisclaimerAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_agreedDisclaimerAtMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      ),
      rehabTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rehab_target'],
      ),
      finalGoalDistance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}final_goal_distance'],
      ),
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      currentTargetDistance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_target_distance'],
      )!,
      agreedDisclaimerAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}agreed_disclaimer_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  /// UUID v4 形式のプライマリキー
  final String id;

  /// 年齢（初期設定時に入力、任意）
  final int? age;

  /// リハビリ対象部位のラベル（任意テキスト）
  final String? rehabTarget;

  /// 最終目標距離(m)（将来達成したい距離）
  final double? finalGoalDistance;

  /// 目標距離更新モード: conservative / standard / challenge / custom
  final String mode;

  /// 次回走行の目標距離(m)
  final double currentTargetDistance;

  /// 免責同意した日時（初回起動時に記録）
  final DateTime agreedDisclaimerAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfile({
    required this.id,
    this.age,
    this.rehabTarget,
    this.finalGoalDistance,
    required this.mode,
    required this.currentTargetDistance,
    required this.agreedDisclaimerAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || rehabTarget != null) {
      map['rehab_target'] = Variable<String>(rehabTarget);
    }
    if (!nullToAbsent || finalGoalDistance != null) {
      map['final_goal_distance'] = Variable<double>(finalGoalDistance);
    }
    map['mode'] = Variable<String>(mode);
    map['current_target_distance'] = Variable<double>(currentTargetDistance);
    map['agreed_disclaimer_at'] = Variable<DateTime>(agreedDisclaimerAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      rehabTarget: rehabTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(rehabTarget),
      finalGoalDistance: finalGoalDistance == null && nullToAbsent
          ? const Value.absent()
          : Value(finalGoalDistance),
      mode: Value(mode),
      currentTargetDistance: Value(currentTargetDistance),
      agreedDisclaimerAt: Value(agreedDisclaimerAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      age: serializer.fromJson<int?>(json['age']),
      rehabTarget: serializer.fromJson<String?>(json['rehabTarget']),
      finalGoalDistance: serializer.fromJson<double?>(
        json['finalGoalDistance'],
      ),
      mode: serializer.fromJson<String>(json['mode']),
      currentTargetDistance: serializer.fromJson<double>(
        json['currentTargetDistance'],
      ),
      agreedDisclaimerAt: serializer.fromJson<DateTime>(
        json['agreedDisclaimerAt'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'age': serializer.toJson<int?>(age),
      'rehabTarget': serializer.toJson<String?>(rehabTarget),
      'finalGoalDistance': serializer.toJson<double?>(finalGoalDistance),
      'mode': serializer.toJson<String>(mode),
      'currentTargetDistance': serializer.toJson<double>(currentTargetDistance),
      'agreedDisclaimerAt': serializer.toJson<DateTime>(agreedDisclaimerAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith({
    String? id,
    Value<int?> age = const Value.absent(),
    Value<String?> rehabTarget = const Value.absent(),
    Value<double?> finalGoalDistance = const Value.absent(),
    String? mode,
    double? currentTargetDistance,
    DateTime? agreedDisclaimerAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    age: age.present ? age.value : this.age,
    rehabTarget: rehabTarget.present ? rehabTarget.value : this.rehabTarget,
    finalGoalDistance: finalGoalDistance.present
        ? finalGoalDistance.value
        : this.finalGoalDistance,
    mode: mode ?? this.mode,
    currentTargetDistance: currentTargetDistance ?? this.currentTargetDistance,
    agreedDisclaimerAt: agreedDisclaimerAt ?? this.agreedDisclaimerAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      age: data.age.present ? data.age.value : this.age,
      rehabTarget: data.rehabTarget.present
          ? data.rehabTarget.value
          : this.rehabTarget,
      finalGoalDistance: data.finalGoalDistance.present
          ? data.finalGoalDistance.value
          : this.finalGoalDistance,
      mode: data.mode.present ? data.mode.value : this.mode,
      currentTargetDistance: data.currentTargetDistance.present
          ? data.currentTargetDistance.value
          : this.currentTargetDistance,
      agreedDisclaimerAt: data.agreedDisclaimerAt.present
          ? data.agreedDisclaimerAt.value
          : this.agreedDisclaimerAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('age: $age, ')
          ..write('rehabTarget: $rehabTarget, ')
          ..write('finalGoalDistance: $finalGoalDistance, ')
          ..write('mode: $mode, ')
          ..write('currentTargetDistance: $currentTargetDistance, ')
          ..write('agreedDisclaimerAt: $agreedDisclaimerAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    age,
    rehabTarget,
    finalGoalDistance,
    mode,
    currentTargetDistance,
    agreedDisclaimerAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.age == this.age &&
          other.rehabTarget == this.rehabTarget &&
          other.finalGoalDistance == this.finalGoalDistance &&
          other.mode == this.mode &&
          other.currentTargetDistance == this.currentTargetDistance &&
          other.agreedDisclaimerAt == this.agreedDisclaimerAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<int?> age;
  final Value<String?> rehabTarget;
  final Value<double?> finalGoalDistance;
  final Value<String> mode;
  final Value<double> currentTargetDistance;
  final Value<DateTime> agreedDisclaimerAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.age = const Value.absent(),
    this.rehabTarget = const Value.absent(),
    this.finalGoalDistance = const Value.absent(),
    this.mode = const Value.absent(),
    this.currentTargetDistance = const Value.absent(),
    this.agreedDisclaimerAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    this.age = const Value.absent(),
    this.rehabTarget = const Value.absent(),
    this.finalGoalDistance = const Value.absent(),
    this.mode = const Value.absent(),
    this.currentTargetDistance = const Value.absent(),
    required DateTime agreedDisclaimerAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       agreedDisclaimerAt = Value(agreedDisclaimerAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<int>? age,
    Expression<String>? rehabTarget,
    Expression<double>? finalGoalDistance,
    Expression<String>? mode,
    Expression<double>? currentTargetDistance,
    Expression<DateTime>? agreedDisclaimerAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (age != null) 'age': age,
      if (rehabTarget != null) 'rehab_target': rehabTarget,
      if (finalGoalDistance != null) 'final_goal_distance': finalGoalDistance,
      if (mode != null) 'mode': mode,
      if (currentTargetDistance != null)
        'current_target_distance': currentTargetDistance,
      if (agreedDisclaimerAt != null)
        'agreed_disclaimer_at': agreedDisclaimerAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<int?>? age,
    Value<String?>? rehabTarget,
    Value<double?>? finalGoalDistance,
    Value<String>? mode,
    Value<double>? currentTargetDistance,
    Value<DateTime>? agreedDisclaimerAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      age: age ?? this.age,
      rehabTarget: rehabTarget ?? this.rehabTarget,
      finalGoalDistance: finalGoalDistance ?? this.finalGoalDistance,
      mode: mode ?? this.mode,
      currentTargetDistance:
          currentTargetDistance ?? this.currentTargetDistance,
      agreedDisclaimerAt: agreedDisclaimerAt ?? this.agreedDisclaimerAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (rehabTarget.present) {
      map['rehab_target'] = Variable<String>(rehabTarget.value);
    }
    if (finalGoalDistance.present) {
      map['final_goal_distance'] = Variable<double>(finalGoalDistance.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (currentTargetDistance.present) {
      map['current_target_distance'] = Variable<double>(
        currentTargetDistance.value,
      );
    }
    if (agreedDisclaimerAt.present) {
      map['agreed_disclaimer_at'] = Variable<DateTime>(
        agreedDisclaimerAt.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('age: $age, ')
          ..write('rehabTarget: $rehabTarget, ')
          ..write('finalGoalDistance: $finalGoalDistance, ')
          ..write('mode: $mode, ')
          ..write('currentTargetDistance: $currentTargetDistance, ')
          ..write('agreedDisclaimerAt: $agreedDisclaimerAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _designThemeMeta = const VerificationMeta(
    'designTheme',
  );
  @override
  late final GeneratedColumn<String> designTheme = GeneratedColumn<String>(
    'design_theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('soft'),
  );
  static const VerificationMeta _fontSizeMeta = const VerificationMeta(
    'fontSize',
  );
  @override
  late final GeneratedColumn<String> fontSize = GeneratedColumn<String>(
    'font_size',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _notificationEnabledMeta =
      const VerificationMeta('notificationEnabled');
  @override
  late final GeneratedColumn<bool> notificationEnabled = GeneratedColumn<bool>(
    'notification_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notification_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _streakAlertEnabledMeta =
      const VerificationMeta('streakAlertEnabled');
  @override
  late final GeneratedColumn<bool> streakAlertEnabled = GeneratedColumn<bool>(
    'streak_alert_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("streak_alert_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _weatherAlertEnabledMeta =
      const VerificationMeta('weatherAlertEnabled');
  @override
  late final GeneratedColumn<bool> weatherAlertEnabled = GeneratedColumn<bool>(
    'weather_alert_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("weather_alert_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _gpsCorrectionEnabledMeta =
      const VerificationMeta('gpsCorrectionEnabled');
  @override
  late final GeneratedColumn<bool> gpsCorrectionEnabled = GeneratedColumn<bool>(
    'gps_correction_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("gps_correction_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    designTheme,
    fontSize,
    notificationEnabled,
    streakAlertEnabled,
    weatherAlertEnabled,
    gpsCorrectionEnabled,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('design_theme')) {
      context.handle(
        _designThemeMeta,
        designTheme.isAcceptableOrUnknown(
          data['design_theme']!,
          _designThemeMeta,
        ),
      );
    }
    if (data.containsKey('font_size')) {
      context.handle(
        _fontSizeMeta,
        fontSize.isAcceptableOrUnknown(data['font_size']!, _fontSizeMeta),
      );
    }
    if (data.containsKey('notification_enabled')) {
      context.handle(
        _notificationEnabledMeta,
        notificationEnabled.isAcceptableOrUnknown(
          data['notification_enabled']!,
          _notificationEnabledMeta,
        ),
      );
    }
    if (data.containsKey('streak_alert_enabled')) {
      context.handle(
        _streakAlertEnabledMeta,
        streakAlertEnabled.isAcceptableOrUnknown(
          data['streak_alert_enabled']!,
          _streakAlertEnabledMeta,
        ),
      );
    }
    if (data.containsKey('weather_alert_enabled')) {
      context.handle(
        _weatherAlertEnabledMeta,
        weatherAlertEnabled.isAcceptableOrUnknown(
          data['weather_alert_enabled']!,
          _weatherAlertEnabledMeta,
        ),
      );
    }
    if (data.containsKey('gps_correction_enabled')) {
      context.handle(
        _gpsCorrectionEnabledMeta,
        gpsCorrectionEnabled.isAcceptableOrUnknown(
          data['gps_correction_enabled']!,
          _gpsCorrectionEnabledMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      designTheme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}design_theme'],
      )!,
      fontSize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}font_size'],
      )!,
      notificationEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notification_enabled'],
      )!,
      streakAlertEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}streak_alert_enabled'],
      )!,
      weatherAlertEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}weather_alert_enabled'],
      )!,
      gpsCorrectionEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}gps_correction_enabled'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  final String id;

  /// UserProfiles FK
  final String userId;

  /// デザインテーマ: soft / simple
  final String designTheme;

  /// 文字サイズ: small / medium / large / xlarge
  final String fontSize;

  /// プッシュ通知全体 ON/OFF
  final bool notificationEnabled;

  /// ストリーク警告通知
  final bool streakAlertEnabled;

  /// 天気警告通知（フェーズ2機能）
  final bool weatherAlertEnabled;

  /// GPS 軌跡を Mapbox Map Matching API で道路にスナップするか
  ///
  /// true: 走行終了時に GPS 列を Map Matching に投げ、道路上に補正してから保存。
  /// false: 生 GPS 座標をそのまま保存。
  final bool gpsCorrectionEnabled;
  final DateTime updatedAt;
  const UserSetting({
    required this.id,
    required this.userId,
    required this.designTheme,
    required this.fontSize,
    required this.notificationEnabled,
    required this.streakAlertEnabled,
    required this.weatherAlertEnabled,
    required this.gpsCorrectionEnabled,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['design_theme'] = Variable<String>(designTheme);
    map['font_size'] = Variable<String>(fontSize);
    map['notification_enabled'] = Variable<bool>(notificationEnabled);
    map['streak_alert_enabled'] = Variable<bool>(streakAlertEnabled);
    map['weather_alert_enabled'] = Variable<bool>(weatherAlertEnabled);
    map['gps_correction_enabled'] = Variable<bool>(gpsCorrectionEnabled);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      userId: Value(userId),
      designTheme: Value(designTheme),
      fontSize: Value(fontSize),
      notificationEnabled: Value(notificationEnabled),
      streakAlertEnabled: Value(streakAlertEnabled),
      weatherAlertEnabled: Value(weatherAlertEnabled),
      gpsCorrectionEnabled: Value(gpsCorrectionEnabled),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      designTheme: serializer.fromJson<String>(json['designTheme']),
      fontSize: serializer.fromJson<String>(json['fontSize']),
      notificationEnabled: serializer.fromJson<bool>(
        json['notificationEnabled'],
      ),
      streakAlertEnabled: serializer.fromJson<bool>(json['streakAlertEnabled']),
      weatherAlertEnabled: serializer.fromJson<bool>(
        json['weatherAlertEnabled'],
      ),
      gpsCorrectionEnabled: serializer.fromJson<bool>(
        json['gpsCorrectionEnabled'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'designTheme': serializer.toJson<String>(designTheme),
      'fontSize': serializer.toJson<String>(fontSize),
      'notificationEnabled': serializer.toJson<bool>(notificationEnabled),
      'streakAlertEnabled': serializer.toJson<bool>(streakAlertEnabled),
      'weatherAlertEnabled': serializer.toJson<bool>(weatherAlertEnabled),
      'gpsCorrectionEnabled': serializer.toJson<bool>(gpsCorrectionEnabled),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSetting copyWith({
    String? id,
    String? userId,
    String? designTheme,
    String? fontSize,
    bool? notificationEnabled,
    bool? streakAlertEnabled,
    bool? weatherAlertEnabled,
    bool? gpsCorrectionEnabled,
    DateTime? updatedAt,
  }) => UserSetting(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    designTheme: designTheme ?? this.designTheme,
    fontSize: fontSize ?? this.fontSize,
    notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    streakAlertEnabled: streakAlertEnabled ?? this.streakAlertEnabled,
    weatherAlertEnabled: weatherAlertEnabled ?? this.weatherAlertEnabled,
    gpsCorrectionEnabled: gpsCorrectionEnabled ?? this.gpsCorrectionEnabled,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      designTheme: data.designTheme.present
          ? data.designTheme.value
          : this.designTheme,
      fontSize: data.fontSize.present ? data.fontSize.value : this.fontSize,
      notificationEnabled: data.notificationEnabled.present
          ? data.notificationEnabled.value
          : this.notificationEnabled,
      streakAlertEnabled: data.streakAlertEnabled.present
          ? data.streakAlertEnabled.value
          : this.streakAlertEnabled,
      weatherAlertEnabled: data.weatherAlertEnabled.present
          ? data.weatherAlertEnabled.value
          : this.weatherAlertEnabled,
      gpsCorrectionEnabled: data.gpsCorrectionEnabled.present
          ? data.gpsCorrectionEnabled.value
          : this.gpsCorrectionEnabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('designTheme: $designTheme, ')
          ..write('fontSize: $fontSize, ')
          ..write('notificationEnabled: $notificationEnabled, ')
          ..write('streakAlertEnabled: $streakAlertEnabled, ')
          ..write('weatherAlertEnabled: $weatherAlertEnabled, ')
          ..write('gpsCorrectionEnabled: $gpsCorrectionEnabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    designTheme,
    fontSize,
    notificationEnabled,
    streakAlertEnabled,
    weatherAlertEnabled,
    gpsCorrectionEnabled,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.designTheme == this.designTheme &&
          other.fontSize == this.fontSize &&
          other.notificationEnabled == this.notificationEnabled &&
          other.streakAlertEnabled == this.streakAlertEnabled &&
          other.weatherAlertEnabled == this.weatherAlertEnabled &&
          other.gpsCorrectionEnabled == this.gpsCorrectionEnabled &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> designTheme;
  final Value<String> fontSize;
  final Value<bool> notificationEnabled;
  final Value<bool> streakAlertEnabled;
  final Value<bool> weatherAlertEnabled;
  final Value<bool> gpsCorrectionEnabled;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.designTheme = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.notificationEnabled = const Value.absent(),
    this.streakAlertEnabled = const Value.absent(),
    this.weatherAlertEnabled = const Value.absent(),
    this.gpsCorrectionEnabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String id,
    required String userId,
    this.designTheme = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.notificationEnabled = const Value.absent(),
    this.streakAlertEnabled = const Value.absent(),
    this.weatherAlertEnabled = const Value.absent(),
    this.gpsCorrectionEnabled = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       updatedAt = Value(updatedAt);
  static Insertable<UserSetting> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? designTheme,
    Expression<String>? fontSize,
    Expression<bool>? notificationEnabled,
    Expression<bool>? streakAlertEnabled,
    Expression<bool>? weatherAlertEnabled,
    Expression<bool>? gpsCorrectionEnabled,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (designTheme != null) 'design_theme': designTheme,
      if (fontSize != null) 'font_size': fontSize,
      if (notificationEnabled != null)
        'notification_enabled': notificationEnabled,
      if (streakAlertEnabled != null)
        'streak_alert_enabled': streakAlertEnabled,
      if (weatherAlertEnabled != null)
        'weather_alert_enabled': weatherAlertEnabled,
      if (gpsCorrectionEnabled != null)
        'gps_correction_enabled': gpsCorrectionEnabled,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? designTheme,
    Value<String>? fontSize,
    Value<bool>? notificationEnabled,
    Value<bool>? streakAlertEnabled,
    Value<bool>? weatherAlertEnabled,
    Value<bool>? gpsCorrectionEnabled,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      designTheme: designTheme ?? this.designTheme,
      fontSize: fontSize ?? this.fontSize,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      streakAlertEnabled: streakAlertEnabled ?? this.streakAlertEnabled,
      weatherAlertEnabled: weatherAlertEnabled ?? this.weatherAlertEnabled,
      gpsCorrectionEnabled: gpsCorrectionEnabled ?? this.gpsCorrectionEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (designTheme.present) {
      map['design_theme'] = Variable<String>(designTheme.value);
    }
    if (fontSize.present) {
      map['font_size'] = Variable<String>(fontSize.value);
    }
    if (notificationEnabled.present) {
      map['notification_enabled'] = Variable<bool>(notificationEnabled.value);
    }
    if (streakAlertEnabled.present) {
      map['streak_alert_enabled'] = Variable<bool>(streakAlertEnabled.value);
    }
    if (weatherAlertEnabled.present) {
      map['weather_alert_enabled'] = Variable<bool>(weatherAlertEnabled.value);
    }
    if (gpsCorrectionEnabled.present) {
      map['gps_correction_enabled'] = Variable<bool>(
        gpsCorrectionEnabled.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('designTheme: $designTheme, ')
          ..write('fontSize: $fontSize, ')
          ..write('notificationEnabled: $notificationEnabled, ')
          ..write('streakAlertEnabled: $streakAlertEnabled, ')
          ..write('weatherAlertEnabled: $weatherAlertEnabled, ')
          ..write('gpsCorrectionEnabled: $gpsCorrectionEnabled, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RunSessionsTable extends RunSessions
    with TableInfo<$RunSessionsTable, RunSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedDistanceMeta = const VerificationMeta(
    'plannedDistance',
  );
  @override
  late final GeneratedColumn<double> plannedDistance = GeneratedColumn<double>(
    'planned_distance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualDistanceMeta = const VerificationMeta(
    'actualDistance',
  );
  @override
  late final GeneratedColumn<double> actualDistance = GeneratedColumn<double>(
    'actual_distance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgPaceSecsPerKmMeta = const VerificationMeta(
    'avgPaceSecsPerKm',
  );
  @override
  late final GeneratedColumn<double> avgPaceSecsPerKm = GeneratedColumn<double>(
    'avg_pace_secs_per_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeTypeMeta = const VerificationMeta(
    'routeType',
  );
  @override
  late final GeneratedColumn<String> routeType = GeneratedColumn<String>(
    'route_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('loop'),
  );
  static const VerificationMeta _routeGeoJsonMeta = const VerificationMeta(
    'routeGeoJson',
  );
  @override
  late final GeneratedColumn<String> routeGeoJson = GeneratedColumn<String>(
    'route_geo_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isGoalAchievedMeta = const VerificationMeta(
    'isGoalAchieved',
  );
  @override
  late final GeneratedColumn<bool> isGoalAchieved = GeneratedColumn<bool>(
    'is_goal_achieved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_goal_achieved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('completed'),
  );
  static const VerificationMeta _startLatMeta = const VerificationMeta(
    'startLat',
  );
  @override
  late final GeneratedColumn<double> startLat = GeneratedColumn<double>(
    'start_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startLngMeta = const VerificationMeta(
    'startLng',
  );
  @override
  late final GeneratedColumn<double> startLng = GeneratedColumn<double>(
    'start_lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endLatMeta = const VerificationMeta('endLat');
  @override
  late final GeneratedColumn<double> endLat = GeneratedColumn<double>(
    'end_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endLngMeta = const VerificationMeta('endLng');
  @override
  late final GeneratedColumn<double> endLng = GeneratedColumn<double>(
    'end_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimatedCaloriesMeta = const VerificationMeta(
    'estimatedCalories',
  );
  @override
  late final GeneratedColumn<int> estimatedCalories = GeneratedColumn<int>(
    'estimated_calories',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    startedAt,
    finishedAt,
    plannedDistance,
    actualDistance,
    durationSeconds,
    avgPaceSecsPerKm,
    routeType,
    routeGeoJson,
    isGoalAchieved,
    status,
    startLat,
    startLng,
    endLat,
    endLng,
    estimatedCalories,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'run_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('planned_distance')) {
      context.handle(
        _plannedDistanceMeta,
        plannedDistance.isAcceptableOrUnknown(
          data['planned_distance']!,
          _plannedDistanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedDistanceMeta);
    }
    if (data.containsKey('actual_distance')) {
      context.handle(
        _actualDistanceMeta,
        actualDistance.isAcceptableOrUnknown(
          data['actual_distance']!,
          _actualDistanceMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('avg_pace_secs_per_km')) {
      context.handle(
        _avgPaceSecsPerKmMeta,
        avgPaceSecsPerKm.isAcceptableOrUnknown(
          data['avg_pace_secs_per_km']!,
          _avgPaceSecsPerKmMeta,
        ),
      );
    }
    if (data.containsKey('route_type')) {
      context.handle(
        _routeTypeMeta,
        routeType.isAcceptableOrUnknown(data['route_type']!, _routeTypeMeta),
      );
    }
    if (data.containsKey('route_geo_json')) {
      context.handle(
        _routeGeoJsonMeta,
        routeGeoJson.isAcceptableOrUnknown(
          data['route_geo_json']!,
          _routeGeoJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_goal_achieved')) {
      context.handle(
        _isGoalAchievedMeta,
        isGoalAchieved.isAcceptableOrUnknown(
          data['is_goal_achieved']!,
          _isGoalAchievedMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('start_lat')) {
      context.handle(
        _startLatMeta,
        startLat.isAcceptableOrUnknown(data['start_lat']!, _startLatMeta),
      );
    } else if (isInserting) {
      context.missing(_startLatMeta);
    }
    if (data.containsKey('start_lng')) {
      context.handle(
        _startLngMeta,
        startLng.isAcceptableOrUnknown(data['start_lng']!, _startLngMeta),
      );
    } else if (isInserting) {
      context.missing(_startLngMeta);
    }
    if (data.containsKey('end_lat')) {
      context.handle(
        _endLatMeta,
        endLat.isAcceptableOrUnknown(data['end_lat']!, _endLatMeta),
      );
    }
    if (data.containsKey('end_lng')) {
      context.handle(
        _endLngMeta,
        endLng.isAcceptableOrUnknown(data['end_lng']!, _endLngMeta),
      );
    }
    if (data.containsKey('estimated_calories')) {
      context.handle(
        _estimatedCaloriesMeta,
        estimatedCalories.isAcceptableOrUnknown(
          data['estimated_calories']!,
          _estimatedCaloriesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      plannedDistance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}planned_distance'],
      )!,
      actualDistance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_distance'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      avgPaceSecsPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_pace_secs_per_km'],
      ),
      routeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_type'],
      )!,
      routeGeoJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_geo_json'],
      ),
      isGoalAchieved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_goal_achieved'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_lat'],
      )!,
      startLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_lng'],
      )!,
      endLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_lat'],
      ),
      endLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_lng'],
      ),
      estimatedCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_calories'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RunSessionsTable createAlias(String alias) {
    return $RunSessionsTable(attachedDatabase, alias);
  }
}

class RunSession extends DataClass implements Insertable<RunSession> {
  final String id;

  /// UserProfiles FK
  final String userId;

  /// 走行開始時刻
  final DateTime startedAt;

  /// 走行終了時刻（中断時は null の場合あり）
  final DateTime? finishedAt;

  /// 生成時の計画距離(m)
  final double plannedDistance;

  /// GPS 累計距離(m)
  final double actualDistance;

  /// 純粋な走行時間（一時停止除く）単位: 秒
  final int durationSeconds;

  /// 平均ペース(秒/km)
  final double? avgPaceSecsPerKm;

  /// ルート形状: loop / oneway
  final String routeType;

  /// 生成ルートの GeoJSON 文字列（地図プレビュー用）
  final String? routeGeoJson;

  /// 計画距離の 95% 以上を達成したか
  final bool isGoalAchieved;

  /// セッション状態: completed / abandoned / interrupted
  final String status;

  /// 出発地点座標
  final double startLat;
  final double startLng;

  /// 到着地点座標（片道ルートのみ）
  final double? endLat;
  final double? endLng;

  /// 推定消費カロリー(kcal)
  final int? estimatedCalories;
  final DateTime createdAt;
  const RunSession({
    required this.id,
    required this.userId,
    required this.startedAt,
    this.finishedAt,
    required this.plannedDistance,
    required this.actualDistance,
    required this.durationSeconds,
    this.avgPaceSecsPerKm,
    required this.routeType,
    this.routeGeoJson,
    required this.isGoalAchieved,
    required this.status,
    required this.startLat,
    required this.startLng,
    this.endLat,
    this.endLng,
    this.estimatedCalories,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['planned_distance'] = Variable<double>(plannedDistance);
    map['actual_distance'] = Variable<double>(actualDistance);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    if (!nullToAbsent || avgPaceSecsPerKm != null) {
      map['avg_pace_secs_per_km'] = Variable<double>(avgPaceSecsPerKm);
    }
    map['route_type'] = Variable<String>(routeType);
    if (!nullToAbsent || routeGeoJson != null) {
      map['route_geo_json'] = Variable<String>(routeGeoJson);
    }
    map['is_goal_achieved'] = Variable<bool>(isGoalAchieved);
    map['status'] = Variable<String>(status);
    map['start_lat'] = Variable<double>(startLat);
    map['start_lng'] = Variable<double>(startLng);
    if (!nullToAbsent || endLat != null) {
      map['end_lat'] = Variable<double>(endLat);
    }
    if (!nullToAbsent || endLng != null) {
      map['end_lng'] = Variable<double>(endLng);
    }
    if (!nullToAbsent || estimatedCalories != null) {
      map['estimated_calories'] = Variable<int>(estimatedCalories);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RunSessionsCompanion toCompanion(bool nullToAbsent) {
    return RunSessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      plannedDistance: Value(plannedDistance),
      actualDistance: Value(actualDistance),
      durationSeconds: Value(durationSeconds),
      avgPaceSecsPerKm: avgPaceSecsPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(avgPaceSecsPerKm),
      routeType: Value(routeType),
      routeGeoJson: routeGeoJson == null && nullToAbsent
          ? const Value.absent()
          : Value(routeGeoJson),
      isGoalAchieved: Value(isGoalAchieved),
      status: Value(status),
      startLat: Value(startLat),
      startLng: Value(startLng),
      endLat: endLat == null && nullToAbsent
          ? const Value.absent()
          : Value(endLat),
      endLng: endLng == null && nullToAbsent
          ? const Value.absent()
          : Value(endLng),
      estimatedCalories: estimatedCalories == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedCalories),
      createdAt: Value(createdAt),
    );
  }

  factory RunSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunSession(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      plannedDistance: serializer.fromJson<double>(json['plannedDistance']),
      actualDistance: serializer.fromJson<double>(json['actualDistance']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      avgPaceSecsPerKm: serializer.fromJson<double?>(json['avgPaceSecsPerKm']),
      routeType: serializer.fromJson<String>(json['routeType']),
      routeGeoJson: serializer.fromJson<String?>(json['routeGeoJson']),
      isGoalAchieved: serializer.fromJson<bool>(json['isGoalAchieved']),
      status: serializer.fromJson<String>(json['status']),
      startLat: serializer.fromJson<double>(json['startLat']),
      startLng: serializer.fromJson<double>(json['startLng']),
      endLat: serializer.fromJson<double?>(json['endLat']),
      endLng: serializer.fromJson<double?>(json['endLng']),
      estimatedCalories: serializer.fromJson<int?>(json['estimatedCalories']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'plannedDistance': serializer.toJson<double>(plannedDistance),
      'actualDistance': serializer.toJson<double>(actualDistance),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'avgPaceSecsPerKm': serializer.toJson<double?>(avgPaceSecsPerKm),
      'routeType': serializer.toJson<String>(routeType),
      'routeGeoJson': serializer.toJson<String?>(routeGeoJson),
      'isGoalAchieved': serializer.toJson<bool>(isGoalAchieved),
      'status': serializer.toJson<String>(status),
      'startLat': serializer.toJson<double>(startLat),
      'startLng': serializer.toJson<double>(startLng),
      'endLat': serializer.toJson<double?>(endLat),
      'endLng': serializer.toJson<double?>(endLng),
      'estimatedCalories': serializer.toJson<int?>(estimatedCalories),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RunSession copyWith({
    String? id,
    String? userId,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    double? plannedDistance,
    double? actualDistance,
    int? durationSeconds,
    Value<double?> avgPaceSecsPerKm = const Value.absent(),
    String? routeType,
    Value<String?> routeGeoJson = const Value.absent(),
    bool? isGoalAchieved,
    String? status,
    double? startLat,
    double? startLng,
    Value<double?> endLat = const Value.absent(),
    Value<double?> endLng = const Value.absent(),
    Value<int?> estimatedCalories = const Value.absent(),
    DateTime? createdAt,
  }) => RunSession(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    plannedDistance: plannedDistance ?? this.plannedDistance,
    actualDistance: actualDistance ?? this.actualDistance,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    avgPaceSecsPerKm: avgPaceSecsPerKm.present
        ? avgPaceSecsPerKm.value
        : this.avgPaceSecsPerKm,
    routeType: routeType ?? this.routeType,
    routeGeoJson: routeGeoJson.present ? routeGeoJson.value : this.routeGeoJson,
    isGoalAchieved: isGoalAchieved ?? this.isGoalAchieved,
    status: status ?? this.status,
    startLat: startLat ?? this.startLat,
    startLng: startLng ?? this.startLng,
    endLat: endLat.present ? endLat.value : this.endLat,
    endLng: endLng.present ? endLng.value : this.endLng,
    estimatedCalories: estimatedCalories.present
        ? estimatedCalories.value
        : this.estimatedCalories,
    createdAt: createdAt ?? this.createdAt,
  );
  RunSession copyWithCompanion(RunSessionsCompanion data) {
    return RunSession(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      plannedDistance: data.plannedDistance.present
          ? data.plannedDistance.value
          : this.plannedDistance,
      actualDistance: data.actualDistance.present
          ? data.actualDistance.value
          : this.actualDistance,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      avgPaceSecsPerKm: data.avgPaceSecsPerKm.present
          ? data.avgPaceSecsPerKm.value
          : this.avgPaceSecsPerKm,
      routeType: data.routeType.present ? data.routeType.value : this.routeType,
      routeGeoJson: data.routeGeoJson.present
          ? data.routeGeoJson.value
          : this.routeGeoJson,
      isGoalAchieved: data.isGoalAchieved.present
          ? data.isGoalAchieved.value
          : this.isGoalAchieved,
      status: data.status.present ? data.status.value : this.status,
      startLat: data.startLat.present ? data.startLat.value : this.startLat,
      startLng: data.startLng.present ? data.startLng.value : this.startLng,
      endLat: data.endLat.present ? data.endLat.value : this.endLat,
      endLng: data.endLng.present ? data.endLng.value : this.endLng,
      estimatedCalories: data.estimatedCalories.present
          ? data.estimatedCalories.value
          : this.estimatedCalories,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunSession(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('plannedDistance: $plannedDistance, ')
          ..write('actualDistance: $actualDistance, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('avgPaceSecsPerKm: $avgPaceSecsPerKm, ')
          ..write('routeType: $routeType, ')
          ..write('routeGeoJson: $routeGeoJson, ')
          ..write('isGoalAchieved: $isGoalAchieved, ')
          ..write('status: $status, ')
          ..write('startLat: $startLat, ')
          ..write('startLng: $startLng, ')
          ..write('endLat: $endLat, ')
          ..write('endLng: $endLng, ')
          ..write('estimatedCalories: $estimatedCalories, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    startedAt,
    finishedAt,
    plannedDistance,
    actualDistance,
    durationSeconds,
    avgPaceSecsPerKm,
    routeType,
    routeGeoJson,
    isGoalAchieved,
    status,
    startLat,
    startLng,
    endLat,
    endLng,
    estimatedCalories,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunSession &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.plannedDistance == this.plannedDistance &&
          other.actualDistance == this.actualDistance &&
          other.durationSeconds == this.durationSeconds &&
          other.avgPaceSecsPerKm == this.avgPaceSecsPerKm &&
          other.routeType == this.routeType &&
          other.routeGeoJson == this.routeGeoJson &&
          other.isGoalAchieved == this.isGoalAchieved &&
          other.status == this.status &&
          other.startLat == this.startLat &&
          other.startLng == this.startLng &&
          other.endLat == this.endLat &&
          other.endLng == this.endLng &&
          other.estimatedCalories == this.estimatedCalories &&
          other.createdAt == this.createdAt);
}

class RunSessionsCompanion extends UpdateCompanion<RunSession> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<double> plannedDistance;
  final Value<double> actualDistance;
  final Value<int> durationSeconds;
  final Value<double?> avgPaceSecsPerKm;
  final Value<String> routeType;
  final Value<String?> routeGeoJson;
  final Value<bool> isGoalAchieved;
  final Value<String> status;
  final Value<double> startLat;
  final Value<double> startLng;
  final Value<double?> endLat;
  final Value<double?> endLng;
  final Value<int?> estimatedCalories;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RunSessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.plannedDistance = const Value.absent(),
    this.actualDistance = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.avgPaceSecsPerKm = const Value.absent(),
    this.routeType = const Value.absent(),
    this.routeGeoJson = const Value.absent(),
    this.isGoalAchieved = const Value.absent(),
    this.status = const Value.absent(),
    this.startLat = const Value.absent(),
    this.startLng = const Value.absent(),
    this.endLat = const Value.absent(),
    this.endLng = const Value.absent(),
    this.estimatedCalories = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunSessionsCompanion.insert({
    required String id,
    required String userId,
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    required double plannedDistance,
    this.actualDistance = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.avgPaceSecsPerKm = const Value.absent(),
    this.routeType = const Value.absent(),
    this.routeGeoJson = const Value.absent(),
    this.isGoalAchieved = const Value.absent(),
    this.status = const Value.absent(),
    required double startLat,
    required double startLng,
    this.endLat = const Value.absent(),
    this.endLng = const Value.absent(),
    this.estimatedCalories = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       startedAt = Value(startedAt),
       plannedDistance = Value(plannedDistance),
       startLat = Value(startLat),
       startLng = Value(startLng),
       createdAt = Value(createdAt);
  static Insertable<RunSession> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<double>? plannedDistance,
    Expression<double>? actualDistance,
    Expression<int>? durationSeconds,
    Expression<double>? avgPaceSecsPerKm,
    Expression<String>? routeType,
    Expression<String>? routeGeoJson,
    Expression<bool>? isGoalAchieved,
    Expression<String>? status,
    Expression<double>? startLat,
    Expression<double>? startLng,
    Expression<double>? endLat,
    Expression<double>? endLng,
    Expression<int>? estimatedCalories,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (plannedDistance != null) 'planned_distance': plannedDistance,
      if (actualDistance != null) 'actual_distance': actualDistance,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (avgPaceSecsPerKm != null) 'avg_pace_secs_per_km': avgPaceSecsPerKm,
      if (routeType != null) 'route_type': routeType,
      if (routeGeoJson != null) 'route_geo_json': routeGeoJson,
      if (isGoalAchieved != null) 'is_goal_achieved': isGoalAchieved,
      if (status != null) 'status': status,
      if (startLat != null) 'start_lat': startLat,
      if (startLng != null) 'start_lng': startLng,
      if (endLat != null) 'end_lat': endLat,
      if (endLng != null) 'end_lng': endLng,
      if (estimatedCalories != null) 'estimated_calories': estimatedCalories,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<double>? plannedDistance,
    Value<double>? actualDistance,
    Value<int>? durationSeconds,
    Value<double?>? avgPaceSecsPerKm,
    Value<String>? routeType,
    Value<String?>? routeGeoJson,
    Value<bool>? isGoalAchieved,
    Value<String>? status,
    Value<double>? startLat,
    Value<double>? startLng,
    Value<double?>? endLat,
    Value<double?>? endLng,
    Value<int?>? estimatedCalories,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RunSessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      plannedDistance: plannedDistance ?? this.plannedDistance,
      actualDistance: actualDistance ?? this.actualDistance,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      avgPaceSecsPerKm: avgPaceSecsPerKm ?? this.avgPaceSecsPerKm,
      routeType: routeType ?? this.routeType,
      routeGeoJson: routeGeoJson ?? this.routeGeoJson,
      isGoalAchieved: isGoalAchieved ?? this.isGoalAchieved,
      status: status ?? this.status,
      startLat: startLat ?? this.startLat,
      startLng: startLng ?? this.startLng,
      endLat: endLat ?? this.endLat,
      endLng: endLng ?? this.endLng,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (plannedDistance.present) {
      map['planned_distance'] = Variable<double>(plannedDistance.value);
    }
    if (actualDistance.present) {
      map['actual_distance'] = Variable<double>(actualDistance.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (avgPaceSecsPerKm.present) {
      map['avg_pace_secs_per_km'] = Variable<double>(avgPaceSecsPerKm.value);
    }
    if (routeType.present) {
      map['route_type'] = Variable<String>(routeType.value);
    }
    if (routeGeoJson.present) {
      map['route_geo_json'] = Variable<String>(routeGeoJson.value);
    }
    if (isGoalAchieved.present) {
      map['is_goal_achieved'] = Variable<bool>(isGoalAchieved.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startLat.present) {
      map['start_lat'] = Variable<double>(startLat.value);
    }
    if (startLng.present) {
      map['start_lng'] = Variable<double>(startLng.value);
    }
    if (endLat.present) {
      map['end_lat'] = Variable<double>(endLat.value);
    }
    if (endLng.present) {
      map['end_lng'] = Variable<double>(endLng.value);
    }
    if (estimatedCalories.present) {
      map['estimated_calories'] = Variable<int>(estimatedCalories.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunSessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('plannedDistance: $plannedDistance, ')
          ..write('actualDistance: $actualDistance, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('avgPaceSecsPerKm: $avgPaceSecsPerKm, ')
          ..write('routeType: $routeType, ')
          ..write('routeGeoJson: $routeGeoJson, ')
          ..write('isGoalAchieved: $isGoalAchieved, ')
          ..write('status: $status, ')
          ..write('startLat: $startLat, ')
          ..write('startLng: $startLng, ')
          ..write('endLat: $endLat, ')
          ..write('endLng: $endLng, ')
          ..write('estimatedCalories: $estimatedCalories, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GpsPointsTable extends GpsPoints
    with TableInfo<$GpsPointsTable, GpsPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GpsPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES run_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMMeta = const VerificationMeta(
    'altitudeM',
  );
  @override
  late final GeneratedColumn<double> altitudeM = GeneratedColumn<double>(
    'altitude_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMpsMeta = const VerificationMeta(
    'speedMps',
  );
  @override
  late final GeneratedColumn<double> speedMps = GeneratedColumn<double>(
    'speed_mps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    lat,
    lng,
    altitudeM,
    accuracyM,
    speedMps,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gps_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<GpsPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('altitude_m')) {
      context.handle(
        _altitudeMMeta,
        altitudeM.isAcceptableOrUnknown(data['altitude_m']!, _altitudeMMeta),
      );
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    }
    if (data.containsKey('speed_mps')) {
      context.handle(
        _speedMpsMeta,
        speedMps.isAcceptableOrUnknown(data['speed_mps']!, _speedMpsMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GpsPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GpsPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      altitudeM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude_m'],
      ),
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_m'],
      ),
      speedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_mps'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $GpsPointsTable createAlias(String alias) {
    return $GpsPointsTable(attachedDatabase, alias);
  }
}

class GpsPoint extends DataClass implements Insertable<GpsPoint> {
  final String id;

  /// RunSessions FK
  final String sessionId;

  /// 緯度
  final double lat;

  /// 経度
  final double lng;

  /// 標高(m)
  final double? altitudeM;

  /// GPS 精度(m)。20m 超はルート描画に使用しない
  final double? accuracyM;

  /// 瞬間速度(m/s)
  final double? speedMps;

  /// 記録時刻
  final DateTime recordedAt;
  const GpsPoint({
    required this.id,
    required this.sessionId,
    required this.lat,
    required this.lng,
    this.altitudeM,
    this.accuracyM,
    this.speedMps,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || altitudeM != null) {
      map['altitude_m'] = Variable<double>(altitudeM);
    }
    if (!nullToAbsent || accuracyM != null) {
      map['accuracy_m'] = Variable<double>(accuracyM);
    }
    if (!nullToAbsent || speedMps != null) {
      map['speed_mps'] = Variable<double>(speedMps);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  GpsPointsCompanion toCompanion(bool nullToAbsent) {
    return GpsPointsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      lat: Value(lat),
      lng: Value(lng),
      altitudeM: altitudeM == null && nullToAbsent
          ? const Value.absent()
          : Value(altitudeM),
      accuracyM: accuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyM),
      speedMps: speedMps == null && nullToAbsent
          ? const Value.absent()
          : Value(speedMps),
      recordedAt: Value(recordedAt),
    );
  }

  factory GpsPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GpsPoint(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      altitudeM: serializer.fromJson<double?>(json['altitudeM']),
      accuracyM: serializer.fromJson<double?>(json['accuracyM']),
      speedMps: serializer.fromJson<double?>(json['speedMps']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'altitudeM': serializer.toJson<double?>(altitudeM),
      'accuracyM': serializer.toJson<double?>(accuracyM),
      'speedMps': serializer.toJson<double?>(speedMps),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  GpsPoint copyWith({
    String? id,
    String? sessionId,
    double? lat,
    double? lng,
    Value<double?> altitudeM = const Value.absent(),
    Value<double?> accuracyM = const Value.absent(),
    Value<double?> speedMps = const Value.absent(),
    DateTime? recordedAt,
  }) => GpsPoint(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    altitudeM: altitudeM.present ? altitudeM.value : this.altitudeM,
    accuracyM: accuracyM.present ? accuracyM.value : this.accuracyM,
    speedMps: speedMps.present ? speedMps.value : this.speedMps,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  GpsPoint copyWithCompanion(GpsPointsCompanion data) {
    return GpsPoint(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      altitudeM: data.altitudeM.present ? data.altitudeM.value : this.altitudeM,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      speedMps: data.speedMps.present ? data.speedMps.value : this.speedMps,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GpsPoint(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('altitudeM: $altitudeM, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('speedMps: $speedMps, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    lat,
    lng,
    altitudeM,
    accuracyM,
    speedMps,
    recordedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GpsPoint &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.altitudeM == this.altitudeM &&
          other.accuracyM == this.accuracyM &&
          other.speedMps == this.speedMps &&
          other.recordedAt == this.recordedAt);
}

class GpsPointsCompanion extends UpdateCompanion<GpsPoint> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double?> altitudeM;
  final Value<double?> accuracyM;
  final Value<double?> speedMps;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const GpsPointsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.altitudeM = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.speedMps = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GpsPointsCompanion.insert({
    required String id,
    required String sessionId,
    required double lat,
    required double lng,
    this.altitudeM = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.speedMps = const Value.absent(),
    required DateTime recordedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       lat = Value(lat),
       lng = Value(lng),
       recordedAt = Value(recordedAt);
  static Insertable<GpsPoint> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? altitudeM,
    Expression<double>? accuracyM,
    Expression<double>? speedMps,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (altitudeM != null) 'altitude_m': altitudeM,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (speedMps != null) 'speed_mps': speedMps,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GpsPointsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<double>? lat,
    Value<double>? lng,
    Value<double?>? altitudeM,
    Value<double?>? accuracyM,
    Value<double?>? speedMps,
    Value<DateTime>? recordedAt,
    Value<int>? rowid,
  }) {
    return GpsPointsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      altitudeM: altitudeM ?? this.altitudeM,
      accuracyM: accuracyM ?? this.accuracyM,
      speedMps: speedMps ?? this.speedMps,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (altitudeM.present) {
      map['altitude_m'] = Variable<double>(altitudeM.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (speedMps.present) {
      map['speed_mps'] = Variable<double>(speedMps.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GpsPointsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('altitudeM: $altitudeM, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('speedMps: $speedMps, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConditionLogsTable extends ConditionLogs
    with TableInfo<$ConditionLogsTable, ConditionLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConditionLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES run_sessions (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _timingMeta = const VerificationMeta('timing');
  @override
  late final GeneratedColumn<String> timing = GeneratedColumn<String>(
    'timing',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _painScoreMeta = const VerificationMeta(
    'painScore',
  );
  @override
  late final GeneratedColumn<int> painScore = GeneratedColumn<int>(
    'pain_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    sessionId,
    timing,
    painScore,
    memo,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'condition_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConditionLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('timing')) {
      context.handle(
        _timingMeta,
        timing.isAcceptableOrUnknown(data['timing']!, _timingMeta),
      );
    } else if (isInserting) {
      context.missing(_timingMeta);
    }
    if (data.containsKey('pain_score')) {
      context.handle(
        _painScoreMeta,
        painScore.isAcceptableOrUnknown(data['pain_score']!, _painScoreMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConditionLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConditionLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      timing: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timing'],
      )!,
      painScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pain_score'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $ConditionLogsTable createAlias(String alias) {
    return $ConditionLogsTable(attachedDatabase, alias);
  }
}

class ConditionLog extends DataClass implements Insertable<ConditionLog> {
  final String id;

  /// UserProfiles FK
  final String userId;

  /// RunSessions FK（nullable: standalone 記録の場合は null）
  final String? sessionId;

  /// 記録タイミング: before / after / standalone
  final String timing;

  /// 痛みスコア 0（無痛）〜 10（最大痛）
  final int painScore;

  /// 自由記述メモ（最大 500 文字）
  final String? memo;
  final DateTime recordedAt;
  const ConditionLog({
    required this.id,
    required this.userId,
    this.sessionId,
    required this.timing,
    required this.painScore,
    this.memo,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['timing'] = Variable<String>(timing);
    map['pain_score'] = Variable<int>(painScore);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  ConditionLogsCompanion toCompanion(bool nullToAbsent) {
    return ConditionLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      timing: Value(timing),
      painScore: Value(painScore),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      recordedAt: Value(recordedAt),
    );
  }

  factory ConditionLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConditionLog(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      timing: serializer.fromJson<String>(json['timing']),
      painScore: serializer.fromJson<int>(json['painScore']),
      memo: serializer.fromJson<String?>(json['memo']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'sessionId': serializer.toJson<String?>(sessionId),
      'timing': serializer.toJson<String>(timing),
      'painScore': serializer.toJson<int>(painScore),
      'memo': serializer.toJson<String?>(memo),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  ConditionLog copyWith({
    String? id,
    String? userId,
    Value<String?> sessionId = const Value.absent(),
    String? timing,
    int? painScore,
    Value<String?> memo = const Value.absent(),
    DateTime? recordedAt,
  }) => ConditionLog(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    timing: timing ?? this.timing,
    painScore: painScore ?? this.painScore,
    memo: memo.present ? memo.value : this.memo,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  ConditionLog copyWithCompanion(ConditionLogsCompanion data) {
    return ConditionLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      timing: data.timing.present ? data.timing.value : this.timing,
      painScore: data.painScore.present ? data.painScore.value : this.painScore,
      memo: data.memo.present ? data.memo.value : this.memo,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConditionLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('sessionId: $sessionId, ')
          ..write('timing: $timing, ')
          ..write('painScore: $painScore, ')
          ..write('memo: $memo, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, sessionId, timing, painScore, memo, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConditionLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.sessionId == this.sessionId &&
          other.timing == this.timing &&
          other.painScore == this.painScore &&
          other.memo == this.memo &&
          other.recordedAt == this.recordedAt);
}

class ConditionLogsCompanion extends UpdateCompanion<ConditionLog> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> sessionId;
  final Value<String> timing;
  final Value<int> painScore;
  final Value<String?> memo;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const ConditionLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.timing = const Value.absent(),
    this.painScore = const Value.absent(),
    this.memo = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConditionLogsCompanion.insert({
    required String id,
    required String userId,
    this.sessionId = const Value.absent(),
    required String timing,
    this.painScore = const Value.absent(),
    this.memo = const Value.absent(),
    required DateTime recordedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       timing = Value(timing),
       recordedAt = Value(recordedAt);
  static Insertable<ConditionLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? sessionId,
    Expression<String>? timing,
    Expression<int>? painScore,
    Expression<String>? memo,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (sessionId != null) 'session_id': sessionId,
      if (timing != null) 'timing': timing,
      if (painScore != null) 'pain_score': painScore,
      if (memo != null) 'memo': memo,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConditionLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? sessionId,
    Value<String>? timing,
    Value<int>? painScore,
    Value<String?>? memo,
    Value<DateTime>? recordedAt,
    Value<int>? rowid,
  }) {
    return ConditionLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      timing: timing ?? this.timing,
      painScore: painScore ?? this.painScore,
      memo: memo ?? this.memo,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (timing.present) {
      map['timing'] = Variable<String>(timing.value);
    }
    if (painScore.present) {
      map['pain_score'] = Variable<int>(painScore.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConditionLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('sessionId: $sessionId, ')
          ..write('timing: $timing, ')
          ..write('painScore: $painScore, ')
          ..write('memo: $memo, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PainAreasTable extends PainAreas
    with TableInfo<$PainAreasTable, PainArea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PainAreasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conditionLogIdMeta = const VerificationMeta(
    'conditionLogId',
  );
  @override
  late final GeneratedColumn<String> conditionLogId = GeneratedColumn<String>(
    'condition_log_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES condition_logs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _bodyPartMeta = const VerificationMeta(
    'bodyPart',
  );
  @override
  late final GeneratedColumn<String> bodyPart = GeneratedColumn<String>(
    'body_part',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, conditionLogId, bodyPart, side];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pain_areas';
  @override
  VerificationContext validateIntegrity(
    Insertable<PainArea> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('condition_log_id')) {
      context.handle(
        _conditionLogIdMeta,
        conditionLogId.isAcceptableOrUnknown(
          data['condition_log_id']!,
          _conditionLogIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conditionLogIdMeta);
    }
    if (data.containsKey('body_part')) {
      context.handle(
        _bodyPartMeta,
        bodyPart.isAcceptableOrUnknown(data['body_part']!, _bodyPartMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyPartMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PainArea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PainArea(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conditionLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition_log_id'],
      )!,
      bodyPart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_part'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      ),
    );
  }

  @override
  $PainAreasTable createAlias(String alias) {
    return $PainAreasTable(attachedDatabase, alias);
  }
}

class PainArea extends DataClass implements Insertable<PainArea> {
  final String id;

  /// ConditionLogs FK
  final String conditionLogId;

  /// 部位コード（仕様書 2.6 参照）
  /// 例: right_knee / left_ankle / lower_back / neck 等
  final String bodyPart;

  /// 人体図の面: front / back
  final String? side;
  const PainArea({
    required this.id,
    required this.conditionLogId,
    required this.bodyPart,
    this.side,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['condition_log_id'] = Variable<String>(conditionLogId);
    map['body_part'] = Variable<String>(bodyPart);
    if (!nullToAbsent || side != null) {
      map['side'] = Variable<String>(side);
    }
    return map;
  }

  PainAreasCompanion toCompanion(bool nullToAbsent) {
    return PainAreasCompanion(
      id: Value(id),
      conditionLogId: Value(conditionLogId),
      bodyPart: Value(bodyPart),
      side: side == null && nullToAbsent ? const Value.absent() : Value(side),
    );
  }

  factory PainArea.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PainArea(
      id: serializer.fromJson<String>(json['id']),
      conditionLogId: serializer.fromJson<String>(json['conditionLogId']),
      bodyPart: serializer.fromJson<String>(json['bodyPart']),
      side: serializer.fromJson<String?>(json['side']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conditionLogId': serializer.toJson<String>(conditionLogId),
      'bodyPart': serializer.toJson<String>(bodyPart),
      'side': serializer.toJson<String?>(side),
    };
  }

  PainArea copyWith({
    String? id,
    String? conditionLogId,
    String? bodyPart,
    Value<String?> side = const Value.absent(),
  }) => PainArea(
    id: id ?? this.id,
    conditionLogId: conditionLogId ?? this.conditionLogId,
    bodyPart: bodyPart ?? this.bodyPart,
    side: side.present ? side.value : this.side,
  );
  PainArea copyWithCompanion(PainAreasCompanion data) {
    return PainArea(
      id: data.id.present ? data.id.value : this.id,
      conditionLogId: data.conditionLogId.present
          ? data.conditionLogId.value
          : this.conditionLogId,
      bodyPart: data.bodyPart.present ? data.bodyPart.value : this.bodyPart,
      side: data.side.present ? data.side.value : this.side,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PainArea(')
          ..write('id: $id, ')
          ..write('conditionLogId: $conditionLogId, ')
          ..write('bodyPart: $bodyPart, ')
          ..write('side: $side')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, conditionLogId, bodyPart, side);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PainArea &&
          other.id == this.id &&
          other.conditionLogId == this.conditionLogId &&
          other.bodyPart == this.bodyPart &&
          other.side == this.side);
}

class PainAreasCompanion extends UpdateCompanion<PainArea> {
  final Value<String> id;
  final Value<String> conditionLogId;
  final Value<String> bodyPart;
  final Value<String?> side;
  final Value<int> rowid;
  const PainAreasCompanion({
    this.id = const Value.absent(),
    this.conditionLogId = const Value.absent(),
    this.bodyPart = const Value.absent(),
    this.side = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PainAreasCompanion.insert({
    required String id,
    required String conditionLogId,
    required String bodyPart,
    this.side = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conditionLogId = Value(conditionLogId),
       bodyPart = Value(bodyPart);
  static Insertable<PainArea> custom({
    Expression<String>? id,
    Expression<String>? conditionLogId,
    Expression<String>? bodyPart,
    Expression<String>? side,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conditionLogId != null) 'condition_log_id': conditionLogId,
      if (bodyPart != null) 'body_part': bodyPart,
      if (side != null) 'side': side,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PainAreasCompanion copyWith({
    Value<String>? id,
    Value<String>? conditionLogId,
    Value<String>? bodyPart,
    Value<String?>? side,
    Value<int>? rowid,
  }) {
    return PainAreasCompanion(
      id: id ?? this.id,
      conditionLogId: conditionLogId ?? this.conditionLogId,
      bodyPart: bodyPart ?? this.bodyPart,
      side: side ?? this.side,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conditionLogId.present) {
      map['condition_log_id'] = Variable<String>(conditionLogId.value);
    }
    if (bodyPart.present) {
      map['body_part'] = Variable<String>(bodyPart.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PainAreasCompanion(')
          ..write('id: $id, ')
          ..write('conditionLogId: $conditionLogId, ')
          ..write('bodyPart: $bodyPart, ')
          ..write('side: $side, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedRoutesTable extends SavedRoutes
    with TableInfo<$SavedRoutesTable, SavedRoute> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedRoutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _targetDistanceMMeta = const VerificationMeta(
    'targetDistanceM',
  );
  @override
  late final GeneratedColumn<double> targetDistanceM = GeneratedColumn<double>(
    'target_distance_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualDistanceMMeta = const VerificationMeta(
    'actualDistanceM',
  );
  @override
  late final GeneratedColumn<double> actualDistanceM = GeneratedColumn<double>(
    'actual_distance_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeTypeMeta = const VerificationMeta(
    'routeType',
  );
  @override
  late final GeneratedColumn<String> routeType = GeneratedColumn<String>(
    'route_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _polylineJsonMeta = const VerificationMeta(
    'polylineJson',
  );
  @override
  late final GeneratedColumn<String> polylineJson = GeneratedColumn<String>(
    'polyline_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departureLatMeta = const VerificationMeta(
    'departureLat',
  );
  @override
  late final GeneratedColumn<double> departureLat = GeneratedColumn<double>(
    'departure_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departureLngMeta = const VerificationMeta(
    'departureLng',
  );
  @override
  late final GeneratedColumn<double> departureLng = GeneratedColumn<double>(
    'departure_lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationLatMeta = const VerificationMeta(
    'destinationLat',
  );
  @override
  late final GeneratedColumn<double> destinationLat = GeneratedColumn<double>(
    'destination_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _destinationLngMeta = const VerificationMeta(
    'destinationLng',
  );
  @override
  late final GeneratedColumn<double> destinationLng = GeneratedColumn<double>(
    'destination_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    targetDistanceM,
    actualDistanceM,
    durationSeconds,
    routeType,
    polylineJson,
    departureLat,
    departureLng,
    destinationLat,
    destinationLng,
    isFavorite,
    createdAt,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_routes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedRoute> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('target_distance_m')) {
      context.handle(
        _targetDistanceMMeta,
        targetDistanceM.isAcceptableOrUnknown(
          data['target_distance_m']!,
          _targetDistanceMMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetDistanceMMeta);
    }
    if (data.containsKey('actual_distance_m')) {
      context.handle(
        _actualDistanceMMeta,
        actualDistanceM.isAcceptableOrUnknown(
          data['actual_distance_m']!,
          _actualDistanceMMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualDistanceMMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('route_type')) {
      context.handle(
        _routeTypeMeta,
        routeType.isAcceptableOrUnknown(data['route_type']!, _routeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_routeTypeMeta);
    }
    if (data.containsKey('polyline_json')) {
      context.handle(
        _polylineJsonMeta,
        polylineJson.isAcceptableOrUnknown(
          data['polyline_json']!,
          _polylineJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_polylineJsonMeta);
    }
    if (data.containsKey('departure_lat')) {
      context.handle(
        _departureLatMeta,
        departureLat.isAcceptableOrUnknown(
          data['departure_lat']!,
          _departureLatMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departureLatMeta);
    }
    if (data.containsKey('departure_lng')) {
      context.handle(
        _departureLngMeta,
        departureLng.isAcceptableOrUnknown(
          data['departure_lng']!,
          _departureLngMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departureLngMeta);
    }
    if (data.containsKey('destination_lat')) {
      context.handle(
        _destinationLatMeta,
        destinationLat.isAcceptableOrUnknown(
          data['destination_lat']!,
          _destinationLatMeta,
        ),
      );
    }
    if (data.containsKey('destination_lng')) {
      context.handle(
        _destinationLngMeta,
        destinationLng.isAcceptableOrUnknown(
          data['destination_lng']!,
          _destinationLngMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedRoute map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedRoute(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_distance_m'],
      )!,
      actualDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_distance_m'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      routeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_type'],
      )!,
      polylineJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}polyline_json'],
      )!,
      departureLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}departure_lat'],
      )!,
      departureLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}departure_lng'],
      )!,
      destinationLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}destination_lat'],
      ),
      destinationLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}destination_lng'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
    );
  }

  @override
  $SavedRoutesTable createAlias(String alias) {
    return $SavedRoutesTable(attachedDatabase, alias);
  }
}

class SavedRoute extends DataClass implements Insertable<SavedRoute> {
  final String id;

  /// UserProfiles FK
  final String userId;

  /// 任意のルート名（ユーザーが付ける）。未設定時は出発地点座標等から生成される。
  final String name;

  /// 目標距離（m）— ユーザーがスライダーで指定した値
  final double targetDistanceM;

  /// 実際の距離（m）— Mapbox から取得した実ルート距離
  final double actualDistanceM;

  /// 推定所要時間（秒）
  final int durationSeconds;

  /// ルート種別: circular / oneWay
  final String routeType;

  /// ルートの座標列を JSON 文字列で保存
  ///
  /// 形式: `[[lat, lng], [lat, lng], ...]`
  final String polylineJson;

  /// 出発地点緯度
  final double departureLat;

  /// 出発地点経度
  final double departureLng;

  /// 目的地点緯度（片道で指定された場合のみ）
  final double? destinationLat;

  /// 目的地点経度（片道で指定された場合のみ）
  final double? destinationLng;

  /// お気に入りフラグ
  final bool isFavorite;

  /// 作成日時
  final DateTime createdAt;

  /// 最終使用日時（走行開始時に更新）
  final DateTime? lastUsedAt;
  const SavedRoute({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetDistanceM,
    required this.actualDistanceM,
    required this.durationSeconds,
    required this.routeType,
    required this.polylineJson,
    required this.departureLat,
    required this.departureLng,
    this.destinationLat,
    this.destinationLng,
    required this.isFavorite,
    required this.createdAt,
    this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['target_distance_m'] = Variable<double>(targetDistanceM);
    map['actual_distance_m'] = Variable<double>(actualDistanceM);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['route_type'] = Variable<String>(routeType);
    map['polyline_json'] = Variable<String>(polylineJson);
    map['departure_lat'] = Variable<double>(departureLat);
    map['departure_lng'] = Variable<double>(departureLng);
    if (!nullToAbsent || destinationLat != null) {
      map['destination_lat'] = Variable<double>(destinationLat);
    }
    if (!nullToAbsent || destinationLng != null) {
      map['destination_lng'] = Variable<double>(destinationLng);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    return map;
  }

  SavedRoutesCompanion toCompanion(bool nullToAbsent) {
    return SavedRoutesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      targetDistanceM: Value(targetDistanceM),
      actualDistanceM: Value(actualDistanceM),
      durationSeconds: Value(durationSeconds),
      routeType: Value(routeType),
      polylineJson: Value(polylineJson),
      departureLat: Value(departureLat),
      departureLng: Value(departureLng),
      destinationLat: destinationLat == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationLat),
      destinationLng: destinationLng == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationLng),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
    );
  }

  factory SavedRoute.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedRoute(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      targetDistanceM: serializer.fromJson<double>(json['targetDistanceM']),
      actualDistanceM: serializer.fromJson<double>(json['actualDistanceM']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      routeType: serializer.fromJson<String>(json['routeType']),
      polylineJson: serializer.fromJson<String>(json['polylineJson']),
      departureLat: serializer.fromJson<double>(json['departureLat']),
      departureLng: serializer.fromJson<double>(json['departureLng']),
      destinationLat: serializer.fromJson<double?>(json['destinationLat']),
      destinationLng: serializer.fromJson<double?>(json['destinationLng']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'targetDistanceM': serializer.toJson<double>(targetDistanceM),
      'actualDistanceM': serializer.toJson<double>(actualDistanceM),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'routeType': serializer.toJson<String>(routeType),
      'polylineJson': serializer.toJson<String>(polylineJson),
      'departureLat': serializer.toJson<double>(departureLat),
      'departureLng': serializer.toJson<double>(departureLng),
      'destinationLat': serializer.toJson<double?>(destinationLat),
      'destinationLng': serializer.toJson<double?>(destinationLng),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
    };
  }

  SavedRoute copyWith({
    String? id,
    String? userId,
    String? name,
    double? targetDistanceM,
    double? actualDistanceM,
    int? durationSeconds,
    String? routeType,
    String? polylineJson,
    double? departureLat,
    double? departureLng,
    Value<double?> destinationLat = const Value.absent(),
    Value<double?> destinationLng = const Value.absent(),
    bool? isFavorite,
    DateTime? createdAt,
    Value<DateTime?> lastUsedAt = const Value.absent(),
  }) => SavedRoute(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    targetDistanceM: targetDistanceM ?? this.targetDistanceM,
    actualDistanceM: actualDistanceM ?? this.actualDistanceM,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    routeType: routeType ?? this.routeType,
    polylineJson: polylineJson ?? this.polylineJson,
    departureLat: departureLat ?? this.departureLat,
    departureLng: departureLng ?? this.departureLng,
    destinationLat: destinationLat.present
        ? destinationLat.value
        : this.destinationLat,
    destinationLng: destinationLng.present
        ? destinationLng.value
        : this.destinationLng,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt ?? this.createdAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
  );
  SavedRoute copyWithCompanion(SavedRoutesCompanion data) {
    return SavedRoute(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      targetDistanceM: data.targetDistanceM.present
          ? data.targetDistanceM.value
          : this.targetDistanceM,
      actualDistanceM: data.actualDistanceM.present
          ? data.actualDistanceM.value
          : this.actualDistanceM,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      routeType: data.routeType.present ? data.routeType.value : this.routeType,
      polylineJson: data.polylineJson.present
          ? data.polylineJson.value
          : this.polylineJson,
      departureLat: data.departureLat.present
          ? data.departureLat.value
          : this.departureLat,
      departureLng: data.departureLng.present
          ? data.departureLng.value
          : this.departureLng,
      destinationLat: data.destinationLat.present
          ? data.destinationLat.value
          : this.destinationLat,
      destinationLng: data.destinationLng.present
          ? data.destinationLng.value
          : this.destinationLng,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedRoute(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('targetDistanceM: $targetDistanceM, ')
          ..write('actualDistanceM: $actualDistanceM, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('routeType: $routeType, ')
          ..write('polylineJson: $polylineJson, ')
          ..write('departureLat: $departureLat, ')
          ..write('departureLng: $departureLng, ')
          ..write('destinationLat: $destinationLat, ')
          ..write('destinationLng: $destinationLng, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    targetDistanceM,
    actualDistanceM,
    durationSeconds,
    routeType,
    polylineJson,
    departureLat,
    departureLng,
    destinationLat,
    destinationLng,
    isFavorite,
    createdAt,
    lastUsedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedRoute &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.targetDistanceM == this.targetDistanceM &&
          other.actualDistanceM == this.actualDistanceM &&
          other.durationSeconds == this.durationSeconds &&
          other.routeType == this.routeType &&
          other.polylineJson == this.polylineJson &&
          other.departureLat == this.departureLat &&
          other.departureLng == this.departureLng &&
          other.destinationLat == this.destinationLat &&
          other.destinationLng == this.destinationLng &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt);
}

class SavedRoutesCompanion extends UpdateCompanion<SavedRoute> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<double> targetDistanceM;
  final Value<double> actualDistanceM;
  final Value<int> durationSeconds;
  final Value<String> routeType;
  final Value<String> polylineJson;
  final Value<double> departureLat;
  final Value<double> departureLng;
  final Value<double?> destinationLat;
  final Value<double?> destinationLng;
  final Value<bool> isFavorite;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUsedAt;
  final Value<int> rowid;
  const SavedRoutesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.targetDistanceM = const Value.absent(),
    this.actualDistanceM = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.routeType = const Value.absent(),
    this.polylineJson = const Value.absent(),
    this.departureLat = const Value.absent(),
    this.departureLng = const Value.absent(),
    this.destinationLat = const Value.absent(),
    this.destinationLng = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedRoutesCompanion.insert({
    required String id,
    required String userId,
    this.name = const Value.absent(),
    required double targetDistanceM,
    required double actualDistanceM,
    required int durationSeconds,
    required String routeType,
    required String polylineJson,
    required double departureLat,
    required double departureLng,
    this.destinationLat = const Value.absent(),
    this.destinationLng = const Value.absent(),
    this.isFavorite = const Value.absent(),
    required DateTime createdAt,
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       targetDistanceM = Value(targetDistanceM),
       actualDistanceM = Value(actualDistanceM),
       durationSeconds = Value(durationSeconds),
       routeType = Value(routeType),
       polylineJson = Value(polylineJson),
       departureLat = Value(departureLat),
       departureLng = Value(departureLng),
       createdAt = Value(createdAt);
  static Insertable<SavedRoute> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<double>? targetDistanceM,
    Expression<double>? actualDistanceM,
    Expression<int>? durationSeconds,
    Expression<String>? routeType,
    Expression<String>? polylineJson,
    Expression<double>? departureLat,
    Expression<double>? departureLng,
    Expression<double>? destinationLat,
    Expression<double>? destinationLng,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (targetDistanceM != null) 'target_distance_m': targetDistanceM,
      if (actualDistanceM != null) 'actual_distance_m': actualDistanceM,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (routeType != null) 'route_type': routeType,
      if (polylineJson != null) 'polyline_json': polylineJson,
      if (departureLat != null) 'departure_lat': departureLat,
      if (departureLng != null) 'departure_lng': departureLng,
      if (destinationLat != null) 'destination_lat': destinationLat,
      if (destinationLng != null) 'destination_lng': destinationLng,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedRoutesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<double>? targetDistanceM,
    Value<double>? actualDistanceM,
    Value<int>? durationSeconds,
    Value<String>? routeType,
    Value<String>? polylineJson,
    Value<double>? departureLat,
    Value<double>? departureLng,
    Value<double?>? destinationLat,
    Value<double?>? destinationLng,
    Value<bool>? isFavorite,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return SavedRoutesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetDistanceM: targetDistanceM ?? this.targetDistanceM,
      actualDistanceM: actualDistanceM ?? this.actualDistanceM,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      routeType: routeType ?? this.routeType,
      polylineJson: polylineJson ?? this.polylineJson,
      departureLat: departureLat ?? this.departureLat,
      departureLng: departureLng ?? this.departureLng,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetDistanceM.present) {
      map['target_distance_m'] = Variable<double>(targetDistanceM.value);
    }
    if (actualDistanceM.present) {
      map['actual_distance_m'] = Variable<double>(actualDistanceM.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (routeType.present) {
      map['route_type'] = Variable<String>(routeType.value);
    }
    if (polylineJson.present) {
      map['polyline_json'] = Variable<String>(polylineJson.value);
    }
    if (departureLat.present) {
      map['departure_lat'] = Variable<double>(departureLat.value);
    }
    if (departureLng.present) {
      map['departure_lng'] = Variable<double>(departureLng.value);
    }
    if (destinationLat.present) {
      map['destination_lat'] = Variable<double>(destinationLat.value);
    }
    if (destinationLng.present) {
      map['destination_lng'] = Variable<double>(destinationLng.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedRoutesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('targetDistanceM: $targetDistanceM, ')
          ..write('actualDistanceM: $actualDistanceM, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('routeType: $routeType, ')
          ..write('polylineJson: $polylineJson, ')
          ..write('departureLat: $departureLat, ')
          ..write('departureLng: $departureLng, ')
          ..write('destinationLat: $destinationLat, ')
          ..write('destinationLng: $destinationLng, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $RunSessionsTable runSessions = $RunSessionsTable(this);
  late final $GpsPointsTable gpsPoints = $GpsPointsTable(this);
  late final $ConditionLogsTable conditionLogs = $ConditionLogsTable(this);
  late final $PainAreasTable painAreas = $PainAreasTable(this);
  late final $SavedRoutesTable savedRoutes = $SavedRoutesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    userSettings,
    runSessions,
    gpsPoints,
    conditionLogs,
    painAreas,
    savedRoutes,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_settings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('run_sessions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'run_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('gps_points', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('condition_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'run_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('condition_logs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'condition_logs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pain_areas', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('saved_routes', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      Value<int?> age,
      Value<String?> rehabTarget,
      Value<double?> finalGoalDistance,
      Value<String> mode,
      Value<double> currentTargetDistance,
      required DateTime agreedDisclaimerAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<int?> age,
      Value<String?> rehabTarget,
      Value<double?> finalGoalDistance,
      Value<String> mode,
      Value<double> currentTargetDistance,
      Value<DateTime> agreedDisclaimerAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$UserProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile> {
  $$UserProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserSettingsTable, List<UserSetting>>
  _userSettingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userSettings,
    aliasName: $_aliasNameGenerator(db.userProfiles.id, db.userSettings.userId),
  );

  $$UserSettingsTableProcessedTableManager get userSettingsRefs {
    final manager = $$UserSettingsTableTableManager(
      $_db,
      $_db.userSettings,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userSettingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RunSessionsTable, List<RunSession>>
  _runSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.runSessions,
    aliasName: $_aliasNameGenerator(db.userProfiles.id, db.runSessions.userId),
  );

  $$RunSessionsTableProcessedTableManager get runSessionsRefs {
    final manager = $$RunSessionsTableTableManager(
      $_db,
      $_db.runSessions,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_runSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConditionLogsTable, List<ConditionLog>>
  _conditionLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conditionLogs,
    aliasName: $_aliasNameGenerator(
      db.userProfiles.id,
      db.conditionLogs.userId,
    ),
  );

  $$ConditionLogsTableProcessedTableManager get conditionLogsRefs {
    final manager = $$ConditionLogsTableTableManager(
      $_db,
      $_db.conditionLogs,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_conditionLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SavedRoutesTable, List<SavedRoute>>
  _savedRoutesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.savedRoutes,
    aliasName: $_aliasNameGenerator(db.userProfiles.id, db.savedRoutes.userId),
  );

  $$SavedRoutesTableProcessedTableManager get savedRoutesRefs {
    final manager = $$SavedRoutesTableTableManager(
      $_db,
      $_db.savedRoutes,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_savedRoutesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
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

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rehabTarget => $composableBuilder(
    column: $table.rehabTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get finalGoalDistance => $composableBuilder(
    column: $table.finalGoalDistance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentTargetDistance => $composableBuilder(
    column: $table.currentTargetDistance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get agreedDisclaimerAt => $composableBuilder(
    column: $table.agreedDisclaimerAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userSettingsRefs(
    Expression<bool> Function($$UserSettingsTableFilterComposer f) f,
  ) {
    final $$UserSettingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userSettings,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserSettingsTableFilterComposer(
            $db: $db,
            $table: $db.userSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> runSessionsRefs(
    Expression<bool> Function($$RunSessionsTableFilterComposer f) f,
  ) {
    final $$RunSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableFilterComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> conditionLogsRefs(
    Expression<bool> Function($$ConditionLogsTableFilterComposer f) f,
  ) {
    final $$ConditionLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conditionLogs,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConditionLogsTableFilterComposer(
            $db: $db,
            $table: $db.conditionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> savedRoutesRefs(
    Expression<bool> Function($$SavedRoutesTableFilterComposer f) f,
  ) {
    final $$SavedRoutesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedRoutes,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedRoutesTableFilterComposer(
            $db: $db,
            $table: $db.savedRoutes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
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

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rehabTarget => $composableBuilder(
    column: $table.rehabTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get finalGoalDistance => $composableBuilder(
    column: $table.finalGoalDistance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentTargetDistance => $composableBuilder(
    column: $table.currentTargetDistance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get agreedDisclaimerAt => $composableBuilder(
    column: $table.agreedDisclaimerAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get rehabTarget => $composableBuilder(
    column: $table.rehabTarget,
    builder: (column) => column,
  );

  GeneratedColumn<double> get finalGoalDistance => $composableBuilder(
    column: $table.finalGoalDistance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<double> get currentTargetDistance => $composableBuilder(
    column: $table.currentTargetDistance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get agreedDisclaimerAt => $composableBuilder(
    column: $table.agreedDisclaimerAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> userSettingsRefs<T extends Object>(
    Expression<T> Function($$UserSettingsTableAnnotationComposer a) f,
  ) {
    final $$UserSettingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userSettings,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserSettingsTableAnnotationComposer(
            $db: $db,
            $table: $db.userSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> runSessionsRefs<T extends Object>(
    Expression<T> Function($$RunSessionsTableAnnotationComposer a) f,
  ) {
    final $$RunSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> conditionLogsRefs<T extends Object>(
    Expression<T> Function($$ConditionLogsTableAnnotationComposer a) f,
  ) {
    final $$ConditionLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conditionLogs,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConditionLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.conditionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> savedRoutesRefs<T extends Object>(
    Expression<T> Function($$SavedRoutesTableAnnotationComposer a) f,
  ) {
    final $$SavedRoutesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedRoutes,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedRoutesTableAnnotationComposer(
            $db: $db,
            $table: $db.savedRoutes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (UserProfile, $$UserProfilesTableReferences),
          UserProfile,
          PrefetchHooks Function({
            bool userSettingsRefs,
            bool runSessionsRefs,
            bool conditionLogsRefs,
            bool savedRoutesRefs,
          })
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<String?> rehabTarget = const Value.absent(),
                Value<double?> finalGoalDistance = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<double> currentTargetDistance = const Value.absent(),
                Value<DateTime> agreedDisclaimerAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                age: age,
                rehabTarget: rehabTarget,
                finalGoalDistance: finalGoalDistance,
                mode: mode,
                currentTargetDistance: currentTargetDistance,
                agreedDisclaimerAt: agreedDisclaimerAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int?> age = const Value.absent(),
                Value<String?> rehabTarget = const Value.absent(),
                Value<double?> finalGoalDistance = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<double> currentTargetDistance = const Value.absent(),
                required DateTime agreedDisclaimerAt,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                age: age,
                rehabTarget: rehabTarget,
                finalGoalDistance: finalGoalDistance,
                mode: mode,
                currentTargetDistance: currentTargetDistance,
                agreedDisclaimerAt: agreedDisclaimerAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                userSettingsRefs = false,
                runSessionsRefs = false,
                conditionLogsRefs = false,
                savedRoutesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (userSettingsRefs) db.userSettings,
                    if (runSessionsRefs) db.runSessions,
                    if (conditionLogsRefs) db.conditionLogs,
                    if (savedRoutesRefs) db.savedRoutes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (userSettingsRefs)
                        await $_getPrefetchedData<
                          UserProfile,
                          $UserProfilesTable,
                          UserSetting
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableReferences
                              ._userSettingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).userSettingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (runSessionsRefs)
                        await $_getPrefetchedData<
                          UserProfile,
                          $UserProfilesTable,
                          RunSession
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableReferences
                              ._runSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).runSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (conditionLogsRefs)
                        await $_getPrefetchedData<
                          UserProfile,
                          $UserProfilesTable,
                          ConditionLog
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableReferences
                              ._conditionLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).conditionLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (savedRoutesRefs)
                        await $_getPrefetchedData<
                          UserProfile,
                          $UserProfilesTable,
                          SavedRoute
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableReferences
                              ._savedRoutesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).savedRoutesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (UserProfile, $$UserProfilesTableReferences),
      UserProfile,
      PrefetchHooks Function({
        bool userSettingsRefs,
        bool runSessionsRefs,
        bool conditionLogsRefs,
        bool savedRoutesRefs,
      })
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      required String id,
      required String userId,
      Value<String> designTheme,
      Value<String> fontSize,
      Value<bool> notificationEnabled,
      Value<bool> streakAlertEnabled,
      Value<bool> weatherAlertEnabled,
      Value<bool> gpsCorrectionEnabled,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> designTheme,
      Value<String> fontSize,
      Value<bool> notificationEnabled,
      Value<bool> streakAlertEnabled,
      Value<bool> weatherAlertEnabled,
      Value<bool> gpsCorrectionEnabled,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$UserSettingsTableReferences
    extends BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting> {
  $$UserSettingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserProfilesTable _userIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias(
        $_aliasNameGenerator(db.userSettings.userId, db.userProfiles.id),
      );

  $$UserProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
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

  ColumnFilters<String> get designTheme => $composableBuilder(
    column: $table.designTheme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fontSize => $composableBuilder(
    column: $table.fontSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationEnabled => $composableBuilder(
    column: $table.notificationEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get streakAlertEnabled => $composableBuilder(
    column: $table.streakAlertEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weatherAlertEnabled => $composableBuilder(
    column: $table.weatherAlertEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get gpsCorrectionEnabled => $composableBuilder(
    column: $table.gpsCorrectionEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableFilterComposer get userId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
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

  ColumnOrderings<String> get designTheme => $composableBuilder(
    column: $table.designTheme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fontSize => $composableBuilder(
    column: $table.fontSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationEnabled => $composableBuilder(
    column: $table.notificationEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get streakAlertEnabled => $composableBuilder(
    column: $table.streakAlertEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weatherAlertEnabled => $composableBuilder(
    column: $table.weatherAlertEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get gpsCorrectionEnabled => $composableBuilder(
    column: $table.gpsCorrectionEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableOrderingComposer get userId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get designTheme => $composableBuilder(
    column: $table.designTheme,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fontSize =>
      $composableBuilder(column: $table.fontSize, builder: (column) => column);

  GeneratedColumn<bool> get notificationEnabled => $composableBuilder(
    column: $table.notificationEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get streakAlertEnabled => $composableBuilder(
    column: $table.streakAlertEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get weatherAlertEnabled => $composableBuilder(
    column: $table.weatherAlertEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get gpsCorrectionEnabled => $composableBuilder(
    column: $table.gpsCorrectionEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$UserProfilesTableAnnotationComposer get userId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          UserSetting,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (UserSetting, $$UserSettingsTableReferences),
          UserSetting,
          PrefetchHooks Function({bool userId})
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> designTheme = const Value.absent(),
                Value<String> fontSize = const Value.absent(),
                Value<bool> notificationEnabled = const Value.absent(),
                Value<bool> streakAlertEnabled = const Value.absent(),
                Value<bool> weatherAlertEnabled = const Value.absent(),
                Value<bool> gpsCorrectionEnabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion(
                id: id,
                userId: userId,
                designTheme: designTheme,
                fontSize: fontSize,
                notificationEnabled: notificationEnabled,
                streakAlertEnabled: streakAlertEnabled,
                weatherAlertEnabled: weatherAlertEnabled,
                gpsCorrectionEnabled: gpsCorrectionEnabled,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String> designTheme = const Value.absent(),
                Value<String> fontSize = const Value.absent(),
                Value<bool> notificationEnabled = const Value.absent(),
                Value<bool> streakAlertEnabled = const Value.absent(),
                Value<bool> weatherAlertEnabled = const Value.absent(),
                Value<bool> gpsCorrectionEnabled = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                id: id,
                userId: userId,
                designTheme: designTheme,
                fontSize: fontSize,
                notificationEnabled: notificationEnabled,
                streakAlertEnabled: streakAlertEnabled,
                weatherAlertEnabled: weatherAlertEnabled,
                gpsCorrectionEnabled: gpsCorrectionEnabled,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserSettingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$UserSettingsTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$UserSettingsTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      UserSetting,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (UserSetting, $$UserSettingsTableReferences),
      UserSetting,
      PrefetchHooks Function({bool userId})
    >;
typedef $$RunSessionsTableCreateCompanionBuilder =
    RunSessionsCompanion Function({
      required String id,
      required String userId,
      required DateTime startedAt,
      Value<DateTime?> finishedAt,
      required double plannedDistance,
      Value<double> actualDistance,
      Value<int> durationSeconds,
      Value<double?> avgPaceSecsPerKm,
      Value<String> routeType,
      Value<String?> routeGeoJson,
      Value<bool> isGoalAchieved,
      Value<String> status,
      required double startLat,
      required double startLng,
      Value<double?> endLat,
      Value<double?> endLng,
      Value<int?> estimatedCalories,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$RunSessionsTableUpdateCompanionBuilder =
    RunSessionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<double> plannedDistance,
      Value<double> actualDistance,
      Value<int> durationSeconds,
      Value<double?> avgPaceSecsPerKm,
      Value<String> routeType,
      Value<String?> routeGeoJson,
      Value<bool> isGoalAchieved,
      Value<String> status,
      Value<double> startLat,
      Value<double> startLng,
      Value<double?> endLat,
      Value<double?> endLng,
      Value<int?> estimatedCalories,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$RunSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $RunSessionsTable, RunSession> {
  $$RunSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserProfilesTable _userIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias(
        $_aliasNameGenerator(db.runSessions.userId, db.userProfiles.id),
      );

  $$UserProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GpsPointsTable, List<GpsPoint>>
  _gpsPointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gpsPoints,
    aliasName: $_aliasNameGenerator(db.runSessions.id, db.gpsPoints.sessionId),
  );

  $$GpsPointsTableProcessedTableManager get gpsPointsRefs {
    final manager = $$GpsPointsTableTableManager(
      $_db,
      $_db.gpsPoints,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gpsPointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConditionLogsTable, List<ConditionLog>>
  _conditionLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conditionLogs,
    aliasName: $_aliasNameGenerator(
      db.runSessions.id,
      db.conditionLogs.sessionId,
    ),
  );

  $$ConditionLogsTableProcessedTableManager get conditionLogsRefs {
    final manager = $$ConditionLogsTableTableManager(
      $_db,
      $_db.conditionLogs,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_conditionLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RunSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $RunSessionsTable> {
  $$RunSessionsTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedDistance => $composableBuilder(
    column: $table.plannedDistance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualDistance => $composableBuilder(
    column: $table.actualDistance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgPaceSecsPerKm => $composableBuilder(
    column: $table.avgPaceSecsPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeType => $composableBuilder(
    column: $table.routeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeGeoJson => $composableBuilder(
    column: $table.routeGeoJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGoalAchieved => $composableBuilder(
    column: $table.isGoalAchieved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startLat => $composableBuilder(
    column: $table.startLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startLng => $composableBuilder(
    column: $table.startLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endLat => $composableBuilder(
    column: $table.endLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endLng => $composableBuilder(
    column: $table.endLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedCalories => $composableBuilder(
    column: $table.estimatedCalories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableFilterComposer get userId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> gpsPointsRefs(
    Expression<bool> Function($$GpsPointsTableFilterComposer f) f,
  ) {
    final $$GpsPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gpsPoints,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GpsPointsTableFilterComposer(
            $db: $db,
            $table: $db.gpsPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> conditionLogsRefs(
    Expression<bool> Function($$ConditionLogsTableFilterComposer f) f,
  ) {
    final $$ConditionLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conditionLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConditionLogsTableFilterComposer(
            $db: $db,
            $table: $db.conditionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RunSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RunSessionsTable> {
  $$RunSessionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedDistance => $composableBuilder(
    column: $table.plannedDistance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualDistance => $composableBuilder(
    column: $table.actualDistance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgPaceSecsPerKm => $composableBuilder(
    column: $table.avgPaceSecsPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeType => $composableBuilder(
    column: $table.routeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeGeoJson => $composableBuilder(
    column: $table.routeGeoJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGoalAchieved => $composableBuilder(
    column: $table.isGoalAchieved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startLat => $composableBuilder(
    column: $table.startLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startLng => $composableBuilder(
    column: $table.startLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endLat => $composableBuilder(
    column: $table.endLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endLng => $composableBuilder(
    column: $table.endLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedCalories => $composableBuilder(
    column: $table.estimatedCalories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableOrderingComposer get userId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunSessionsTable> {
  $$RunSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedDistance => $composableBuilder(
    column: $table.plannedDistance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualDistance => $composableBuilder(
    column: $table.actualDistance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgPaceSecsPerKm => $composableBuilder(
    column: $table.avgPaceSecsPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routeType =>
      $composableBuilder(column: $table.routeType, builder: (column) => column);

  GeneratedColumn<String> get routeGeoJson => $composableBuilder(
    column: $table.routeGeoJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isGoalAchieved => $composableBuilder(
    column: $table.isGoalAchieved,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get startLat =>
      $composableBuilder(column: $table.startLat, builder: (column) => column);

  GeneratedColumn<double> get startLng =>
      $composableBuilder(column: $table.startLng, builder: (column) => column);

  GeneratedColumn<double> get endLat =>
      $composableBuilder(column: $table.endLat, builder: (column) => column);

  GeneratedColumn<double> get endLng =>
      $composableBuilder(column: $table.endLng, builder: (column) => column);

  GeneratedColumn<int> get estimatedCalories => $composableBuilder(
    column: $table.estimatedCalories,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UserProfilesTableAnnotationComposer get userId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> gpsPointsRefs<T extends Object>(
    Expression<T> Function($$GpsPointsTableAnnotationComposer a) f,
  ) {
    final $$GpsPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gpsPoints,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GpsPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.gpsPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> conditionLogsRefs<T extends Object>(
    Expression<T> Function($$ConditionLogsTableAnnotationComposer a) f,
  ) {
    final $$ConditionLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conditionLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConditionLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.conditionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RunSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunSessionsTable,
          RunSession,
          $$RunSessionsTableFilterComposer,
          $$RunSessionsTableOrderingComposer,
          $$RunSessionsTableAnnotationComposer,
          $$RunSessionsTableCreateCompanionBuilder,
          $$RunSessionsTableUpdateCompanionBuilder,
          (RunSession, $$RunSessionsTableReferences),
          RunSession,
          PrefetchHooks Function({
            bool userId,
            bool gpsPointsRefs,
            bool conditionLogsRefs,
          })
        > {
  $$RunSessionsTableTableManager(_$AppDatabase db, $RunSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<double> plannedDistance = const Value.absent(),
                Value<double> actualDistance = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double?> avgPaceSecsPerKm = const Value.absent(),
                Value<String> routeType = const Value.absent(),
                Value<String?> routeGeoJson = const Value.absent(),
                Value<bool> isGoalAchieved = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> startLat = const Value.absent(),
                Value<double> startLng = const Value.absent(),
                Value<double?> endLat = const Value.absent(),
                Value<double?> endLng = const Value.absent(),
                Value<int?> estimatedCalories = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunSessionsCompanion(
                id: id,
                userId: userId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                plannedDistance: plannedDistance,
                actualDistance: actualDistance,
                durationSeconds: durationSeconds,
                avgPaceSecsPerKm: avgPaceSecsPerKm,
                routeType: routeType,
                routeGeoJson: routeGeoJson,
                isGoalAchieved: isGoalAchieved,
                status: status,
                startLat: startLat,
                startLng: startLng,
                endLat: endLat,
                endLng: endLng,
                estimatedCalories: estimatedCalories,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                required double plannedDistance,
                Value<double> actualDistance = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double?> avgPaceSecsPerKm = const Value.absent(),
                Value<String> routeType = const Value.absent(),
                Value<String?> routeGeoJson = const Value.absent(),
                Value<bool> isGoalAchieved = const Value.absent(),
                Value<String> status = const Value.absent(),
                required double startLat,
                required double startLng,
                Value<double?> endLat = const Value.absent(),
                Value<double?> endLng = const Value.absent(),
                Value<int?> estimatedCalories = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RunSessionsCompanion.insert(
                id: id,
                userId: userId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                plannedDistance: plannedDistance,
                actualDistance: actualDistance,
                durationSeconds: durationSeconds,
                avgPaceSecsPerKm: avgPaceSecsPerKm,
                routeType: routeType,
                routeGeoJson: routeGeoJson,
                isGoalAchieved: isGoalAchieved,
                status: status,
                startLat: startLat,
                startLng: startLng,
                endLat: endLat,
                endLng: endLng,
                estimatedCalories: estimatedCalories,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RunSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                userId = false,
                gpsPointsRefs = false,
                conditionLogsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gpsPointsRefs) db.gpsPoints,
                    if (conditionLogsRefs) db.conditionLogs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable:
                                        $$RunSessionsTableReferences
                                            ._userIdTable(db),
                                    referencedColumn:
                                        $$RunSessionsTableReferences
                                            ._userIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gpsPointsRefs)
                        await $_getPrefetchedData<
                          RunSession,
                          $RunSessionsTable,
                          GpsPoint
                        >(
                          currentTable: table,
                          referencedTable: $$RunSessionsTableReferences
                              ._gpsPointsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RunSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).gpsPointsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (conditionLogsRefs)
                        await $_getPrefetchedData<
                          RunSession,
                          $RunSessionsTable,
                          ConditionLog
                        >(
                          currentTable: table,
                          referencedTable: $$RunSessionsTableReferences
                              ._conditionLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RunSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).conditionLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RunSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunSessionsTable,
      RunSession,
      $$RunSessionsTableFilterComposer,
      $$RunSessionsTableOrderingComposer,
      $$RunSessionsTableAnnotationComposer,
      $$RunSessionsTableCreateCompanionBuilder,
      $$RunSessionsTableUpdateCompanionBuilder,
      (RunSession, $$RunSessionsTableReferences),
      RunSession,
      PrefetchHooks Function({
        bool userId,
        bool gpsPointsRefs,
        bool conditionLogsRefs,
      })
    >;
typedef $$GpsPointsTableCreateCompanionBuilder =
    GpsPointsCompanion Function({
      required String id,
      required String sessionId,
      required double lat,
      required double lng,
      Value<double?> altitudeM,
      Value<double?> accuracyM,
      Value<double?> speedMps,
      required DateTime recordedAt,
      Value<int> rowid,
    });
typedef $$GpsPointsTableUpdateCompanionBuilder =
    GpsPointsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<double> lat,
      Value<double> lng,
      Value<double?> altitudeM,
      Value<double?> accuracyM,
      Value<double?> speedMps,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });

final class $$GpsPointsTableReferences
    extends BaseReferences<_$AppDatabase, $GpsPointsTable, GpsPoint> {
  $$GpsPointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RunSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.runSessions.createAlias(
        $_aliasNameGenerator(db.gpsPoints.sessionId, db.runSessions.id),
      );

  $$RunSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$RunSessionsTableTableManager(
      $_db,
      $_db.runSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GpsPointsTableFilterComposer
    extends Composer<_$AppDatabase, $GpsPointsTable> {
  $$GpsPointsTableFilterComposer({
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

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitudeM => $composableBuilder(
    column: $table.altitudeM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RunSessionsTableFilterComposer get sessionId {
    final $$RunSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableFilterComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GpsPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $GpsPointsTable> {
  $$GpsPointsTableOrderingComposer({
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

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitudeM => $composableBuilder(
    column: $table.altitudeM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RunSessionsTableOrderingComposer get sessionId {
    final $$RunSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GpsPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GpsPointsTable> {
  $$GpsPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get altitudeM =>
      $composableBuilder(column: $table.altitudeM, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<double> get speedMps =>
      $composableBuilder(column: $table.speedMps, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  $$RunSessionsTableAnnotationComposer get sessionId {
    final $$RunSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GpsPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GpsPointsTable,
          GpsPoint,
          $$GpsPointsTableFilterComposer,
          $$GpsPointsTableOrderingComposer,
          $$GpsPointsTableAnnotationComposer,
          $$GpsPointsTableCreateCompanionBuilder,
          $$GpsPointsTableUpdateCompanionBuilder,
          (GpsPoint, $$GpsPointsTableReferences),
          GpsPoint,
          PrefetchHooks Function({bool sessionId})
        > {
  $$GpsPointsTableTableManager(_$AppDatabase db, $GpsPointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GpsPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GpsPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GpsPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<double?> altitudeM = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<double?> speedMps = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GpsPointsCompanion(
                id: id,
                sessionId: sessionId,
                lat: lat,
                lng: lng,
                altitudeM: altitudeM,
                accuracyM: accuracyM,
                speedMps: speedMps,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required double lat,
                required double lng,
                Value<double?> altitudeM = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<double?> speedMps = const Value.absent(),
                required DateTime recordedAt,
                Value<int> rowid = const Value.absent(),
              }) => GpsPointsCompanion.insert(
                id: id,
                sessionId: sessionId,
                lat: lat,
                lng: lng,
                altitudeM: altitudeM,
                accuracyM: accuracyM,
                speedMps: speedMps,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GpsPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$GpsPointsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$GpsPointsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GpsPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GpsPointsTable,
      GpsPoint,
      $$GpsPointsTableFilterComposer,
      $$GpsPointsTableOrderingComposer,
      $$GpsPointsTableAnnotationComposer,
      $$GpsPointsTableCreateCompanionBuilder,
      $$GpsPointsTableUpdateCompanionBuilder,
      (GpsPoint, $$GpsPointsTableReferences),
      GpsPoint,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$ConditionLogsTableCreateCompanionBuilder =
    ConditionLogsCompanion Function({
      required String id,
      required String userId,
      Value<String?> sessionId,
      required String timing,
      Value<int> painScore,
      Value<String?> memo,
      required DateTime recordedAt,
      Value<int> rowid,
    });
typedef $$ConditionLogsTableUpdateCompanionBuilder =
    ConditionLogsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> sessionId,
      Value<String> timing,
      Value<int> painScore,
      Value<String?> memo,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });

final class $$ConditionLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ConditionLogsTable, ConditionLog> {
  $$ConditionLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserProfilesTable _userIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias(
        $_aliasNameGenerator(db.conditionLogs.userId, db.userProfiles.id),
      );

  $$UserProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RunSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.runSessions.createAlias(
        $_aliasNameGenerator(db.conditionLogs.sessionId, db.runSessions.id),
      );

  $$RunSessionsTableProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<String>('session_id');
    if ($_column == null) return null;
    final manager = $$RunSessionsTableTableManager(
      $_db,
      $_db.runSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PainAreasTable, List<PainArea>>
  _painAreasRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.painAreas,
    aliasName: $_aliasNameGenerator(
      db.conditionLogs.id,
      db.painAreas.conditionLogId,
    ),
  );

  $$PainAreasTableProcessedTableManager get painAreasRefs {
    final manager = $$PainAreasTableTableManager(
      $_db,
      $_db.painAreas,
    ).filter((f) => f.conditionLogId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_painAreasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConditionLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ConditionLogsTable> {
  $$ConditionLogsTableFilterComposer({
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

  ColumnFilters<String> get timing => $composableBuilder(
    column: $table.timing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get painScore => $composableBuilder(
    column: $table.painScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableFilterComposer get userId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RunSessionsTableFilterComposer get sessionId {
    final $$RunSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableFilterComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> painAreasRefs(
    Expression<bool> Function($$PainAreasTableFilterComposer f) f,
  ) {
    final $$PainAreasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.painAreas,
      getReferencedColumn: (t) => t.conditionLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PainAreasTableFilterComposer(
            $db: $db,
            $table: $db.painAreas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConditionLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConditionLogsTable> {
  $$ConditionLogsTableOrderingComposer({
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

  ColumnOrderings<String> get timing => $composableBuilder(
    column: $table.timing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get painScore => $composableBuilder(
    column: $table.painScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableOrderingComposer get userId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RunSessionsTableOrderingComposer get sessionId {
    final $$RunSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConditionLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConditionLogsTable> {
  $$ConditionLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get timing =>
      $composableBuilder(column: $table.timing, builder: (column) => column);

  GeneratedColumn<int> get painScore =>
      $composableBuilder(column: $table.painScore, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  $$UserProfilesTableAnnotationComposer get userId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RunSessionsTableAnnotationComposer get sessionId {
    final $$RunSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.runSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.runSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> painAreasRefs<T extends Object>(
    Expression<T> Function($$PainAreasTableAnnotationComposer a) f,
  ) {
    final $$PainAreasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.painAreas,
      getReferencedColumn: (t) => t.conditionLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PainAreasTableAnnotationComposer(
            $db: $db,
            $table: $db.painAreas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConditionLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConditionLogsTable,
          ConditionLog,
          $$ConditionLogsTableFilterComposer,
          $$ConditionLogsTableOrderingComposer,
          $$ConditionLogsTableAnnotationComposer,
          $$ConditionLogsTableCreateCompanionBuilder,
          $$ConditionLogsTableUpdateCompanionBuilder,
          (ConditionLog, $$ConditionLogsTableReferences),
          ConditionLog,
          PrefetchHooks Function({
            bool userId,
            bool sessionId,
            bool painAreasRefs,
          })
        > {
  $$ConditionLogsTableTableManager(_$AppDatabase db, $ConditionLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConditionLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConditionLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConditionLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<String> timing = const Value.absent(),
                Value<int> painScore = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConditionLogsCompanion(
                id: id,
                userId: userId,
                sessionId: sessionId,
                timing: timing,
                painScore: painScore,
                memo: memo,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> sessionId = const Value.absent(),
                required String timing,
                Value<int> painScore = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                required DateTime recordedAt,
                Value<int> rowid = const Value.absent(),
              }) => ConditionLogsCompanion.insert(
                id: id,
                userId: userId,
                sessionId: sessionId,
                timing: timing,
                painScore: painScore,
                memo: memo,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConditionLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({userId = false, sessionId = false, painAreasRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (painAreasRefs) db.painAreas],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable:
                                        $$ConditionLogsTableReferences
                                            ._userIdTable(db),
                                    referencedColumn:
                                        $$ConditionLogsTableReferences
                                            ._userIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$ConditionLogsTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$ConditionLogsTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (painAreasRefs)
                        await $_getPrefetchedData<
                          ConditionLog,
                          $ConditionLogsTable,
                          PainArea
                        >(
                          currentTable: table,
                          referencedTable: $$ConditionLogsTableReferences
                              ._painAreasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConditionLogsTableReferences(
                                db,
                                table,
                                p0,
                              ).painAreasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.conditionLogId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ConditionLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConditionLogsTable,
      ConditionLog,
      $$ConditionLogsTableFilterComposer,
      $$ConditionLogsTableOrderingComposer,
      $$ConditionLogsTableAnnotationComposer,
      $$ConditionLogsTableCreateCompanionBuilder,
      $$ConditionLogsTableUpdateCompanionBuilder,
      (ConditionLog, $$ConditionLogsTableReferences),
      ConditionLog,
      PrefetchHooks Function({bool userId, bool sessionId, bool painAreasRefs})
    >;
typedef $$PainAreasTableCreateCompanionBuilder =
    PainAreasCompanion Function({
      required String id,
      required String conditionLogId,
      required String bodyPart,
      Value<String?> side,
      Value<int> rowid,
    });
typedef $$PainAreasTableUpdateCompanionBuilder =
    PainAreasCompanion Function({
      Value<String> id,
      Value<String> conditionLogId,
      Value<String> bodyPart,
      Value<String?> side,
      Value<int> rowid,
    });

final class $$PainAreasTableReferences
    extends BaseReferences<_$AppDatabase, $PainAreasTable, PainArea> {
  $$PainAreasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConditionLogsTable _conditionLogIdTable(_$AppDatabase db) =>
      db.conditionLogs.createAlias(
        $_aliasNameGenerator(db.painAreas.conditionLogId, db.conditionLogs.id),
      );

  $$ConditionLogsTableProcessedTableManager get conditionLogId {
    final $_column = $_itemColumn<String>('condition_log_id')!;

    final manager = $$ConditionLogsTableTableManager(
      $_db,
      $_db.conditionLogs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conditionLogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PainAreasTableFilterComposer
    extends Composer<_$AppDatabase, $PainAreasTable> {
  $$PainAreasTableFilterComposer({
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

  ColumnFilters<String> get bodyPart => $composableBuilder(
    column: $table.bodyPart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  $$ConditionLogsTableFilterComposer get conditionLogId {
    final $$ConditionLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conditionLogId,
      referencedTable: $db.conditionLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConditionLogsTableFilterComposer(
            $db: $db,
            $table: $db.conditionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PainAreasTableOrderingComposer
    extends Composer<_$AppDatabase, $PainAreasTable> {
  $$PainAreasTableOrderingComposer({
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

  ColumnOrderings<String> get bodyPart => $composableBuilder(
    column: $table.bodyPart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConditionLogsTableOrderingComposer get conditionLogId {
    final $$ConditionLogsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conditionLogId,
      referencedTable: $db.conditionLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConditionLogsTableOrderingComposer(
            $db: $db,
            $table: $db.conditionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PainAreasTableAnnotationComposer
    extends Composer<_$AppDatabase, $PainAreasTable> {
  $$PainAreasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bodyPart =>
      $composableBuilder(column: $table.bodyPart, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  $$ConditionLogsTableAnnotationComposer get conditionLogId {
    final $$ConditionLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conditionLogId,
      referencedTable: $db.conditionLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConditionLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.conditionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PainAreasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PainAreasTable,
          PainArea,
          $$PainAreasTableFilterComposer,
          $$PainAreasTableOrderingComposer,
          $$PainAreasTableAnnotationComposer,
          $$PainAreasTableCreateCompanionBuilder,
          $$PainAreasTableUpdateCompanionBuilder,
          (PainArea, $$PainAreasTableReferences),
          PainArea,
          PrefetchHooks Function({bool conditionLogId})
        > {
  $$PainAreasTableTableManager(_$AppDatabase db, $PainAreasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PainAreasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PainAreasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PainAreasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> conditionLogId = const Value.absent(),
                Value<String> bodyPart = const Value.absent(),
                Value<String?> side = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PainAreasCompanion(
                id: id,
                conditionLogId: conditionLogId,
                bodyPart: bodyPart,
                side: side,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String conditionLogId,
                required String bodyPart,
                Value<String?> side = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PainAreasCompanion.insert(
                id: id,
                conditionLogId: conditionLogId,
                bodyPart: bodyPart,
                side: side,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PainAreasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({conditionLogId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (conditionLogId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.conditionLogId,
                                referencedTable: $$PainAreasTableReferences
                                    ._conditionLogIdTable(db),
                                referencedColumn: $$PainAreasTableReferences
                                    ._conditionLogIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PainAreasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PainAreasTable,
      PainArea,
      $$PainAreasTableFilterComposer,
      $$PainAreasTableOrderingComposer,
      $$PainAreasTableAnnotationComposer,
      $$PainAreasTableCreateCompanionBuilder,
      $$PainAreasTableUpdateCompanionBuilder,
      (PainArea, $$PainAreasTableReferences),
      PainArea,
      PrefetchHooks Function({bool conditionLogId})
    >;
typedef $$SavedRoutesTableCreateCompanionBuilder =
    SavedRoutesCompanion Function({
      required String id,
      required String userId,
      Value<String> name,
      required double targetDistanceM,
      required double actualDistanceM,
      required int durationSeconds,
      required String routeType,
      required String polylineJson,
      required double departureLat,
      required double departureLng,
      Value<double?> destinationLat,
      Value<double?> destinationLng,
      Value<bool> isFavorite,
      required DateTime createdAt,
      Value<DateTime?> lastUsedAt,
      Value<int> rowid,
    });
typedef $$SavedRoutesTableUpdateCompanionBuilder =
    SavedRoutesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<double> targetDistanceM,
      Value<double> actualDistanceM,
      Value<int> durationSeconds,
      Value<String> routeType,
      Value<String> polylineJson,
      Value<double> departureLat,
      Value<double> departureLng,
      Value<double?> destinationLat,
      Value<double?> destinationLng,
      Value<bool> isFavorite,
      Value<DateTime> createdAt,
      Value<DateTime?> lastUsedAt,
      Value<int> rowid,
    });

final class $$SavedRoutesTableReferences
    extends BaseReferences<_$AppDatabase, $SavedRoutesTable, SavedRoute> {
  $$SavedRoutesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserProfilesTable _userIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias(
        $_aliasNameGenerator(db.savedRoutes.userId, db.userProfiles.id),
      );

  $$UserProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SavedRoutesTableFilterComposer
    extends Composer<_$AppDatabase, $SavedRoutesTable> {
  $$SavedRoutesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetDistanceM => $composableBuilder(
    column: $table.targetDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualDistanceM => $composableBuilder(
    column: $table.actualDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeType => $composableBuilder(
    column: $table.routeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get polylineJson => $composableBuilder(
    column: $table.polylineJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get departureLat => $composableBuilder(
    column: $table.departureLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get departureLng => $composableBuilder(
    column: $table.departureLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get destinationLat => $composableBuilder(
    column: $table.destinationLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get destinationLng => $composableBuilder(
    column: $table.destinationLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableFilterComposer get userId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedRoutesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedRoutesTable> {
  $$SavedRoutesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetDistanceM => $composableBuilder(
    column: $table.targetDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualDistanceM => $composableBuilder(
    column: $table.actualDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeType => $composableBuilder(
    column: $table.routeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get polylineJson => $composableBuilder(
    column: $table.polylineJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get departureLat => $composableBuilder(
    column: $table.departureLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get departureLng => $composableBuilder(
    column: $table.departureLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get destinationLat => $composableBuilder(
    column: $table.destinationLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get destinationLng => $composableBuilder(
    column: $table.destinationLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableOrderingComposer get userId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedRoutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedRoutesTable> {
  $$SavedRoutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get targetDistanceM => $composableBuilder(
    column: $table.targetDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualDistanceM => $composableBuilder(
    column: $table.actualDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routeType =>
      $composableBuilder(column: $table.routeType, builder: (column) => column);

  GeneratedColumn<String> get polylineJson => $composableBuilder(
    column: $table.polylineJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get departureLat => $composableBuilder(
    column: $table.departureLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get departureLng => $composableBuilder(
    column: $table.departureLng,
    builder: (column) => column,
  );

  GeneratedColumn<double> get destinationLat => $composableBuilder(
    column: $table.destinationLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get destinationLng => $composableBuilder(
    column: $table.destinationLng,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  $$UserProfilesTableAnnotationComposer get userId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedRoutesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedRoutesTable,
          SavedRoute,
          $$SavedRoutesTableFilterComposer,
          $$SavedRoutesTableOrderingComposer,
          $$SavedRoutesTableAnnotationComposer,
          $$SavedRoutesTableCreateCompanionBuilder,
          $$SavedRoutesTableUpdateCompanionBuilder,
          (SavedRoute, $$SavedRoutesTableReferences),
          SavedRoute,
          PrefetchHooks Function({bool userId})
        > {
  $$SavedRoutesTableTableManager(_$AppDatabase db, $SavedRoutesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedRoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedRoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedRoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> targetDistanceM = const Value.absent(),
                Value<double> actualDistanceM = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String> routeType = const Value.absent(),
                Value<String> polylineJson = const Value.absent(),
                Value<double> departureLat = const Value.absent(),
                Value<double> departureLng = const Value.absent(),
                Value<double?> destinationLat = const Value.absent(),
                Value<double?> destinationLng = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedRoutesCompanion(
                id: id,
                userId: userId,
                name: name,
                targetDistanceM: targetDistanceM,
                actualDistanceM: actualDistanceM,
                durationSeconds: durationSeconds,
                routeType: routeType,
                polylineJson: polylineJson,
                departureLat: departureLat,
                departureLng: departureLng,
                destinationLat: destinationLat,
                destinationLng: destinationLng,
                isFavorite: isFavorite,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String> name = const Value.absent(),
                required double targetDistanceM,
                required double actualDistanceM,
                required int durationSeconds,
                required String routeType,
                required String polylineJson,
                required double departureLat,
                required double departureLng,
                Value<double?> destinationLat = const Value.absent(),
                Value<double?> destinationLng = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedRoutesCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                targetDistanceM: targetDistanceM,
                actualDistanceM: actualDistanceM,
                durationSeconds: durationSeconds,
                routeType: routeType,
                polylineJson: polylineJson,
                departureLat: departureLat,
                departureLng: departureLng,
                destinationLat: destinationLat,
                destinationLng: destinationLng,
                isFavorite: isFavorite,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavedRoutesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$SavedRoutesTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$SavedRoutesTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SavedRoutesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedRoutesTable,
      SavedRoute,
      $$SavedRoutesTableFilterComposer,
      $$SavedRoutesTableOrderingComposer,
      $$SavedRoutesTableAnnotationComposer,
      $$SavedRoutesTableCreateCompanionBuilder,
      $$SavedRoutesTableUpdateCompanionBuilder,
      (SavedRoute, $$SavedRoutesTableReferences),
      SavedRoute,
      PrefetchHooks Function({bool userId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$RunSessionsTableTableManager get runSessions =>
      $$RunSessionsTableTableManager(_db, _db.runSessions);
  $$GpsPointsTableTableManager get gpsPoints =>
      $$GpsPointsTableTableManager(_db, _db.gpsPoints);
  $$ConditionLogsTableTableManager get conditionLogs =>
      $$ConditionLogsTableTableManager(_db, _db.conditionLogs);
  $$PainAreasTableTableManager get painAreas =>
      $$PainAreasTableTableManager(_db, _db.painAreas);
  $$SavedRoutesTableTableManager get savedRoutes =>
      $$SavedRoutesTableTableManager(_db, _db.savedRoutes);
}
