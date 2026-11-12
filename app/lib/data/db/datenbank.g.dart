// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datenbank.dart';

// ignore_for_file: type=lint
class $StandorteTable extends Standorte
    with TableInfo<$StandorteTable, Standort> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StandorteTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'standorte';
  @override
  VerificationContext validateIntegrity(
    Insertable<Standort> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Standort map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Standort(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $StandorteTable createAlias(String alias) {
    return $StandorteTable(attachedDatabase, alias);
  }
}

class Standort extends DataClass implements Insertable<Standort> {
  final int id;
  final String name;
  const Standort({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  StandorteCompanion toCompanion(bool nullToAbsent) {
    return StandorteCompanion(id: Value(id), name: Value(name));
  }

  factory Standort.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Standort(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Standort copyWith({int? id, String? name}) =>
      Standort(id: id ?? this.id, name: name ?? this.name);
  Standort copyWithCompanion(StandorteCompanion data) {
    return Standort(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Standort(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Standort && other.id == this.id && other.name == this.name);
}

class StandorteCompanion extends UpdateCompanion<Standort> {
  final Value<int> id;
  final Value<String> name;
  const StandorteCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  StandorteCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Standort> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  StandorteCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return StandorteCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StandorteCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $MuskelgruppenTable extends Muskelgruppen
    with TableInfo<$MuskelgruppenTable, Muskelgruppe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MuskelgruppenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sortierungMeta = const VerificationMeta(
    'sortierung',
  );
  @override
  late final GeneratedColumn<int> sortierung = GeneratedColumn<int>(
    'sortierung',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sortierung];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'muskelgruppen';
  @override
  VerificationContext validateIntegrity(
    Insertable<Muskelgruppe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sortierung')) {
      context.handle(
        _sortierungMeta,
        sortierung.isAcceptableOrUnknown(data['sortierung']!, _sortierungMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Muskelgruppe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Muskelgruppe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortierung: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sortierung'],
      )!,
    );
  }

  @override
  $MuskelgruppenTable createAlias(String alias) {
    return $MuskelgruppenTable(attachedDatabase, alias);
  }
}

class Muskelgruppe extends DataClass implements Insertable<Muskelgruppe> {
  final int id;
  final String name;

  /// Anzeigereihenfolge in Auswahllisten.
  final int sortierung;
  const Muskelgruppe({
    required this.id,
    required this.name,
    required this.sortierung,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sortierung'] = Variable<int>(sortierung);
    return map;
  }

  MuskelgruppenCompanion toCompanion(bool nullToAbsent) {
    return MuskelgruppenCompanion(
      id: Value(id),
      name: Value(name),
      sortierung: Value(sortierung),
    );
  }

  factory Muskelgruppe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Muskelgruppe(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortierung: serializer.fromJson<int>(json['sortierung']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sortierung': serializer.toJson<int>(sortierung),
    };
  }

  Muskelgruppe copyWith({int? id, String? name, int? sortierung}) =>
      Muskelgruppe(
        id: id ?? this.id,
        name: name ?? this.name,
        sortierung: sortierung ?? this.sortierung,
      );
  Muskelgruppe copyWithCompanion(MuskelgruppenCompanion data) {
    return Muskelgruppe(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortierung: data.sortierung.present
          ? data.sortierung.value
          : this.sortierung,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Muskelgruppe(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortierung: $sortierung')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortierung);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Muskelgruppe &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortierung == this.sortierung);
}

class MuskelgruppenCompanion extends UpdateCompanion<Muskelgruppe> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sortierung;
  const MuskelgruppenCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortierung = const Value.absent(),
  });
  MuskelgruppenCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sortierung = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Muskelgruppe> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sortierung,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortierung != null) 'sortierung': sortierung,
    });
  }

  MuskelgruppenCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? sortierung,
  }) {
    return MuskelgruppenCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortierung: sortierung ?? this.sortierung,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortierung.present) {
      map['sortierung'] = Variable<int>(sortierung.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MuskelgruppenCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortierung: $sortierung')
          ..write(')'))
        .toString();
  }
}

class $GeraeteTable extends Geraete with TableInfo<$GeraeteTable, Geraet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeraeteTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _standortIdMeta = const VerificationMeta(
    'standortId',
  );
  @override
  late final GeneratedColumn<int> standortId = GeneratedColumn<int>(
    'standort_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES standorte (id)',
    ),
  );
  static const VerificationMeta _kuerzelMeta = const VerificationMeta(
    'kuerzel',
  );
  @override
  late final GeneratedColumn<String> kuerzel = GeneratedColumn<String>(
    'kuerzel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _funktionMeta = const VerificationMeta(
    'funktion',
  );
  @override
  late final GeneratedColumn<String> funktion = GeneratedColumn<String>(
    'funktion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muskelgruppeIdMeta = const VerificationMeta(
    'muskelgruppeId',
  );
  @override
  late final GeneratedColumn<int> muskelgruppeId = GeneratedColumn<int>(
    'muskelgruppe_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES muskelgruppen (id)',
    ),
  );
  static const VerificationMeta _herstellerMeta = const VerificationMeta(
    'hersteller',
  );
  @override
  late final GeneratedColumn<String> hersteller = GeneratedColumn<String>(
    'hersteller',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modellMeta = const VerificationMeta('modell');
  @override
  late final GeneratedColumn<String> modell = GeneratedColumn<String>(
    'modell',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Einheit, String> einheit =
      GeneratedColumn<String>(
        'einheit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Einheit>($GeraeteTable.$convertereinheit);
  static const VerificationMeta _assistiertMeta = const VerificationMeta(
    'assistiert',
  );
  @override
  late final GeneratedColumn<bool> assistiert = GeneratedColumn<bool>(
    'assistiert',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("assistiert" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _linksRechtsGetrenntMeta =
      const VerificationMeta('linksRechtsGetrennt');
  @override
  late final GeneratedColumn<bool> linksRechtsGetrennt = GeneratedColumn<bool>(
    'links_rechts_getrennt',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("links_rechts_getrennt" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _einstellung1Meta = const VerificationMeta(
    'einstellung1',
  );
  @override
  late final GeneratedColumn<String> einstellung1 = GeneratedColumn<String>(
    'einstellung1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _einstellung2Meta = const VerificationMeta(
    'einstellung2',
  );
  @override
  late final GeneratedColumn<String> einstellung2 = GeneratedColumn<String>(
    'einstellung2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _einstellung3Meta = const VerificationMeta(
    'einstellung3',
  );
  @override
  late final GeneratedColumn<String> einstellung3 = GeneratedColumn<String>(
    'einstellung3',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notizMeta = const VerificationMeta('notiz');
  @override
  late final GeneratedColumn<String> notiz = GeneratedColumn<String>(
    'notiz',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    standortId,
    kuerzel,
    funktion,
    muskelgruppeId,
    hersteller,
    modell,
    einheit,
    assistiert,
    linksRechtsGetrennt,
    einstellung1,
    einstellung2,
    einstellung3,
    notiz,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'geraete';
  @override
  VerificationContext validateIntegrity(
    Insertable<Geraet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('standort_id')) {
      context.handle(
        _standortIdMeta,
        standortId.isAcceptableOrUnknown(data['standort_id']!, _standortIdMeta),
      );
    } else if (isInserting) {
      context.missing(_standortIdMeta);
    }
    if (data.containsKey('kuerzel')) {
      context.handle(
        _kuerzelMeta,
        kuerzel.isAcceptableOrUnknown(data['kuerzel']!, _kuerzelMeta),
      );
    } else if (isInserting) {
      context.missing(_kuerzelMeta);
    }
    if (data.containsKey('funktion')) {
      context.handle(
        _funktionMeta,
        funktion.isAcceptableOrUnknown(data['funktion']!, _funktionMeta),
      );
    }
    if (data.containsKey('muskelgruppe_id')) {
      context.handle(
        _muskelgruppeIdMeta,
        muskelgruppeId.isAcceptableOrUnknown(
          data['muskelgruppe_id']!,
          _muskelgruppeIdMeta,
        ),
      );
    }
    if (data.containsKey('hersteller')) {
      context.handle(
        _herstellerMeta,
        hersteller.isAcceptableOrUnknown(data['hersteller']!, _herstellerMeta),
      );
    }
    if (data.containsKey('modell')) {
      context.handle(
        _modellMeta,
        modell.isAcceptableOrUnknown(data['modell']!, _modellMeta),
      );
    }
    if (data.containsKey('assistiert')) {
      context.handle(
        _assistiertMeta,
        assistiert.isAcceptableOrUnknown(data['assistiert']!, _assistiertMeta),
      );
    }
    if (data.containsKey('links_rechts_getrennt')) {
      context.handle(
        _linksRechtsGetrenntMeta,
        linksRechtsGetrennt.isAcceptableOrUnknown(
          data['links_rechts_getrennt']!,
          _linksRechtsGetrenntMeta,
        ),
      );
    }
    if (data.containsKey('einstellung1')) {
      context.handle(
        _einstellung1Meta,
        einstellung1.isAcceptableOrUnknown(
          data['einstellung1']!,
          _einstellung1Meta,
        ),
      );
    }
    if (data.containsKey('einstellung2')) {
      context.handle(
        _einstellung2Meta,
        einstellung2.isAcceptableOrUnknown(
          data['einstellung2']!,
          _einstellung2Meta,
        ),
      );
    }
    if (data.containsKey('einstellung3')) {
      context.handle(
        _einstellung3Meta,
        einstellung3.isAcceptableOrUnknown(
          data['einstellung3']!,
          _einstellung3Meta,
        ),
      );
    }
    if (data.containsKey('notiz')) {
      context.handle(
        _notizMeta,
        notiz.isAcceptableOrUnknown(data['notiz']!, _notizMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {standortId, kuerzel},
  ];
  @override
  Geraet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Geraet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      standortId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}standort_id'],
      )!,
      kuerzel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kuerzel'],
      )!,
      funktion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}funktion'],
      ),
      muskelgruppeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}muskelgruppe_id'],
      ),
      hersteller: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hersteller'],
      ),
      modell: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modell'],
      ),
      einheit: $GeraeteTable.$convertereinheit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}einheit'],
        )!,
      ),
      assistiert: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}assistiert'],
      )!,
      linksRechtsGetrennt: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}links_rechts_getrennt'],
      )!,
      einstellung1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}einstellung1'],
      ),
      einstellung2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}einstellung2'],
      ),
      einstellung3: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}einstellung3'],
      ),
      notiz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notiz'],
      ),
    );
  }

  @override
  $GeraeteTable createAlias(String alias) {
    return $GeraeteTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Einheit, String, String> $convertereinheit =
      const EnumNameConverter<Einheit>(Einheit.values);
}

class Geraet extends DataClass implements Insertable<Geraet> {
  final int id;
  final int standortId;
  final String kuerzel;
  final String? funktion;

  /// Hauptmuskelgruppe; leer, solange unbekannt.
  final int? muskelgruppeId;
  final String? hersteller;
  final String? modell;

  /// Vorgabe-Einheit für neue Sätze (R1.6) – ändert alte Sätze nicht.
  final Einheit einheit;
  final bool assistiert;
  final bool linksRechtsGetrennt;
  final String? einstellung1;
  final String? einstellung2;
  final String? einstellung3;
  final String? notiz;
  const Geraet({
    required this.id,
    required this.standortId,
    required this.kuerzel,
    this.funktion,
    this.muskelgruppeId,
    this.hersteller,
    this.modell,
    required this.einheit,
    required this.assistiert,
    required this.linksRechtsGetrennt,
    this.einstellung1,
    this.einstellung2,
    this.einstellung3,
    this.notiz,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['standort_id'] = Variable<int>(standortId);
    map['kuerzel'] = Variable<String>(kuerzel);
    if (!nullToAbsent || funktion != null) {
      map['funktion'] = Variable<String>(funktion);
    }
    if (!nullToAbsent || muskelgruppeId != null) {
      map['muskelgruppe_id'] = Variable<int>(muskelgruppeId);
    }
    if (!nullToAbsent || hersteller != null) {
      map['hersteller'] = Variable<String>(hersteller);
    }
    if (!nullToAbsent || modell != null) {
      map['modell'] = Variable<String>(modell);
    }
    {
      map['einheit'] = Variable<String>(
        $GeraeteTable.$convertereinheit.toSql(einheit),
      );
    }
    map['assistiert'] = Variable<bool>(assistiert);
    map['links_rechts_getrennt'] = Variable<bool>(linksRechtsGetrennt);
    if (!nullToAbsent || einstellung1 != null) {
      map['einstellung1'] = Variable<String>(einstellung1);
    }
    if (!nullToAbsent || einstellung2 != null) {
      map['einstellung2'] = Variable<String>(einstellung2);
    }
    if (!nullToAbsent || einstellung3 != null) {
      map['einstellung3'] = Variable<String>(einstellung3);
    }
    if (!nullToAbsent || notiz != null) {
      map['notiz'] = Variable<String>(notiz);
    }
    return map;
  }

  GeraeteCompanion toCompanion(bool nullToAbsent) {
    return GeraeteCompanion(
      id: Value(id),
      standortId: Value(standortId),
      kuerzel: Value(kuerzel),
      funktion: funktion == null && nullToAbsent
          ? const Value.absent()
          : Value(funktion),
      muskelgruppeId: muskelgruppeId == null && nullToAbsent
          ? const Value.absent()
          : Value(muskelgruppeId),
      hersteller: hersteller == null && nullToAbsent
          ? const Value.absent()
          : Value(hersteller),
      modell: modell == null && nullToAbsent
          ? const Value.absent()
          : Value(modell),
      einheit: Value(einheit),
      assistiert: Value(assistiert),
      linksRechtsGetrennt: Value(linksRechtsGetrennt),
      einstellung1: einstellung1 == null && nullToAbsent
          ? const Value.absent()
          : Value(einstellung1),
      einstellung2: einstellung2 == null && nullToAbsent
          ? const Value.absent()
          : Value(einstellung2),
      einstellung3: einstellung3 == null && nullToAbsent
          ? const Value.absent()
          : Value(einstellung3),
      notiz: notiz == null && nullToAbsent
          ? const Value.absent()
          : Value(notiz),
    );
  }

  factory Geraet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Geraet(
      id: serializer.fromJson<int>(json['id']),
      standortId: serializer.fromJson<int>(json['standortId']),
      kuerzel: serializer.fromJson<String>(json['kuerzel']),
      funktion: serializer.fromJson<String?>(json['funktion']),
      muskelgruppeId: serializer.fromJson<int?>(json['muskelgruppeId']),
      hersteller: serializer.fromJson<String?>(json['hersteller']),
      modell: serializer.fromJson<String?>(json['modell']),
      einheit: $GeraeteTable.$convertereinheit.fromJson(
        serializer.fromJson<String>(json['einheit']),
      ),
      assistiert: serializer.fromJson<bool>(json['assistiert']),
      linksRechtsGetrennt: serializer.fromJson<bool>(
        json['linksRechtsGetrennt'],
      ),
      einstellung1: serializer.fromJson<String?>(json['einstellung1']),
      einstellung2: serializer.fromJson<String?>(json['einstellung2']),
      einstellung3: serializer.fromJson<String?>(json['einstellung3']),
      notiz: serializer.fromJson<String?>(json['notiz']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'standortId': serializer.toJson<int>(standortId),
      'kuerzel': serializer.toJson<String>(kuerzel),
      'funktion': serializer.toJson<String?>(funktion),
      'muskelgruppeId': serializer.toJson<int?>(muskelgruppeId),
      'hersteller': serializer.toJson<String?>(hersteller),
      'modell': serializer.toJson<String?>(modell),
      'einheit': serializer.toJson<String>(
        $GeraeteTable.$convertereinheit.toJson(einheit),
      ),
      'assistiert': serializer.toJson<bool>(assistiert),
      'linksRechtsGetrennt': serializer.toJson<bool>(linksRechtsGetrennt),
      'einstellung1': serializer.toJson<String?>(einstellung1),
      'einstellung2': serializer.toJson<String?>(einstellung2),
      'einstellung3': serializer.toJson<String?>(einstellung3),
      'notiz': serializer.toJson<String?>(notiz),
    };
  }

  Geraet copyWith({
    int? id,
    int? standortId,
    String? kuerzel,
    Value<String?> funktion = const Value.absent(),
    Value<int?> muskelgruppeId = const Value.absent(),
    Value<String?> hersteller = const Value.absent(),
    Value<String?> modell = const Value.absent(),
    Einheit? einheit,
    bool? assistiert,
    bool? linksRechtsGetrennt,
    Value<String?> einstellung1 = const Value.absent(),
    Value<String?> einstellung2 = const Value.absent(),
    Value<String?> einstellung3 = const Value.absent(),
    Value<String?> notiz = const Value.absent(),
  }) => Geraet(
    id: id ?? this.id,
    standortId: standortId ?? this.standortId,
    kuerzel: kuerzel ?? this.kuerzel,
    funktion: funktion.present ? funktion.value : this.funktion,
    muskelgruppeId: muskelgruppeId.present
        ? muskelgruppeId.value
        : this.muskelgruppeId,
    hersteller: hersteller.present ? hersteller.value : this.hersteller,
    modell: modell.present ? modell.value : this.modell,
    einheit: einheit ?? this.einheit,
    assistiert: assistiert ?? this.assistiert,
    linksRechtsGetrennt: linksRechtsGetrennt ?? this.linksRechtsGetrennt,
    einstellung1: einstellung1.present ? einstellung1.value : this.einstellung1,
    einstellung2: einstellung2.present ? einstellung2.value : this.einstellung2,
    einstellung3: einstellung3.present ? einstellung3.value : this.einstellung3,
    notiz: notiz.present ? notiz.value : this.notiz,
  );
  Geraet copyWithCompanion(GeraeteCompanion data) {
    return Geraet(
      id: data.id.present ? data.id.value : this.id,
      standortId: data.standortId.present
          ? data.standortId.value
          : this.standortId,
      kuerzel: data.kuerzel.present ? data.kuerzel.value : this.kuerzel,
      funktion: data.funktion.present ? data.funktion.value : this.funktion,
      muskelgruppeId: data.muskelgruppeId.present
          ? data.muskelgruppeId.value
          : this.muskelgruppeId,
      hersteller: data.hersteller.present
          ? data.hersteller.value
          : this.hersteller,
      modell: data.modell.present ? data.modell.value : this.modell,
      einheit: data.einheit.present ? data.einheit.value : this.einheit,
      assistiert: data.assistiert.present
          ? data.assistiert.value
          : this.assistiert,
      linksRechtsGetrennt: data.linksRechtsGetrennt.present
          ? data.linksRechtsGetrennt.value
          : this.linksRechtsGetrennt,
      einstellung1: data.einstellung1.present
          ? data.einstellung1.value
          : this.einstellung1,
      einstellung2: data.einstellung2.present
          ? data.einstellung2.value
          : this.einstellung2,
      einstellung3: data.einstellung3.present
          ? data.einstellung3.value
          : this.einstellung3,
      notiz: data.notiz.present ? data.notiz.value : this.notiz,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Geraet(')
          ..write('id: $id, ')
          ..write('standortId: $standortId, ')
          ..write('kuerzel: $kuerzel, ')
          ..write('funktion: $funktion, ')
          ..write('muskelgruppeId: $muskelgruppeId, ')
          ..write('hersteller: $hersteller, ')
          ..write('modell: $modell, ')
          ..write('einheit: $einheit, ')
          ..write('assistiert: $assistiert, ')
          ..write('linksRechtsGetrennt: $linksRechtsGetrennt, ')
          ..write('einstellung1: $einstellung1, ')
          ..write('einstellung2: $einstellung2, ')
          ..write('einstellung3: $einstellung3, ')
          ..write('notiz: $notiz')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    standortId,
    kuerzel,
    funktion,
    muskelgruppeId,
    hersteller,
    modell,
    einheit,
    assistiert,
    linksRechtsGetrennt,
    einstellung1,
    einstellung2,
    einstellung3,
    notiz,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Geraet &&
          other.id == this.id &&
          other.standortId == this.standortId &&
          other.kuerzel == this.kuerzel &&
          other.funktion == this.funktion &&
          other.muskelgruppeId == this.muskelgruppeId &&
          other.hersteller == this.hersteller &&
          other.modell == this.modell &&
          other.einheit == this.einheit &&
          other.assistiert == this.assistiert &&
          other.linksRechtsGetrennt == this.linksRechtsGetrennt &&
          other.einstellung1 == this.einstellung1 &&
          other.einstellung2 == this.einstellung2 &&
          other.einstellung3 == this.einstellung3 &&
          other.notiz == this.notiz);
}

class GeraeteCompanion extends UpdateCompanion<Geraet> {
  final Value<int> id;
  final Value<int> standortId;
  final Value<String> kuerzel;
  final Value<String?> funktion;
  final Value<int?> muskelgruppeId;
  final Value<String?> hersteller;
  final Value<String?> modell;
  final Value<Einheit> einheit;
  final Value<bool> assistiert;
  final Value<bool> linksRechtsGetrennt;
  final Value<String?> einstellung1;
  final Value<String?> einstellung2;
  final Value<String?> einstellung3;
  final Value<String?> notiz;
  const GeraeteCompanion({
    this.id = const Value.absent(),
    this.standortId = const Value.absent(),
    this.kuerzel = const Value.absent(),
    this.funktion = const Value.absent(),
    this.muskelgruppeId = const Value.absent(),
    this.hersteller = const Value.absent(),
    this.modell = const Value.absent(),
    this.einheit = const Value.absent(),
    this.assistiert = const Value.absent(),
    this.linksRechtsGetrennt = const Value.absent(),
    this.einstellung1 = const Value.absent(),
    this.einstellung2 = const Value.absent(),
    this.einstellung3 = const Value.absent(),
    this.notiz = const Value.absent(),
  });
  GeraeteCompanion.insert({
    this.id = const Value.absent(),
    required int standortId,
    required String kuerzel,
    this.funktion = const Value.absent(),
    this.muskelgruppeId = const Value.absent(),
    this.hersteller = const Value.absent(),
    this.modell = const Value.absent(),
    required Einheit einheit,
    this.assistiert = const Value.absent(),
    this.linksRechtsGetrennt = const Value.absent(),
    this.einstellung1 = const Value.absent(),
    this.einstellung2 = const Value.absent(),
    this.einstellung3 = const Value.absent(),
    this.notiz = const Value.absent(),
  }) : standortId = Value(standortId),
       kuerzel = Value(kuerzel),
       einheit = Value(einheit);
  static Insertable<Geraet> custom({
    Expression<int>? id,
    Expression<int>? standortId,
    Expression<String>? kuerzel,
    Expression<String>? funktion,
    Expression<int>? muskelgruppeId,
    Expression<String>? hersteller,
    Expression<String>? modell,
    Expression<String>? einheit,
    Expression<bool>? assistiert,
    Expression<bool>? linksRechtsGetrennt,
    Expression<String>? einstellung1,
    Expression<String>? einstellung2,
    Expression<String>? einstellung3,
    Expression<String>? notiz,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (standortId != null) 'standort_id': standortId,
      if (kuerzel != null) 'kuerzel': kuerzel,
      if (funktion != null) 'funktion': funktion,
      if (muskelgruppeId != null) 'muskelgruppe_id': muskelgruppeId,
      if (hersteller != null) 'hersteller': hersteller,
      if (modell != null) 'modell': modell,
      if (einheit != null) 'einheit': einheit,
      if (assistiert != null) 'assistiert': assistiert,
      if (linksRechtsGetrennt != null)
        'links_rechts_getrennt': linksRechtsGetrennt,
      if (einstellung1 != null) 'einstellung1': einstellung1,
      if (einstellung2 != null) 'einstellung2': einstellung2,
      if (einstellung3 != null) 'einstellung3': einstellung3,
      if (notiz != null) 'notiz': notiz,
    });
  }

  GeraeteCompanion copyWith({
    Value<int>? id,
    Value<int>? standortId,
    Value<String>? kuerzel,
    Value<String?>? funktion,
    Value<int?>? muskelgruppeId,
    Value<String?>? hersteller,
    Value<String?>? modell,
    Value<Einheit>? einheit,
    Value<bool>? assistiert,
    Value<bool>? linksRechtsGetrennt,
    Value<String?>? einstellung1,
    Value<String?>? einstellung2,
    Value<String?>? einstellung3,
    Value<String?>? notiz,
  }) {
    return GeraeteCompanion(
      id: id ?? this.id,
      standortId: standortId ?? this.standortId,
      kuerzel: kuerzel ?? this.kuerzel,
      funktion: funktion ?? this.funktion,
      muskelgruppeId: muskelgruppeId ?? this.muskelgruppeId,
      hersteller: hersteller ?? this.hersteller,
      modell: modell ?? this.modell,
      einheit: einheit ?? this.einheit,
      assistiert: assistiert ?? this.assistiert,
      linksRechtsGetrennt: linksRechtsGetrennt ?? this.linksRechtsGetrennt,
      einstellung1: einstellung1 ?? this.einstellung1,
      einstellung2: einstellung2 ?? this.einstellung2,
      einstellung3: einstellung3 ?? this.einstellung3,
      notiz: notiz ?? this.notiz,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (standortId.present) {
      map['standort_id'] = Variable<int>(standortId.value);
    }
    if (kuerzel.present) {
      map['kuerzel'] = Variable<String>(kuerzel.value);
    }
    if (funktion.present) {
      map['funktion'] = Variable<String>(funktion.value);
    }
    if (muskelgruppeId.present) {
      map['muskelgruppe_id'] = Variable<int>(muskelgruppeId.value);
    }
    if (hersteller.present) {
      map['hersteller'] = Variable<String>(hersteller.value);
    }
    if (modell.present) {
      map['modell'] = Variable<String>(modell.value);
    }
    if (einheit.present) {
      map['einheit'] = Variable<String>(
        $GeraeteTable.$convertereinheit.toSql(einheit.value),
      );
    }
    if (assistiert.present) {
      map['assistiert'] = Variable<bool>(assistiert.value);
    }
    if (linksRechtsGetrennt.present) {
      map['links_rechts_getrennt'] = Variable<bool>(linksRechtsGetrennt.value);
    }
    if (einstellung1.present) {
      map['einstellung1'] = Variable<String>(einstellung1.value);
    }
    if (einstellung2.present) {
      map['einstellung2'] = Variable<String>(einstellung2.value);
    }
    if (einstellung3.present) {
      map['einstellung3'] = Variable<String>(einstellung3.value);
    }
    if (notiz.present) {
      map['notiz'] = Variable<String>(notiz.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeraeteCompanion(')
          ..write('id: $id, ')
          ..write('standortId: $standortId, ')
          ..write('kuerzel: $kuerzel, ')
          ..write('funktion: $funktion, ')
          ..write('muskelgruppeId: $muskelgruppeId, ')
          ..write('hersteller: $hersteller, ')
          ..write('modell: $modell, ')
          ..write('einheit: $einheit, ')
          ..write('assistiert: $assistiert, ')
          ..write('linksRechtsGetrennt: $linksRechtsGetrennt, ')
          ..write('einstellung1: $einstellung1, ')
          ..write('einstellung2: $einstellung2, ')
          ..write('einstellung3: $einstellung3, ')
          ..write('notiz: $notiz')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, TrainingsSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _datumMeta = const VerificationMeta('datum');
  @override
  late final GeneratedColumn<String> datum = GeneratedColumn<String>(
    'datum',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _standortIdMeta = const VerificationMeta(
    'standortId',
  );
  @override
  late final GeneratedColumn<int> standortId = GeneratedColumn<int>(
    'standort_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES standorte (id)',
    ),
  );
  static const VerificationMeta _koerpergewichtKgMeta = const VerificationMeta(
    'koerpergewichtKg',
  );
  @override
  late final GeneratedColumn<double> koerpergewichtKg = GeneratedColumn<double>(
    'koerpergewicht_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    datum,
    standortId,
    koerpergewichtKg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingsSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('datum')) {
      context.handle(
        _datumMeta,
        datum.isAcceptableOrUnknown(data['datum']!, _datumMeta),
      );
    } else if (isInserting) {
      context.missing(_datumMeta);
    }
    if (data.containsKey('standort_id')) {
      context.handle(
        _standortIdMeta,
        standortId.isAcceptableOrUnknown(data['standort_id']!, _standortIdMeta),
      );
    } else if (isInserting) {
      context.missing(_standortIdMeta);
    }
    if (data.containsKey('koerpergewicht_kg')) {
      context.handle(
        _koerpergewichtKgMeta,
        koerpergewichtKg.isAcceptableOrUnknown(
          data['koerpergewicht_kg']!,
          _koerpergewichtKgMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingsSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingsSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      datum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datum'],
      )!,
      standortId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}standort_id'],
      )!,
      koerpergewichtKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}koerpergewicht_kg'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class TrainingsSession extends DataClass
    implements Insertable<TrainingsSession> {
  final int id;

  /// Kalenderdatum als Text `JJJJ-MM-TT` (ohne Uhrzeit, ohne Zeitzonen-Effekte).
  final String datum;
  final int standortId;
  final double? koerpergewichtKg;
  const TrainingsSession({
    required this.id,
    required this.datum,
    required this.standortId,
    this.koerpergewichtKg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['datum'] = Variable<String>(datum);
    map['standort_id'] = Variable<int>(standortId);
    if (!nullToAbsent || koerpergewichtKg != null) {
      map['koerpergewicht_kg'] = Variable<double>(koerpergewichtKg);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      datum: Value(datum),
      standortId: Value(standortId),
      koerpergewichtKg: koerpergewichtKg == null && nullToAbsent
          ? const Value.absent()
          : Value(koerpergewichtKg),
    );
  }

  factory TrainingsSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingsSession(
      id: serializer.fromJson<int>(json['id']),
      datum: serializer.fromJson<String>(json['datum']),
      standortId: serializer.fromJson<int>(json['standortId']),
      koerpergewichtKg: serializer.fromJson<double?>(json['koerpergewichtKg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'datum': serializer.toJson<String>(datum),
      'standortId': serializer.toJson<int>(standortId),
      'koerpergewichtKg': serializer.toJson<double?>(koerpergewichtKg),
    };
  }

  TrainingsSession copyWith({
    int? id,
    String? datum,
    int? standortId,
    Value<double?> koerpergewichtKg = const Value.absent(),
  }) => TrainingsSession(
    id: id ?? this.id,
    datum: datum ?? this.datum,
    standortId: standortId ?? this.standortId,
    koerpergewichtKg: koerpergewichtKg.present
        ? koerpergewichtKg.value
        : this.koerpergewichtKg,
  );
  TrainingsSession copyWithCompanion(SessionsCompanion data) {
    return TrainingsSession(
      id: data.id.present ? data.id.value : this.id,
      datum: data.datum.present ? data.datum.value : this.datum,
      standortId: data.standortId.present
          ? data.standortId.value
          : this.standortId,
      koerpergewichtKg: data.koerpergewichtKg.present
          ? data.koerpergewichtKg.value
          : this.koerpergewichtKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingsSession(')
          ..write('id: $id, ')
          ..write('datum: $datum, ')
          ..write('standortId: $standortId, ')
          ..write('koerpergewichtKg: $koerpergewichtKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, datum, standortId, koerpergewichtKg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingsSession &&
          other.id == this.id &&
          other.datum == this.datum &&
          other.standortId == this.standortId &&
          other.koerpergewichtKg == this.koerpergewichtKg);
}

class SessionsCompanion extends UpdateCompanion<TrainingsSession> {
  final Value<int> id;
  final Value<String> datum;
  final Value<int> standortId;
  final Value<double?> koerpergewichtKg;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.datum = const Value.absent(),
    this.standortId = const Value.absent(),
    this.koerpergewichtKg = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String datum,
    required int standortId,
    this.koerpergewichtKg = const Value.absent(),
  }) : datum = Value(datum),
       standortId = Value(standortId);
  static Insertable<TrainingsSession> custom({
    Expression<int>? id,
    Expression<String>? datum,
    Expression<int>? standortId,
    Expression<double>? koerpergewichtKg,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (datum != null) 'datum': datum,
      if (standortId != null) 'standort_id': standortId,
      if (koerpergewichtKg != null) 'koerpergewicht_kg': koerpergewichtKg,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? datum,
    Value<int>? standortId,
    Value<double?>? koerpergewichtKg,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      datum: datum ?? this.datum,
      standortId: standortId ?? this.standortId,
      koerpergewichtKg: koerpergewichtKg ?? this.koerpergewichtKg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (datum.present) {
      map['datum'] = Variable<String>(datum.value);
    }
    if (standortId.present) {
      map['standort_id'] = Variable<int>(standortId.value);
    }
    if (koerpergewichtKg.present) {
      map['koerpergewicht_kg'] = Variable<double>(koerpergewichtKg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('datum: $datum, ')
          ..write('standortId: $standortId, ')
          ..write('koerpergewichtKg: $koerpergewichtKg')
          ..write(')'))
        .toString();
  }
}

class $SaetzeTable extends Saetze with TableInfo<$SaetzeTable, Satz> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaetzeTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _geraetIdMeta = const VerificationMeta(
    'geraetId',
  );
  @override
  late final GeneratedColumn<int> geraetId = GeneratedColumn<int>(
    'geraet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES geraete (id)',
    ),
  );
  static const VerificationMeta _satzNrMeta = const VerificationMeta('satzNr');
  @override
  late final GeneratedColumn<int> satzNr = GeneratedColumn<int>(
    'satz_nr',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Seite?, String> seite =
      GeneratedColumn<String>(
        'seite',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Seite?>($SaetzeTable.$converterseiten);
  static const VerificationMeta _wiederholungenMeta = const VerificationMeta(
    'wiederholungen',
  );
  @override
  late final GeneratedColumn<int> wiederholungen = GeneratedColumn<int>(
    'wiederholungen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eingabewertMeta = const VerificationMeta(
    'eingabewert',
  );
  @override
  late final GeneratedColumn<double> eingabewert = GeneratedColumn<double>(
    'eingabewert',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Einheit, String> eingabeeinheit =
      GeneratedColumn<String>(
        'eingabeeinheit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Einheit>($SaetzeTable.$convertereingabeeinheit);
  static const VerificationMeta _gewichtKgMeta = const VerificationMeta(
    'gewichtKg',
  );
  @override
  late final GeneratedColumn<double> gewichtKg = GeneratedColumn<double>(
    'gewicht_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notizMeta = const VerificationMeta('notiz');
  @override
  late final GeneratedColumn<String> notiz = GeneratedColumn<String>(
    'notiz',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    geraetId,
    satzNr,
    seite,
    wiederholungen,
    eingabewert,
    eingabeeinheit,
    gewichtKg,
    notiz,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saetze';
  @override
  VerificationContext validateIntegrity(
    Insertable<Satz> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('geraet_id')) {
      context.handle(
        _geraetIdMeta,
        geraetId.isAcceptableOrUnknown(data['geraet_id']!, _geraetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_geraetIdMeta);
    }
    if (data.containsKey('satz_nr')) {
      context.handle(
        _satzNrMeta,
        satzNr.isAcceptableOrUnknown(data['satz_nr']!, _satzNrMeta),
      );
    } else if (isInserting) {
      context.missing(_satzNrMeta);
    }
    if (data.containsKey('wiederholungen')) {
      context.handle(
        _wiederholungenMeta,
        wiederholungen.isAcceptableOrUnknown(
          data['wiederholungen']!,
          _wiederholungenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wiederholungenMeta);
    }
    if (data.containsKey('eingabewert')) {
      context.handle(
        _eingabewertMeta,
        eingabewert.isAcceptableOrUnknown(
          data['eingabewert']!,
          _eingabewertMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eingabewertMeta);
    }
    if (data.containsKey('gewicht_kg')) {
      context.handle(
        _gewichtKgMeta,
        gewichtKg.isAcceptableOrUnknown(data['gewicht_kg']!, _gewichtKgMeta),
      );
    } else if (isInserting) {
      context.missing(_gewichtKgMeta);
    }
    if (data.containsKey('notiz')) {
      context.handle(
        _notizMeta,
        notiz.isAcceptableOrUnknown(data['notiz']!, _notizMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Satz map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Satz(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      geraetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}geraet_id'],
      )!,
      satzNr: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}satz_nr'],
      )!,
      seite: $SaetzeTable.$converterseiten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}seite'],
        ),
      ),
      wiederholungen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wiederholungen'],
      )!,
      eingabewert: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}eingabewert'],
      )!,
      eingabeeinheit: $SaetzeTable.$convertereingabeeinheit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}eingabeeinheit'],
        )!,
      ),
      gewichtKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gewicht_kg'],
      )!,
      notiz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notiz'],
      ),
    );
  }

  @override
  $SaetzeTable createAlias(String alias) {
    return $SaetzeTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Seite, String, String> $converterseite =
      const EnumNameConverter<Seite>(Seite.values);
  static JsonTypeConverter2<Seite?, String?, String?> $converterseiten =
      JsonTypeConverter2.asNullable($converterseite);
  static JsonTypeConverter2<Einheit, String, String> $convertereingabeeinheit =
      const EnumNameConverter<Einheit>(Einheit.values);
}

class Satz extends DataClass implements Insertable<Satz> {
  final int id;
  final int sessionId;

  /// Verweist auf das Gerät, nicht auf das Kürzel (R1.6).
  final int geraetId;

  /// Zählt pro Gerät, Seite und Session (R2.7).
  final int satzNr;

  /// L / R bei links/rechts getrennten Geräten, sonst leer.
  final Seite? seite;
  final int wiederholungen;

  /// Original-Eingabe, z. B. 70 + lbs.
  final double eingabewert;
  final Einheit eingabeeinheit;

  /// Effektives Gewicht in kg (berechnet, bei assistiert: Körpergewicht − Eingabe).
  final double gewichtKg;
  final String? notiz;
  const Satz({
    required this.id,
    required this.sessionId,
    required this.geraetId,
    required this.satzNr,
    this.seite,
    required this.wiederholungen,
    required this.eingabewert,
    required this.eingabeeinheit,
    required this.gewichtKg,
    this.notiz,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['geraet_id'] = Variable<int>(geraetId);
    map['satz_nr'] = Variable<int>(satzNr);
    if (!nullToAbsent || seite != null) {
      map['seite'] = Variable<String>(
        $SaetzeTable.$converterseiten.toSql(seite),
      );
    }
    map['wiederholungen'] = Variable<int>(wiederholungen);
    map['eingabewert'] = Variable<double>(eingabewert);
    {
      map['eingabeeinheit'] = Variable<String>(
        $SaetzeTable.$convertereingabeeinheit.toSql(eingabeeinheit),
      );
    }
    map['gewicht_kg'] = Variable<double>(gewichtKg);
    if (!nullToAbsent || notiz != null) {
      map['notiz'] = Variable<String>(notiz);
    }
    return map;
  }

  SaetzeCompanion toCompanion(bool nullToAbsent) {
    return SaetzeCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      geraetId: Value(geraetId),
      satzNr: Value(satzNr),
      seite: seite == null && nullToAbsent
          ? const Value.absent()
          : Value(seite),
      wiederholungen: Value(wiederholungen),
      eingabewert: Value(eingabewert),
      eingabeeinheit: Value(eingabeeinheit),
      gewichtKg: Value(gewichtKg),
      notiz: notiz == null && nullToAbsent
          ? const Value.absent()
          : Value(notiz),
    );
  }

  factory Satz.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Satz(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      geraetId: serializer.fromJson<int>(json['geraetId']),
      satzNr: serializer.fromJson<int>(json['satzNr']),
      seite: $SaetzeTable.$converterseiten.fromJson(
        serializer.fromJson<String?>(json['seite']),
      ),
      wiederholungen: serializer.fromJson<int>(json['wiederholungen']),
      eingabewert: serializer.fromJson<double>(json['eingabewert']),
      eingabeeinheit: $SaetzeTable.$convertereingabeeinheit.fromJson(
        serializer.fromJson<String>(json['eingabeeinheit']),
      ),
      gewichtKg: serializer.fromJson<double>(json['gewichtKg']),
      notiz: serializer.fromJson<String?>(json['notiz']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'geraetId': serializer.toJson<int>(geraetId),
      'satzNr': serializer.toJson<int>(satzNr),
      'seite': serializer.toJson<String?>(
        $SaetzeTable.$converterseiten.toJson(seite),
      ),
      'wiederholungen': serializer.toJson<int>(wiederholungen),
      'eingabewert': serializer.toJson<double>(eingabewert),
      'eingabeeinheit': serializer.toJson<String>(
        $SaetzeTable.$convertereingabeeinheit.toJson(eingabeeinheit),
      ),
      'gewichtKg': serializer.toJson<double>(gewichtKg),
      'notiz': serializer.toJson<String?>(notiz),
    };
  }

  Satz copyWith({
    int? id,
    int? sessionId,
    int? geraetId,
    int? satzNr,
    Value<Seite?> seite = const Value.absent(),
    int? wiederholungen,
    double? eingabewert,
    Einheit? eingabeeinheit,
    double? gewichtKg,
    Value<String?> notiz = const Value.absent(),
  }) => Satz(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    geraetId: geraetId ?? this.geraetId,
    satzNr: satzNr ?? this.satzNr,
    seite: seite.present ? seite.value : this.seite,
    wiederholungen: wiederholungen ?? this.wiederholungen,
    eingabewert: eingabewert ?? this.eingabewert,
    eingabeeinheit: eingabeeinheit ?? this.eingabeeinheit,
    gewichtKg: gewichtKg ?? this.gewichtKg,
    notiz: notiz.present ? notiz.value : this.notiz,
  );
  Satz copyWithCompanion(SaetzeCompanion data) {
    return Satz(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      geraetId: data.geraetId.present ? data.geraetId.value : this.geraetId,
      satzNr: data.satzNr.present ? data.satzNr.value : this.satzNr,
      seite: data.seite.present ? data.seite.value : this.seite,
      wiederholungen: data.wiederholungen.present
          ? data.wiederholungen.value
          : this.wiederholungen,
      eingabewert: data.eingabewert.present
          ? data.eingabewert.value
          : this.eingabewert,
      eingabeeinheit: data.eingabeeinheit.present
          ? data.eingabeeinheit.value
          : this.eingabeeinheit,
      gewichtKg: data.gewichtKg.present ? data.gewichtKg.value : this.gewichtKg,
      notiz: data.notiz.present ? data.notiz.value : this.notiz,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Satz(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('geraetId: $geraetId, ')
          ..write('satzNr: $satzNr, ')
          ..write('seite: $seite, ')
          ..write('wiederholungen: $wiederholungen, ')
          ..write('eingabewert: $eingabewert, ')
          ..write('eingabeeinheit: $eingabeeinheit, ')
          ..write('gewichtKg: $gewichtKg, ')
          ..write('notiz: $notiz')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    geraetId,
    satzNr,
    seite,
    wiederholungen,
    eingabewert,
    eingabeeinheit,
    gewichtKg,
    notiz,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Satz &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.geraetId == this.geraetId &&
          other.satzNr == this.satzNr &&
          other.seite == this.seite &&
          other.wiederholungen == this.wiederholungen &&
          other.eingabewert == this.eingabewert &&
          other.eingabeeinheit == this.eingabeeinheit &&
          other.gewichtKg == this.gewichtKg &&
          other.notiz == this.notiz);
}

class SaetzeCompanion extends UpdateCompanion<Satz> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> geraetId;
  final Value<int> satzNr;
  final Value<Seite?> seite;
  final Value<int> wiederholungen;
  final Value<double> eingabewert;
  final Value<Einheit> eingabeeinheit;
  final Value<double> gewichtKg;
  final Value<String?> notiz;
  const SaetzeCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.geraetId = const Value.absent(),
    this.satzNr = const Value.absent(),
    this.seite = const Value.absent(),
    this.wiederholungen = const Value.absent(),
    this.eingabewert = const Value.absent(),
    this.eingabeeinheit = const Value.absent(),
    this.gewichtKg = const Value.absent(),
    this.notiz = const Value.absent(),
  });
  SaetzeCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int geraetId,
    required int satzNr,
    this.seite = const Value.absent(),
    required int wiederholungen,
    required double eingabewert,
    required Einheit eingabeeinheit,
    required double gewichtKg,
    this.notiz = const Value.absent(),
  }) : sessionId = Value(sessionId),
       geraetId = Value(geraetId),
       satzNr = Value(satzNr),
       wiederholungen = Value(wiederholungen),
       eingabewert = Value(eingabewert),
       eingabeeinheit = Value(eingabeeinheit),
       gewichtKg = Value(gewichtKg);
  static Insertable<Satz> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? geraetId,
    Expression<int>? satzNr,
    Expression<String>? seite,
    Expression<int>? wiederholungen,
    Expression<double>? eingabewert,
    Expression<String>? eingabeeinheit,
    Expression<double>? gewichtKg,
    Expression<String>? notiz,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (geraetId != null) 'geraet_id': geraetId,
      if (satzNr != null) 'satz_nr': satzNr,
      if (seite != null) 'seite': seite,
      if (wiederholungen != null) 'wiederholungen': wiederholungen,
      if (eingabewert != null) 'eingabewert': eingabewert,
      if (eingabeeinheit != null) 'eingabeeinheit': eingabeeinheit,
      if (gewichtKg != null) 'gewicht_kg': gewichtKg,
      if (notiz != null) 'notiz': notiz,
    });
  }

  SaetzeCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? geraetId,
    Value<int>? satzNr,
    Value<Seite?>? seite,
    Value<int>? wiederholungen,
    Value<double>? eingabewert,
    Value<Einheit>? eingabeeinheit,
    Value<double>? gewichtKg,
    Value<String?>? notiz,
  }) {
    return SaetzeCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      geraetId: geraetId ?? this.geraetId,
      satzNr: satzNr ?? this.satzNr,
      seite: seite ?? this.seite,
      wiederholungen: wiederholungen ?? this.wiederholungen,
      eingabewert: eingabewert ?? this.eingabewert,
      eingabeeinheit: eingabeeinheit ?? this.eingabeeinheit,
      gewichtKg: gewichtKg ?? this.gewichtKg,
      notiz: notiz ?? this.notiz,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (geraetId.present) {
      map['geraet_id'] = Variable<int>(geraetId.value);
    }
    if (satzNr.present) {
      map['satz_nr'] = Variable<int>(satzNr.value);
    }
    if (seite.present) {
      map['seite'] = Variable<String>(
        $SaetzeTable.$converterseiten.toSql(seite.value),
      );
    }
    if (wiederholungen.present) {
      map['wiederholungen'] = Variable<int>(wiederholungen.value);
    }
    if (eingabewert.present) {
      map['eingabewert'] = Variable<double>(eingabewert.value);
    }
    if (eingabeeinheit.present) {
      map['eingabeeinheit'] = Variable<String>(
        $SaetzeTable.$convertereingabeeinheit.toSql(eingabeeinheit.value),
      );
    }
    if (gewichtKg.present) {
      map['gewicht_kg'] = Variable<double>(gewichtKg.value);
    }
    if (notiz.present) {
      map['notiz'] = Variable<String>(notiz.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaetzeCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('geraetId: $geraetId, ')
          ..write('satzNr: $satzNr, ')
          ..write('seite: $seite, ')
          ..write('wiederholungen: $wiederholungen, ')
          ..write('eingabewert: $eingabewert, ')
          ..write('eingabeeinheit: $eingabeeinheit, ')
          ..write('gewichtKg: $gewichtKg, ')
          ..write('notiz: $notiz')
          ..write(')'))
        .toString();
  }
}

abstract class _$Datenbank extends GeneratedDatabase {
  _$Datenbank(QueryExecutor e) : super(e);
  $DatenbankManager get managers => $DatenbankManager(this);
  late final $StandorteTable standorte = $StandorteTable(this);
  late final $MuskelgruppenTable muskelgruppen = $MuskelgruppenTable(this);
  late final $GeraeteTable geraete = $GeraeteTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SaetzeTable saetze = $SaetzeTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    standorte,
    muskelgruppen,
    geraete,
    sessions,
    saetze,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('saetze', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$StandorteTableCreateCompanionBuilder =
    StandorteCompanion Function({Value<int> id, required String name});
typedef $$StandorteTableUpdateCompanionBuilder =
    StandorteCompanion Function({Value<int> id, Value<String> name});

final class $$StandorteTableReferences
    extends BaseReferences<_$Datenbank, $StandorteTable, Standort> {
  $$StandorteTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GeraeteTable, List<Geraet>> _geraeteRefsTable(
    _$Datenbank db,
  ) => MultiTypedResultKey.fromTable(
    db.geraete,
    aliasName: 'standorte__id__geraete__standort_id',
  );

  $$GeraeteTableProcessedTableManager get geraeteRefs {
    final manager = $$GeraeteTableTableManager(
      $_db,
      $_db.geraete,
    ).filter((f) => f.standortId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_geraeteRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionsTable, List<TrainingsSession>>
  _sessionsRefsTable(_$Datenbank db) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'standorte__id__sessions__standort_id',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.standortId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StandorteTableFilterComposer
    extends Composer<_$Datenbank, $StandorteTable> {
  $$StandorteTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> geraeteRefs(
    Expression<bool> Function($$GeraeteTableFilterComposer f) f,
  ) {
    final $$GeraeteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.geraete,
      getReferencedColumn: (t) => t.standortId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GeraeteTableFilterComposer(
            $db: $db,
            $table: $db.geraete,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.standortId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StandorteTableOrderingComposer
    extends Composer<_$Datenbank, $StandorteTable> {
  $$StandorteTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StandorteTableAnnotationComposer
    extends Composer<_$Datenbank, $StandorteTable> {
  $$StandorteTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> geraeteRefs<T extends Object>(
    Expression<T> Function($$GeraeteTableAnnotationComposer a) f,
  ) {
    final $$GeraeteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.geraete,
      getReferencedColumn: (t) => t.standortId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GeraeteTableAnnotationComposer(
            $db: $db,
            $table: $db.geraete,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.standortId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StandorteTableTableManager
    extends
        RootTableManager<
          _$Datenbank,
          $StandorteTable,
          Standort,
          $$StandorteTableFilterComposer,
          $$StandorteTableOrderingComposer,
          $$StandorteTableAnnotationComposer,
          $$StandorteTableCreateCompanionBuilder,
          $$StandorteTableUpdateCompanionBuilder,
          (Standort, $$StandorteTableReferences),
          Standort,
          PrefetchHooks Function({bool geraeteRefs, bool sessionsRefs})
        > {
  $$StandorteTableTableManager(_$Datenbank db, $StandorteTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StandorteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StandorteTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StandorteTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => StandorteCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  StandorteCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StandorteTable, Standort>(table),
                  $$StandorteTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({geraeteRefs = false, sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (geraeteRefs) db.geraete,
                if (sessionsRefs) db.sessions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (geraeteRefs)
                    await $_getPrefetchedDataByColumns<
                      Standort,
                      $StandorteTable,
                      Geraet,
                      $GeraeteTable
                    >(
                      currentTable: table,
                      referencedTable: $$StandorteTableReferences
                          ._geraeteRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StandorteTableReferences(db, table, p0).geraeteRefs,
                      currentColumn: 'id',
                      referencedColumn: 'standort_id',
                      typedResults: items,
                    ),
                  if (sessionsRefs)
                    await $_getPrefetchedDataByColumns<
                      Standort,
                      $StandorteTable,
                      TrainingsSession,
                      $SessionsTable
                    >(
                      currentTable: table,
                      referencedTable: $$StandorteTableReferences
                          ._sessionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StandorteTableReferences(
                            db,
                            table,
                            p0,
                          ).sessionsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'standort_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StandorteTableProcessedTableManager =
    ProcessedTableManager<
      _$Datenbank,
      $StandorteTable,
      Standort,
      $$StandorteTableFilterComposer,
      $$StandorteTableOrderingComposer,
      $$StandorteTableAnnotationComposer,
      $$StandorteTableCreateCompanionBuilder,
      $$StandorteTableUpdateCompanionBuilder,
      (Standort, $$StandorteTableReferences),
      Standort,
      PrefetchHooks Function({bool geraeteRefs, bool sessionsRefs})
    >;
typedef $$MuskelgruppenTableCreateCompanionBuilder =
    MuskelgruppenCompanion Function({
      Value<int> id,
      required String name,
      Value<int> sortierung,
    });
typedef $$MuskelgruppenTableUpdateCompanionBuilder =
    MuskelgruppenCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> sortierung,
    });

final class $$MuskelgruppenTableReferences
    extends BaseReferences<_$Datenbank, $MuskelgruppenTable, Muskelgruppe> {
  $$MuskelgruppenTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$GeraeteTable, List<Geraet>> _geraeteRefsTable(
    _$Datenbank db,
  ) => MultiTypedResultKey.fromTable(
    db.geraete,
    aliasName: 'muskelgruppen__id__geraete__muskelgruppe_id',
  );

  $$GeraeteTableProcessedTableManager get geraeteRefs {
    final manager = $$GeraeteTableTableManager(
      $_db,
      $_db.geraete,
    ).filter((f) => f.muskelgruppeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_geraeteRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MuskelgruppenTableFilterComposer
    extends Composer<_$Datenbank, $MuskelgruppenTable> {
  $$MuskelgruppenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> geraeteRefs(
    Expression<bool> Function($$GeraeteTableFilterComposer f) f,
  ) {
    final $$GeraeteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.geraete,
      getReferencedColumn: (t) => t.muskelgruppeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GeraeteTableFilterComposer(
            $db: $db,
            $table: $db.geraete,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MuskelgruppenTableOrderingComposer
    extends Composer<_$Datenbank, $MuskelgruppenTable> {
  $$MuskelgruppenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MuskelgruppenTableAnnotationComposer
    extends Composer<_$Datenbank, $MuskelgruppenTable> {
  $$MuskelgruppenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => column,
  );

  Expression<T> geraeteRefs<T extends Object>(
    Expression<T> Function($$GeraeteTableAnnotationComposer a) f,
  ) {
    final $$GeraeteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.geraete,
      getReferencedColumn: (t) => t.muskelgruppeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GeraeteTableAnnotationComposer(
            $db: $db,
            $table: $db.geraete,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MuskelgruppenTableTableManager
    extends
        RootTableManager<
          _$Datenbank,
          $MuskelgruppenTable,
          Muskelgruppe,
          $$MuskelgruppenTableFilterComposer,
          $$MuskelgruppenTableOrderingComposer,
          $$MuskelgruppenTableAnnotationComposer,
          $$MuskelgruppenTableCreateCompanionBuilder,
          $$MuskelgruppenTableUpdateCompanionBuilder,
          (Muskelgruppe, $$MuskelgruppenTableReferences),
          Muskelgruppe,
          PrefetchHooks Function({bool geraeteRefs})
        > {
  $$MuskelgruppenTableTableManager(_$Datenbank db, $MuskelgruppenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MuskelgruppenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MuskelgruppenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MuskelgruppenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortierung = const Value.absent(),
              }) => MuskelgruppenCompanion(
                id: id,
                name: name,
                sortierung: sortierung,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> sortierung = const Value.absent(),
              }) => MuskelgruppenCompanion.insert(
                id: id,
                name: name,
                sortierung: sortierung,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MuskelgruppenTable, Muskelgruppe>(table),
                  $$MuskelgruppenTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({geraeteRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (geraeteRefs) db.geraete],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (geraeteRefs)
                    await $_getPrefetchedDataByColumns<
                      Muskelgruppe,
                      $MuskelgruppenTable,
                      Geraet,
                      $GeraeteTable
                    >(
                      currentTable: table,
                      referencedTable: $$MuskelgruppenTableReferences
                          ._geraeteRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MuskelgruppenTableReferences(
                            db,
                            table,
                            p0,
                          ).geraeteRefs,
                      currentColumn: 'id',
                      referencedColumn: 'muskelgruppe_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MuskelgruppenTableProcessedTableManager =
    ProcessedTableManager<
      _$Datenbank,
      $MuskelgruppenTable,
      Muskelgruppe,
      $$MuskelgruppenTableFilterComposer,
      $$MuskelgruppenTableOrderingComposer,
      $$MuskelgruppenTableAnnotationComposer,
      $$MuskelgruppenTableCreateCompanionBuilder,
      $$MuskelgruppenTableUpdateCompanionBuilder,
      (Muskelgruppe, $$MuskelgruppenTableReferences),
      Muskelgruppe,
      PrefetchHooks Function({bool geraeteRefs})
    >;
typedef $$GeraeteTableCreateCompanionBuilder =
    GeraeteCompanion Function({
      Value<int> id,
      required int standortId,
      required String kuerzel,
      Value<String?> funktion,
      Value<int?> muskelgruppeId,
      Value<String?> hersteller,
      Value<String?> modell,
      required Einheit einheit,
      Value<bool> assistiert,
      Value<bool> linksRechtsGetrennt,
      Value<String?> einstellung1,
      Value<String?> einstellung2,
      Value<String?> einstellung3,
      Value<String?> notiz,
    });
typedef $$GeraeteTableUpdateCompanionBuilder =
    GeraeteCompanion Function({
      Value<int> id,
      Value<int> standortId,
      Value<String> kuerzel,
      Value<String?> funktion,
      Value<int?> muskelgruppeId,
      Value<String?> hersteller,
      Value<String?> modell,
      Value<Einheit> einheit,
      Value<bool> assistiert,
      Value<bool> linksRechtsGetrennt,
      Value<String?> einstellung1,
      Value<String?> einstellung2,
      Value<String?> einstellung3,
      Value<String?> notiz,
    });

final class $$GeraeteTableReferences
    extends BaseReferences<_$Datenbank, $GeraeteTable, Geraet> {
  $$GeraeteTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StandorteTable _standortIdTable(_$Datenbank db) =>
      db.standorte.createAlias('geraete__standort_id__standorte__id');

  $$StandorteTableProcessedTableManager get standortId {
    final $_column = $_itemColumn<int>('standort_id')!;

    final manager = $$StandorteTableTableManager(
      $_db,
      $_db.standorte,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_standortIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MuskelgruppenTable _muskelgruppeIdTable(_$Datenbank db) => db
      .muskelgruppen
      .createAlias('geraete__muskelgruppe_id__muskelgruppen__id');

  $$MuskelgruppenTableProcessedTableManager? get muskelgruppeId {
    final $_column = $_itemColumn<int>('muskelgruppe_id');
    if ($_column == null) return null;
    final manager = $$MuskelgruppenTableTableManager(
      $_db,
      $_db.muskelgruppen,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_muskelgruppeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SaetzeTable, List<Satz>> _saetzeRefsTable(
    _$Datenbank db,
  ) => MultiTypedResultKey.fromTable(
    db.saetze,
    aliasName: 'geraete__id__saetze__geraet_id',
  );

  $$SaetzeTableProcessedTableManager get saetzeRefs {
    final manager = $$SaetzeTableTableManager(
      $_db,
      $_db.saetze,
    ).filter((f) => f.geraetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_saetzeRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GeraeteTableFilterComposer
    extends Composer<_$Datenbank, $GeraeteTable> {
  $$GeraeteTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kuerzel => $composableBuilder(
    column: $table.kuerzel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get funktion => $composableBuilder(
    column: $table.funktion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hersteller => $composableBuilder(
    column: $table.hersteller,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modell => $composableBuilder(
    column: $table.modell,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Einheit, Einheit, String> get einheit =>
      $composableBuilder(
        column: $table.einheit,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get assistiert => $composableBuilder(
    column: $table.assistiert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get linksRechtsGetrennt => $composableBuilder(
    column: $table.linksRechtsGetrennt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get einstellung1 => $composableBuilder(
    column: $table.einstellung1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get einstellung2 => $composableBuilder(
    column: $table.einstellung2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get einstellung3 => $composableBuilder(
    column: $table.einstellung3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notiz => $composableBuilder(
    column: $table.notiz,
    builder: (column) => ColumnFilters(column),
  );

  $$StandorteTableFilterComposer get standortId {
    final $$StandorteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.standortId,
      referencedTable: $db.standorte,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StandorteTableFilterComposer(
            $db: $db,
            $table: $db.standorte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuskelgruppenTableFilterComposer get muskelgruppeId {
    final $$MuskelgruppenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muskelgruppeId,
      referencedTable: $db.muskelgruppen,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuskelgruppenTableFilterComposer(
            $db: $db,
            $table: $db.muskelgruppen,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> saetzeRefs(
    Expression<bool> Function($$SaetzeTableFilterComposer f) f,
  ) {
    final $$SaetzeTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saetze,
      getReferencedColumn: (t) => t.geraetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaetzeTableFilterComposer(
            $db: $db,
            $table: $db.saetze,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GeraeteTableOrderingComposer
    extends Composer<_$Datenbank, $GeraeteTable> {
  $$GeraeteTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kuerzel => $composableBuilder(
    column: $table.kuerzel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get funktion => $composableBuilder(
    column: $table.funktion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hersteller => $composableBuilder(
    column: $table.hersteller,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modell => $composableBuilder(
    column: $table.modell,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get einheit => $composableBuilder(
    column: $table.einheit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get assistiert => $composableBuilder(
    column: $table.assistiert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get linksRechtsGetrennt => $composableBuilder(
    column: $table.linksRechtsGetrennt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get einstellung1 => $composableBuilder(
    column: $table.einstellung1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get einstellung2 => $composableBuilder(
    column: $table.einstellung2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get einstellung3 => $composableBuilder(
    column: $table.einstellung3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notiz => $composableBuilder(
    column: $table.notiz,
    builder: (column) => ColumnOrderings(column),
  );

  $$StandorteTableOrderingComposer get standortId {
    final $$StandorteTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.standortId,
      referencedTable: $db.standorte,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StandorteTableOrderingComposer(
            $db: $db,
            $table: $db.standorte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuskelgruppenTableOrderingComposer get muskelgruppeId {
    final $$MuskelgruppenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muskelgruppeId,
      referencedTable: $db.muskelgruppen,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuskelgruppenTableOrderingComposer(
            $db: $db,
            $table: $db.muskelgruppen,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GeraeteTableAnnotationComposer
    extends Composer<_$Datenbank, $GeraeteTable> {
  $$GeraeteTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kuerzel =>
      $composableBuilder(column: $table.kuerzel, builder: (column) => column);

  GeneratedColumn<String> get funktion =>
      $composableBuilder(column: $table.funktion, builder: (column) => column);

  GeneratedColumn<String> get hersteller => $composableBuilder(
    column: $table.hersteller,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modell =>
      $composableBuilder(column: $table.modell, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Einheit, String> get einheit =>
      $composableBuilder(column: $table.einheit, builder: (column) => column);

  GeneratedColumn<bool> get assistiert => $composableBuilder(
    column: $table.assistiert,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get linksRechtsGetrennt => $composableBuilder(
    column: $table.linksRechtsGetrennt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get einstellung1 => $composableBuilder(
    column: $table.einstellung1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get einstellung2 => $composableBuilder(
    column: $table.einstellung2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get einstellung3 => $composableBuilder(
    column: $table.einstellung3,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notiz =>
      $composableBuilder(column: $table.notiz, builder: (column) => column);

  $$StandorteTableAnnotationComposer get standortId {
    final $$StandorteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.standortId,
      referencedTable: $db.standorte,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StandorteTableAnnotationComposer(
            $db: $db,
            $table: $db.standorte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuskelgruppenTableAnnotationComposer get muskelgruppeId {
    final $$MuskelgruppenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muskelgruppeId,
      referencedTable: $db.muskelgruppen,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuskelgruppenTableAnnotationComposer(
            $db: $db,
            $table: $db.muskelgruppen,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> saetzeRefs<T extends Object>(
    Expression<T> Function($$SaetzeTableAnnotationComposer a) f,
  ) {
    final $$SaetzeTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saetze,
      getReferencedColumn: (t) => t.geraetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaetzeTableAnnotationComposer(
            $db: $db,
            $table: $db.saetze,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GeraeteTableTableManager
    extends
        RootTableManager<
          _$Datenbank,
          $GeraeteTable,
          Geraet,
          $$GeraeteTableFilterComposer,
          $$GeraeteTableOrderingComposer,
          $$GeraeteTableAnnotationComposer,
          $$GeraeteTableCreateCompanionBuilder,
          $$GeraeteTableUpdateCompanionBuilder,
          (Geraet, $$GeraeteTableReferences),
          Geraet,
          PrefetchHooks Function({
            bool standortId,
            bool muskelgruppeId,
            bool saetzeRefs,
          })
        > {
  $$GeraeteTableTableManager(_$Datenbank db, $GeraeteTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeraeteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeraeteTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeraeteTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> standortId = const Value.absent(),
                Value<String> kuerzel = const Value.absent(),
                Value<String?> funktion = const Value.absent(),
                Value<int?> muskelgruppeId = const Value.absent(),
                Value<String?> hersteller = const Value.absent(),
                Value<String?> modell = const Value.absent(),
                Value<Einheit> einheit = const Value.absent(),
                Value<bool> assistiert = const Value.absent(),
                Value<bool> linksRechtsGetrennt = const Value.absent(),
                Value<String?> einstellung1 = const Value.absent(),
                Value<String?> einstellung2 = const Value.absent(),
                Value<String?> einstellung3 = const Value.absent(),
                Value<String?> notiz = const Value.absent(),
              }) => GeraeteCompanion(
                id: id,
                standortId: standortId,
                kuerzel: kuerzel,
                funktion: funktion,
                muskelgruppeId: muskelgruppeId,
                hersteller: hersteller,
                modell: modell,
                einheit: einheit,
                assistiert: assistiert,
                linksRechtsGetrennt: linksRechtsGetrennt,
                einstellung1: einstellung1,
                einstellung2: einstellung2,
                einstellung3: einstellung3,
                notiz: notiz,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int standortId,
                required String kuerzel,
                Value<String?> funktion = const Value.absent(),
                Value<int?> muskelgruppeId = const Value.absent(),
                Value<String?> hersteller = const Value.absent(),
                Value<String?> modell = const Value.absent(),
                required Einheit einheit,
                Value<bool> assistiert = const Value.absent(),
                Value<bool> linksRechtsGetrennt = const Value.absent(),
                Value<String?> einstellung1 = const Value.absent(),
                Value<String?> einstellung2 = const Value.absent(),
                Value<String?> einstellung3 = const Value.absent(),
                Value<String?> notiz = const Value.absent(),
              }) => GeraeteCompanion.insert(
                id: id,
                standortId: standortId,
                kuerzel: kuerzel,
                funktion: funktion,
                muskelgruppeId: muskelgruppeId,
                hersteller: hersteller,
                modell: modell,
                einheit: einheit,
                assistiert: assistiert,
                linksRechtsGetrennt: linksRechtsGetrennt,
                einstellung1: einstellung1,
                einstellung2: einstellung2,
                einstellung3: einstellung3,
                notiz: notiz,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GeraeteTable, Geraet>(table),
                  $$GeraeteTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                standortId = false,
                muskelgruppeId = false,
                saetzeRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (saetzeRefs) db.saetze],
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
                        if (standortId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.standortId,
                                    referencedTable: $$GeraeteTableReferences
                                        ._standortIdTable(db),
                                    referencedColumn: $$GeraeteTableReferences
                                        ._standortIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (muskelgruppeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.muskelgruppeId,
                                    referencedTable: $$GeraeteTableReferences
                                        ._muskelgruppeIdTable(db),
                                    referencedColumn: $$GeraeteTableReferences
                                        ._muskelgruppeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (saetzeRefs)
                        await $_getPrefetchedDataByColumns<
                          Geraet,
                          $GeraeteTable,
                          Satz,
                          $SaetzeTable
                        >(
                          currentTable: table,
                          referencedTable: $$GeraeteTableReferences
                              ._saetzeRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GeraeteTableReferences(
                                db,
                                table,
                                p0,
                              ).saetzeRefs,
                          currentColumn: 'id',
                          referencedColumn: 'geraet_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GeraeteTableProcessedTableManager =
    ProcessedTableManager<
      _$Datenbank,
      $GeraeteTable,
      Geraet,
      $$GeraeteTableFilterComposer,
      $$GeraeteTableOrderingComposer,
      $$GeraeteTableAnnotationComposer,
      $$GeraeteTableCreateCompanionBuilder,
      $$GeraeteTableUpdateCompanionBuilder,
      (Geraet, $$GeraeteTableReferences),
      Geraet,
      PrefetchHooks Function({
        bool standortId,
        bool muskelgruppeId,
        bool saetzeRefs,
      })
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required String datum,
      required int standortId,
      Value<double?> koerpergewichtKg,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<String> datum,
      Value<int> standortId,
      Value<double?> koerpergewichtKg,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$Datenbank, $SessionsTable, TrainingsSession> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StandorteTable _standortIdTable(_$Datenbank db) =>
      db.standorte.createAlias('sessions__standort_id__standorte__id');

  $$StandorteTableProcessedTableManager get standortId {
    final $_column = $_itemColumn<int>('standort_id')!;

    final manager = $$StandorteTableTableManager(
      $_db,
      $_db.standorte,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_standortIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SaetzeTable, List<Satz>> _saetzeRefsTable(
    _$Datenbank db,
  ) => MultiTypedResultKey.fromTable(
    db.saetze,
    aliasName: 'sessions__id__saetze__session_id',
  );

  $$SaetzeTableProcessedTableManager get saetzeRefs {
    final manager = $$SaetzeTableTableManager(
      $_db,
      $_db.saetze,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_saetzeRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$Datenbank, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datum => $composableBuilder(
    column: $table.datum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get koerpergewichtKg => $composableBuilder(
    column: $table.koerpergewichtKg,
    builder: (column) => ColumnFilters(column),
  );

  $$StandorteTableFilterComposer get standortId {
    final $$StandorteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.standortId,
      referencedTable: $db.standorte,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StandorteTableFilterComposer(
            $db: $db,
            $table: $db.standorte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> saetzeRefs(
    Expression<bool> Function($$SaetzeTableFilterComposer f) f,
  ) {
    final $$SaetzeTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saetze,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaetzeTableFilterComposer(
            $db: $db,
            $table: $db.saetze,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$Datenbank, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datum => $composableBuilder(
    column: $table.datum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get koerpergewichtKg => $composableBuilder(
    column: $table.koerpergewichtKg,
    builder: (column) => ColumnOrderings(column),
  );

  $$StandorteTableOrderingComposer get standortId {
    final $$StandorteTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.standortId,
      referencedTable: $db.standorte,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StandorteTableOrderingComposer(
            $db: $db,
            $table: $db.standorte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$Datenbank, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get datum =>
      $composableBuilder(column: $table.datum, builder: (column) => column);

  GeneratedColumn<double> get koerpergewichtKg => $composableBuilder(
    column: $table.koerpergewichtKg,
    builder: (column) => column,
  );

  $$StandorteTableAnnotationComposer get standortId {
    final $$StandorteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.standortId,
      referencedTable: $db.standorte,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StandorteTableAnnotationComposer(
            $db: $db,
            $table: $db.standorte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> saetzeRefs<T extends Object>(
    Expression<T> Function($$SaetzeTableAnnotationComposer a) f,
  ) {
    final $$SaetzeTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saetze,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaetzeTableAnnotationComposer(
            $db: $db,
            $table: $db.saetze,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$Datenbank,
          $SessionsTable,
          TrainingsSession,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (TrainingsSession, $$SessionsTableReferences),
          TrainingsSession,
          PrefetchHooks Function({bool standortId, bool saetzeRefs})
        > {
  $$SessionsTableTableManager(_$Datenbank db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> datum = const Value.absent(),
                Value<int> standortId = const Value.absent(),
                Value<double?> koerpergewichtKg = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                datum: datum,
                standortId: standortId,
                koerpergewichtKg: koerpergewichtKg,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String datum,
                required int standortId,
                Value<double?> koerpergewichtKg = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                datum: datum,
                standortId: standortId,
                koerpergewichtKg: koerpergewichtKg,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, TrainingsSession>(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({standortId = false, saetzeRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (saetzeRefs) db.saetze],
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
                    if (standortId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.standortId,
                                referencedTable: $$SessionsTableReferences
                                    ._standortIdTable(db),
                                referencedColumn: $$SessionsTableReferences
                                    ._standortIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (saetzeRefs)
                    await $_getPrefetchedDataByColumns<
                      TrainingsSession,
                      $SessionsTable,
                      Satz,
                      $SaetzeTable
                    >(
                      currentTable: table,
                      referencedTable: $$SessionsTableReferences
                          ._saetzeRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SessionsTableReferences(db, table, p0).saetzeRefs,
                      currentColumn: 'id',
                      referencedColumn: 'session_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$Datenbank,
      $SessionsTable,
      TrainingsSession,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (TrainingsSession, $$SessionsTableReferences),
      TrainingsSession,
      PrefetchHooks Function({bool standortId, bool saetzeRefs})
    >;
typedef $$SaetzeTableCreateCompanionBuilder =
    SaetzeCompanion Function({
      Value<int> id,
      required int sessionId,
      required int geraetId,
      required int satzNr,
      Value<Seite?> seite,
      required int wiederholungen,
      required double eingabewert,
      required Einheit eingabeeinheit,
      required double gewichtKg,
      Value<String?> notiz,
    });
typedef $$SaetzeTableUpdateCompanionBuilder =
    SaetzeCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> geraetId,
      Value<int> satzNr,
      Value<Seite?> seite,
      Value<int> wiederholungen,
      Value<double> eingabewert,
      Value<Einheit> eingabeeinheit,
      Value<double> gewichtKg,
      Value<String?> notiz,
    });

final class $$SaetzeTableReferences
    extends BaseReferences<_$Datenbank, $SaetzeTable, Satz> {
  $$SaetzeTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$Datenbank db) =>
      db.sessions.createAlias('saetze__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GeraeteTable _geraetIdTable(_$Datenbank db) =>
      db.geraete.createAlias('saetze__geraet_id__geraete__id');

  $$GeraeteTableProcessedTableManager get geraetId {
    final $_column = $_itemColumn<int>('geraet_id')!;

    final manager = $$GeraeteTableTableManager(
      $_db,
      $_db.geraete,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_geraetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SaetzeTableFilterComposer extends Composer<_$Datenbank, $SaetzeTable> {
  $$SaetzeTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get satzNr => $composableBuilder(
    column: $table.satzNr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Seite?, Seite, String> get seite =>
      $composableBuilder(
        column: $table.seite,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get wiederholungen => $composableBuilder(
    column: $table.wiederholungen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get eingabewert => $composableBuilder(
    column: $table.eingabewert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Einheit, Einheit, String> get eingabeeinheit =>
      $composableBuilder(
        column: $table.eingabeeinheit,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get gewichtKg => $composableBuilder(
    column: $table.gewichtKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notiz => $composableBuilder(
    column: $table.notiz,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GeraeteTableFilterComposer get geraetId {
    final $$GeraeteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.geraetId,
      referencedTable: $db.geraete,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GeraeteTableFilterComposer(
            $db: $db,
            $table: $db.geraete,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaetzeTableOrderingComposer
    extends Composer<_$Datenbank, $SaetzeTable> {
  $$SaetzeTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get satzNr => $composableBuilder(
    column: $table.satzNr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seite => $composableBuilder(
    column: $table.seite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wiederholungen => $composableBuilder(
    column: $table.wiederholungen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get eingabewert => $composableBuilder(
    column: $table.eingabewert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eingabeeinheit => $composableBuilder(
    column: $table.eingabeeinheit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gewichtKg => $composableBuilder(
    column: $table.gewichtKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notiz => $composableBuilder(
    column: $table.notiz,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GeraeteTableOrderingComposer get geraetId {
    final $$GeraeteTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.geraetId,
      referencedTable: $db.geraete,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GeraeteTableOrderingComposer(
            $db: $db,
            $table: $db.geraete,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaetzeTableAnnotationComposer
    extends Composer<_$Datenbank, $SaetzeTable> {
  $$SaetzeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get satzNr =>
      $composableBuilder(column: $table.satzNr, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Seite?, String> get seite =>
      $composableBuilder(column: $table.seite, builder: (column) => column);

  GeneratedColumn<int> get wiederholungen => $composableBuilder(
    column: $table.wiederholungen,
    builder: (column) => column,
  );

  GeneratedColumn<double> get eingabewert => $composableBuilder(
    column: $table.eingabewert,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Einheit, String> get eingabeeinheit =>
      $composableBuilder(
        column: $table.eingabeeinheit,
        builder: (column) => column,
      );

  GeneratedColumn<double> get gewichtKg =>
      $composableBuilder(column: $table.gewichtKg, builder: (column) => column);

  GeneratedColumn<String> get notiz =>
      $composableBuilder(column: $table.notiz, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GeraeteTableAnnotationComposer get geraetId {
    final $$GeraeteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.geraetId,
      referencedTable: $db.geraete,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GeraeteTableAnnotationComposer(
            $db: $db,
            $table: $db.geraete,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaetzeTableTableManager
    extends
        RootTableManager<
          _$Datenbank,
          $SaetzeTable,
          Satz,
          $$SaetzeTableFilterComposer,
          $$SaetzeTableOrderingComposer,
          $$SaetzeTableAnnotationComposer,
          $$SaetzeTableCreateCompanionBuilder,
          $$SaetzeTableUpdateCompanionBuilder,
          (Satz, $$SaetzeTableReferences),
          Satz,
          PrefetchHooks Function({bool sessionId, bool geraetId})
        > {
  $$SaetzeTableTableManager(_$Datenbank db, $SaetzeTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaetzeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaetzeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaetzeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> geraetId = const Value.absent(),
                Value<int> satzNr = const Value.absent(),
                Value<Seite?> seite = const Value.absent(),
                Value<int> wiederholungen = const Value.absent(),
                Value<double> eingabewert = const Value.absent(),
                Value<Einheit> eingabeeinheit = const Value.absent(),
                Value<double> gewichtKg = const Value.absent(),
                Value<String?> notiz = const Value.absent(),
              }) => SaetzeCompanion(
                id: id,
                sessionId: sessionId,
                geraetId: geraetId,
                satzNr: satzNr,
                seite: seite,
                wiederholungen: wiederholungen,
                eingabewert: eingabewert,
                eingabeeinheit: eingabeeinheit,
                gewichtKg: gewichtKg,
                notiz: notiz,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int geraetId,
                required int satzNr,
                Value<Seite?> seite = const Value.absent(),
                required int wiederholungen,
                required double eingabewert,
                required Einheit eingabeeinheit,
                required double gewichtKg,
                Value<String?> notiz = const Value.absent(),
              }) => SaetzeCompanion.insert(
                id: id,
                sessionId: sessionId,
                geraetId: geraetId,
                satzNr: satzNr,
                seite: seite,
                wiederholungen: wiederholungen,
                eingabewert: eingabewert,
                eingabeeinheit: eingabeeinheit,
                gewichtKg: gewichtKg,
                notiz: notiz,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaetzeTable, Satz>(table),
                  $$SaetzeTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, geraetId = false}) {
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
                                referencedTable: $$SaetzeTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$SaetzeTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (geraetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.geraetId,
                                referencedTable: $$SaetzeTableReferences
                                    ._geraetIdTable(db),
                                referencedColumn: $$SaetzeTableReferences
                                    ._geraetIdTable(db)
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

typedef $$SaetzeTableProcessedTableManager =
    ProcessedTableManager<
      _$Datenbank,
      $SaetzeTable,
      Satz,
      $$SaetzeTableFilterComposer,
      $$SaetzeTableOrderingComposer,
      $$SaetzeTableAnnotationComposer,
      $$SaetzeTableCreateCompanionBuilder,
      $$SaetzeTableUpdateCompanionBuilder,
      (Satz, $$SaetzeTableReferences),
      Satz,
      PrefetchHooks Function({bool sessionId, bool geraetId})
    >;

class $DatenbankManager {
  final _$Datenbank _db;
  $DatenbankManager(this._db);
  $$StandorteTableTableManager get standorte =>
      $$StandorteTableTableManager(_db, _db.standorte);
  $$MuskelgruppenTableTableManager get muskelgruppen =>
      $$MuskelgruppenTableTableManager(_db, _db.muskelgruppen);
  $$GeraeteTableTableManager get geraete =>
      $$GeraeteTableTableManager(_db, _db.geraete);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SaetzeTableTableManager get saetze =>
      $$SaetzeTableTableManager(_db, _db.saetze);
}
