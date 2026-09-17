// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RolesTable extends Roles with TableInfo<$RolesTable, Role> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RolesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSystemRoleMeta = const VerificationMeta(
    'isSystemRole',
  );
  @override
  late final GeneratedColumn<bool> isSystemRole = GeneratedColumn<bool>(
    'is_system_role',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system_role" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, description, isSystemRole];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Role> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_system_role')) {
      context.handle(
        _isSystemRoleMeta,
        isSystemRole.isAcceptableOrUnknown(
          data['is_system_role']!,
          _isSystemRoleMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Role map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Role(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isSystemRole: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system_role'],
      )!,
    );
  }

  @override
  $RolesTable createAlias(String alias) {
    return $RolesTable(attachedDatabase, alias);
  }
}

class Role extends DataClass implements Insertable<Role> {
  final int id;
  final String name;
  final String? description;
  final bool isSystemRole;
  const Role({
    required this.id,
    required this.name,
    this.description,
    required this.isSystemRole,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_system_role'] = Variable<bool>(isSystemRole);
    return map;
  }

  RolesCompanion toCompanion(bool nullToAbsent) {
    return RolesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isSystemRole: Value(isSystemRole),
    );
  }

  factory Role.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Role(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      isSystemRole: serializer.fromJson<bool>(json['isSystemRole']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'isSystemRole': serializer.toJson<bool>(isSystemRole),
    };
  }

  Role copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    bool? isSystemRole,
  }) => Role(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    isSystemRole: isSystemRole ?? this.isSystemRole,
  );
  Role copyWithCompanion(RolesCompanion data) {
    return Role(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      isSystemRole: data.isSystemRole.present
          ? data.isSystemRole.value
          : this.isSystemRole,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Role(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isSystemRole: $isSystemRole')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, isSystemRole);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Role &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.isSystemRole == this.isSystemRole);
}

class RolesCompanion extends UpdateCompanion<Role> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> isSystemRole;
  const RolesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isSystemRole = const Value.absent(),
  });
  RolesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.isSystemRole = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Role> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? isSystemRole,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isSystemRole != null) 'is_system_role': isSystemRole,
    });
  }

  RolesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<bool>? isSystemRole,
  }) {
    return RolesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isSystemRole: isSystemRole ?? this.isSystemRole,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isSystemRole.present) {
      map['is_system_role'] = Variable<bool>(isSystemRole.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RolesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isSystemRole: $isSystemRole')
          ..write(')'))
        .toString();
  }
}

class $PermissionsTable extends Permissions
    with TableInfo<$PermissionsTable, Permission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PermissionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _moduleMeta = const VerificationMeta('module');
  @override
  late final GeneratedColumn<String> module = GeneratedColumn<String>(
    'module',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, code, module, action, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'permissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Permission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('module')) {
      context.handle(
        _moduleMeta,
        module.isAcceptableOrUnknown(data['module']!, _moduleMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Permission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Permission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      module: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $PermissionsTable createAlias(String alias) {
    return $PermissionsTable(attachedDatabase, alias);
  }
}

class Permission extends DataClass implements Insertable<Permission> {
  final int id;
  final String code;
  final String module;
  final String action;
  final String? description;
  const Permission({
    required this.id,
    required this.code,
    required this.module,
    required this.action,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['module'] = Variable<String>(module);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  PermissionsCompanion toCompanion(bool nullToAbsent) {
    return PermissionsCompanion(
      id: Value(id),
      code: Value(code),
      module: Value(module),
      action: Value(action),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory Permission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Permission(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      module: serializer.fromJson<String>(json['module']),
      action: serializer.fromJson<String>(json['action']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'module': serializer.toJson<String>(module),
      'action': serializer.toJson<String>(action),
      'description': serializer.toJson<String?>(description),
    };
  }

  Permission copyWith({
    int? id,
    String? code,
    String? module,
    String? action,
    Value<String?> description = const Value.absent(),
  }) => Permission(
    id: id ?? this.id,
    code: code ?? this.code,
    module: module ?? this.module,
    action: action ?? this.action,
    description: description.present ? description.value : this.description,
  );
  Permission copyWithCompanion(PermissionsCompanion data) {
    return Permission(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      module: data.module.present ? data.module.value : this.module,
      action: data.action.present ? data.action.value : this.action,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Permission(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('module: $module, ')
          ..write('action: $action, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, module, action, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Permission &&
          other.id == this.id &&
          other.code == this.code &&
          other.module == this.module &&
          other.action == this.action &&
          other.description == this.description);
}

class PermissionsCompanion extends UpdateCompanion<Permission> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> module;
  final Value<String> action;
  final Value<String?> description;
  const PermissionsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.module = const Value.absent(),
    this.action = const Value.absent(),
    this.description = const Value.absent(),
  });
  PermissionsCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String module,
    required String action,
    this.description = const Value.absent(),
  }) : code = Value(code),
       module = Value(module),
       action = Value(action);
  static Insertable<Permission> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? module,
    Expression<String>? action,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (module != null) 'module': module,
      if (action != null) 'action': action,
      if (description != null) 'description': description,
    });
  }

  PermissionsCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? module,
    Value<String>? action,
    Value<String?>? description,
  }) {
    return PermissionsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      module: module ?? this.module,
      action: action ?? this.action,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (module.present) {
      map['module'] = Variable<String>(module.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PermissionsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('module: $module, ')
          ..write('action: $action, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $RolePermissionsTable extends RolePermissions
    with TableInfo<$RolePermissionsTable, RolePermission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RolePermissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<int> roleId = GeneratedColumn<int>(
    'role_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionIdMeta = const VerificationMeta(
    'permissionId',
  );
  @override
  late final GeneratedColumn<int> permissionId = GeneratedColumn<int>(
    'permission_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [roleId, permissionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'role_permissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RolePermission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    if (data.containsKey('permission_id')) {
      context.handle(
        _permissionIdMeta,
        permissionId.isAcceptableOrUnknown(
          data['permission_id']!,
          _permissionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_permissionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roleId, permissionId};
  @override
  RolePermission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RolePermission(
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role_id'],
      )!,
      permissionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}permission_id'],
      )!,
    );
  }

  @override
  $RolePermissionsTable createAlias(String alias) {
    return $RolePermissionsTable(attachedDatabase, alias);
  }
}

class RolePermission extends DataClass implements Insertable<RolePermission> {
  final int roleId;
  final int permissionId;
  const RolePermission({required this.roleId, required this.permissionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['role_id'] = Variable<int>(roleId);
    map['permission_id'] = Variable<int>(permissionId);
    return map;
  }

  RolePermissionsCompanion toCompanion(bool nullToAbsent) {
    return RolePermissionsCompanion(
      roleId: Value(roleId),
      permissionId: Value(permissionId),
    );
  }

  factory RolePermission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RolePermission(
      roleId: serializer.fromJson<int>(json['roleId']),
      permissionId: serializer.fromJson<int>(json['permissionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roleId': serializer.toJson<int>(roleId),
      'permissionId': serializer.toJson<int>(permissionId),
    };
  }

  RolePermission copyWith({int? roleId, int? permissionId}) => RolePermission(
    roleId: roleId ?? this.roleId,
    permissionId: permissionId ?? this.permissionId,
  );
  RolePermission copyWithCompanion(RolePermissionsCompanion data) {
    return RolePermission(
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      permissionId: data.permissionId.present
          ? data.permissionId.value
          : this.permissionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RolePermission(')
          ..write('roleId: $roleId, ')
          ..write('permissionId: $permissionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(roleId, permissionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RolePermission &&
          other.roleId == this.roleId &&
          other.permissionId == this.permissionId);
}

class RolePermissionsCompanion extends UpdateCompanion<RolePermission> {
  final Value<int> roleId;
  final Value<int> permissionId;
  final Value<int> rowid;
  const RolePermissionsCompanion({
    this.roleId = const Value.absent(),
    this.permissionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RolePermissionsCompanion.insert({
    required int roleId,
    required int permissionId,
    this.rowid = const Value.absent(),
  }) : roleId = Value(roleId),
       permissionId = Value(permissionId);
  static Insertable<RolePermission> custom({
    Expression<int>? roleId,
    Expression<int>? permissionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (roleId != null) 'role_id': roleId,
      if (permissionId != null) 'permission_id': permissionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RolePermissionsCompanion copyWith({
    Value<int>? roleId,
    Value<int>? permissionId,
    Value<int>? rowid,
  }) {
    return RolePermissionsCompanion(
      roleId: roleId ?? this.roleId,
      permissionId: permissionId ?? this.permissionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roleId.present) {
      map['role_id'] = Variable<int>(roleId.value);
    }
    if (permissionId.present) {
      map['permission_id'] = Variable<int>(permissionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RolePermissionsCompanion(')
          ..write('roleId: $roleId, ')
          ..write('permissionId: $permissionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPermissionOverridesTable extends UserPermissionOverrides
    with TableInfo<$UserPermissionOverridesTable, UserPermissionOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPermissionOverridesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionIdMeta = const VerificationMeta(
    'permissionId',
  );
  @override
  late final GeneratedColumn<int> permissionId = GeneratedColumn<int>(
    'permission_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allowMeta = const VerificationMeta('allow');
  @override
  late final GeneratedColumn<bool> allow = GeneratedColumn<bool>(
    'allow',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, permissionId, allow];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_permission_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPermissionOverride> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('permission_id')) {
      context.handle(
        _permissionIdMeta,
        permissionId.isAcceptableOrUnknown(
          data['permission_id']!,
          _permissionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_permissionIdMeta);
    }
    if (data.containsKey('allow')) {
      context.handle(
        _allowMeta,
        allow.isAcceptableOrUnknown(data['allow']!, _allowMeta),
      );
    } else if (isInserting) {
      context.missing(_allowMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, permissionId},
  ];
  @override
  UserPermissionOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPermissionOverride(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      permissionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}permission_id'],
      )!,
      allow: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow'],
      )!,
    );
  }

  @override
  $UserPermissionOverridesTable createAlias(String alias) {
    return $UserPermissionOverridesTable(attachedDatabase, alias);
  }
}

class UserPermissionOverride extends DataClass
    implements Insertable<UserPermissionOverride> {
  final int id;
  final int userId;
  final int permissionId;
  final bool allow;
  const UserPermissionOverride({
    required this.id,
    required this.userId,
    required this.permissionId,
    required this.allow,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['permission_id'] = Variable<int>(permissionId);
    map['allow'] = Variable<bool>(allow);
    return map;
  }

  UserPermissionOverridesCompanion toCompanion(bool nullToAbsent) {
    return UserPermissionOverridesCompanion(
      id: Value(id),
      userId: Value(userId),
      permissionId: Value(permissionId),
      allow: Value(allow),
    );
  }

  factory UserPermissionOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPermissionOverride(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      permissionId: serializer.fromJson<int>(json['permissionId']),
      allow: serializer.fromJson<bool>(json['allow']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'permissionId': serializer.toJson<int>(permissionId),
      'allow': serializer.toJson<bool>(allow),
    };
  }

  UserPermissionOverride copyWith({
    int? id,
    int? userId,
    int? permissionId,
    bool? allow,
  }) => UserPermissionOverride(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    permissionId: permissionId ?? this.permissionId,
    allow: allow ?? this.allow,
  );
  UserPermissionOverride copyWithCompanion(
    UserPermissionOverridesCompanion data,
  ) {
    return UserPermissionOverride(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      permissionId: data.permissionId.present
          ? data.permissionId.value
          : this.permissionId,
      allow: data.allow.present ? data.allow.value : this.allow,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPermissionOverride(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('permissionId: $permissionId, ')
          ..write('allow: $allow')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, permissionId, allow);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPermissionOverride &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.permissionId == this.permissionId &&
          other.allow == this.allow);
}

class UserPermissionOverridesCompanion
    extends UpdateCompanion<UserPermissionOverride> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int> permissionId;
  final Value<bool> allow;
  const UserPermissionOverridesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.permissionId = const Value.absent(),
    this.allow = const Value.absent(),
  });
  UserPermissionOverridesCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required int permissionId,
    required bool allow,
  }) : userId = Value(userId),
       permissionId = Value(permissionId),
       allow = Value(allow);
  static Insertable<UserPermissionOverride> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? permissionId,
    Expression<bool>? allow,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (permissionId != null) 'permission_id': permissionId,
      if (allow != null) 'allow': allow,
    });
  }

  UserPermissionOverridesCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<int>? permissionId,
    Value<bool>? allow,
  }) {
    return UserPermissionOverridesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      permissionId: permissionId ?? this.permissionId,
      allow: allow ?? this.allow,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (permissionId.present) {
      map['permission_id'] = Variable<int>(permissionId.value);
    }
    if (allow.present) {
      map['allow'] = Variable<bool>(allow.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPermissionOverridesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('permissionId: $permissionId, ')
          ..write('allow: $allow')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<int> roleId = GeneratedColumn<int>(
    'role_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    password,
    fullName,
    roleId,
    isActive,
    lastLoginAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role_id'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String username;
  final String password;
  final String fullName;
  final int roleId;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  const User({
    required this.id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.roleId,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['password'] = Variable<String>(password);
    map['full_name'] = Variable<String>(fullName);
    map['role_id'] = Variable<int>(roleId);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      password: Value(password),
      fullName: Value(fullName),
      roleId: Value(roleId),
      isActive: Value(isActive),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      password: serializer.fromJson<String>(json['password']),
      fullName: serializer.fromJson<String>(json['fullName']),
      roleId: serializer.fromJson<int>(json['roleId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'password': serializer.toJson<String>(password),
      'fullName': serializer.toJson<String>(fullName),
      'roleId': serializer.toJson<int>(roleId),
      'isActive': serializer.toJson<bool>(isActive),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? fullName,
    int? roleId,
    bool? isActive,
    Value<DateTime?> lastLoginAt = const Value.absent(),
    DateTime? createdAt,
  }) => User(
    id: id ?? this.id,
    username: username ?? this.username,
    password: password ?? this.password,
    fullName: fullName ?? this.fullName,
    roleId: roleId ?? this.roleId,
    isActive: isActive ?? this.isActive,
    lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
    createdAt: createdAt ?? this.createdAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      password: data.password.present ? data.password.value : this.password,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('fullName: $fullName, ')
          ..write('roleId: $roleId, ')
          ..write('isActive: $isActive, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    password,
    fullName,
    roleId,
    isActive,
    lastLoginAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.username == this.username &&
          other.password == this.password &&
          other.fullName == this.fullName &&
          other.roleId == this.roleId &&
          other.isActive == this.isActive &&
          other.lastLoginAt == this.lastLoginAt &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> password;
  final Value<String> fullName;
  final Value<int> roleId;
  final Value<bool> isActive;
  final Value<DateTime?> lastLoginAt;
  final Value<DateTime> createdAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.fullName = const Value.absent(),
    this.roleId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String password,
    required String fullName,
    required int roleId,
    this.isActive = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : username = Value(username),
       password = Value(password),
       fullName = Value(fullName),
       roleId = Value(roleId);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? password,
    Expression<String>? fullName,
    Expression<int>? roleId,
    Expression<bool>? isActive,
    Expression<DateTime>? lastLoginAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (fullName != null) 'full_name': fullName,
      if (roleId != null) 'role_id': roleId,
      if (isActive != null) 'is_active': isActive,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<String>? password,
    Value<String>? fullName,
    Value<int>? roleId,
    Value<bool>? isActive,
    Value<DateTime?>? lastLoginAt,
    Value<DateTime>? createdAt,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      roleId: roleId ?? this.roleId,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<int>(roleId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('fullName: $fullName, ')
          ..write('roleId: $roleId, ')
          ..write('isActive: $isActive, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DepartmentsTable extends Departments
    with TableInfo<$DepartmentsTable, Department> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DepartmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'departments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Department> instance, {
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
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Department map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Department(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DepartmentsTable createAlias(String alias) {
    return $DepartmentsTable(attachedDatabase, alias);
  }
}

class Department extends DataClass implements Insertable<Department> {
  final int id;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  const Department({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DepartmentsCompanion toCompanion(bool nullToAbsent) {
    return DepartmentsCompanion(
      id: Value(id),
      name: Value(name),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Department.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Department(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Department copyWith({
    int? id,
    String? name,
    bool? isActive,
    DateTime? createdAt,
  }) => Department(
    id: id ?? this.id,
    name: name ?? this.name,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Department copyWithCompanion(DepartmentsCompanion data) {
    return Department(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Department(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Department &&
          other.id == this.id &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class DepartmentsCompanion extends UpdateCompanion<Department> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const DepartmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DepartmentsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Department> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DepartmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return DepartmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
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
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DepartmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserDepartmentsTable extends UserDepartments
    with TableInfo<$UserDepartmentsTable, UserDepartment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserDepartmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departmentIdMeta = const VerificationMeta(
    'departmentId',
  );
  @override
  late final GeneratedColumn<int> departmentId = GeneratedColumn<int>(
    'department_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, departmentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_departments';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserDepartment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('department_id')) {
      context.handle(
        _departmentIdMeta,
        departmentId.isAcceptableOrUnknown(
          data['department_id']!,
          _departmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departmentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, departmentId},
  ];
  @override
  UserDepartment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserDepartment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      departmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}department_id'],
      )!,
    );
  }

  @override
  $UserDepartmentsTable createAlias(String alias) {
    return $UserDepartmentsTable(attachedDatabase, alias);
  }
}

class UserDepartment extends DataClass implements Insertable<UserDepartment> {
  final int id;
  final int userId;
  final int departmentId;
  const UserDepartment({
    required this.id,
    required this.userId,
    required this.departmentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['department_id'] = Variable<int>(departmentId);
    return map;
  }

  UserDepartmentsCompanion toCompanion(bool nullToAbsent) {
    return UserDepartmentsCompanion(
      id: Value(id),
      userId: Value(userId),
      departmentId: Value(departmentId),
    );
  }

  factory UserDepartment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserDepartment(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      departmentId: serializer.fromJson<int>(json['departmentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'departmentId': serializer.toJson<int>(departmentId),
    };
  }

  UserDepartment copyWith({int? id, int? userId, int? departmentId}) =>
      UserDepartment(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        departmentId: departmentId ?? this.departmentId,
      );
  UserDepartment copyWithCompanion(UserDepartmentsCompanion data) {
    return UserDepartment(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      departmentId: data.departmentId.present
          ? data.departmentId.value
          : this.departmentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserDepartment(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('departmentId: $departmentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, departmentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserDepartment &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.departmentId == this.departmentId);
}

class UserDepartmentsCompanion extends UpdateCompanion<UserDepartment> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int> departmentId;
  const UserDepartmentsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.departmentId = const Value.absent(),
  });
  UserDepartmentsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required int departmentId,
  }) : userId = Value(userId),
       departmentId = Value(departmentId);
  static Insertable<UserDepartment> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? departmentId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (departmentId != null) 'department_id': departmentId,
    });
  }

  UserDepartmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<int>? departmentId,
  }) {
    return UserDepartmentsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      departmentId: departmentId ?? this.departmentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (departmentId.present) {
      map['department_id'] = Variable<int>(departmentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserDepartmentsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('departmentId: $departmentId')
          ..write(')'))
        .toString();
  }
}

class $MainTitlesTable extends MainTitles
    with TableInfo<$MainTitlesTable, MainTitle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MainTitlesTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'main_titles';
  @override
  VerificationContext validateIntegrity(
    Insertable<MainTitle> instance, {
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
  MainTitle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MainTitle(
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
  $MainTitlesTable createAlias(String alias) {
    return $MainTitlesTable(attachedDatabase, alias);
  }
}

class MainTitle extends DataClass implements Insertable<MainTitle> {
  final int id;
  final String name;
  const MainTitle({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  MainTitlesCompanion toCompanion(bool nullToAbsent) {
    return MainTitlesCompanion(id: Value(id), name: Value(name));
  }

  factory MainTitle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MainTitle(
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

  MainTitle copyWith({int? id, String? name}) =>
      MainTitle(id: id ?? this.id, name: name ?? this.name);
  MainTitle copyWithCompanion(MainTitlesCompanion data) {
    return MainTitle(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MainTitle(')
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
      (other is MainTitle && other.id == this.id && other.name == this.name);
}

class MainTitlesCompanion extends UpdateCompanion<MainTitle> {
  final Value<int> id;
  final Value<String> name;
  const MainTitlesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  MainTitlesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<MainTitle> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  MainTitlesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return MainTitlesCompanion(id: id ?? this.id, name: name ?? this.name);
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
    return (StringBuffer('MainTitlesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $TitleGroupsTable extends TitleGroups
    with TableInfo<$TitleGroupsTable, TitleGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TitleGroupsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _mainTitleIdMeta = const VerificationMeta(
    'mainTitleId',
  );
  @override
  late final GeneratedColumn<int> mainTitleId = GeneratedColumn<int>(
    'main_title_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleNameMeta = const VerificationMeta(
    'titleName',
  );
  @override
  late final GeneratedColumn<String> titleName = GeneratedColumn<String>(
    'title_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vfNoMeta = const VerificationMeta('vfNo');
  @override
  late final GeneratedColumn<String> vfNo = GeneratedColumn<String>(
    'vf_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, mainTitleId, titleName, vfNo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'title_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<TitleGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('main_title_id')) {
      context.handle(
        _mainTitleIdMeta,
        mainTitleId.isAcceptableOrUnknown(
          data['main_title_id']!,
          _mainTitleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mainTitleIdMeta);
    }
    if (data.containsKey('title_name')) {
      context.handle(
        _titleNameMeta,
        titleName.isAcceptableOrUnknown(data['title_name']!, _titleNameMeta),
      );
    } else if (isInserting) {
      context.missing(_titleNameMeta);
    }
    if (data.containsKey('vf_no')) {
      context.handle(
        _vfNoMeta,
        vfNo.isAcceptableOrUnknown(data['vf_no']!, _vfNoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TitleGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TitleGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mainTitleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}main_title_id'],
      )!,
      titleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_name'],
      )!,
      vfNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vf_no'],
      ),
    );
  }

  @override
  $TitleGroupsTable createAlias(String alias) {
    return $TitleGroupsTable(attachedDatabase, alias);
  }
}

class TitleGroup extends DataClass implements Insertable<TitleGroup> {
  final int id;
  final int mainTitleId;
  final String titleName;
  final String? vfNo;
  const TitleGroup({
    required this.id,
    required this.mainTitleId,
    required this.titleName,
    this.vfNo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['main_title_id'] = Variable<int>(mainTitleId);
    map['title_name'] = Variable<String>(titleName);
    if (!nullToAbsent || vfNo != null) {
      map['vf_no'] = Variable<String>(vfNo);
    }
    return map;
  }

  TitleGroupsCompanion toCompanion(bool nullToAbsent) {
    return TitleGroupsCompanion(
      id: Value(id),
      mainTitleId: Value(mainTitleId),
      titleName: Value(titleName),
      vfNo: vfNo == null && nullToAbsent ? const Value.absent() : Value(vfNo),
    );
  }

  factory TitleGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TitleGroup(
      id: serializer.fromJson<int>(json['id']),
      mainTitleId: serializer.fromJson<int>(json['mainTitleId']),
      titleName: serializer.fromJson<String>(json['titleName']),
      vfNo: serializer.fromJson<String?>(json['vfNo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mainTitleId': serializer.toJson<int>(mainTitleId),
      'titleName': serializer.toJson<String>(titleName),
      'vfNo': serializer.toJson<String?>(vfNo),
    };
  }

  TitleGroup copyWith({
    int? id,
    int? mainTitleId,
    String? titleName,
    Value<String?> vfNo = const Value.absent(),
  }) => TitleGroup(
    id: id ?? this.id,
    mainTitleId: mainTitleId ?? this.mainTitleId,
    titleName: titleName ?? this.titleName,
    vfNo: vfNo.present ? vfNo.value : this.vfNo,
  );
  TitleGroup copyWithCompanion(TitleGroupsCompanion data) {
    return TitleGroup(
      id: data.id.present ? data.id.value : this.id,
      mainTitleId: data.mainTitleId.present
          ? data.mainTitleId.value
          : this.mainTitleId,
      titleName: data.titleName.present ? data.titleName.value : this.titleName,
      vfNo: data.vfNo.present ? data.vfNo.value : this.vfNo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TitleGroup(')
          ..write('id: $id, ')
          ..write('mainTitleId: $mainTitleId, ')
          ..write('titleName: $titleName, ')
          ..write('vfNo: $vfNo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mainTitleId, titleName, vfNo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TitleGroup &&
          other.id == this.id &&
          other.mainTitleId == this.mainTitleId &&
          other.titleName == this.titleName &&
          other.vfNo == this.vfNo);
}

class TitleGroupsCompanion extends UpdateCompanion<TitleGroup> {
  final Value<int> id;
  final Value<int> mainTitleId;
  final Value<String> titleName;
  final Value<String?> vfNo;
  const TitleGroupsCompanion({
    this.id = const Value.absent(),
    this.mainTitleId = const Value.absent(),
    this.titleName = const Value.absent(),
    this.vfNo = const Value.absent(),
  });
  TitleGroupsCompanion.insert({
    this.id = const Value.absent(),
    required int mainTitleId,
    required String titleName,
    this.vfNo = const Value.absent(),
  }) : mainTitleId = Value(mainTitleId),
       titleName = Value(titleName);
  static Insertable<TitleGroup> custom({
    Expression<int>? id,
    Expression<int>? mainTitleId,
    Expression<String>? titleName,
    Expression<String>? vfNo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mainTitleId != null) 'main_title_id': mainTitleId,
      if (titleName != null) 'title_name': titleName,
      if (vfNo != null) 'vf_no': vfNo,
    });
  }

  TitleGroupsCompanion copyWith({
    Value<int>? id,
    Value<int>? mainTitleId,
    Value<String>? titleName,
    Value<String?>? vfNo,
  }) {
    return TitleGroupsCompanion(
      id: id ?? this.id,
      mainTitleId: mainTitleId ?? this.mainTitleId,
      titleName: titleName ?? this.titleName,
      vfNo: vfNo ?? this.vfNo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mainTitleId.present) {
      map['main_title_id'] = Variable<int>(mainTitleId.value);
    }
    if (titleName.present) {
      map['title_name'] = Variable<String>(titleName.value);
    }
    if (vfNo.present) {
      map['vf_no'] = Variable<String>(vfNo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TitleGroupsCompanion(')
          ..write('id: $id, ')
          ..write('mainTitleId: $mainTitleId, ')
          ..write('titleName: $titleName, ')
          ..write('vfNo: $vfNo')
          ..write(')'))
        .toString();
  }
}

class $TitlesTable extends Titles with TableInfo<$TitlesTable, Title> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TitlesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _mainTitleIdMeta = const VerificationMeta(
    'mainTitleId',
  );
  @override
  late final GeneratedColumn<int> mainTitleId = GeneratedColumn<int>(
    'main_title_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departmentIdMeta = const VerificationMeta(
    'departmentId',
  );
  @override
  late final GeneratedColumn<int> departmentId = GeneratedColumn<int>(
    'department_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleGroupIdMeta = const VerificationMeta(
    'titleGroupId',
  );
  @override
  late final GeneratedColumn<int> titleGroupId = GeneratedColumn<int>(
    'title_group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleNameMeta = const VerificationMeta(
    'titleName',
  );
  @override
  late final GeneratedColumn<String> titleName = GeneratedColumn<String>(
    'title_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vfNoMeta = const VerificationMeta('vfNo');
  @override
  late final GeneratedColumn<String> vfNo = GeneratedColumn<String>(
    'vf_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<int> createdBy = GeneratedColumn<int>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mainTitleId,
    departmentId,
    titleGroupId,
    titleName,
    vfNo,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'titles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Title> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('main_title_id')) {
      context.handle(
        _mainTitleIdMeta,
        mainTitleId.isAcceptableOrUnknown(
          data['main_title_id']!,
          _mainTitleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mainTitleIdMeta);
    }
    if (data.containsKey('department_id')) {
      context.handle(
        _departmentIdMeta,
        departmentId.isAcceptableOrUnknown(
          data['department_id']!,
          _departmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departmentIdMeta);
    }
    if (data.containsKey('title_group_id')) {
      context.handle(
        _titleGroupIdMeta,
        titleGroupId.isAcceptableOrUnknown(
          data['title_group_id']!,
          _titleGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('title_name')) {
      context.handle(
        _titleNameMeta,
        titleName.isAcceptableOrUnknown(data['title_name']!, _titleNameMeta),
      );
    } else if (isInserting) {
      context.missing(_titleNameMeta);
    }
    if (data.containsKey('vf_no')) {
      context.handle(
        _vfNoMeta,
        vfNo.isAcceptableOrUnknown(data['vf_no']!, _vfNoMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Title map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Title(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mainTitleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}main_title_id'],
      )!,
      departmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}department_id'],
      )!,
      titleGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}title_group_id'],
      ),
      titleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_name'],
      )!,
      vfNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vf_no'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TitlesTable createAlias(String alias) {
    return $TitlesTable(attachedDatabase, alias);
  }
}

class Title extends DataClass implements Insertable<Title> {
  final int id;
  final int mainTitleId;
  final int departmentId;
  final int? titleGroupId;
  final String titleName;
  final String? vfNo;
  final int createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const Title({
    required this.id,
    required this.mainTitleId,
    required this.departmentId,
    this.titleGroupId,
    required this.titleName,
    this.vfNo,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['main_title_id'] = Variable<int>(mainTitleId);
    map['department_id'] = Variable<int>(departmentId);
    if (!nullToAbsent || titleGroupId != null) {
      map['title_group_id'] = Variable<int>(titleGroupId);
    }
    map['title_name'] = Variable<String>(titleName);
    if (!nullToAbsent || vfNo != null) {
      map['vf_no'] = Variable<String>(vfNo);
    }
    map['created_by'] = Variable<int>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  TitlesCompanion toCompanion(bool nullToAbsent) {
    return TitlesCompanion(
      id: Value(id),
      mainTitleId: Value(mainTitleId),
      departmentId: Value(departmentId),
      titleGroupId: titleGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(titleGroupId),
      titleName: Value(titleName),
      vfNo: vfNo == null && nullToAbsent ? const Value.absent() : Value(vfNo),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Title.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Title(
      id: serializer.fromJson<int>(json['id']),
      mainTitleId: serializer.fromJson<int>(json['mainTitleId']),
      departmentId: serializer.fromJson<int>(json['departmentId']),
      titleGroupId: serializer.fromJson<int?>(json['titleGroupId']),
      titleName: serializer.fromJson<String>(json['titleName']),
      vfNo: serializer.fromJson<String?>(json['vfNo']),
      createdBy: serializer.fromJson<int>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mainTitleId': serializer.toJson<int>(mainTitleId),
      'departmentId': serializer.toJson<int>(departmentId),
      'titleGroupId': serializer.toJson<int?>(titleGroupId),
      'titleName': serializer.toJson<String>(titleName),
      'vfNo': serializer.toJson<String?>(vfNo),
      'createdBy': serializer.toJson<int>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Title copyWith({
    int? id,
    int? mainTitleId,
    int? departmentId,
    Value<int?> titleGroupId = const Value.absent(),
    String? titleName,
    Value<String?> vfNo = const Value.absent(),
    int? createdBy,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => Title(
    id: id ?? this.id,
    mainTitleId: mainTitleId ?? this.mainTitleId,
    departmentId: departmentId ?? this.departmentId,
    titleGroupId: titleGroupId.present ? titleGroupId.value : this.titleGroupId,
    titleName: titleName ?? this.titleName,
    vfNo: vfNo.present ? vfNo.value : this.vfNo,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Title copyWithCompanion(TitlesCompanion data) {
    return Title(
      id: data.id.present ? data.id.value : this.id,
      mainTitleId: data.mainTitleId.present
          ? data.mainTitleId.value
          : this.mainTitleId,
      departmentId: data.departmentId.present
          ? data.departmentId.value
          : this.departmentId,
      titleGroupId: data.titleGroupId.present
          ? data.titleGroupId.value
          : this.titleGroupId,
      titleName: data.titleName.present ? data.titleName.value : this.titleName,
      vfNo: data.vfNo.present ? data.vfNo.value : this.vfNo,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Title(')
          ..write('id: $id, ')
          ..write('mainTitleId: $mainTitleId, ')
          ..write('departmentId: $departmentId, ')
          ..write('titleGroupId: $titleGroupId, ')
          ..write('titleName: $titleName, ')
          ..write('vfNo: $vfNo, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mainTitleId,
    departmentId,
    titleGroupId,
    titleName,
    vfNo,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Title &&
          other.id == this.id &&
          other.mainTitleId == this.mainTitleId &&
          other.departmentId == this.departmentId &&
          other.titleGroupId == this.titleGroupId &&
          other.titleName == this.titleName &&
          other.vfNo == this.vfNo &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TitlesCompanion extends UpdateCompanion<Title> {
  final Value<int> id;
  final Value<int> mainTitleId;
  final Value<int> departmentId;
  final Value<int?> titleGroupId;
  final Value<String> titleName;
  final Value<String?> vfNo;
  final Value<int> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const TitlesCompanion({
    this.id = const Value.absent(),
    this.mainTitleId = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.titleGroupId = const Value.absent(),
    this.titleName = const Value.absent(),
    this.vfNo = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TitlesCompanion.insert({
    this.id = const Value.absent(),
    required int mainTitleId,
    required int departmentId,
    this.titleGroupId = const Value.absent(),
    required String titleName,
    this.vfNo = const Value.absent(),
    required int createdBy,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : mainTitleId = Value(mainTitleId),
       departmentId = Value(departmentId),
       titleName = Value(titleName),
       createdBy = Value(createdBy);
  static Insertable<Title> custom({
    Expression<int>? id,
    Expression<int>? mainTitleId,
    Expression<int>? departmentId,
    Expression<int>? titleGroupId,
    Expression<String>? titleName,
    Expression<String>? vfNo,
    Expression<int>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mainTitleId != null) 'main_title_id': mainTitleId,
      if (departmentId != null) 'department_id': departmentId,
      if (titleGroupId != null) 'title_group_id': titleGroupId,
      if (titleName != null) 'title_name': titleName,
      if (vfNo != null) 'vf_no': vfNo,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TitlesCompanion copyWith({
    Value<int>? id,
    Value<int>? mainTitleId,
    Value<int>? departmentId,
    Value<int?>? titleGroupId,
    Value<String>? titleName,
    Value<String?>? vfNo,
    Value<int>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
  }) {
    return TitlesCompanion(
      id: id ?? this.id,
      mainTitleId: mainTitleId ?? this.mainTitleId,
      departmentId: departmentId ?? this.departmentId,
      titleGroupId: titleGroupId ?? this.titleGroupId,
      titleName: titleName ?? this.titleName,
      vfNo: vfNo ?? this.vfNo,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mainTitleId.present) {
      map['main_title_id'] = Variable<int>(mainTitleId.value);
    }
    if (departmentId.present) {
      map['department_id'] = Variable<int>(departmentId.value);
    }
    if (titleGroupId.present) {
      map['title_group_id'] = Variable<int>(titleGroupId.value);
    }
    if (titleName.present) {
      map['title_name'] = Variable<String>(titleName.value);
    }
    if (vfNo.present) {
      map['vf_no'] = Variable<String>(vfNo.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<int>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TitlesCompanion(')
          ..write('id: $id, ')
          ..write('mainTitleId: $mainTitleId, ')
          ..write('departmentId: $departmentId, ')
          ..write('titleGroupId: $titleGroupId, ')
          ..write('titleName: $titleName, ')
          ..write('vfNo: $vfNo, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SubTitleGroupsTable extends SubTitleGroups
    with TableInfo<$SubTitleGroupsTable, SubTitleGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubTitleGroupsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleGroupIdMeta = const VerificationMeta(
    'titleGroupId',
  );
  @override
  late final GeneratedColumn<int> titleGroupId = GeneratedColumn<int>(
    'title_group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subTitleNameMeta = const VerificationMeta(
    'subTitleName',
  );
  @override
  late final GeneratedColumn<String> subTitleName = GeneratedColumn<String>(
    'sub_title_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, titleGroupId, subTitleName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sub_title_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubTitleGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title_group_id')) {
      context.handle(
        _titleGroupIdMeta,
        titleGroupId.isAcceptableOrUnknown(
          data['title_group_id']!,
          _titleGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_titleGroupIdMeta);
    }
    if (data.containsKey('sub_title_name')) {
      context.handle(
        _subTitleNameMeta,
        subTitleName.isAcceptableOrUnknown(
          data['sub_title_name']!,
          _subTitleNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subTitleNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubTitleGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubTitleGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      titleGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}title_group_id'],
      )!,
      subTitleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_title_name'],
      )!,
    );
  }

  @override
  $SubTitleGroupsTable createAlias(String alias) {
    return $SubTitleGroupsTable(attachedDatabase, alias);
  }
}

class SubTitleGroup extends DataClass implements Insertable<SubTitleGroup> {
  final int id;
  final int titleGroupId;
  final String subTitleName;
  const SubTitleGroup({
    required this.id,
    required this.titleGroupId,
    required this.subTitleName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title_group_id'] = Variable<int>(titleGroupId);
    map['sub_title_name'] = Variable<String>(subTitleName);
    return map;
  }

  SubTitleGroupsCompanion toCompanion(bool nullToAbsent) {
    return SubTitleGroupsCompanion(
      id: Value(id),
      titleGroupId: Value(titleGroupId),
      subTitleName: Value(subTitleName),
    );
  }

  factory SubTitleGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubTitleGroup(
      id: serializer.fromJson<int>(json['id']),
      titleGroupId: serializer.fromJson<int>(json['titleGroupId']),
      subTitleName: serializer.fromJson<String>(json['subTitleName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'titleGroupId': serializer.toJson<int>(titleGroupId),
      'subTitleName': serializer.toJson<String>(subTitleName),
    };
  }

  SubTitleGroup copyWith({int? id, int? titleGroupId, String? subTitleName}) =>
      SubTitleGroup(
        id: id ?? this.id,
        titleGroupId: titleGroupId ?? this.titleGroupId,
        subTitleName: subTitleName ?? this.subTitleName,
      );
  SubTitleGroup copyWithCompanion(SubTitleGroupsCompanion data) {
    return SubTitleGroup(
      id: data.id.present ? data.id.value : this.id,
      titleGroupId: data.titleGroupId.present
          ? data.titleGroupId.value
          : this.titleGroupId,
      subTitleName: data.subTitleName.present
          ? data.subTitleName.value
          : this.subTitleName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubTitleGroup(')
          ..write('id: $id, ')
          ..write('titleGroupId: $titleGroupId, ')
          ..write('subTitleName: $subTitleName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, titleGroupId, subTitleName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubTitleGroup &&
          other.id == this.id &&
          other.titleGroupId == this.titleGroupId &&
          other.subTitleName == this.subTitleName);
}

class SubTitleGroupsCompanion extends UpdateCompanion<SubTitleGroup> {
  final Value<int> id;
  final Value<int> titleGroupId;
  final Value<String> subTitleName;
  const SubTitleGroupsCompanion({
    this.id = const Value.absent(),
    this.titleGroupId = const Value.absent(),
    this.subTitleName = const Value.absent(),
  });
  SubTitleGroupsCompanion.insert({
    this.id = const Value.absent(),
    required int titleGroupId,
    required String subTitleName,
  }) : titleGroupId = Value(titleGroupId),
       subTitleName = Value(subTitleName);
  static Insertable<SubTitleGroup> custom({
    Expression<int>? id,
    Expression<int>? titleGroupId,
    Expression<String>? subTitleName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titleGroupId != null) 'title_group_id': titleGroupId,
      if (subTitleName != null) 'sub_title_name': subTitleName,
    });
  }

  SubTitleGroupsCompanion copyWith({
    Value<int>? id,
    Value<int>? titleGroupId,
    Value<String>? subTitleName,
  }) {
    return SubTitleGroupsCompanion(
      id: id ?? this.id,
      titleGroupId: titleGroupId ?? this.titleGroupId,
      subTitleName: subTitleName ?? this.subTitleName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (titleGroupId.present) {
      map['title_group_id'] = Variable<int>(titleGroupId.value);
    }
    if (subTitleName.present) {
      map['sub_title_name'] = Variable<String>(subTitleName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubTitleGroupsCompanion(')
          ..write('id: $id, ')
          ..write('titleGroupId: $titleGroupId, ')
          ..write('subTitleName: $subTitleName')
          ..write(')'))
        .toString();
  }
}

class $SubTitlesTable extends SubTitles
    with TableInfo<$SubTitlesTable, SubTitle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubTitlesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleIdMeta = const VerificationMeta(
    'titleId',
  );
  @override
  late final GeneratedColumn<int> titleId = GeneratedColumn<int>(
    'title_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subTitleGroupIdMeta = const VerificationMeta(
    'subTitleGroupId',
  );
  @override
  late final GeneratedColumn<int> subTitleGroupId = GeneratedColumn<int>(
    'sub_title_group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subTitleNameMeta = const VerificationMeta(
    'subTitleName',
  );
  @override
  late final GeneratedColumn<String> subTitleName = GeneratedColumn<String>(
    'sub_title_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingBalanceMeta = const VerificationMeta(
    'openingBalance',
  );
  @override
  late final GeneratedColumn<double> openingBalance = GeneratedColumn<double>(
    'opening_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<int> createdBy = GeneratedColumn<int>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    titleId,
    subTitleGroupId,
    subTitleName,
    openingBalance,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sub_titles';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubTitle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title_id')) {
      context.handle(
        _titleIdMeta,
        titleId.isAcceptableOrUnknown(data['title_id']!, _titleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_titleIdMeta);
    }
    if (data.containsKey('sub_title_group_id')) {
      context.handle(
        _subTitleGroupIdMeta,
        subTitleGroupId.isAcceptableOrUnknown(
          data['sub_title_group_id']!,
          _subTitleGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('sub_title_name')) {
      context.handle(
        _subTitleNameMeta,
        subTitleName.isAcceptableOrUnknown(
          data['sub_title_name']!,
          _subTitleNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subTitleNameMeta);
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
        _openingBalanceMeta,
        openingBalance.isAcceptableOrUnknown(
          data['opening_balance']!,
          _openingBalanceMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubTitle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubTitle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      titleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}title_id'],
      )!,
      subTitleGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sub_title_group_id'],
      ),
      subTitleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_title_name'],
      )!,
      openingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opening_balance'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $SubTitlesTable createAlias(String alias) {
    return $SubTitlesTable(attachedDatabase, alias);
  }
}

class SubTitle extends DataClass implements Insertable<SubTitle> {
  final int id;
  final int titleId;
  final int? subTitleGroupId;
  final String subTitleName;
  final double openingBalance;
  final int createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const SubTitle({
    required this.id,
    required this.titleId,
    this.subTitleGroupId,
    required this.subTitleName,
    required this.openingBalance,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title_id'] = Variable<int>(titleId);
    if (!nullToAbsent || subTitleGroupId != null) {
      map['sub_title_group_id'] = Variable<int>(subTitleGroupId);
    }
    map['sub_title_name'] = Variable<String>(subTitleName);
    map['opening_balance'] = Variable<double>(openingBalance);
    map['created_by'] = Variable<int>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  SubTitlesCompanion toCompanion(bool nullToAbsent) {
    return SubTitlesCompanion(
      id: Value(id),
      titleId: Value(titleId),
      subTitleGroupId: subTitleGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(subTitleGroupId),
      subTitleName: Value(subTitleName),
      openingBalance: Value(openingBalance),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory SubTitle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubTitle(
      id: serializer.fromJson<int>(json['id']),
      titleId: serializer.fromJson<int>(json['titleId']),
      subTitleGroupId: serializer.fromJson<int?>(json['subTitleGroupId']),
      subTitleName: serializer.fromJson<String>(json['subTitleName']),
      openingBalance: serializer.fromJson<double>(json['openingBalance']),
      createdBy: serializer.fromJson<int>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'titleId': serializer.toJson<int>(titleId),
      'subTitleGroupId': serializer.toJson<int?>(subTitleGroupId),
      'subTitleName': serializer.toJson<String>(subTitleName),
      'openingBalance': serializer.toJson<double>(openingBalance),
      'createdBy': serializer.toJson<int>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  SubTitle copyWith({
    int? id,
    int? titleId,
    Value<int?> subTitleGroupId = const Value.absent(),
    String? subTitleName,
    double? openingBalance,
    int? createdBy,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => SubTitle(
    id: id ?? this.id,
    titleId: titleId ?? this.titleId,
    subTitleGroupId: subTitleGroupId.present
        ? subTitleGroupId.value
        : this.subTitleGroupId,
    subTitleName: subTitleName ?? this.subTitleName,
    openingBalance: openingBalance ?? this.openingBalance,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  SubTitle copyWithCompanion(SubTitlesCompanion data) {
    return SubTitle(
      id: data.id.present ? data.id.value : this.id,
      titleId: data.titleId.present ? data.titleId.value : this.titleId,
      subTitleGroupId: data.subTitleGroupId.present
          ? data.subTitleGroupId.value
          : this.subTitleGroupId,
      subTitleName: data.subTitleName.present
          ? data.subTitleName.value
          : this.subTitleName,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubTitle(')
          ..write('id: $id, ')
          ..write('titleId: $titleId, ')
          ..write('subTitleGroupId: $subTitleGroupId, ')
          ..write('subTitleName: $subTitleName, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    titleId,
    subTitleGroupId,
    subTitleName,
    openingBalance,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubTitle &&
          other.id == this.id &&
          other.titleId == this.titleId &&
          other.subTitleGroupId == this.subTitleGroupId &&
          other.subTitleName == this.subTitleName &&
          other.openingBalance == this.openingBalance &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SubTitlesCompanion extends UpdateCompanion<SubTitle> {
  final Value<int> id;
  final Value<int> titleId;
  final Value<int?> subTitleGroupId;
  final Value<String> subTitleName;
  final Value<double> openingBalance;
  final Value<int> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const SubTitlesCompanion({
    this.id = const Value.absent(),
    this.titleId = const Value.absent(),
    this.subTitleGroupId = const Value.absent(),
    this.subTitleName = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SubTitlesCompanion.insert({
    this.id = const Value.absent(),
    required int titleId,
    this.subTitleGroupId = const Value.absent(),
    required String subTitleName,
    this.openingBalance = const Value.absent(),
    required int createdBy,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : titleId = Value(titleId),
       subTitleName = Value(subTitleName),
       createdBy = Value(createdBy);
  static Insertable<SubTitle> custom({
    Expression<int>? id,
    Expression<int>? titleId,
    Expression<int>? subTitleGroupId,
    Expression<String>? subTitleName,
    Expression<double>? openingBalance,
    Expression<int>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titleId != null) 'title_id': titleId,
      if (subTitleGroupId != null) 'sub_title_group_id': subTitleGroupId,
      if (subTitleName != null) 'sub_title_name': subTitleName,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SubTitlesCompanion copyWith({
    Value<int>? id,
    Value<int>? titleId,
    Value<int?>? subTitleGroupId,
    Value<String>? subTitleName,
    Value<double>? openingBalance,
    Value<int>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
  }) {
    return SubTitlesCompanion(
      id: id ?? this.id,
      titleId: titleId ?? this.titleId,
      subTitleGroupId: subTitleGroupId ?? this.subTitleGroupId,
      subTitleName: subTitleName ?? this.subTitleName,
      openingBalance: openingBalance ?? this.openingBalance,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (titleId.present) {
      map['title_id'] = Variable<int>(titleId.value);
    }
    if (subTitleGroupId.present) {
      map['sub_title_group_id'] = Variable<int>(subTitleGroupId.value);
    }
    if (subTitleName.present) {
      map['sub_title_name'] = Variable<String>(subTitleName.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<double>(openingBalance.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<int>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubTitlesCompanion(')
          ..write('id: $id, ')
          ..write('titleId: $titleId, ')
          ..write('subTitleGroupId: $subTitleGroupId, ')
          ..write('subTitleName: $subTitleName, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BalanceEntriesTable extends BalanceEntries
    with TableInfo<$BalanceEntriesTable, BalanceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BalanceEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _subTitleIdMeta = const VerificationMeta(
    'subTitleId',
  );
  @override
  late final GeneratedColumn<int> subTitleId = GeneratedColumn<int>(
    'sub_title_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departmentIdMeta = const VerificationMeta(
    'departmentId',
  );
  @override
  late final GeneratedColumn<int> departmentId = GeneratedColumn<int>(
    'department_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _debitAmountMeta = const VerificationMeta(
    'debitAmount',
  );
  @override
  late final GeneratedColumn<double> debitAmount = GeneratedColumn<double>(
    'debit_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _creditAmountMeta = const VerificationMeta(
    'creditAmount',
  );
  @override
  late final GeneratedColumn<double> creditAmount = GeneratedColumn<double>(
    'credit_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<int> createdBy = GeneratedColumn<int>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subTitleId,
    departmentId,
    entryDate,
    debitAmount,
    creditAmount,
    details,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'balance_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<BalanceEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sub_title_id')) {
      context.handle(
        _subTitleIdMeta,
        subTitleId.isAcceptableOrUnknown(
          data['sub_title_id']!,
          _subTitleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subTitleIdMeta);
    }
    if (data.containsKey('department_id')) {
      context.handle(
        _departmentIdMeta,
        departmentId.isAcceptableOrUnknown(
          data['department_id']!,
          _departmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departmentIdMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('debit_amount')) {
      context.handle(
        _debitAmountMeta,
        debitAmount.isAcceptableOrUnknown(
          data['debit_amount']!,
          _debitAmountMeta,
        ),
      );
    }
    if (data.containsKey('credit_amount')) {
      context.handle(
        _creditAmountMeta,
        creditAmount.isAcceptableOrUnknown(
          data['credit_amount']!,
          _creditAmountMeta,
        ),
      );
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {subTitleId, entryDate},
  ];
  @override
  BalanceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BalanceEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      subTitleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sub_title_id'],
      )!,
      departmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}department_id'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entry_date'],
      )!,
      debitAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}debit_amount'],
      )!,
      creditAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_amount'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $BalanceEntriesTable createAlias(String alias) {
    return $BalanceEntriesTable(attachedDatabase, alias);
  }
}

class BalanceEntry extends DataClass implements Insertable<BalanceEntry> {
  final int id;
  final int subTitleId;
  final int departmentId;
  final DateTime entryDate;
  final double debitAmount;
  final double creditAmount;
  final String? details;
  final int createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const BalanceEntry({
    required this.id,
    required this.subTitleId,
    required this.departmentId,
    required this.entryDate,
    required this.debitAmount,
    required this.creditAmount,
    this.details,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sub_title_id'] = Variable<int>(subTitleId);
    map['department_id'] = Variable<int>(departmentId);
    map['entry_date'] = Variable<DateTime>(entryDate);
    map['debit_amount'] = Variable<double>(debitAmount);
    map['credit_amount'] = Variable<double>(creditAmount);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    map['created_by'] = Variable<int>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  BalanceEntriesCompanion toCompanion(bool nullToAbsent) {
    return BalanceEntriesCompanion(
      id: Value(id),
      subTitleId: Value(subTitleId),
      departmentId: Value(departmentId),
      entryDate: Value(entryDate),
      debitAmount: Value(debitAmount),
      creditAmount: Value(creditAmount),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory BalanceEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BalanceEntry(
      id: serializer.fromJson<int>(json['id']),
      subTitleId: serializer.fromJson<int>(json['subTitleId']),
      departmentId: serializer.fromJson<int>(json['departmentId']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      debitAmount: serializer.fromJson<double>(json['debitAmount']),
      creditAmount: serializer.fromJson<double>(json['creditAmount']),
      details: serializer.fromJson<String?>(json['details']),
      createdBy: serializer.fromJson<int>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subTitleId': serializer.toJson<int>(subTitleId),
      'departmentId': serializer.toJson<int>(departmentId),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'debitAmount': serializer.toJson<double>(debitAmount),
      'creditAmount': serializer.toJson<double>(creditAmount),
      'details': serializer.toJson<String?>(details),
      'createdBy': serializer.toJson<int>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  BalanceEntry copyWith({
    int? id,
    int? subTitleId,
    int? departmentId,
    DateTime? entryDate,
    double? debitAmount,
    double? creditAmount,
    Value<String?> details = const Value.absent(),
    int? createdBy,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => BalanceEntry(
    id: id ?? this.id,
    subTitleId: subTitleId ?? this.subTitleId,
    departmentId: departmentId ?? this.departmentId,
    entryDate: entryDate ?? this.entryDate,
    debitAmount: debitAmount ?? this.debitAmount,
    creditAmount: creditAmount ?? this.creditAmount,
    details: details.present ? details.value : this.details,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  BalanceEntry copyWithCompanion(BalanceEntriesCompanion data) {
    return BalanceEntry(
      id: data.id.present ? data.id.value : this.id,
      subTitleId: data.subTitleId.present
          ? data.subTitleId.value
          : this.subTitleId,
      departmentId: data.departmentId.present
          ? data.departmentId.value
          : this.departmentId,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      debitAmount: data.debitAmount.present
          ? data.debitAmount.value
          : this.debitAmount,
      creditAmount: data.creditAmount.present
          ? data.creditAmount.value
          : this.creditAmount,
      details: data.details.present ? data.details.value : this.details,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BalanceEntry(')
          ..write('id: $id, ')
          ..write('subTitleId: $subTitleId, ')
          ..write('departmentId: $departmentId, ')
          ..write('entryDate: $entryDate, ')
          ..write('debitAmount: $debitAmount, ')
          ..write('creditAmount: $creditAmount, ')
          ..write('details: $details, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subTitleId,
    departmentId,
    entryDate,
    debitAmount,
    creditAmount,
    details,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BalanceEntry &&
          other.id == this.id &&
          other.subTitleId == this.subTitleId &&
          other.departmentId == this.departmentId &&
          other.entryDate == this.entryDate &&
          other.debitAmount == this.debitAmount &&
          other.creditAmount == this.creditAmount &&
          other.details == this.details &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BalanceEntriesCompanion extends UpdateCompanion<BalanceEntry> {
  final Value<int> id;
  final Value<int> subTitleId;
  final Value<int> departmentId;
  final Value<DateTime> entryDate;
  final Value<double> debitAmount;
  final Value<double> creditAmount;
  final Value<String?> details;
  final Value<int> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const BalanceEntriesCompanion({
    this.id = const Value.absent(),
    this.subTitleId = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.debitAmount = const Value.absent(),
    this.creditAmount = const Value.absent(),
    this.details = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BalanceEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int subTitleId,
    required int departmentId,
    required DateTime entryDate,
    this.debitAmount = const Value.absent(),
    this.creditAmount = const Value.absent(),
    this.details = const Value.absent(),
    required int createdBy,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : subTitleId = Value(subTitleId),
       departmentId = Value(departmentId),
       entryDate = Value(entryDate),
       createdBy = Value(createdBy);
  static Insertable<BalanceEntry> custom({
    Expression<int>? id,
    Expression<int>? subTitleId,
    Expression<int>? departmentId,
    Expression<DateTime>? entryDate,
    Expression<double>? debitAmount,
    Expression<double>? creditAmount,
    Expression<String>? details,
    Expression<int>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subTitleId != null) 'sub_title_id': subTitleId,
      if (departmentId != null) 'department_id': departmentId,
      if (entryDate != null) 'entry_date': entryDate,
      if (debitAmount != null) 'debit_amount': debitAmount,
      if (creditAmount != null) 'credit_amount': creditAmount,
      if (details != null) 'details': details,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BalanceEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? subTitleId,
    Value<int>? departmentId,
    Value<DateTime>? entryDate,
    Value<double>? debitAmount,
    Value<double>? creditAmount,
    Value<String?>? details,
    Value<int>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
  }) {
    return BalanceEntriesCompanion(
      id: id ?? this.id,
      subTitleId: subTitleId ?? this.subTitleId,
      departmentId: departmentId ?? this.departmentId,
      entryDate: entryDate ?? this.entryDate,
      debitAmount: debitAmount ?? this.debitAmount,
      creditAmount: creditAmount ?? this.creditAmount,
      details: details ?? this.details,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subTitleId.present) {
      map['sub_title_id'] = Variable<int>(subTitleId.value);
    }
    if (departmentId.present) {
      map['department_id'] = Variable<int>(departmentId.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (debitAmount.present) {
      map['debit_amount'] = Variable<double>(debitAmount.value);
    }
    if (creditAmount.present) {
      map['credit_amount'] = Variable<double>(creditAmount.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<int>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BalanceEntriesCompanion(')
          ..write('id: $id, ')
          ..write('subTitleId: $subTitleId, ')
          ..write('departmentId: $departmentId, ')
          ..write('entryDate: $entryDate, ')
          ..write('debitAmount: $debitAmount, ')
          ..write('creditAmount: $creditAmount, ')
          ..write('details: $details, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DayBooksTable extends DayBooks with TableInfo<$DayBooksTable, DayBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayBooksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _departmentIdMeta = const VerificationMeta(
    'departmentId',
  );
  @override
  late final GeneratedColumn<int> departmentId = GeneratedColumn<int>(
    'department_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<DateTime> businessDate = GeneratedColumn<DateTime>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('OPEN'),
  );
  static const VerificationMeta _computedClosingMeta = const VerificationMeta(
    'computedClosing',
  );
  @override
  late final GeneratedColumn<double> computedClosing = GeneratedColumn<double>(
    'computed_closing',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closingCheckIdMeta = const VerificationMeta(
    'closingCheckId',
  );
  @override
  late final GeneratedColumn<int> closingCheckId = GeneratedColumn<int>(
    'closing_check_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedByMeta = const VerificationMeta(
    'closedBy',
  );
  @override
  late final GeneratedColumn<int> closedBy = GeneratedColumn<int>(
    'closed_by',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    departmentId,
    businessDate,
    status,
    computedClosing,
    closingCheckId,
    closedBy,
    closedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayBook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('department_id')) {
      context.handle(
        _departmentIdMeta,
        departmentId.isAcceptableOrUnknown(
          data['department_id']!,
          _departmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departmentIdMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('computed_closing')) {
      context.handle(
        _computedClosingMeta,
        computedClosing.isAcceptableOrUnknown(
          data['computed_closing']!,
          _computedClosingMeta,
        ),
      );
    }
    if (data.containsKey('closing_check_id')) {
      context.handle(
        _closingCheckIdMeta,
        closingCheckId.isAcceptableOrUnknown(
          data['closing_check_id']!,
          _closingCheckIdMeta,
        ),
      );
    }
    if (data.containsKey('closed_by')) {
      context.handle(
        _closedByMeta,
        closedBy.isAcceptableOrUnknown(data['closed_by']!, _closedByMeta),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {departmentId, businessDate},
  ];
  @override
  DayBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayBook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      departmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}department_id'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}business_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      computedClosing: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}computed_closing'],
      ),
      closingCheckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closing_check_id'],
      ),
      closedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closed_by'],
      ),
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
    );
  }

  @override
  $DayBooksTable createAlias(String alias) {
    return $DayBooksTable(attachedDatabase, alias);
  }
}

class DayBook extends DataClass implements Insertable<DayBook> {
  final int id;
  final int departmentId;
  final DateTime businessDate;
  final String status;
  final double? computedClosing;
  final int? closingCheckId;
  final int? closedBy;
  final DateTime? closedAt;
  const DayBook({
    required this.id,
    required this.departmentId,
    required this.businessDate,
    required this.status,
    this.computedClosing,
    this.closingCheckId,
    this.closedBy,
    this.closedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['department_id'] = Variable<int>(departmentId);
    map['business_date'] = Variable<DateTime>(businessDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || computedClosing != null) {
      map['computed_closing'] = Variable<double>(computedClosing);
    }
    if (!nullToAbsent || closingCheckId != null) {
      map['closing_check_id'] = Variable<int>(closingCheckId);
    }
    if (!nullToAbsent || closedBy != null) {
      map['closed_by'] = Variable<int>(closedBy);
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    return map;
  }

  DayBooksCompanion toCompanion(bool nullToAbsent) {
    return DayBooksCompanion(
      id: Value(id),
      departmentId: Value(departmentId),
      businessDate: Value(businessDate),
      status: Value(status),
      computedClosing: computedClosing == null && nullToAbsent
          ? const Value.absent()
          : Value(computedClosing),
      closingCheckId: closingCheckId == null && nullToAbsent
          ? const Value.absent()
          : Value(closingCheckId),
      closedBy: closedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(closedBy),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
    );
  }

  factory DayBook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayBook(
      id: serializer.fromJson<int>(json['id']),
      departmentId: serializer.fromJson<int>(json['departmentId']),
      businessDate: serializer.fromJson<DateTime>(json['businessDate']),
      status: serializer.fromJson<String>(json['status']),
      computedClosing: serializer.fromJson<double?>(json['computedClosing']),
      closingCheckId: serializer.fromJson<int?>(json['closingCheckId']),
      closedBy: serializer.fromJson<int?>(json['closedBy']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'departmentId': serializer.toJson<int>(departmentId),
      'businessDate': serializer.toJson<DateTime>(businessDate),
      'status': serializer.toJson<String>(status),
      'computedClosing': serializer.toJson<double?>(computedClosing),
      'closingCheckId': serializer.toJson<int?>(closingCheckId),
      'closedBy': serializer.toJson<int?>(closedBy),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
    };
  }

  DayBook copyWith({
    int? id,
    int? departmentId,
    DateTime? businessDate,
    String? status,
    Value<double?> computedClosing = const Value.absent(),
    Value<int?> closingCheckId = const Value.absent(),
    Value<int?> closedBy = const Value.absent(),
    Value<DateTime?> closedAt = const Value.absent(),
  }) => DayBook(
    id: id ?? this.id,
    departmentId: departmentId ?? this.departmentId,
    businessDate: businessDate ?? this.businessDate,
    status: status ?? this.status,
    computedClosing: computedClosing.present
        ? computedClosing.value
        : this.computedClosing,
    closingCheckId: closingCheckId.present
        ? closingCheckId.value
        : this.closingCheckId,
    closedBy: closedBy.present ? closedBy.value : this.closedBy,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
  );
  DayBook copyWithCompanion(DayBooksCompanion data) {
    return DayBook(
      id: data.id.present ? data.id.value : this.id,
      departmentId: data.departmentId.present
          ? data.departmentId.value
          : this.departmentId,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      status: data.status.present ? data.status.value : this.status,
      computedClosing: data.computedClosing.present
          ? data.computedClosing.value
          : this.computedClosing,
      closingCheckId: data.closingCheckId.present
          ? data.closingCheckId.value
          : this.closingCheckId,
      closedBy: data.closedBy.present ? data.closedBy.value : this.closedBy,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayBook(')
          ..write('id: $id, ')
          ..write('departmentId: $departmentId, ')
          ..write('businessDate: $businessDate, ')
          ..write('status: $status, ')
          ..write('computedClosing: $computedClosing, ')
          ..write('closingCheckId: $closingCheckId, ')
          ..write('closedBy: $closedBy, ')
          ..write('closedAt: $closedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    departmentId,
    businessDate,
    status,
    computedClosing,
    closingCheckId,
    closedBy,
    closedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayBook &&
          other.id == this.id &&
          other.departmentId == this.departmentId &&
          other.businessDate == this.businessDate &&
          other.status == this.status &&
          other.computedClosing == this.computedClosing &&
          other.closingCheckId == this.closingCheckId &&
          other.closedBy == this.closedBy &&
          other.closedAt == this.closedAt);
}

class DayBooksCompanion extends UpdateCompanion<DayBook> {
  final Value<int> id;
  final Value<int> departmentId;
  final Value<DateTime> businessDate;
  final Value<String> status;
  final Value<double?> computedClosing;
  final Value<int?> closingCheckId;
  final Value<int?> closedBy;
  final Value<DateTime?> closedAt;
  const DayBooksCompanion({
    this.id = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.status = const Value.absent(),
    this.computedClosing = const Value.absent(),
    this.closingCheckId = const Value.absent(),
    this.closedBy = const Value.absent(),
    this.closedAt = const Value.absent(),
  });
  DayBooksCompanion.insert({
    this.id = const Value.absent(),
    required int departmentId,
    required DateTime businessDate,
    this.status = const Value.absent(),
    this.computedClosing = const Value.absent(),
    this.closingCheckId = const Value.absent(),
    this.closedBy = const Value.absent(),
    this.closedAt = const Value.absent(),
  }) : departmentId = Value(departmentId),
       businessDate = Value(businessDate);
  static Insertable<DayBook> custom({
    Expression<int>? id,
    Expression<int>? departmentId,
    Expression<DateTime>? businessDate,
    Expression<String>? status,
    Expression<double>? computedClosing,
    Expression<int>? closingCheckId,
    Expression<int>? closedBy,
    Expression<DateTime>? closedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (departmentId != null) 'department_id': departmentId,
      if (businessDate != null) 'business_date': businessDate,
      if (status != null) 'status': status,
      if (computedClosing != null) 'computed_closing': computedClosing,
      if (closingCheckId != null) 'closing_check_id': closingCheckId,
      if (closedBy != null) 'closed_by': closedBy,
      if (closedAt != null) 'closed_at': closedAt,
    });
  }

  DayBooksCompanion copyWith({
    Value<int>? id,
    Value<int>? departmentId,
    Value<DateTime>? businessDate,
    Value<String>? status,
    Value<double?>? computedClosing,
    Value<int?>? closingCheckId,
    Value<int?>? closedBy,
    Value<DateTime?>? closedAt,
  }) {
    return DayBooksCompanion(
      id: id ?? this.id,
      departmentId: departmentId ?? this.departmentId,
      businessDate: businessDate ?? this.businessDate,
      status: status ?? this.status,
      computedClosing: computedClosing ?? this.computedClosing,
      closingCheckId: closingCheckId ?? this.closingCheckId,
      closedBy: closedBy ?? this.closedBy,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (departmentId.present) {
      map['department_id'] = Variable<int>(departmentId.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<DateTime>(businessDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (computedClosing.present) {
      map['computed_closing'] = Variable<double>(computedClosing.value);
    }
    if (closingCheckId.present) {
      map['closing_check_id'] = Variable<int>(closingCheckId.value);
    }
    if (closedBy.present) {
      map['closed_by'] = Variable<int>(closedBy.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayBooksCompanion(')
          ..write('id: $id, ')
          ..write('departmentId: $departmentId, ')
          ..write('businessDate: $businessDate, ')
          ..write('status: $status, ')
          ..write('computedClosing: $computedClosing, ')
          ..write('closingCheckId: $closingCheckId, ')
          ..write('closedBy: $closedBy, ')
          ..write('closedAt: $closedAt')
          ..write(')'))
        .toString();
  }
}

class $ClosingBalanceChecksTable extends ClosingBalanceChecks
    with TableInfo<$ClosingBalanceChecksTable, ClosingBalanceCheck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClosingBalanceChecksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _departmentIdMeta = const VerificationMeta(
    'departmentId',
  );
  @override
  late final GeneratedColumn<int> departmentId = GeneratedColumn<int>(
    'department_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkDateMeta = const VerificationMeta(
    'checkDate',
  );
  @override
  late final GeneratedColumn<DateTime> checkDate = GeneratedColumn<DateTime>(
    'check_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualClosingMeta = const VerificationMeta(
    'actualClosing',
  );
  @override
  late final GeneratedColumn<double> actualClosing = GeneratedColumn<double>(
    'actual_closing',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enteredByMeta = const VerificationMeta(
    'enteredBy',
  );
  @override
  late final GeneratedColumn<int> enteredBy = GeneratedColumn<int>(
    'entered_by',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enteredAtMeta = const VerificationMeta(
    'enteredAt',
  );
  @override
  late final GeneratedColumn<DateTime> enteredAt = GeneratedColumn<DateTime>(
    'entered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    departmentId,
    checkDate,
    actualClosing,
    enteredBy,
    enteredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'closing_balance_checks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClosingBalanceCheck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('department_id')) {
      context.handle(
        _departmentIdMeta,
        departmentId.isAcceptableOrUnknown(
          data['department_id']!,
          _departmentIdMeta,
        ),
      );
    }
    if (data.containsKey('check_date')) {
      context.handle(
        _checkDateMeta,
        checkDate.isAcceptableOrUnknown(data['check_date']!, _checkDateMeta),
      );
    } else if (isInserting) {
      context.missing(_checkDateMeta);
    }
    if (data.containsKey('actual_closing')) {
      context.handle(
        _actualClosingMeta,
        actualClosing.isAcceptableOrUnknown(
          data['actual_closing']!,
          _actualClosingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualClosingMeta);
    }
    if (data.containsKey('entered_by')) {
      context.handle(
        _enteredByMeta,
        enteredBy.isAcceptableOrUnknown(data['entered_by']!, _enteredByMeta),
      );
    } else if (isInserting) {
      context.missing(_enteredByMeta);
    }
    if (data.containsKey('entered_at')) {
      context.handle(
        _enteredAtMeta,
        enteredAt.isAcceptableOrUnknown(data['entered_at']!, _enteredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {departmentId, checkDate},
  ];
  @override
  ClosingBalanceCheck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClosingBalanceCheck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      departmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}department_id'],
      ),
      checkDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_date'],
      )!,
      actualClosing: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_closing'],
      )!,
      enteredBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entered_by'],
      )!,
      enteredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entered_at'],
      )!,
    );
  }

  @override
  $ClosingBalanceChecksTable createAlias(String alias) {
    return $ClosingBalanceChecksTable(attachedDatabase, alias);
  }
}

class ClosingBalanceCheck extends DataClass
    implements Insertable<ClosingBalanceCheck> {
  final int id;
  final int? departmentId;
  final DateTime checkDate;
  final double actualClosing;
  final int enteredBy;
  final DateTime enteredAt;
  const ClosingBalanceCheck({
    required this.id,
    this.departmentId,
    required this.checkDate,
    required this.actualClosing,
    required this.enteredBy,
    required this.enteredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || departmentId != null) {
      map['department_id'] = Variable<int>(departmentId);
    }
    map['check_date'] = Variable<DateTime>(checkDate);
    map['actual_closing'] = Variable<double>(actualClosing);
    map['entered_by'] = Variable<int>(enteredBy);
    map['entered_at'] = Variable<DateTime>(enteredAt);
    return map;
  }

  ClosingBalanceChecksCompanion toCompanion(bool nullToAbsent) {
    return ClosingBalanceChecksCompanion(
      id: Value(id),
      departmentId: departmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(departmentId),
      checkDate: Value(checkDate),
      actualClosing: Value(actualClosing),
      enteredBy: Value(enteredBy),
      enteredAt: Value(enteredAt),
    );
  }

  factory ClosingBalanceCheck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClosingBalanceCheck(
      id: serializer.fromJson<int>(json['id']),
      departmentId: serializer.fromJson<int?>(json['departmentId']),
      checkDate: serializer.fromJson<DateTime>(json['checkDate']),
      actualClosing: serializer.fromJson<double>(json['actualClosing']),
      enteredBy: serializer.fromJson<int>(json['enteredBy']),
      enteredAt: serializer.fromJson<DateTime>(json['enteredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'departmentId': serializer.toJson<int?>(departmentId),
      'checkDate': serializer.toJson<DateTime>(checkDate),
      'actualClosing': serializer.toJson<double>(actualClosing),
      'enteredBy': serializer.toJson<int>(enteredBy),
      'enteredAt': serializer.toJson<DateTime>(enteredAt),
    };
  }

  ClosingBalanceCheck copyWith({
    int? id,
    Value<int?> departmentId = const Value.absent(),
    DateTime? checkDate,
    double? actualClosing,
    int? enteredBy,
    DateTime? enteredAt,
  }) => ClosingBalanceCheck(
    id: id ?? this.id,
    departmentId: departmentId.present ? departmentId.value : this.departmentId,
    checkDate: checkDate ?? this.checkDate,
    actualClosing: actualClosing ?? this.actualClosing,
    enteredBy: enteredBy ?? this.enteredBy,
    enteredAt: enteredAt ?? this.enteredAt,
  );
  ClosingBalanceCheck copyWithCompanion(ClosingBalanceChecksCompanion data) {
    return ClosingBalanceCheck(
      id: data.id.present ? data.id.value : this.id,
      departmentId: data.departmentId.present
          ? data.departmentId.value
          : this.departmentId,
      checkDate: data.checkDate.present ? data.checkDate.value : this.checkDate,
      actualClosing: data.actualClosing.present
          ? data.actualClosing.value
          : this.actualClosing,
      enteredBy: data.enteredBy.present ? data.enteredBy.value : this.enteredBy,
      enteredAt: data.enteredAt.present ? data.enteredAt.value : this.enteredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClosingBalanceCheck(')
          ..write('id: $id, ')
          ..write('departmentId: $departmentId, ')
          ..write('checkDate: $checkDate, ')
          ..write('actualClosing: $actualClosing, ')
          ..write('enteredBy: $enteredBy, ')
          ..write('enteredAt: $enteredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    departmentId,
    checkDate,
    actualClosing,
    enteredBy,
    enteredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClosingBalanceCheck &&
          other.id == this.id &&
          other.departmentId == this.departmentId &&
          other.checkDate == this.checkDate &&
          other.actualClosing == this.actualClosing &&
          other.enteredBy == this.enteredBy &&
          other.enteredAt == this.enteredAt);
}

class ClosingBalanceChecksCompanion
    extends UpdateCompanion<ClosingBalanceCheck> {
  final Value<int> id;
  final Value<int?> departmentId;
  final Value<DateTime> checkDate;
  final Value<double> actualClosing;
  final Value<int> enteredBy;
  final Value<DateTime> enteredAt;
  const ClosingBalanceChecksCompanion({
    this.id = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.checkDate = const Value.absent(),
    this.actualClosing = const Value.absent(),
    this.enteredBy = const Value.absent(),
    this.enteredAt = const Value.absent(),
  });
  ClosingBalanceChecksCompanion.insert({
    this.id = const Value.absent(),
    this.departmentId = const Value.absent(),
    required DateTime checkDate,
    required double actualClosing,
    required int enteredBy,
    this.enteredAt = const Value.absent(),
  }) : checkDate = Value(checkDate),
       actualClosing = Value(actualClosing),
       enteredBy = Value(enteredBy);
  static Insertable<ClosingBalanceCheck> custom({
    Expression<int>? id,
    Expression<int>? departmentId,
    Expression<DateTime>? checkDate,
    Expression<double>? actualClosing,
    Expression<int>? enteredBy,
    Expression<DateTime>? enteredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (departmentId != null) 'department_id': departmentId,
      if (checkDate != null) 'check_date': checkDate,
      if (actualClosing != null) 'actual_closing': actualClosing,
      if (enteredBy != null) 'entered_by': enteredBy,
      if (enteredAt != null) 'entered_at': enteredAt,
    });
  }

  ClosingBalanceChecksCompanion copyWith({
    Value<int>? id,
    Value<int?>? departmentId,
    Value<DateTime>? checkDate,
    Value<double>? actualClosing,
    Value<int>? enteredBy,
    Value<DateTime>? enteredAt,
  }) {
    return ClosingBalanceChecksCompanion(
      id: id ?? this.id,
      departmentId: departmentId ?? this.departmentId,
      checkDate: checkDate ?? this.checkDate,
      actualClosing: actualClosing ?? this.actualClosing,
      enteredBy: enteredBy ?? this.enteredBy,
      enteredAt: enteredAt ?? this.enteredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (departmentId.present) {
      map['department_id'] = Variable<int>(departmentId.value);
    }
    if (checkDate.present) {
      map['check_date'] = Variable<DateTime>(checkDate.value);
    }
    if (actualClosing.present) {
      map['actual_closing'] = Variable<double>(actualClosing.value);
    }
    if (enteredBy.present) {
      map['entered_by'] = Variable<int>(enteredBy.value);
    }
    if (enteredAt.present) {
      map['entered_at'] = Variable<DateTime>(enteredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClosingBalanceChecksCompanion(')
          ..write('id: $id, ')
          ..write('departmentId: $departmentId, ')
          ..write('checkDate: $checkDate, ')
          ..write('actualClosing: $actualClosing, ')
          ..write('enteredBy: $enteredBy, ')
          ..write('enteredAt: $enteredAt')
          ..write(')'))
        .toString();
  }
}

class $ExportPasswordHistoryTable extends ExportPasswordHistory
    with TableInfo<$ExportPasswordHistoryTable, ExportPasswordHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportPasswordHistoryTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exportTypeMeta = const VerificationMeta(
    'exportType',
  );
  @override
  late final GeneratedColumn<String> exportType = GeneratedColumn<String>(
    'export_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exportPasswordMeta = const VerificationMeta(
    'exportPassword',
  );
  @override
  late final GeneratedColumn<String> exportPassword = GeneratedColumn<String>(
    'export_password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromDateMeta = const VerificationMeta(
    'fromDate',
  );
  @override
  late final GeneratedColumn<DateTime> fromDate = GeneratedColumn<DateTime>(
    'from_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toDateMeta = const VerificationMeta('toDate');
  @override
  late final GeneratedColumn<DateTime> toDate = GeneratedColumn<DateTime>(
    'to_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _departmentIdMeta = const VerificationMeta(
    'departmentId',
  );
  @override
  late final GeneratedColumn<int> departmentId = GeneratedColumn<int>(
    'department_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    exportType,
    exportPassword,
    fromDate,
    toDate,
    departmentId,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_password_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExportPasswordHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('export_type')) {
      context.handle(
        _exportTypeMeta,
        exportType.isAcceptableOrUnknown(data['export_type']!, _exportTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_exportTypeMeta);
    }
    if (data.containsKey('export_password')) {
      context.handle(
        _exportPasswordMeta,
        exportPassword.isAcceptableOrUnknown(
          data['export_password']!,
          _exportPasswordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exportPasswordMeta);
    }
    if (data.containsKey('from_date')) {
      context.handle(
        _fromDateMeta,
        fromDate.isAcceptableOrUnknown(data['from_date']!, _fromDateMeta),
      );
    } else if (isInserting) {
      context.missing(_fromDateMeta);
    }
    if (data.containsKey('to_date')) {
      context.handle(
        _toDateMeta,
        toDate.isAcceptableOrUnknown(data['to_date']!, _toDateMeta),
      );
    }
    if (data.containsKey('department_id')) {
      context.handle(
        _departmentIdMeta,
        departmentId.isAcceptableOrUnknown(
          data['department_id']!,
          _departmentIdMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExportPasswordHistoryData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportPasswordHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      exportType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}export_type'],
      )!,
      exportPassword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}export_password'],
      )!,
      fromDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}from_date'],
      )!,
      toDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}to_date'],
      ),
      departmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}department_id'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
    );
  }

  @override
  $ExportPasswordHistoryTable createAlias(String alias) {
    return $ExportPasswordHistoryTable(attachedDatabase, alias);
  }
}

class ExportPasswordHistoryData extends DataClass
    implements Insertable<ExportPasswordHistoryData> {
  final int id;
  final int userId;
  final String exportType;
  final String exportPassword;
  final DateTime fromDate;
  final DateTime? toDate;
  final int? departmentId;
  final DateTime downloadedAt;
  const ExportPasswordHistoryData({
    required this.id,
    required this.userId,
    required this.exportType,
    required this.exportPassword,
    required this.fromDate,
    this.toDate,
    this.departmentId,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['export_type'] = Variable<String>(exportType);
    map['export_password'] = Variable<String>(exportPassword);
    map['from_date'] = Variable<DateTime>(fromDate);
    if (!nullToAbsent || toDate != null) {
      map['to_date'] = Variable<DateTime>(toDate);
    }
    if (!nullToAbsent || departmentId != null) {
      map['department_id'] = Variable<int>(departmentId);
    }
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  ExportPasswordHistoryCompanion toCompanion(bool nullToAbsent) {
    return ExportPasswordHistoryCompanion(
      id: Value(id),
      userId: Value(userId),
      exportType: Value(exportType),
      exportPassword: Value(exportPassword),
      fromDate: Value(fromDate),
      toDate: toDate == null && nullToAbsent
          ? const Value.absent()
          : Value(toDate),
      departmentId: departmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(departmentId),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory ExportPasswordHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportPasswordHistoryData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      exportType: serializer.fromJson<String>(json['exportType']),
      exportPassword: serializer.fromJson<String>(json['exportPassword']),
      fromDate: serializer.fromJson<DateTime>(json['fromDate']),
      toDate: serializer.fromJson<DateTime?>(json['toDate']),
      departmentId: serializer.fromJson<int?>(json['departmentId']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'exportType': serializer.toJson<String>(exportType),
      'exportPassword': serializer.toJson<String>(exportPassword),
      'fromDate': serializer.toJson<DateTime>(fromDate),
      'toDate': serializer.toJson<DateTime?>(toDate),
      'departmentId': serializer.toJson<int?>(departmentId),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  ExportPasswordHistoryData copyWith({
    int? id,
    int? userId,
    String? exportType,
    String? exportPassword,
    DateTime? fromDate,
    Value<DateTime?> toDate = const Value.absent(),
    Value<int?> departmentId = const Value.absent(),
    DateTime? downloadedAt,
  }) => ExportPasswordHistoryData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    exportType: exportType ?? this.exportType,
    exportPassword: exportPassword ?? this.exportPassword,
    fromDate: fromDate ?? this.fromDate,
    toDate: toDate.present ? toDate.value : this.toDate,
    departmentId: departmentId.present ? departmentId.value : this.departmentId,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  ExportPasswordHistoryData copyWithCompanion(
    ExportPasswordHistoryCompanion data,
  ) {
    return ExportPasswordHistoryData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      exportType: data.exportType.present
          ? data.exportType.value
          : this.exportType,
      exportPassword: data.exportPassword.present
          ? data.exportPassword.value
          : this.exportPassword,
      fromDate: data.fromDate.present ? data.fromDate.value : this.fromDate,
      toDate: data.toDate.present ? data.toDate.value : this.toDate,
      departmentId: data.departmentId.present
          ? data.departmentId.value
          : this.departmentId,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportPasswordHistoryData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('exportType: $exportType, ')
          ..write('exportPassword: $exportPassword, ')
          ..write('fromDate: $fromDate, ')
          ..write('toDate: $toDate, ')
          ..write('departmentId: $departmentId, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    exportType,
    exportPassword,
    fromDate,
    toDate,
    departmentId,
    downloadedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportPasswordHistoryData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.exportType == this.exportType &&
          other.exportPassword == this.exportPassword &&
          other.fromDate == this.fromDate &&
          other.toDate == this.toDate &&
          other.departmentId == this.departmentId &&
          other.downloadedAt == this.downloadedAt);
}

class ExportPasswordHistoryCompanion
    extends UpdateCompanion<ExportPasswordHistoryData> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> exportType;
  final Value<String> exportPassword;
  final Value<DateTime> fromDate;
  final Value<DateTime?> toDate;
  final Value<int?> departmentId;
  final Value<DateTime> downloadedAt;
  const ExportPasswordHistoryCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.exportType = const Value.absent(),
    this.exportPassword = const Value.absent(),
    this.fromDate = const Value.absent(),
    this.toDate = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  });
  ExportPasswordHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String exportType,
    required String exportPassword,
    required DateTime fromDate,
    this.toDate = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  }) : userId = Value(userId),
       exportType = Value(exportType),
       exportPassword = Value(exportPassword),
       fromDate = Value(fromDate);
  static Insertable<ExportPasswordHistoryData> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? exportType,
    Expression<String>? exportPassword,
    Expression<DateTime>? fromDate,
    Expression<DateTime>? toDate,
    Expression<int>? departmentId,
    Expression<DateTime>? downloadedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (exportType != null) 'export_type': exportType,
      if (exportPassword != null) 'export_password': exportPassword,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
      if (departmentId != null) 'department_id': departmentId,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
    });
  }

  ExportPasswordHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? exportType,
    Value<String>? exportPassword,
    Value<DateTime>? fromDate,
    Value<DateTime?>? toDate,
    Value<int?>? departmentId,
    Value<DateTime>? downloadedAt,
  }) {
    return ExportPasswordHistoryCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exportType: exportType ?? this.exportType,
      exportPassword: exportPassword ?? this.exportPassword,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      departmentId: departmentId ?? this.departmentId,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (exportType.present) {
      map['export_type'] = Variable<String>(exportType.value);
    }
    if (exportPassword.present) {
      map['export_password'] = Variable<String>(exportPassword.value);
    }
    if (fromDate.present) {
      map['from_date'] = Variable<DateTime>(fromDate.value);
    }
    if (toDate.present) {
      map['to_date'] = Variable<DateTime>(toDate.value);
    }
    if (departmentId.present) {
      map['department_id'] = Variable<int>(departmentId.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportPasswordHistoryCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('exportType: $exportType, ')
          ..write('exportPassword: $exportPassword, ')
          ..write('fromDate: $fromDate, ')
          ..write('toDate: $toDate, ')
          ..write('departmentId: $departmentId, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<int> recordId = GeneratedColumn<int>(
    'record_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oldValueMeta = const VerificationMeta(
    'oldValue',
  );
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
    'old_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
    'new_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    action,
    entityTable,
    recordId,
    oldValue,
    newValue,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    }
    if (data.containsKey('old_value')) {
      context.handle(
        _oldValueMeta,
        oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}record_id'],
      ),
      oldValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_value'],
      ),
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_value'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final int id;
  final int userId;
  final String action;
  final String entityTable;
  final int? recordId;
  final String? oldValue;
  final String? newValue;
  final DateTime createdAt;
  const AuditLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.entityTable,
    this.recordId,
    this.oldValue,
    this.newValue,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['action'] = Variable<String>(action);
    map['entity_table'] = Variable<String>(entityTable);
    if (!nullToAbsent || recordId != null) {
      map['record_id'] = Variable<int>(recordId);
    }
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      action: Value(action),
      entityTable: Value(entityTable),
      recordId: recordId == null && nullToAbsent
          ? const Value.absent()
          : Value(recordId),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      createdAt: Value(createdAt),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      action: serializer.fromJson<String>(json['action']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      recordId: serializer.fromJson<int?>(json['recordId']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'action': serializer.toJson<String>(action),
      'entityTable': serializer.toJson<String>(entityTable),
      'recordId': serializer.toJson<int?>(recordId),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String?>(newValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AuditLog copyWith({
    int? id,
    int? userId,
    String? action,
    String? entityTable,
    Value<int?> recordId = const Value.absent(),
    Value<String?> oldValue = const Value.absent(),
    Value<String?> newValue = const Value.absent(),
    DateTime? createdAt,
  }) => AuditLog(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    action: action ?? this.action,
    entityTable: entityTable ?? this.entityTable,
    recordId: recordId.present ? recordId.value : this.recordId,
    oldValue: oldValue.present ? oldValue.value : this.oldValue,
    newValue: newValue.present ? newValue.value : this.newValue,
    createdAt: createdAt ?? this.createdAt,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      action: data.action.present ? data.action.value : this.action,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entityTable: $entityTable, ')
          ..write('recordId: $recordId, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    action,
    entityTable,
    recordId,
    oldValue,
    newValue,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.action == this.action &&
          other.entityTable == this.entityTable &&
          other.recordId == this.recordId &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.createdAt == this.createdAt);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> action;
  final Value<String> entityTable;
  final Value<int?> recordId;
  final Value<String?> oldValue;
  final Value<String?> newValue;
  final Value<DateTime> createdAt;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.action = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String action,
    required String entityTable,
    this.recordId = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : userId = Value(userId),
       action = Value(action),
       entityTable = Value(entityTable);
  static Insertable<AuditLog> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? action,
    Expression<String>? entityTable,
    Expression<int>? recordId,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (action != null) 'action': action,
      if (entityTable != null) 'entity_table': entityTable,
      if (recordId != null) 'record_id': recordId,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AuditLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? action,
    Value<String>? entityTable,
    Value<int?>? recordId,
    Value<String?>? oldValue,
    Value<String?>? newValue,
    Value<DateTime>? createdAt,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      entityTable: entityTable ?? this.entityTable,
      recordId: recordId ?? this.recordId,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<int>(recordId.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entityTable: $entityTable, ')
          ..write('recordId: $recordId, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FinancialYearsTable extends FinancialYears
    with TableInfo<$FinancialYearsTable, FinancialYear> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialYearsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _yearLabelMeta = const VerificationMeta(
    'yearLabel',
  );
  @override
  late final GeneratedColumn<String> yearLabel = GeneratedColumn<String>(
    'year_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, yearLabel, startDate, endDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_years';
  @override
  VerificationContext validateIntegrity(
    Insertable<FinancialYear> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('year_label')) {
      context.handle(
        _yearLabelMeta,
        yearLabel.isAcceptableOrUnknown(data['year_label']!, _yearLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_yearLabelMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FinancialYear map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialYear(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      yearLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year_label'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
    );
  }

  @override
  $FinancialYearsTable createAlias(String alias) {
    return $FinancialYearsTable(attachedDatabase, alias);
  }
}

class FinancialYear extends DataClass implements Insertable<FinancialYear> {
  final int id;
  final String yearLabel;
  final DateTime startDate;
  final DateTime endDate;
  const FinancialYear({
    required this.id,
    required this.yearLabel,
    required this.startDate,
    required this.endDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['year_label'] = Variable<String>(yearLabel);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    return map;
  }

  FinancialYearsCompanion toCompanion(bool nullToAbsent) {
    return FinancialYearsCompanion(
      id: Value(id),
      yearLabel: Value(yearLabel),
      startDate: Value(startDate),
      endDate: Value(endDate),
    );
  }

  factory FinancialYear.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancialYear(
      id: serializer.fromJson<int>(json['id']),
      yearLabel: serializer.fromJson<String>(json['yearLabel']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'yearLabel': serializer.toJson<String>(yearLabel),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
    };
  }

  FinancialYear copyWith({
    int? id,
    String? yearLabel,
    DateTime? startDate,
    DateTime? endDate,
  }) => FinancialYear(
    id: id ?? this.id,
    yearLabel: yearLabel ?? this.yearLabel,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
  );
  FinancialYear copyWithCompanion(FinancialYearsCompanion data) {
    return FinancialYear(
      id: data.id.present ? data.id.value : this.id,
      yearLabel: data.yearLabel.present ? data.yearLabel.value : this.yearLabel,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialYear(')
          ..write('id: $id, ')
          ..write('yearLabel: $yearLabel, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, yearLabel, startDate, endDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialYear &&
          other.id == this.id &&
          other.yearLabel == this.yearLabel &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate);
}

class FinancialYearsCompanion extends UpdateCompanion<FinancialYear> {
  final Value<int> id;
  final Value<String> yearLabel;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  const FinancialYearsCompanion({
    this.id = const Value.absent(),
    this.yearLabel = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
  });
  FinancialYearsCompanion.insert({
    this.id = const Value.absent(),
    required String yearLabel,
    required DateTime startDate,
    required DateTime endDate,
  }) : yearLabel = Value(yearLabel),
       startDate = Value(startDate),
       endDate = Value(endDate);
  static Insertable<FinancialYear> custom({
    Expression<int>? id,
    Expression<String>? yearLabel,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (yearLabel != null) 'year_label': yearLabel,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
  }

  FinancialYearsCompanion copyWith({
    Value<int>? id,
    Value<String>? yearLabel,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
  }) {
    return FinancialYearsCompanion(
      id: id ?? this.id,
      yearLabel: yearLabel ?? this.yearLabel,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (yearLabel.present) {
      map['year_label'] = Variable<String>(yearLabel.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinancialYearsCompanion(')
          ..write('id: $id, ')
          ..write('yearLabel: $yearLabel, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RolesTable roles = $RolesTable(this);
  late final $PermissionsTable permissions = $PermissionsTable(this);
  late final $RolePermissionsTable rolePermissions = $RolePermissionsTable(
    this,
  );
  late final $UserPermissionOverridesTable userPermissionOverrides =
      $UserPermissionOverridesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $DepartmentsTable departments = $DepartmentsTable(this);
  late final $UserDepartmentsTable userDepartments = $UserDepartmentsTable(
    this,
  );
  late final $MainTitlesTable mainTitles = $MainTitlesTable(this);
  late final $TitleGroupsTable titleGroups = $TitleGroupsTable(this);
  late final $TitlesTable titles = $TitlesTable(this);
  late final $SubTitleGroupsTable subTitleGroups = $SubTitleGroupsTable(this);
  late final $SubTitlesTable subTitles = $SubTitlesTable(this);
  late final $BalanceEntriesTable balanceEntries = $BalanceEntriesTable(this);
  late final $DayBooksTable dayBooks = $DayBooksTable(this);
  late final $ClosingBalanceChecksTable closingBalanceChecks =
      $ClosingBalanceChecksTable(this);
  late final $ExportPasswordHistoryTable exportPasswordHistory =
      $ExportPasswordHistoryTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $FinancialYearsTable financialYears = $FinancialYearsTable(this);
  late final Index idxBalanceEntriesDeptDate = Index(
    'idx_balance_entries_dept_date',
    'CREATE INDEX idx_balance_entries_dept_date ON balance_entries (department_id, entry_date)',
  );
  late final RbacDao rbacDao = RbacDao(this as AppDatabase);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final DepartmentDao departmentDao = DepartmentDao(this as AppDatabase);
  late final ChartOfAccountsDao chartOfAccountsDao = ChartOfAccountsDao(
    this as AppDatabase,
  );
  late final TransactionDao transactionDao = TransactionDao(
    this as AppDatabase,
  );
  late final DayBookDao dayBookDao = DayBookDao(this as AppDatabase);
  late final ExportDao exportDao = ExportDao(this as AppDatabase);
  late final AuditDao auditDao = AuditDao(this as AppDatabase);
  late final FinancialYearDao financialYearDao = FinancialYearDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    roles,
    permissions,
    rolePermissions,
    userPermissionOverrides,
    users,
    departments,
    userDepartments,
    mainTitles,
    titleGroups,
    titles,
    subTitleGroups,
    subTitles,
    balanceEntries,
    dayBooks,
    closingBalanceChecks,
    exportPasswordHistory,
    auditLogs,
    financialYears,
    idxBalanceEntriesDeptDate,
  ];
}

typedef $$RolesTableCreateCompanionBuilder =
    RolesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<bool> isSystemRole,
    });
typedef $$RolesTableUpdateCompanionBuilder =
    RolesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<bool> isSystemRole,
    });

class $$RolesTableFilterComposer extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystemRole => $composableBuilder(
    column: $table.isSystemRole,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RolesTableOrderingComposer
    extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystemRole => $composableBuilder(
    column: $table.isSystemRole,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RolesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSystemRole => $composableBuilder(
    column: $table.isSystemRole,
    builder: (column) => column,
  );
}

class $$RolesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RolesTable,
          Role,
          $$RolesTableFilterComposer,
          $$RolesTableOrderingComposer,
          $$RolesTableAnnotationComposer,
          $$RolesTableCreateCompanionBuilder,
          $$RolesTableUpdateCompanionBuilder,
          (Role, BaseReferences<_$AppDatabase, $RolesTable, Role>),
          Role,
          PrefetchHooks Function()
        > {
  $$RolesTableTableManager(_$AppDatabase db, $RolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isSystemRole = const Value.absent(),
              }) => RolesCompanion(
                id: id,
                name: name,
                description: description,
                isSystemRole: isSystemRole,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<bool> isSystemRole = const Value.absent(),
              }) => RolesCompanion.insert(
                id: id,
                name: name,
                description: description,
                isSystemRole: isSystemRole,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RolesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RolesTable,
      Role,
      $$RolesTableFilterComposer,
      $$RolesTableOrderingComposer,
      $$RolesTableAnnotationComposer,
      $$RolesTableCreateCompanionBuilder,
      $$RolesTableUpdateCompanionBuilder,
      (Role, BaseReferences<_$AppDatabase, $RolesTable, Role>),
      Role,
      PrefetchHooks Function()
    >;
typedef $$PermissionsTableCreateCompanionBuilder =
    PermissionsCompanion Function({
      Value<int> id,
      required String code,
      required String module,
      required String action,
      Value<String?> description,
    });
typedef $$PermissionsTableUpdateCompanionBuilder =
    PermissionsCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> module,
      Value<String> action,
      Value<String?> description,
    });

class $$PermissionsTableFilterComposer
    extends Composer<_$AppDatabase, $PermissionsTable> {
  $$PermissionsTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get module => $composableBuilder(
    column: $table.module,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PermissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PermissionsTable> {
  $$PermissionsTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get module => $composableBuilder(
    column: $table.module,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PermissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PermissionsTable> {
  $$PermissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get module =>
      $composableBuilder(column: $table.module, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$PermissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PermissionsTable,
          Permission,
          $$PermissionsTableFilterComposer,
          $$PermissionsTableOrderingComposer,
          $$PermissionsTableAnnotationComposer,
          $$PermissionsTableCreateCompanionBuilder,
          $$PermissionsTableUpdateCompanionBuilder,
          (
            Permission,
            BaseReferences<_$AppDatabase, $PermissionsTable, Permission>,
          ),
          Permission,
          PrefetchHooks Function()
        > {
  $$PermissionsTableTableManager(_$AppDatabase db, $PermissionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PermissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PermissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PermissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> module = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> description = const Value.absent(),
              }) => PermissionsCompanion(
                id: id,
                code: code,
                module: module,
                action: action,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required String module,
                required String action,
                Value<String?> description = const Value.absent(),
              }) => PermissionsCompanion.insert(
                id: id,
                code: code,
                module: module,
                action: action,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PermissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PermissionsTable,
      Permission,
      $$PermissionsTableFilterComposer,
      $$PermissionsTableOrderingComposer,
      $$PermissionsTableAnnotationComposer,
      $$PermissionsTableCreateCompanionBuilder,
      $$PermissionsTableUpdateCompanionBuilder,
      (
        Permission,
        BaseReferences<_$AppDatabase, $PermissionsTable, Permission>,
      ),
      Permission,
      PrefetchHooks Function()
    >;
typedef $$RolePermissionsTableCreateCompanionBuilder =
    RolePermissionsCompanion Function({
      required int roleId,
      required int permissionId,
      Value<int> rowid,
    });
typedef $$RolePermissionsTableUpdateCompanionBuilder =
    RolePermissionsCompanion Function({
      Value<int> roleId,
      Value<int> permissionId,
      Value<int> rowid,
    });

class $$RolePermissionsTableFilterComposer
    extends Composer<_$AppDatabase, $RolePermissionsTable> {
  $$RolePermissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get roleId => $composableBuilder(
    column: $table.roleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get permissionId => $composableBuilder(
    column: $table.permissionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RolePermissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RolePermissionsTable> {
  $$RolePermissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get roleId => $composableBuilder(
    column: $table.roleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get permissionId => $composableBuilder(
    column: $table.permissionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RolePermissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RolePermissionsTable> {
  $$RolePermissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get roleId =>
      $composableBuilder(column: $table.roleId, builder: (column) => column);

  GeneratedColumn<int> get permissionId => $composableBuilder(
    column: $table.permissionId,
    builder: (column) => column,
  );
}

class $$RolePermissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RolePermissionsTable,
          RolePermission,
          $$RolePermissionsTableFilterComposer,
          $$RolePermissionsTableOrderingComposer,
          $$RolePermissionsTableAnnotationComposer,
          $$RolePermissionsTableCreateCompanionBuilder,
          $$RolePermissionsTableUpdateCompanionBuilder,
          (
            RolePermission,
            BaseReferences<
              _$AppDatabase,
              $RolePermissionsTable,
              RolePermission
            >,
          ),
          RolePermission,
          PrefetchHooks Function()
        > {
  $$RolePermissionsTableTableManager(
    _$AppDatabase db,
    $RolePermissionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RolePermissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RolePermissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RolePermissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> roleId = const Value.absent(),
                Value<int> permissionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RolePermissionsCompanion(
                roleId: roleId,
                permissionId: permissionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int roleId,
                required int permissionId,
                Value<int> rowid = const Value.absent(),
              }) => RolePermissionsCompanion.insert(
                roleId: roleId,
                permissionId: permissionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RolePermissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RolePermissionsTable,
      RolePermission,
      $$RolePermissionsTableFilterComposer,
      $$RolePermissionsTableOrderingComposer,
      $$RolePermissionsTableAnnotationComposer,
      $$RolePermissionsTableCreateCompanionBuilder,
      $$RolePermissionsTableUpdateCompanionBuilder,
      (
        RolePermission,
        BaseReferences<_$AppDatabase, $RolePermissionsTable, RolePermission>,
      ),
      RolePermission,
      PrefetchHooks Function()
    >;
typedef $$UserPermissionOverridesTableCreateCompanionBuilder =
    UserPermissionOverridesCompanion Function({
      Value<int> id,
      required int userId,
      required int permissionId,
      required bool allow,
    });
typedef $$UserPermissionOverridesTableUpdateCompanionBuilder =
    UserPermissionOverridesCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<int> permissionId,
      Value<bool> allow,
    });

class $$UserPermissionOverridesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPermissionOverridesTable> {
  $$UserPermissionOverridesTableFilterComposer({
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

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get permissionId => $composableBuilder(
    column: $table.permissionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allow => $composableBuilder(
    column: $table.allow,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPermissionOverridesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPermissionOverridesTable> {
  $$UserPermissionOverridesTableOrderingComposer({
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

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get permissionId => $composableBuilder(
    column: $table.permissionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allow => $composableBuilder(
    column: $table.allow,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPermissionOverridesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPermissionOverridesTable> {
  $$UserPermissionOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get permissionId => $composableBuilder(
    column: $table.permissionId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allow =>
      $composableBuilder(column: $table.allow, builder: (column) => column);
}

class $$UserPermissionOverridesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPermissionOverridesTable,
          UserPermissionOverride,
          $$UserPermissionOverridesTableFilterComposer,
          $$UserPermissionOverridesTableOrderingComposer,
          $$UserPermissionOverridesTableAnnotationComposer,
          $$UserPermissionOverridesTableCreateCompanionBuilder,
          $$UserPermissionOverridesTableUpdateCompanionBuilder,
          (
            UserPermissionOverride,
            BaseReferences<
              _$AppDatabase,
              $UserPermissionOverridesTable,
              UserPermissionOverride
            >,
          ),
          UserPermissionOverride,
          PrefetchHooks Function()
        > {
  $$UserPermissionOverridesTableTableManager(
    _$AppDatabase db,
    $UserPermissionOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPermissionOverridesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UserPermissionOverridesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserPermissionOverridesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> permissionId = const Value.absent(),
                Value<bool> allow = const Value.absent(),
              }) => UserPermissionOverridesCompanion(
                id: id,
                userId: userId,
                permissionId: permissionId,
                allow: allow,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required int permissionId,
                required bool allow,
              }) => UserPermissionOverridesCompanion.insert(
                id: id,
                userId: userId,
                permissionId: permissionId,
                allow: allow,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPermissionOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPermissionOverridesTable,
      UserPermissionOverride,
      $$UserPermissionOverridesTableFilterComposer,
      $$UserPermissionOverridesTableOrderingComposer,
      $$UserPermissionOverridesTableAnnotationComposer,
      $$UserPermissionOverridesTableCreateCompanionBuilder,
      $$UserPermissionOverridesTableUpdateCompanionBuilder,
      (
        UserPermissionOverride,
        BaseReferences<
          _$AppDatabase,
          $UserPermissionOverridesTable,
          UserPermissionOverride
        >,
      ),
      UserPermissionOverride,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String username,
      required String password,
      required String fullName,
      required int roleId,
      Value<bool> isActive,
      Value<DateTime?> lastLoginAt,
      Value<DateTime> createdAt,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<String> password,
      Value<String> fullName,
      Value<int> roleId,
      Value<bool> isActive,
      Value<DateTime?> lastLoginAt,
      Value<DateTime> createdAt,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
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

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roleId => $composableBuilder(
    column: $table.roleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
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

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roleId => $composableBuilder(
    column: $table.roleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<int> get roleId =>
      $composableBuilder(column: $table.roleId, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<int> roleId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                username: username,
                password: password,
                fullName: fullName,
                roleId: roleId,
                isActive: isActive,
                lastLoginAt: lastLoginAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                required String password,
                required String fullName,
                required int roleId,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                username: username,
                password: password,
                fullName: fullName,
                roleId: roleId,
                isActive: isActive,
                lastLoginAt: lastLoginAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$DepartmentsTableCreateCompanionBuilder =
    DepartmentsCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });
typedef $$DepartmentsTableUpdateCompanionBuilder =
    DepartmentsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

class $$DepartmentsTableFilterComposer
    extends Composer<_$AppDatabase, $DepartmentsTable> {
  $$DepartmentsTableFilterComposer({
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

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DepartmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DepartmentsTable> {
  $$DepartmentsTableOrderingComposer({
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

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DepartmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DepartmentsTable> {
  $$DepartmentsTableAnnotationComposer({
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

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DepartmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DepartmentsTable,
          Department,
          $$DepartmentsTableFilterComposer,
          $$DepartmentsTableOrderingComposer,
          $$DepartmentsTableAnnotationComposer,
          $$DepartmentsTableCreateCompanionBuilder,
          $$DepartmentsTableUpdateCompanionBuilder,
          (
            Department,
            BaseReferences<_$AppDatabase, $DepartmentsTable, Department>,
          ),
          Department,
          PrefetchHooks Function()
        > {
  $$DepartmentsTableTableManager(_$AppDatabase db, $DepartmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DepartmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DepartmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DepartmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DepartmentsCompanion(
                id: id,
                name: name,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DepartmentsCompanion.insert(
                id: id,
                name: name,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DepartmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DepartmentsTable,
      Department,
      $$DepartmentsTableFilterComposer,
      $$DepartmentsTableOrderingComposer,
      $$DepartmentsTableAnnotationComposer,
      $$DepartmentsTableCreateCompanionBuilder,
      $$DepartmentsTableUpdateCompanionBuilder,
      (
        Department,
        BaseReferences<_$AppDatabase, $DepartmentsTable, Department>,
      ),
      Department,
      PrefetchHooks Function()
    >;
typedef $$UserDepartmentsTableCreateCompanionBuilder =
    UserDepartmentsCompanion Function({
      Value<int> id,
      required int userId,
      required int departmentId,
    });
typedef $$UserDepartmentsTableUpdateCompanionBuilder =
    UserDepartmentsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<int> departmentId,
    });

class $$UserDepartmentsTableFilterComposer
    extends Composer<_$AppDatabase, $UserDepartmentsTable> {
  $$UserDepartmentsTableFilterComposer({
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

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserDepartmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserDepartmentsTable> {
  $$UserDepartmentsTableOrderingComposer({
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

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserDepartmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserDepartmentsTable> {
  $$UserDepartmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => column,
  );
}

class $$UserDepartmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserDepartmentsTable,
          UserDepartment,
          $$UserDepartmentsTableFilterComposer,
          $$UserDepartmentsTableOrderingComposer,
          $$UserDepartmentsTableAnnotationComposer,
          $$UserDepartmentsTableCreateCompanionBuilder,
          $$UserDepartmentsTableUpdateCompanionBuilder,
          (
            UserDepartment,
            BaseReferences<
              _$AppDatabase,
              $UserDepartmentsTable,
              UserDepartment
            >,
          ),
          UserDepartment,
          PrefetchHooks Function()
        > {
  $$UserDepartmentsTableTableManager(
    _$AppDatabase db,
    $UserDepartmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserDepartmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserDepartmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserDepartmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> departmentId = const Value.absent(),
              }) => UserDepartmentsCompanion(
                id: id,
                userId: userId,
                departmentId: departmentId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required int departmentId,
              }) => UserDepartmentsCompanion.insert(
                id: id,
                userId: userId,
                departmentId: departmentId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserDepartmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserDepartmentsTable,
      UserDepartment,
      $$UserDepartmentsTableFilterComposer,
      $$UserDepartmentsTableOrderingComposer,
      $$UserDepartmentsTableAnnotationComposer,
      $$UserDepartmentsTableCreateCompanionBuilder,
      $$UserDepartmentsTableUpdateCompanionBuilder,
      (
        UserDepartment,
        BaseReferences<_$AppDatabase, $UserDepartmentsTable, UserDepartment>,
      ),
      UserDepartment,
      PrefetchHooks Function()
    >;
typedef $$MainTitlesTableCreateCompanionBuilder =
    MainTitlesCompanion Function({Value<int> id, required String name});
typedef $$MainTitlesTableUpdateCompanionBuilder =
    MainTitlesCompanion Function({Value<int> id, Value<String> name});

class $$MainTitlesTableFilterComposer
    extends Composer<_$AppDatabase, $MainTitlesTable> {
  $$MainTitlesTableFilterComposer({
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
}

class $$MainTitlesTableOrderingComposer
    extends Composer<_$AppDatabase, $MainTitlesTable> {
  $$MainTitlesTableOrderingComposer({
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

class $$MainTitlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MainTitlesTable> {
  $$MainTitlesTableAnnotationComposer({
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
}

class $$MainTitlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MainTitlesTable,
          MainTitle,
          $$MainTitlesTableFilterComposer,
          $$MainTitlesTableOrderingComposer,
          $$MainTitlesTableAnnotationComposer,
          $$MainTitlesTableCreateCompanionBuilder,
          $$MainTitlesTableUpdateCompanionBuilder,
          (
            MainTitle,
            BaseReferences<_$AppDatabase, $MainTitlesTable, MainTitle>,
          ),
          MainTitle,
          PrefetchHooks Function()
        > {
  $$MainTitlesTableTableManager(_$AppDatabase db, $MainTitlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MainTitlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MainTitlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MainTitlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => MainTitlesCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  MainTitlesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MainTitlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MainTitlesTable,
      MainTitle,
      $$MainTitlesTableFilterComposer,
      $$MainTitlesTableOrderingComposer,
      $$MainTitlesTableAnnotationComposer,
      $$MainTitlesTableCreateCompanionBuilder,
      $$MainTitlesTableUpdateCompanionBuilder,
      (MainTitle, BaseReferences<_$AppDatabase, $MainTitlesTable, MainTitle>),
      MainTitle,
      PrefetchHooks Function()
    >;
typedef $$TitleGroupsTableCreateCompanionBuilder =
    TitleGroupsCompanion Function({
      Value<int> id,
      required int mainTitleId,
      required String titleName,
      Value<String?> vfNo,
    });
typedef $$TitleGroupsTableUpdateCompanionBuilder =
    TitleGroupsCompanion Function({
      Value<int> id,
      Value<int> mainTitleId,
      Value<String> titleName,
      Value<String?> vfNo,
    });

class $$TitleGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $TitleGroupsTable> {
  $$TitleGroupsTableFilterComposer({
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

  ColumnFilters<int> get mainTitleId => $composableBuilder(
    column: $table.mainTitleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleName => $composableBuilder(
    column: $table.titleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vfNo => $composableBuilder(
    column: $table.vfNo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TitleGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $TitleGroupsTable> {
  $$TitleGroupsTableOrderingComposer({
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

  ColumnOrderings<int> get mainTitleId => $composableBuilder(
    column: $table.mainTitleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleName => $composableBuilder(
    column: $table.titleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vfNo => $composableBuilder(
    column: $table.vfNo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TitleGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TitleGroupsTable> {
  $$TitleGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mainTitleId => $composableBuilder(
    column: $table.mainTitleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get titleName =>
      $composableBuilder(column: $table.titleName, builder: (column) => column);

  GeneratedColumn<String> get vfNo =>
      $composableBuilder(column: $table.vfNo, builder: (column) => column);
}

class $$TitleGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TitleGroupsTable,
          TitleGroup,
          $$TitleGroupsTableFilterComposer,
          $$TitleGroupsTableOrderingComposer,
          $$TitleGroupsTableAnnotationComposer,
          $$TitleGroupsTableCreateCompanionBuilder,
          $$TitleGroupsTableUpdateCompanionBuilder,
          (
            TitleGroup,
            BaseReferences<_$AppDatabase, $TitleGroupsTable, TitleGroup>,
          ),
          TitleGroup,
          PrefetchHooks Function()
        > {
  $$TitleGroupsTableTableManager(_$AppDatabase db, $TitleGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TitleGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TitleGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TitleGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> mainTitleId = const Value.absent(),
                Value<String> titleName = const Value.absent(),
                Value<String?> vfNo = const Value.absent(),
              }) => TitleGroupsCompanion(
                id: id,
                mainTitleId: mainTitleId,
                titleName: titleName,
                vfNo: vfNo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int mainTitleId,
                required String titleName,
                Value<String?> vfNo = const Value.absent(),
              }) => TitleGroupsCompanion.insert(
                id: id,
                mainTitleId: mainTitleId,
                titleName: titleName,
                vfNo: vfNo,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TitleGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TitleGroupsTable,
      TitleGroup,
      $$TitleGroupsTableFilterComposer,
      $$TitleGroupsTableOrderingComposer,
      $$TitleGroupsTableAnnotationComposer,
      $$TitleGroupsTableCreateCompanionBuilder,
      $$TitleGroupsTableUpdateCompanionBuilder,
      (
        TitleGroup,
        BaseReferences<_$AppDatabase, $TitleGroupsTable, TitleGroup>,
      ),
      TitleGroup,
      PrefetchHooks Function()
    >;
typedef $$TitlesTableCreateCompanionBuilder =
    TitlesCompanion Function({
      Value<int> id,
      required int mainTitleId,
      required int departmentId,
      Value<int?> titleGroupId,
      required String titleName,
      Value<String?> vfNo,
      required int createdBy,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });
typedef $$TitlesTableUpdateCompanionBuilder =
    TitlesCompanion Function({
      Value<int> id,
      Value<int> mainTitleId,
      Value<int> departmentId,
      Value<int?> titleGroupId,
      Value<String> titleName,
      Value<String?> vfNo,
      Value<int> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });

class $$TitlesTableFilterComposer
    extends Composer<_$AppDatabase, $TitlesTable> {
  $$TitlesTableFilterComposer({
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

  ColumnFilters<int> get mainTitleId => $composableBuilder(
    column: $table.mainTitleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get titleGroupId => $composableBuilder(
    column: $table.titleGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleName => $composableBuilder(
    column: $table.titleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vfNo => $composableBuilder(
    column: $table.vfNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdBy => $composableBuilder(
    column: $table.createdBy,
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
}

class $$TitlesTableOrderingComposer
    extends Composer<_$AppDatabase, $TitlesTable> {
  $$TitlesTableOrderingComposer({
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

  ColumnOrderings<int> get mainTitleId => $composableBuilder(
    column: $table.mainTitleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get titleGroupId => $composableBuilder(
    column: $table.titleGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleName => $composableBuilder(
    column: $table.titleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vfNo => $composableBuilder(
    column: $table.vfNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdBy => $composableBuilder(
    column: $table.createdBy,
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

class $$TitlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TitlesTable> {
  $$TitlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mainTitleId => $composableBuilder(
    column: $table.mainTitleId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get titleGroupId => $composableBuilder(
    column: $table.titleGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get titleName =>
      $composableBuilder(column: $table.titleName, builder: (column) => column);

  GeneratedColumn<String> get vfNo =>
      $composableBuilder(column: $table.vfNo, builder: (column) => column);

  GeneratedColumn<int> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TitlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TitlesTable,
          Title,
          $$TitlesTableFilterComposer,
          $$TitlesTableOrderingComposer,
          $$TitlesTableAnnotationComposer,
          $$TitlesTableCreateCompanionBuilder,
          $$TitlesTableUpdateCompanionBuilder,
          (Title, BaseReferences<_$AppDatabase, $TitlesTable, Title>),
          Title,
          PrefetchHooks Function()
        > {
  $$TitlesTableTableManager(_$AppDatabase db, $TitlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TitlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TitlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TitlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> mainTitleId = const Value.absent(),
                Value<int> departmentId = const Value.absent(),
                Value<int?> titleGroupId = const Value.absent(),
                Value<String> titleName = const Value.absent(),
                Value<String?> vfNo = const Value.absent(),
                Value<int> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => TitlesCompanion(
                id: id,
                mainTitleId: mainTitleId,
                departmentId: departmentId,
                titleGroupId: titleGroupId,
                titleName: titleName,
                vfNo: vfNo,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int mainTitleId,
                required int departmentId,
                Value<int?> titleGroupId = const Value.absent(),
                required String titleName,
                Value<String?> vfNo = const Value.absent(),
                required int createdBy,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => TitlesCompanion.insert(
                id: id,
                mainTitleId: mainTitleId,
                departmentId: departmentId,
                titleGroupId: titleGroupId,
                titleName: titleName,
                vfNo: vfNo,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TitlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TitlesTable,
      Title,
      $$TitlesTableFilterComposer,
      $$TitlesTableOrderingComposer,
      $$TitlesTableAnnotationComposer,
      $$TitlesTableCreateCompanionBuilder,
      $$TitlesTableUpdateCompanionBuilder,
      (Title, BaseReferences<_$AppDatabase, $TitlesTable, Title>),
      Title,
      PrefetchHooks Function()
    >;
typedef $$SubTitleGroupsTableCreateCompanionBuilder =
    SubTitleGroupsCompanion Function({
      Value<int> id,
      required int titleGroupId,
      required String subTitleName,
    });
typedef $$SubTitleGroupsTableUpdateCompanionBuilder =
    SubTitleGroupsCompanion Function({
      Value<int> id,
      Value<int> titleGroupId,
      Value<String> subTitleName,
    });

class $$SubTitleGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $SubTitleGroupsTable> {
  $$SubTitleGroupsTableFilterComposer({
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

  ColumnFilters<int> get titleGroupId => $composableBuilder(
    column: $table.titleGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subTitleName => $composableBuilder(
    column: $table.subTitleName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubTitleGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubTitleGroupsTable> {
  $$SubTitleGroupsTableOrderingComposer({
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

  ColumnOrderings<int> get titleGroupId => $composableBuilder(
    column: $table.titleGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subTitleName => $composableBuilder(
    column: $table.subTitleName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubTitleGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubTitleGroupsTable> {
  $$SubTitleGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get titleGroupId => $composableBuilder(
    column: $table.titleGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subTitleName => $composableBuilder(
    column: $table.subTitleName,
    builder: (column) => column,
  );
}

class $$SubTitleGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubTitleGroupsTable,
          SubTitleGroup,
          $$SubTitleGroupsTableFilterComposer,
          $$SubTitleGroupsTableOrderingComposer,
          $$SubTitleGroupsTableAnnotationComposer,
          $$SubTitleGroupsTableCreateCompanionBuilder,
          $$SubTitleGroupsTableUpdateCompanionBuilder,
          (
            SubTitleGroup,
            BaseReferences<_$AppDatabase, $SubTitleGroupsTable, SubTitleGroup>,
          ),
          SubTitleGroup,
          PrefetchHooks Function()
        > {
  $$SubTitleGroupsTableTableManager(
    _$AppDatabase db,
    $SubTitleGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubTitleGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubTitleGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubTitleGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> titleGroupId = const Value.absent(),
                Value<String> subTitleName = const Value.absent(),
              }) => SubTitleGroupsCompanion(
                id: id,
                titleGroupId: titleGroupId,
                subTitleName: subTitleName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int titleGroupId,
                required String subTitleName,
              }) => SubTitleGroupsCompanion.insert(
                id: id,
                titleGroupId: titleGroupId,
                subTitleName: subTitleName,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubTitleGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubTitleGroupsTable,
      SubTitleGroup,
      $$SubTitleGroupsTableFilterComposer,
      $$SubTitleGroupsTableOrderingComposer,
      $$SubTitleGroupsTableAnnotationComposer,
      $$SubTitleGroupsTableCreateCompanionBuilder,
      $$SubTitleGroupsTableUpdateCompanionBuilder,
      (
        SubTitleGroup,
        BaseReferences<_$AppDatabase, $SubTitleGroupsTable, SubTitleGroup>,
      ),
      SubTitleGroup,
      PrefetchHooks Function()
    >;
typedef $$SubTitlesTableCreateCompanionBuilder =
    SubTitlesCompanion Function({
      Value<int> id,
      required int titleId,
      Value<int?> subTitleGroupId,
      required String subTitleName,
      Value<double> openingBalance,
      required int createdBy,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });
typedef $$SubTitlesTableUpdateCompanionBuilder =
    SubTitlesCompanion Function({
      Value<int> id,
      Value<int> titleId,
      Value<int?> subTitleGroupId,
      Value<String> subTitleName,
      Value<double> openingBalance,
      Value<int> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });

class $$SubTitlesTableFilterComposer
    extends Composer<_$AppDatabase, $SubTitlesTable> {
  $$SubTitlesTableFilterComposer({
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

  ColumnFilters<int> get titleId => $composableBuilder(
    column: $table.titleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subTitleGroupId => $composableBuilder(
    column: $table.subTitleGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subTitleName => $composableBuilder(
    column: $table.subTitleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdBy => $composableBuilder(
    column: $table.createdBy,
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
}

class $$SubTitlesTableOrderingComposer
    extends Composer<_$AppDatabase, $SubTitlesTable> {
  $$SubTitlesTableOrderingComposer({
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

  ColumnOrderings<int> get titleId => $composableBuilder(
    column: $table.titleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subTitleGroupId => $composableBuilder(
    column: $table.subTitleGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subTitleName => $composableBuilder(
    column: $table.subTitleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdBy => $composableBuilder(
    column: $table.createdBy,
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

class $$SubTitlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubTitlesTable> {
  $$SubTitlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get titleId =>
      $composableBuilder(column: $table.titleId, builder: (column) => column);

  GeneratedColumn<int> get subTitleGroupId => $composableBuilder(
    column: $table.subTitleGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subTitleName => $composableBuilder(
    column: $table.subTitleName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SubTitlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubTitlesTable,
          SubTitle,
          $$SubTitlesTableFilterComposer,
          $$SubTitlesTableOrderingComposer,
          $$SubTitlesTableAnnotationComposer,
          $$SubTitlesTableCreateCompanionBuilder,
          $$SubTitlesTableUpdateCompanionBuilder,
          (SubTitle, BaseReferences<_$AppDatabase, $SubTitlesTable, SubTitle>),
          SubTitle,
          PrefetchHooks Function()
        > {
  $$SubTitlesTableTableManager(_$AppDatabase db, $SubTitlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubTitlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubTitlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubTitlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> titleId = const Value.absent(),
                Value<int?> subTitleGroupId = const Value.absent(),
                Value<String> subTitleName = const Value.absent(),
                Value<double> openingBalance = const Value.absent(),
                Value<int> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => SubTitlesCompanion(
                id: id,
                titleId: titleId,
                subTitleGroupId: subTitleGroupId,
                subTitleName: subTitleName,
                openingBalance: openingBalance,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int titleId,
                Value<int?> subTitleGroupId = const Value.absent(),
                required String subTitleName,
                Value<double> openingBalance = const Value.absent(),
                required int createdBy,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => SubTitlesCompanion.insert(
                id: id,
                titleId: titleId,
                subTitleGroupId: subTitleGroupId,
                subTitleName: subTitleName,
                openingBalance: openingBalance,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubTitlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubTitlesTable,
      SubTitle,
      $$SubTitlesTableFilterComposer,
      $$SubTitlesTableOrderingComposer,
      $$SubTitlesTableAnnotationComposer,
      $$SubTitlesTableCreateCompanionBuilder,
      $$SubTitlesTableUpdateCompanionBuilder,
      (SubTitle, BaseReferences<_$AppDatabase, $SubTitlesTable, SubTitle>),
      SubTitle,
      PrefetchHooks Function()
    >;
typedef $$BalanceEntriesTableCreateCompanionBuilder =
    BalanceEntriesCompanion Function({
      Value<int> id,
      required int subTitleId,
      required int departmentId,
      required DateTime entryDate,
      Value<double> debitAmount,
      Value<double> creditAmount,
      Value<String?> details,
      required int createdBy,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });
typedef $$BalanceEntriesTableUpdateCompanionBuilder =
    BalanceEntriesCompanion Function({
      Value<int> id,
      Value<int> subTitleId,
      Value<int> departmentId,
      Value<DateTime> entryDate,
      Value<double> debitAmount,
      Value<double> creditAmount,
      Value<String?> details,
      Value<int> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });

class $$BalanceEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $BalanceEntriesTable> {
  $$BalanceEntriesTableFilterComposer({
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

  ColumnFilters<int> get subTitleId => $composableBuilder(
    column: $table.subTitleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get debitAmount => $composableBuilder(
    column: $table.debitAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditAmount => $composableBuilder(
    column: $table.creditAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdBy => $composableBuilder(
    column: $table.createdBy,
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
}

class $$BalanceEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BalanceEntriesTable> {
  $$BalanceEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get subTitleId => $composableBuilder(
    column: $table.subTitleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get debitAmount => $composableBuilder(
    column: $table.debitAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditAmount => $composableBuilder(
    column: $table.creditAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdBy => $composableBuilder(
    column: $table.createdBy,
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

class $$BalanceEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BalanceEntriesTable> {
  $$BalanceEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get subTitleId => $composableBuilder(
    column: $table.subTitleId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<double> get debitAmount => $composableBuilder(
    column: $table.debitAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get creditAmount => $composableBuilder(
    column: $table.creditAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<int> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BalanceEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BalanceEntriesTable,
          BalanceEntry,
          $$BalanceEntriesTableFilterComposer,
          $$BalanceEntriesTableOrderingComposer,
          $$BalanceEntriesTableAnnotationComposer,
          $$BalanceEntriesTableCreateCompanionBuilder,
          $$BalanceEntriesTableUpdateCompanionBuilder,
          (
            BalanceEntry,
            BaseReferences<_$AppDatabase, $BalanceEntriesTable, BalanceEntry>,
          ),
          BalanceEntry,
          PrefetchHooks Function()
        > {
  $$BalanceEntriesTableTableManager(
    _$AppDatabase db,
    $BalanceEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BalanceEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BalanceEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BalanceEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> subTitleId = const Value.absent(),
                Value<int> departmentId = const Value.absent(),
                Value<DateTime> entryDate = const Value.absent(),
                Value<double> debitAmount = const Value.absent(),
                Value<double> creditAmount = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<int> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => BalanceEntriesCompanion(
                id: id,
                subTitleId: subTitleId,
                departmentId: departmentId,
                entryDate: entryDate,
                debitAmount: debitAmount,
                creditAmount: creditAmount,
                details: details,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int subTitleId,
                required int departmentId,
                required DateTime entryDate,
                Value<double> debitAmount = const Value.absent(),
                Value<double> creditAmount = const Value.absent(),
                Value<String?> details = const Value.absent(),
                required int createdBy,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => BalanceEntriesCompanion.insert(
                id: id,
                subTitleId: subTitleId,
                departmentId: departmentId,
                entryDate: entryDate,
                debitAmount: debitAmount,
                creditAmount: creditAmount,
                details: details,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BalanceEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BalanceEntriesTable,
      BalanceEntry,
      $$BalanceEntriesTableFilterComposer,
      $$BalanceEntriesTableOrderingComposer,
      $$BalanceEntriesTableAnnotationComposer,
      $$BalanceEntriesTableCreateCompanionBuilder,
      $$BalanceEntriesTableUpdateCompanionBuilder,
      (
        BalanceEntry,
        BaseReferences<_$AppDatabase, $BalanceEntriesTable, BalanceEntry>,
      ),
      BalanceEntry,
      PrefetchHooks Function()
    >;
typedef $$DayBooksTableCreateCompanionBuilder =
    DayBooksCompanion Function({
      Value<int> id,
      required int departmentId,
      required DateTime businessDate,
      Value<String> status,
      Value<double?> computedClosing,
      Value<int?> closingCheckId,
      Value<int?> closedBy,
      Value<DateTime?> closedAt,
    });
typedef $$DayBooksTableUpdateCompanionBuilder =
    DayBooksCompanion Function({
      Value<int> id,
      Value<int> departmentId,
      Value<DateTime> businessDate,
      Value<String> status,
      Value<double?> computedClosing,
      Value<int?> closingCheckId,
      Value<int?> closedBy,
      Value<DateTime?> closedAt,
    });

class $$DayBooksTableFilterComposer
    extends Composer<_$AppDatabase, $DayBooksTable> {
  $$DayBooksTableFilterComposer({
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

  ColumnFilters<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get computedClosing => $composableBuilder(
    column: $table.computedClosing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closingCheckId => $composableBuilder(
    column: $table.closingCheckId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closedBy => $composableBuilder(
    column: $table.closedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $DayBooksTable> {
  $$DayBooksTableOrderingComposer({
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

  ColumnOrderings<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get computedClosing => $composableBuilder(
    column: $table.computedClosing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closingCheckId => $composableBuilder(
    column: $table.closingCheckId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closedBy => $composableBuilder(
    column: $table.closedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayBooksTable> {
  $$DayBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get computedClosing => $composableBuilder(
    column: $table.computedClosing,
    builder: (column) => column,
  );

  GeneratedColumn<int> get closingCheckId => $composableBuilder(
    column: $table.closingCheckId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get closedBy =>
      $composableBuilder(column: $table.closedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);
}

class $$DayBooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayBooksTable,
          DayBook,
          $$DayBooksTableFilterComposer,
          $$DayBooksTableOrderingComposer,
          $$DayBooksTableAnnotationComposer,
          $$DayBooksTableCreateCompanionBuilder,
          $$DayBooksTableUpdateCompanionBuilder,
          (DayBook, BaseReferences<_$AppDatabase, $DayBooksTable, DayBook>),
          DayBook,
          PrefetchHooks Function()
        > {
  $$DayBooksTableTableManager(_$AppDatabase db, $DayBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> departmentId = const Value.absent(),
                Value<DateTime> businessDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double?> computedClosing = const Value.absent(),
                Value<int?> closingCheckId = const Value.absent(),
                Value<int?> closedBy = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
              }) => DayBooksCompanion(
                id: id,
                departmentId: departmentId,
                businessDate: businessDate,
                status: status,
                computedClosing: computedClosing,
                closingCheckId: closingCheckId,
                closedBy: closedBy,
                closedAt: closedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int departmentId,
                required DateTime businessDate,
                Value<String> status = const Value.absent(),
                Value<double?> computedClosing = const Value.absent(),
                Value<int?> closingCheckId = const Value.absent(),
                Value<int?> closedBy = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
              }) => DayBooksCompanion.insert(
                id: id,
                departmentId: departmentId,
                businessDate: businessDate,
                status: status,
                computedClosing: computedClosing,
                closingCheckId: closingCheckId,
                closedBy: closedBy,
                closedAt: closedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayBooksTable,
      DayBook,
      $$DayBooksTableFilterComposer,
      $$DayBooksTableOrderingComposer,
      $$DayBooksTableAnnotationComposer,
      $$DayBooksTableCreateCompanionBuilder,
      $$DayBooksTableUpdateCompanionBuilder,
      (DayBook, BaseReferences<_$AppDatabase, $DayBooksTable, DayBook>),
      DayBook,
      PrefetchHooks Function()
    >;
typedef $$ClosingBalanceChecksTableCreateCompanionBuilder =
    ClosingBalanceChecksCompanion Function({
      Value<int> id,
      Value<int?> departmentId,
      required DateTime checkDate,
      required double actualClosing,
      required int enteredBy,
      Value<DateTime> enteredAt,
    });
typedef $$ClosingBalanceChecksTableUpdateCompanionBuilder =
    ClosingBalanceChecksCompanion Function({
      Value<int> id,
      Value<int?> departmentId,
      Value<DateTime> checkDate,
      Value<double> actualClosing,
      Value<int> enteredBy,
      Value<DateTime> enteredAt,
    });

class $$ClosingBalanceChecksTableFilterComposer
    extends Composer<_$AppDatabase, $ClosingBalanceChecksTable> {
  $$ClosingBalanceChecksTableFilterComposer({
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

  ColumnFilters<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkDate => $composableBuilder(
    column: $table.checkDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualClosing => $composableBuilder(
    column: $table.actualClosing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get enteredBy => $composableBuilder(
    column: $table.enteredBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get enteredAt => $composableBuilder(
    column: $table.enteredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClosingBalanceChecksTableOrderingComposer
    extends Composer<_$AppDatabase, $ClosingBalanceChecksTable> {
  $$ClosingBalanceChecksTableOrderingComposer({
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

  ColumnOrderings<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkDate => $composableBuilder(
    column: $table.checkDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualClosing => $composableBuilder(
    column: $table.actualClosing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enteredBy => $composableBuilder(
    column: $table.enteredBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get enteredAt => $composableBuilder(
    column: $table.enteredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClosingBalanceChecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClosingBalanceChecksTable> {
  $$ClosingBalanceChecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkDate =>
      $composableBuilder(column: $table.checkDate, builder: (column) => column);

  GeneratedColumn<double> get actualClosing => $composableBuilder(
    column: $table.actualClosing,
    builder: (column) => column,
  );

  GeneratedColumn<int> get enteredBy =>
      $composableBuilder(column: $table.enteredBy, builder: (column) => column);

  GeneratedColumn<DateTime> get enteredAt =>
      $composableBuilder(column: $table.enteredAt, builder: (column) => column);
}

class $$ClosingBalanceChecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClosingBalanceChecksTable,
          ClosingBalanceCheck,
          $$ClosingBalanceChecksTableFilterComposer,
          $$ClosingBalanceChecksTableOrderingComposer,
          $$ClosingBalanceChecksTableAnnotationComposer,
          $$ClosingBalanceChecksTableCreateCompanionBuilder,
          $$ClosingBalanceChecksTableUpdateCompanionBuilder,
          (
            ClosingBalanceCheck,
            BaseReferences<
              _$AppDatabase,
              $ClosingBalanceChecksTable,
              ClosingBalanceCheck
            >,
          ),
          ClosingBalanceCheck,
          PrefetchHooks Function()
        > {
  $$ClosingBalanceChecksTableTableManager(
    _$AppDatabase db,
    $ClosingBalanceChecksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClosingBalanceChecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClosingBalanceChecksTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ClosingBalanceChecksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> departmentId = const Value.absent(),
                Value<DateTime> checkDate = const Value.absent(),
                Value<double> actualClosing = const Value.absent(),
                Value<int> enteredBy = const Value.absent(),
                Value<DateTime> enteredAt = const Value.absent(),
              }) => ClosingBalanceChecksCompanion(
                id: id,
                departmentId: departmentId,
                checkDate: checkDate,
                actualClosing: actualClosing,
                enteredBy: enteredBy,
                enteredAt: enteredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> departmentId = const Value.absent(),
                required DateTime checkDate,
                required double actualClosing,
                required int enteredBy,
                Value<DateTime> enteredAt = const Value.absent(),
              }) => ClosingBalanceChecksCompanion.insert(
                id: id,
                departmentId: departmentId,
                checkDate: checkDate,
                actualClosing: actualClosing,
                enteredBy: enteredBy,
                enteredAt: enteredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClosingBalanceChecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClosingBalanceChecksTable,
      ClosingBalanceCheck,
      $$ClosingBalanceChecksTableFilterComposer,
      $$ClosingBalanceChecksTableOrderingComposer,
      $$ClosingBalanceChecksTableAnnotationComposer,
      $$ClosingBalanceChecksTableCreateCompanionBuilder,
      $$ClosingBalanceChecksTableUpdateCompanionBuilder,
      (
        ClosingBalanceCheck,
        BaseReferences<
          _$AppDatabase,
          $ClosingBalanceChecksTable,
          ClosingBalanceCheck
        >,
      ),
      ClosingBalanceCheck,
      PrefetchHooks Function()
    >;
typedef $$ExportPasswordHistoryTableCreateCompanionBuilder =
    ExportPasswordHistoryCompanion Function({
      Value<int> id,
      required int userId,
      required String exportType,
      required String exportPassword,
      required DateTime fromDate,
      Value<DateTime?> toDate,
      Value<int?> departmentId,
      Value<DateTime> downloadedAt,
    });
typedef $$ExportPasswordHistoryTableUpdateCompanionBuilder =
    ExportPasswordHistoryCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<String> exportType,
      Value<String> exportPassword,
      Value<DateTime> fromDate,
      Value<DateTime?> toDate,
      Value<int?> departmentId,
      Value<DateTime> downloadedAt,
    });

class $$ExportPasswordHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ExportPasswordHistoryTable> {
  $$ExportPasswordHistoryTableFilterComposer({
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

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exportType => $composableBuilder(
    column: $table.exportType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exportPassword => $composableBuilder(
    column: $table.exportPassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fromDate => $composableBuilder(
    column: $table.fromDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get toDate => $composableBuilder(
    column: $table.toDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExportPasswordHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ExportPasswordHistoryTable> {
  $$ExportPasswordHistoryTableOrderingComposer({
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

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exportType => $composableBuilder(
    column: $table.exportType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exportPassword => $composableBuilder(
    column: $table.exportPassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fromDate => $composableBuilder(
    column: $table.fromDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get toDate => $composableBuilder(
    column: $table.toDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExportPasswordHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExportPasswordHistoryTable> {
  $$ExportPasswordHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get exportType => $composableBuilder(
    column: $table.exportType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exportPassword => $composableBuilder(
    column: $table.exportPassword,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fromDate =>
      $composableBuilder(column: $table.fromDate, builder: (column) => column);

  GeneratedColumn<DateTime> get toDate =>
      $composableBuilder(column: $table.toDate, builder: (column) => column);

  GeneratedColumn<int> get departmentId => $composableBuilder(
    column: $table.departmentId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $$ExportPasswordHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExportPasswordHistoryTable,
          ExportPasswordHistoryData,
          $$ExportPasswordHistoryTableFilterComposer,
          $$ExportPasswordHistoryTableOrderingComposer,
          $$ExportPasswordHistoryTableAnnotationComposer,
          $$ExportPasswordHistoryTableCreateCompanionBuilder,
          $$ExportPasswordHistoryTableUpdateCompanionBuilder,
          (
            ExportPasswordHistoryData,
            BaseReferences<
              _$AppDatabase,
              $ExportPasswordHistoryTable,
              ExportPasswordHistoryData
            >,
          ),
          ExportPasswordHistoryData,
          PrefetchHooks Function()
        > {
  $$ExportPasswordHistoryTableTableManager(
    _$AppDatabase db,
    $ExportPasswordHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExportPasswordHistoryTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ExportPasswordHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExportPasswordHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> exportType = const Value.absent(),
                Value<String> exportPassword = const Value.absent(),
                Value<DateTime> fromDate = const Value.absent(),
                Value<DateTime?> toDate = const Value.absent(),
                Value<int?> departmentId = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
              }) => ExportPasswordHistoryCompanion(
                id: id,
                userId: userId,
                exportType: exportType,
                exportPassword: exportPassword,
                fromDate: fromDate,
                toDate: toDate,
                departmentId: departmentId,
                downloadedAt: downloadedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required String exportType,
                required String exportPassword,
                required DateTime fromDate,
                Value<DateTime?> toDate = const Value.absent(),
                Value<int?> departmentId = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
              }) => ExportPasswordHistoryCompanion.insert(
                id: id,
                userId: userId,
                exportType: exportType,
                exportPassword: exportPassword,
                fromDate: fromDate,
                toDate: toDate,
                departmentId: departmentId,
                downloadedAt: downloadedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExportPasswordHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExportPasswordHistoryTable,
      ExportPasswordHistoryData,
      $$ExportPasswordHistoryTableFilterComposer,
      $$ExportPasswordHistoryTableOrderingComposer,
      $$ExportPasswordHistoryTableAnnotationComposer,
      $$ExportPasswordHistoryTableCreateCompanionBuilder,
      $$ExportPasswordHistoryTableUpdateCompanionBuilder,
      (
        ExportPasswordHistoryData,
        BaseReferences<
          _$AppDatabase,
          $ExportPasswordHistoryTable,
          ExportPasswordHistoryData
        >,
      ),
      ExportPasswordHistoryData,
      PrefetchHooks Function()
    >;
typedef $$AuditLogsTableCreateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<int> id,
      required int userId,
      required String action,
      required String entityTable,
      Value<int?> recordId,
      Value<String?> oldValue,
      Value<String?> newValue,
      Value<DateTime> createdAt,
    });
typedef $$AuditLogsTableUpdateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<String> action,
      Value<String> entityTable,
      Value<int?> recordId,
      Value<String?> oldValue,
      Value<String?> newValue,
      Value<DateTime> createdAt,
    });

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
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

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
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

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<int?> recordId = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                userId: userId,
                action: action,
                entityTable: entityTable,
                recordId: recordId,
                oldValue: oldValue,
                newValue: newValue,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required String action,
                required String entityTable,
                Value<int?> recordId = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                userId: userId,
                action: action,
                entityTable: entityTable,
                recordId: recordId,
                oldValue: oldValue,
                newValue: newValue,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;
typedef $$FinancialYearsTableCreateCompanionBuilder =
    FinancialYearsCompanion Function({
      Value<int> id,
      required String yearLabel,
      required DateTime startDate,
      required DateTime endDate,
    });
typedef $$FinancialYearsTableUpdateCompanionBuilder =
    FinancialYearsCompanion Function({
      Value<int> id,
      Value<String> yearLabel,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
    });

class $$FinancialYearsTableFilterComposer
    extends Composer<_$AppDatabase, $FinancialYearsTable> {
  $$FinancialYearsTableFilterComposer({
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

  ColumnFilters<String> get yearLabel => $composableBuilder(
    column: $table.yearLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FinancialYearsTableOrderingComposer
    extends Composer<_$AppDatabase, $FinancialYearsTable> {
  $$FinancialYearsTableOrderingComposer({
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

  ColumnOrderings<String> get yearLabel => $composableBuilder(
    column: $table.yearLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FinancialYearsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FinancialYearsTable> {
  $$FinancialYearsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get yearLabel =>
      $composableBuilder(column: $table.yearLabel, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);
}

class $$FinancialYearsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FinancialYearsTable,
          FinancialYear,
          $$FinancialYearsTableFilterComposer,
          $$FinancialYearsTableOrderingComposer,
          $$FinancialYearsTableAnnotationComposer,
          $$FinancialYearsTableCreateCompanionBuilder,
          $$FinancialYearsTableUpdateCompanionBuilder,
          (
            FinancialYear,
            BaseReferences<_$AppDatabase, $FinancialYearsTable, FinancialYear>,
          ),
          FinancialYear,
          PrefetchHooks Function()
        > {
  $$FinancialYearsTableTableManager(
    _$AppDatabase db,
    $FinancialYearsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinancialYearsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinancialYearsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinancialYearsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> yearLabel = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
              }) => FinancialYearsCompanion(
                id: id,
                yearLabel: yearLabel,
                startDate: startDate,
                endDate: endDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String yearLabel,
                required DateTime startDate,
                required DateTime endDate,
              }) => FinancialYearsCompanion.insert(
                id: id,
                yearLabel: yearLabel,
                startDate: startDate,
                endDate: endDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FinancialYearsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FinancialYearsTable,
      FinancialYear,
      $$FinancialYearsTableFilterComposer,
      $$FinancialYearsTableOrderingComposer,
      $$FinancialYearsTableAnnotationComposer,
      $$FinancialYearsTableCreateCompanionBuilder,
      $$FinancialYearsTableUpdateCompanionBuilder,
      (
        FinancialYear,
        BaseReferences<_$AppDatabase, $FinancialYearsTable, FinancialYear>,
      ),
      FinancialYear,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db, _db.roles);
  $$PermissionsTableTableManager get permissions =>
      $$PermissionsTableTableManager(_db, _db.permissions);
  $$RolePermissionsTableTableManager get rolePermissions =>
      $$RolePermissionsTableTableManager(_db, _db.rolePermissions);
  $$UserPermissionOverridesTableTableManager get userPermissionOverrides =>
      $$UserPermissionOverridesTableTableManager(
        _db,
        _db.userPermissionOverrides,
      );
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$DepartmentsTableTableManager get departments =>
      $$DepartmentsTableTableManager(_db, _db.departments);
  $$UserDepartmentsTableTableManager get userDepartments =>
      $$UserDepartmentsTableTableManager(_db, _db.userDepartments);
  $$MainTitlesTableTableManager get mainTitles =>
      $$MainTitlesTableTableManager(_db, _db.mainTitles);
  $$TitleGroupsTableTableManager get titleGroups =>
      $$TitleGroupsTableTableManager(_db, _db.titleGroups);
  $$TitlesTableTableManager get titles =>
      $$TitlesTableTableManager(_db, _db.titles);
  $$SubTitleGroupsTableTableManager get subTitleGroups =>
      $$SubTitleGroupsTableTableManager(_db, _db.subTitleGroups);
  $$SubTitlesTableTableManager get subTitles =>
      $$SubTitlesTableTableManager(_db, _db.subTitles);
  $$BalanceEntriesTableTableManager get balanceEntries =>
      $$BalanceEntriesTableTableManager(_db, _db.balanceEntries);
  $$DayBooksTableTableManager get dayBooks =>
      $$DayBooksTableTableManager(_db, _db.dayBooks);
  $$ClosingBalanceChecksTableTableManager get closingBalanceChecks =>
      $$ClosingBalanceChecksTableTableManager(_db, _db.closingBalanceChecks);
  $$ExportPasswordHistoryTableTableManager get exportPasswordHistory =>
      $$ExportPasswordHistoryTableTableManager(_db, _db.exportPasswordHistory);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$FinancialYearsTableTableManager get financialYears =>
      $$FinancialYearsTableTableManager(_db, _db.financialYears);
}
