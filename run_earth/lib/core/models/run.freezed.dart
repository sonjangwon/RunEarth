// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Run {

 String get id; String get date; String get day; double get km; String get pace; String get dur; int get kcal; RecordType get type; int get year; int get month; CoverImageType get coverImageType; String? get coverImageUrl; String? get marathonChallengeId; String? get marathonCourseId; bool? get gpsVerified; RunSource get source;
/// Create a copy of Run
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunCopyWith<Run> get copyWith => _$RunCopyWithImpl<Run>(this as Run, _$identity);

  /// Serializes this Run to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Run&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.day, day) || other.day == day)&&(identical(other.km, km) || other.km == km)&&(identical(other.pace, pace) || other.pace == pace)&&(identical(other.dur, dur) || other.dur == dur)&&(identical(other.kcal, kcal) || other.kcal == kcal)&&(identical(other.type, type) || other.type == type)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.coverImageType, coverImageType) || other.coverImageType == coverImageType)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.marathonChallengeId, marathonChallengeId) || other.marathonChallengeId == marathonChallengeId)&&(identical(other.marathonCourseId, marathonCourseId) || other.marathonCourseId == marathonCourseId)&&(identical(other.gpsVerified, gpsVerified) || other.gpsVerified == gpsVerified)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,day,km,pace,dur,kcal,type,year,month,coverImageType,coverImageUrl,marathonChallengeId,marathonCourseId,gpsVerified,source);

@override
String toString() {
  return 'Run(id: $id, date: $date, day: $day, km: $km, pace: $pace, dur: $dur, kcal: $kcal, type: $type, year: $year, month: $month, coverImageType: $coverImageType, coverImageUrl: $coverImageUrl, marathonChallengeId: $marathonChallengeId, marathonCourseId: $marathonCourseId, gpsVerified: $gpsVerified, source: $source)';
}


}

/// @nodoc
abstract mixin class $RunCopyWith<$Res>  {
  factory $RunCopyWith(Run value, $Res Function(Run) _then) = _$RunCopyWithImpl;
@useResult
$Res call({
 String id, String date, String day, double km, String pace, String dur, int kcal, RecordType type, int year, int month, CoverImageType coverImageType, String? coverImageUrl, String? marathonChallengeId, String? marathonCourseId, bool? gpsVerified, RunSource source
});




}
/// @nodoc
class _$RunCopyWithImpl<$Res>
    implements $RunCopyWith<$Res> {
  _$RunCopyWithImpl(this._self, this._then);

  final Run _self;
  final $Res Function(Run) _then;

/// Create a copy of Run
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? day = null,Object? km = null,Object? pace = null,Object? dur = null,Object? kcal = null,Object? type = null,Object? year = null,Object? month = null,Object? coverImageType = null,Object? coverImageUrl = freezed,Object? marathonChallengeId = freezed,Object? marathonCourseId = freezed,Object? gpsVerified = freezed,Object? source = null,}) {
  return _then(Run(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,km: null == km ? _self.km : km // ignore: cast_nullable_to_non_nullable
as double,pace: null == pace ? _self.pace : pace // ignore: cast_nullable_to_non_nullable
as String,dur: null == dur ? _self.dur : dur // ignore: cast_nullable_to_non_nullable
as String,kcal: null == kcal ? _self.kcal : kcal // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecordType,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,coverImageType: null == coverImageType ? _self.coverImageType : coverImageType // ignore: cast_nullable_to_non_nullable
as CoverImageType,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,marathonChallengeId: freezed == marathonChallengeId ? _self.marathonChallengeId : marathonChallengeId // ignore: cast_nullable_to_non_nullable
as String?,marathonCourseId: freezed == marathonCourseId ? _self.marathonCourseId : marathonCourseId // ignore: cast_nullable_to_non_nullable
as String?,gpsVerified: freezed == gpsVerified ? _self.gpsVerified : gpsVerified // ignore: cast_nullable_to_non_nullable
as bool?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as RunSource,
  ));
}

}


/// Adds pattern-matching-related methods to [Run].
extension RunPatterns on Run {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Run value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Run() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Run value)  $default,){
final _that = this;
switch (_that) {
case _Run():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Run value)?  $default,){
final _that = this;
switch (_that) {
case _Run() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String date,  String day,  double km,  String pace,  String dur,  int kcal,  RecordType type,  int year,  int month,  CoverImageType coverImageType,  String? coverImageUrl,  String? marathonChallengeId,  String? marathonCourseId,  bool? gpsVerified,  RunSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Run() when $default != null:
return $default(_that.id,_that.date,_that.day,_that.km,_that.pace,_that.dur,_that.kcal,_that.type,_that.year,_that.month,_that.coverImageType,_that.coverImageUrl,_that.marathonChallengeId,_that.marathonCourseId,_that.gpsVerified,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String date,  String day,  double km,  String pace,  String dur,  int kcal,  RecordType type,  int year,  int month,  CoverImageType coverImageType,  String? coverImageUrl,  String? marathonChallengeId,  String? marathonCourseId,  bool? gpsVerified,  RunSource source)  $default,) {final _that = this;
switch (_that) {
case _Run():
return $default(_that.id,_that.date,_that.day,_that.km,_that.pace,_that.dur,_that.kcal,_that.type,_that.year,_that.month,_that.coverImageType,_that.coverImageUrl,_that.marathonChallengeId,_that.marathonCourseId,_that.gpsVerified,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String date,  String day,  double km,  String pace,  String dur,  int kcal,  RecordType type,  int year,  int month,  CoverImageType coverImageType,  String? coverImageUrl,  String? marathonChallengeId,  String? marathonCourseId,  bool? gpsVerified,  RunSource source)?  $default,) {final _that = this;
switch (_that) {
case _Run() when $default != null:
return $default(_that.id,_that.date,_that.day,_that.km,_that.pace,_that.dur,_that.kcal,_that.type,_that.year,_that.month,_that.coverImageType,_that.coverImageUrl,_that.marathonChallengeId,_that.marathonCourseId,_that.gpsVerified,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Run implements Run {
  const _Run({required this.id, required this.date, required this.day, required this.km, required this.pace, required this.dur, required this.kcal, required this.type, required this.year, required this.month, this.coverImageType = CoverImageType.route, this.coverImageUrl, this.marathonChallengeId, this.marathonCourseId, this.gpsVerified, this.source = RunSource.app});
  factory _Run.fromJson(Map<String, dynamic> json) => _$RunFromJson(json);

@override final  String id;
@override final  String date;
@override final  String day;
@override final  double km;
@override final  String pace;
@override final  String dur;
@override final  int kcal;
@override final  RecordType type;
@override final  int year;
@override final  int month;
@override@JsonKey() final  CoverImageType coverImageType;
@override final  String? coverImageUrl;
@override final  String? marathonChallengeId;
@override final  String? marathonCourseId;
@override final  bool? gpsVerified;
@override@JsonKey() final  RunSource source;

/// Create a copy of Run
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunCopyWith<_Run> get copyWith => __$RunCopyWithImpl<_Run>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RunToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Run&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.day, day) || other.day == day)&&(identical(other.km, km) || other.km == km)&&(identical(other.pace, pace) || other.pace == pace)&&(identical(other.dur, dur) || other.dur == dur)&&(identical(other.kcal, kcal) || other.kcal == kcal)&&(identical(other.type, type) || other.type == type)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.coverImageType, coverImageType) || other.coverImageType == coverImageType)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.marathonChallengeId, marathonChallengeId) || other.marathonChallengeId == marathonChallengeId)&&(identical(other.marathonCourseId, marathonCourseId) || other.marathonCourseId == marathonCourseId)&&(identical(other.gpsVerified, gpsVerified) || other.gpsVerified == gpsVerified)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,day,km,pace,dur,kcal,type,year,month,coverImageType,coverImageUrl,marathonChallengeId,marathonCourseId,gpsVerified,source);

@override
String toString() {
  return 'Run(id: $id, date: $date, day: $day, km: $km, pace: $pace, dur: $dur, kcal: $kcal, type: $type, year: $year, month: $month, coverImageType: $coverImageType, coverImageUrl: $coverImageUrl, marathonChallengeId: $marathonChallengeId, marathonCourseId: $marathonCourseId, gpsVerified: $gpsVerified, source: $source)';
}


}

/// @nodoc
abstract mixin class _$RunCopyWith<$Res> implements $RunCopyWith<$Res> {
  factory _$RunCopyWith(_Run value, $Res Function(_Run) _then) = __$RunCopyWithImpl;
@override @useResult
$Res call({
 String id, String date, String day, double km, String pace, String dur, int kcal, RecordType type, int year, int month, CoverImageType coverImageType, String? coverImageUrl, String? marathonChallengeId, String? marathonCourseId, bool? gpsVerified, RunSource source
});




}
/// @nodoc
class __$RunCopyWithImpl<$Res>
    implements _$RunCopyWith<$Res> {
  __$RunCopyWithImpl(this._self, this._then);

  final _Run _self;
  final $Res Function(_Run) _then;

/// Create a copy of Run
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? day = null,Object? km = null,Object? pace = null,Object? dur = null,Object? kcal = null,Object? type = null,Object? year = null,Object? month = null,Object? coverImageType = null,Object? coverImageUrl = freezed,Object? marathonChallengeId = freezed,Object? marathonCourseId = freezed,Object? gpsVerified = freezed,Object? source = null,}) {
  return _then(_Run(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,km: null == km ? _self.km : km // ignore: cast_nullable_to_non_nullable
as double,pace: null == pace ? _self.pace : pace // ignore: cast_nullable_to_non_nullable
as String,dur: null == dur ? _self.dur : dur // ignore: cast_nullable_to_non_nullable
as String,kcal: null == kcal ? _self.kcal : kcal // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecordType,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,coverImageType: null == coverImageType ? _self.coverImageType : coverImageType // ignore: cast_nullable_to_non_nullable
as CoverImageType,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,marathonChallengeId: freezed == marathonChallengeId ? _self.marathonChallengeId : marathonChallengeId // ignore: cast_nullable_to_non_nullable
as String?,marathonCourseId: freezed == marathonCourseId ? _self.marathonCourseId : marathonCourseId // ignore: cast_nullable_to_non_nullable
as String?,gpsVerified: freezed == gpsVerified ? _self.gpsVerified : gpsVerified // ignore: cast_nullable_to_non_nullable
as bool?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as RunSource,
  ));
}


}

// dart format on
