// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'geo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LatLngPoint {

 double get lat; double get lng; int? get t;
/// Create a copy of LatLngPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LatLngPointCopyWith<LatLngPoint> get copyWith => _$LatLngPointCopyWithImpl<LatLngPoint>(this as LatLngPoint, _$identity);

  /// Serializes this LatLngPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LatLngPoint&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.t, t) || other.t == t));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lat,lng,t);

@override
String toString() {
  return 'LatLngPoint(lat: $lat, lng: $lng, t: $t)';
}


}

/// @nodoc
abstract mixin class $LatLngPointCopyWith<$Res>  {
  factory $LatLngPointCopyWith(LatLngPoint value, $Res Function(LatLngPoint) _then) = _$LatLngPointCopyWithImpl;
@useResult
$Res call({
 double lat, double lng, int? t
});




}
/// @nodoc
class _$LatLngPointCopyWithImpl<$Res>
    implements $LatLngPointCopyWith<$Res> {
  _$LatLngPointCopyWithImpl(this._self, this._then);

  final LatLngPoint _self;
  final $Res Function(LatLngPoint) _then;

/// Create a copy of LatLngPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lat = null,Object? lng = null,Object? t = freezed,}) {
  return _then(LatLngPoint(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,t: freezed == t ? _self.t : t // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [LatLngPoint].
extension LatLngPointPatterns on LatLngPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LatLngPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LatLngPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LatLngPoint value)  $default,){
final _that = this;
switch (_that) {
case _LatLngPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LatLngPoint value)?  $default,){
final _that = this;
switch (_that) {
case _LatLngPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double lat,  double lng,  int? t)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LatLngPoint() when $default != null:
return $default(_that.lat,_that.lng,_that.t);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double lat,  double lng,  int? t)  $default,) {final _that = this;
switch (_that) {
case _LatLngPoint():
return $default(_that.lat,_that.lng,_that.t);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double lat,  double lng,  int? t)?  $default,) {final _that = this;
switch (_that) {
case _LatLngPoint() when $default != null:
return $default(_that.lat,_that.lng,_that.t);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LatLngPoint implements LatLngPoint {
  const _LatLngPoint({required this.lat, required this.lng, this.t});
  factory _LatLngPoint.fromJson(Map<String, dynamic> json) => _$LatLngPointFromJson(json);

@override final  double lat;
@override final  double lng;
@override final  int? t;

/// Create a copy of LatLngPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LatLngPointCopyWith<_LatLngPoint> get copyWith => __$LatLngPointCopyWithImpl<_LatLngPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LatLngPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LatLngPoint&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.t, t) || other.t == t));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lat,lng,t);

@override
String toString() {
  return 'LatLngPoint(lat: $lat, lng: $lng, t: $t)';
}


}

/// @nodoc
abstract mixin class _$LatLngPointCopyWith<$Res> implements $LatLngPointCopyWith<$Res> {
  factory _$LatLngPointCopyWith(_LatLngPoint value, $Res Function(_LatLngPoint) _then) = __$LatLngPointCopyWithImpl;
@override @useResult
$Res call({
 double lat, double lng, int? t
});




}
/// @nodoc
class __$LatLngPointCopyWithImpl<$Res>
    implements _$LatLngPointCopyWith<$Res> {
  __$LatLngPointCopyWithImpl(this._self, this._then);

  final _LatLngPoint _self;
  final $Res Function(_LatLngPoint) _then;

/// Create a copy of LatLngPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lat = null,Object? lng = null,Object? t = freezed,}) {
  return _then(_LatLngPoint(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,t: freezed == t ? _self.t : t // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
