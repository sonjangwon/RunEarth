// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConnectedDevices {

 bool get appleWatch; bool get galaxyWatch;
/// Create a copy of ConnectedDevices
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectedDevicesCopyWith<ConnectedDevices> get copyWith => _$ConnectedDevicesCopyWithImpl<ConnectedDevices>(this as ConnectedDevices, _$identity);

  /// Serializes this ConnectedDevices to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectedDevices&&(identical(other.appleWatch, appleWatch) || other.appleWatch == appleWatch)&&(identical(other.galaxyWatch, galaxyWatch) || other.galaxyWatch == galaxyWatch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appleWatch,galaxyWatch);

@override
String toString() {
  return 'ConnectedDevices(appleWatch: $appleWatch, galaxyWatch: $galaxyWatch)';
}


}

/// @nodoc
abstract mixin class $ConnectedDevicesCopyWith<$Res>  {
  factory $ConnectedDevicesCopyWith(ConnectedDevices value, $Res Function(ConnectedDevices) _then) = _$ConnectedDevicesCopyWithImpl;
@useResult
$Res call({
 bool appleWatch, bool galaxyWatch
});




}
/// @nodoc
class _$ConnectedDevicesCopyWithImpl<$Res>
    implements $ConnectedDevicesCopyWith<$Res> {
  _$ConnectedDevicesCopyWithImpl(this._self, this._then);

  final ConnectedDevices _self;
  final $Res Function(ConnectedDevices) _then;

/// Create a copy of ConnectedDevices
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appleWatch = null,Object? galaxyWatch = null,}) {
  return _then(ConnectedDevices(
appleWatch: null == appleWatch ? _self.appleWatch : appleWatch // ignore: cast_nullable_to_non_nullable
as bool,galaxyWatch: null == galaxyWatch ? _self.galaxyWatch : galaxyWatch // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ConnectedDevices].
extension ConnectedDevicesPatterns on ConnectedDevices {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectedDevices value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectedDevices() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectedDevices value)  $default,){
final _that = this;
switch (_that) {
case _ConnectedDevices():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectedDevices value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectedDevices() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool appleWatch,  bool galaxyWatch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectedDevices() when $default != null:
return $default(_that.appleWatch,_that.galaxyWatch);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool appleWatch,  bool galaxyWatch)  $default,) {final _that = this;
switch (_that) {
case _ConnectedDevices():
return $default(_that.appleWatch,_that.galaxyWatch);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool appleWatch,  bool galaxyWatch)?  $default,) {final _that = this;
switch (_that) {
case _ConnectedDevices() when $default != null:
return $default(_that.appleWatch,_that.galaxyWatch);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConnectedDevices implements ConnectedDevices {
  const _ConnectedDevices({this.appleWatch = false, this.galaxyWatch = false});
  factory _ConnectedDevices.fromJson(Map<String, dynamic> json) => _$ConnectedDevicesFromJson(json);

@override@JsonKey() final  bool appleWatch;
@override@JsonKey() final  bool galaxyWatch;

/// Create a copy of ConnectedDevices
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectedDevicesCopyWith<_ConnectedDevices> get copyWith => __$ConnectedDevicesCopyWithImpl<_ConnectedDevices>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectedDevicesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectedDevices&&(identical(other.appleWatch, appleWatch) || other.appleWatch == appleWatch)&&(identical(other.galaxyWatch, galaxyWatch) || other.galaxyWatch == galaxyWatch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appleWatch,galaxyWatch);

@override
String toString() {
  return 'ConnectedDevices(appleWatch: $appleWatch, galaxyWatch: $galaxyWatch)';
}


}

/// @nodoc
abstract mixin class _$ConnectedDevicesCopyWith<$Res> implements $ConnectedDevicesCopyWith<$Res> {
  factory _$ConnectedDevicesCopyWith(_ConnectedDevices value, $Res Function(_ConnectedDevices) _then) = __$ConnectedDevicesCopyWithImpl;
@override @useResult
$Res call({
 bool appleWatch, bool galaxyWatch
});




}
/// @nodoc
class __$ConnectedDevicesCopyWithImpl<$Res>
    implements _$ConnectedDevicesCopyWith<$Res> {
  __$ConnectedDevicesCopyWithImpl(this._self, this._then);

  final _ConnectedDevices _self;
  final $Res Function(_ConnectedDevices) _then;

/// Create a copy of ConnectedDevices
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appleWatch = null,Object? galaxyWatch = null,}) {
  return _then(_ConnectedDevices(
appleWatch: null == appleWatch ? _self.appleWatch : appleWatch // ignore: cast_nullable_to_non_nullable
as bool,galaxyWatch: null == galaxyWatch ? _self.galaxyWatch : galaxyWatch // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AppUser {

 String get id; String get name; String get avatar; int get streak; AuthProvider get provider; String get createdAt; String? get deletedAt; ConnectedDevices get connectedDevices;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.connectedDevices, connectedDevices) || other.connectedDevices == connectedDevices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatar,streak,provider,createdAt,deletedAt,connectedDevices);

@override
String toString() {
  return 'AppUser(id: $id, name: $name, avatar: $avatar, streak: $streak, provider: $provider, createdAt: $createdAt, deletedAt: $deletedAt, connectedDevices: $connectedDevices)';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String id, String name, String avatar, int streak, AuthProvider provider, String createdAt, String? deletedAt, ConnectedDevices connectedDevices
});


$ConnectedDevicesCopyWith<$Res> get connectedDevices;

}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatar = null,Object? streak = null,Object? provider = null,Object? createdAt = null,Object? deletedAt = freezed,Object? connectedDevices = null,}) {
  return _then(AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatar: null == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as AuthProvider,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as String?,connectedDevices: null == connectedDevices ? _self.connectedDevices : connectedDevices // ignore: cast_nullable_to_non_nullable
as ConnectedDevices,
  ));
}
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectedDevicesCopyWith<$Res> get connectedDevices {
  
  return $ConnectedDevicesCopyWith<$Res>(_self.connectedDevices, (value) {
    return _then(_self.copyWith(connectedDevices: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String avatar,  int streak,  AuthProvider provider,  String createdAt,  String? deletedAt,  ConnectedDevices connectedDevices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.name,_that.avatar,_that.streak,_that.provider,_that.createdAt,_that.deletedAt,_that.connectedDevices);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String avatar,  int streak,  AuthProvider provider,  String createdAt,  String? deletedAt,  ConnectedDevices connectedDevices)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.id,_that.name,_that.avatar,_that.streak,_that.provider,_that.createdAt,_that.deletedAt,_that.connectedDevices);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String avatar,  int streak,  AuthProvider provider,  String createdAt,  String? deletedAt,  ConnectedDevices connectedDevices)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.name,_that.avatar,_that.streak,_that.provider,_that.createdAt,_that.deletedAt,_that.connectedDevices);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser implements AppUser {
  const _AppUser({required this.id, required this.name, required this.avatar, this.streak = 0, required this.provider, required this.createdAt, this.deletedAt, this.connectedDevices = const ConnectedDevices()});
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String id;
@override final  String name;
@override final  String avatar;
@override@JsonKey() final  int streak;
@override final  AuthProvider provider;
@override final  String createdAt;
@override final  String? deletedAt;
@override@JsonKey() final  ConnectedDevices connectedDevices;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.connectedDevices, connectedDevices) || other.connectedDevices == connectedDevices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatar,streak,provider,createdAt,deletedAt,connectedDevices);

@override
String toString() {
  return 'AppUser(id: $id, name: $name, avatar: $avatar, streak: $streak, provider: $provider, createdAt: $createdAt, deletedAt: $deletedAt, connectedDevices: $connectedDevices)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String avatar, int streak, AuthProvider provider, String createdAt, String? deletedAt, ConnectedDevices connectedDevices
});


@override $ConnectedDevicesCopyWith<$Res> get connectedDevices;

}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatar = null,Object? streak = null,Object? provider = null,Object? createdAt = null,Object? deletedAt = freezed,Object? connectedDevices = null,}) {
  return _then(_AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatar: null == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as AuthProvider,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as String?,connectedDevices: null == connectedDevices ? _self.connectedDevices : connectedDevices // ignore: cast_nullable_to_non_nullable
as ConnectedDevices,
  ));
}

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectedDevicesCopyWith<$Res> get connectedDevices {
  
  return $ConnectedDevicesCopyWith<$Res>(_self.connectedDevices, (value) {
    return _then(_self.copyWith(connectedDevices: value));
  });
}
}

// dart format on
