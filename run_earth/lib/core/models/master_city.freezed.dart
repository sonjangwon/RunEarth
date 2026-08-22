// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'master_city.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MasterCity {

 String get id; String get name; String? get countryName; double get lat; double get lng; double get cumulativeKm; bool get isStartCandidate; String get backgroundImageUrl;
/// Create a copy of MasterCity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MasterCityCopyWith<MasterCity> get copyWith => _$MasterCityCopyWithImpl<MasterCity>(this as MasterCity, _$identity);

  /// Serializes this MasterCity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MasterCity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.countryName, countryName) || other.countryName == countryName)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.cumulativeKm, cumulativeKm) || other.cumulativeKm == cumulativeKm)&&(identical(other.isStartCandidate, isStartCandidate) || other.isStartCandidate == isStartCandidate)&&(identical(other.backgroundImageUrl, backgroundImageUrl) || other.backgroundImageUrl == backgroundImageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,countryName,lat,lng,cumulativeKm,isStartCandidate,backgroundImageUrl);

@override
String toString() {
  return 'MasterCity(id: $id, name: $name, countryName: $countryName, lat: $lat, lng: $lng, cumulativeKm: $cumulativeKm, isStartCandidate: $isStartCandidate, backgroundImageUrl: $backgroundImageUrl)';
}


}

/// @nodoc
abstract mixin class $MasterCityCopyWith<$Res>  {
  factory $MasterCityCopyWith(MasterCity value, $Res Function(MasterCity) _then) = _$MasterCityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? countryName, double lat, double lng, double cumulativeKm, bool isStartCandidate, String backgroundImageUrl
});




}
/// @nodoc
class _$MasterCityCopyWithImpl<$Res>
    implements $MasterCityCopyWith<$Res> {
  _$MasterCityCopyWithImpl(this._self, this._then);

  final MasterCity _self;
  final $Res Function(MasterCity) _then;

/// Create a copy of MasterCity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? countryName = freezed,Object? lat = null,Object? lng = null,Object? cumulativeKm = null,Object? isStartCandidate = null,Object? backgroundImageUrl = null,}) {
  return _then(MasterCity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,countryName: freezed == countryName ? _self.countryName : countryName // ignore: cast_nullable_to_non_nullable
as String?,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,cumulativeKm: null == cumulativeKm ? _self.cumulativeKm : cumulativeKm // ignore: cast_nullable_to_non_nullable
as double,isStartCandidate: null == isStartCandidate ? _self.isStartCandidate : isStartCandidate // ignore: cast_nullable_to_non_nullable
as bool,backgroundImageUrl: null == backgroundImageUrl ? _self.backgroundImageUrl : backgroundImageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MasterCity].
extension MasterCityPatterns on MasterCity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MasterCity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MasterCity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MasterCity value)  $default,){
final _that = this;
switch (_that) {
case _MasterCity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MasterCity value)?  $default,){
final _that = this;
switch (_that) {
case _MasterCity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? countryName,  double lat,  double lng,  double cumulativeKm,  bool isStartCandidate,  String backgroundImageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MasterCity() when $default != null:
return $default(_that.id,_that.name,_that.countryName,_that.lat,_that.lng,_that.cumulativeKm,_that.isStartCandidate,_that.backgroundImageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? countryName,  double lat,  double lng,  double cumulativeKm,  bool isStartCandidate,  String backgroundImageUrl)  $default,) {final _that = this;
switch (_that) {
case _MasterCity():
return $default(_that.id,_that.name,_that.countryName,_that.lat,_that.lng,_that.cumulativeKm,_that.isStartCandidate,_that.backgroundImageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? countryName,  double lat,  double lng,  double cumulativeKm,  bool isStartCandidate,  String backgroundImageUrl)?  $default,) {final _that = this;
switch (_that) {
case _MasterCity() when $default != null:
return $default(_that.id,_that.name,_that.countryName,_that.lat,_that.lng,_that.cumulativeKm,_that.isStartCandidate,_that.backgroundImageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MasterCity implements MasterCity {
  const _MasterCity({required this.id, required this.name, this.countryName, required this.lat, required this.lng, required this.cumulativeKm, this.isStartCandidate = false, required this.backgroundImageUrl});
  factory _MasterCity.fromJson(Map<String, dynamic> json) => _$MasterCityFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? countryName;
@override final  double lat;
@override final  double lng;
@override final  double cumulativeKm;
@override@JsonKey() final  bool isStartCandidate;
@override final  String backgroundImageUrl;

/// Create a copy of MasterCity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MasterCityCopyWith<_MasterCity> get copyWith => __$MasterCityCopyWithImpl<_MasterCity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MasterCityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MasterCity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.countryName, countryName) || other.countryName == countryName)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.cumulativeKm, cumulativeKm) || other.cumulativeKm == cumulativeKm)&&(identical(other.isStartCandidate, isStartCandidate) || other.isStartCandidate == isStartCandidate)&&(identical(other.backgroundImageUrl, backgroundImageUrl) || other.backgroundImageUrl == backgroundImageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,countryName,lat,lng,cumulativeKm,isStartCandidate,backgroundImageUrl);

@override
String toString() {
  return 'MasterCity(id: $id, name: $name, countryName: $countryName, lat: $lat, lng: $lng, cumulativeKm: $cumulativeKm, isStartCandidate: $isStartCandidate, backgroundImageUrl: $backgroundImageUrl)';
}


}

/// @nodoc
abstract mixin class _$MasterCityCopyWith<$Res> implements $MasterCityCopyWith<$Res> {
  factory _$MasterCityCopyWith(_MasterCity value, $Res Function(_MasterCity) _then) = __$MasterCityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? countryName, double lat, double lng, double cumulativeKm, bool isStartCandidate, String backgroundImageUrl
});




}
/// @nodoc
class __$MasterCityCopyWithImpl<$Res>
    implements _$MasterCityCopyWith<$Res> {
  __$MasterCityCopyWithImpl(this._self, this._then);

  final _MasterCity _self;
  final $Res Function(_MasterCity) _then;

/// Create a copy of MasterCity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? countryName = freezed,Object? lat = null,Object? lng = null,Object? cumulativeKm = null,Object? isStartCandidate = null,Object? backgroundImageUrl = null,}) {
  return _then(_MasterCity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,countryName: freezed == countryName ? _self.countryName : countryName // ignore: cast_nullable_to_non_nullable
as String?,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,cumulativeKm: null == cumulativeKm ? _self.cumulativeKm : cumulativeKm // ignore: cast_nullable_to_non_nullable
as double,isStartCandidate: null == isStartCandidate ? _self.isStartCandidate : isStartCandidate // ignore: cast_nullable_to_non_nullable
as bool,backgroundImageUrl: null == backgroundImageUrl ? _self.backgroundImageUrl : backgroundImageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$JourneyState {

 String get assignedStartCityId; bool get startResolvedFromGPS; String get startedAt; double get totalDistanceKm; int get currentMilestoneIndex;
/// Create a copy of JourneyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JourneyStateCopyWith<JourneyState> get copyWith => _$JourneyStateCopyWithImpl<JourneyState>(this as JourneyState, _$identity);

  /// Serializes this JourneyState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JourneyState&&(identical(other.assignedStartCityId, assignedStartCityId) || other.assignedStartCityId == assignedStartCityId)&&(identical(other.startResolvedFromGPS, startResolvedFromGPS) || other.startResolvedFromGPS == startResolvedFromGPS)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.totalDistanceKm, totalDistanceKm) || other.totalDistanceKm == totalDistanceKm)&&(identical(other.currentMilestoneIndex, currentMilestoneIndex) || other.currentMilestoneIndex == currentMilestoneIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,assignedStartCityId,startResolvedFromGPS,startedAt,totalDistanceKm,currentMilestoneIndex);

@override
String toString() {
  return 'JourneyState(assignedStartCityId: $assignedStartCityId, startResolvedFromGPS: $startResolvedFromGPS, startedAt: $startedAt, totalDistanceKm: $totalDistanceKm, currentMilestoneIndex: $currentMilestoneIndex)';
}


}

/// @nodoc
abstract mixin class $JourneyStateCopyWith<$Res>  {
  factory $JourneyStateCopyWith(JourneyState value, $Res Function(JourneyState) _then) = _$JourneyStateCopyWithImpl;
@useResult
$Res call({
 String assignedStartCityId, bool startResolvedFromGPS, String startedAt, double totalDistanceKm, int currentMilestoneIndex
});




}
/// @nodoc
class _$JourneyStateCopyWithImpl<$Res>
    implements $JourneyStateCopyWith<$Res> {
  _$JourneyStateCopyWithImpl(this._self, this._then);

  final JourneyState _self;
  final $Res Function(JourneyState) _then;

/// Create a copy of JourneyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? assignedStartCityId = null,Object? startResolvedFromGPS = null,Object? startedAt = null,Object? totalDistanceKm = null,Object? currentMilestoneIndex = null,}) {
  return _then(JourneyState(
assignedStartCityId: null == assignedStartCityId ? _self.assignedStartCityId : assignedStartCityId // ignore: cast_nullable_to_non_nullable
as String,startResolvedFromGPS: null == startResolvedFromGPS ? _self.startResolvedFromGPS : startResolvedFromGPS // ignore: cast_nullable_to_non_nullable
as bool,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String,totalDistanceKm: null == totalDistanceKm ? _self.totalDistanceKm : totalDistanceKm // ignore: cast_nullable_to_non_nullable
as double,currentMilestoneIndex: null == currentMilestoneIndex ? _self.currentMilestoneIndex : currentMilestoneIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [JourneyState].
extension JourneyStatePatterns on JourneyState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JourneyState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JourneyState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JourneyState value)  $default,){
final _that = this;
switch (_that) {
case _JourneyState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JourneyState value)?  $default,){
final _that = this;
switch (_that) {
case _JourneyState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String assignedStartCityId,  bool startResolvedFromGPS,  String startedAt,  double totalDistanceKm,  int currentMilestoneIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JourneyState() when $default != null:
return $default(_that.assignedStartCityId,_that.startResolvedFromGPS,_that.startedAt,_that.totalDistanceKm,_that.currentMilestoneIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String assignedStartCityId,  bool startResolvedFromGPS,  String startedAt,  double totalDistanceKm,  int currentMilestoneIndex)  $default,) {final _that = this;
switch (_that) {
case _JourneyState():
return $default(_that.assignedStartCityId,_that.startResolvedFromGPS,_that.startedAt,_that.totalDistanceKm,_that.currentMilestoneIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String assignedStartCityId,  bool startResolvedFromGPS,  String startedAt,  double totalDistanceKm,  int currentMilestoneIndex)?  $default,) {final _that = this;
switch (_that) {
case _JourneyState() when $default != null:
return $default(_that.assignedStartCityId,_that.startResolvedFromGPS,_that.startedAt,_that.totalDistanceKm,_that.currentMilestoneIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JourneyState implements JourneyState {
  const _JourneyState({required this.assignedStartCityId, required this.startResolvedFromGPS, required this.startedAt, this.totalDistanceKm = 0, this.currentMilestoneIndex = 0});
  factory _JourneyState.fromJson(Map<String, dynamic> json) => _$JourneyStateFromJson(json);

@override final  String assignedStartCityId;
@override final  bool startResolvedFromGPS;
@override final  String startedAt;
@override@JsonKey() final  double totalDistanceKm;
@override@JsonKey() final  int currentMilestoneIndex;

/// Create a copy of JourneyState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JourneyStateCopyWith<_JourneyState> get copyWith => __$JourneyStateCopyWithImpl<_JourneyState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JourneyStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JourneyState&&(identical(other.assignedStartCityId, assignedStartCityId) || other.assignedStartCityId == assignedStartCityId)&&(identical(other.startResolvedFromGPS, startResolvedFromGPS) || other.startResolvedFromGPS == startResolvedFromGPS)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.totalDistanceKm, totalDistanceKm) || other.totalDistanceKm == totalDistanceKm)&&(identical(other.currentMilestoneIndex, currentMilestoneIndex) || other.currentMilestoneIndex == currentMilestoneIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,assignedStartCityId,startResolvedFromGPS,startedAt,totalDistanceKm,currentMilestoneIndex);

@override
String toString() {
  return 'JourneyState(assignedStartCityId: $assignedStartCityId, startResolvedFromGPS: $startResolvedFromGPS, startedAt: $startedAt, totalDistanceKm: $totalDistanceKm, currentMilestoneIndex: $currentMilestoneIndex)';
}


}

/// @nodoc
abstract mixin class _$JourneyStateCopyWith<$Res> implements $JourneyStateCopyWith<$Res> {
  factory _$JourneyStateCopyWith(_JourneyState value, $Res Function(_JourneyState) _then) = __$JourneyStateCopyWithImpl;
@override @useResult
$Res call({
 String assignedStartCityId, bool startResolvedFromGPS, String startedAt, double totalDistanceKm, int currentMilestoneIndex
});




}
/// @nodoc
class __$JourneyStateCopyWithImpl<$Res>
    implements _$JourneyStateCopyWith<$Res> {
  __$JourneyStateCopyWithImpl(this._self, this._then);

  final _JourneyState _self;
  final $Res Function(_JourneyState) _then;

/// Create a copy of JourneyState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? assignedStartCityId = null,Object? startResolvedFromGPS = null,Object? startedAt = null,Object? totalDistanceKm = null,Object? currentMilestoneIndex = null,}) {
  return _then(_JourneyState(
assignedStartCityId: null == assignedStartCityId ? _self.assignedStartCityId : assignedStartCityId // ignore: cast_nullable_to_non_nullable
as String,startResolvedFromGPS: null == startResolvedFromGPS ? _self.startResolvedFromGPS : startResolvedFromGPS // ignore: cast_nullable_to_non_nullable
as bool,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String,totalDistanceKm: null == totalDistanceKm ? _self.totalDistanceKm : totalDistanceKm // ignore: cast_nullable_to_non_nullable
as double,currentMilestoneIndex: null == currentMilestoneIndex ? _self.currentMilestoneIndex : currentMilestoneIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
