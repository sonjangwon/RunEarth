// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_day.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StreakDay {

 String get name; String get date; bool get ran; int? get consec; bool get today; bool get future;
/// Create a copy of StreakDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakDayCopyWith<StreakDay> get copyWith => _$StreakDayCopyWithImpl<StreakDay>(this as StreakDay, _$identity);

  /// Serializes this StreakDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakDay&&(identical(other.name, name) || other.name == name)&&(identical(other.date, date) || other.date == date)&&(identical(other.ran, ran) || other.ran == ran)&&(identical(other.consec, consec) || other.consec == consec)&&(identical(other.today, today) || other.today == today)&&(identical(other.future, future) || other.future == future));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,date,ran,consec,today,future);

@override
String toString() {
  return 'StreakDay(name: $name, date: $date, ran: $ran, consec: $consec, today: $today, future: $future)';
}


}

/// @nodoc
abstract mixin class $StreakDayCopyWith<$Res>  {
  factory $StreakDayCopyWith(StreakDay value, $Res Function(StreakDay) _then) = _$StreakDayCopyWithImpl;
@useResult
$Res call({
 String name, String date, bool ran, int? consec, bool today, bool future
});




}
/// @nodoc
class _$StreakDayCopyWithImpl<$Res>
    implements $StreakDayCopyWith<$Res> {
  _$StreakDayCopyWithImpl(this._self, this._then);

  final StreakDay _self;
  final $Res Function(StreakDay) _then;

/// Create a copy of StreakDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? date = null,Object? ran = null,Object? consec = freezed,Object? today = null,Object? future = null,}) {
  return _then(StreakDay(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,ran: null == ran ? _self.ran : ran // ignore: cast_nullable_to_non_nullable
as bool,consec: freezed == consec ? _self.consec : consec // ignore: cast_nullable_to_non_nullable
as int?,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as bool,future: null == future ? _self.future : future // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakDay].
extension StreakDayPatterns on StreakDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakDay value)  $default,){
final _that = this;
switch (_that) {
case _StreakDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakDay value)?  $default,){
final _that = this;
switch (_that) {
case _StreakDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String date,  bool ran,  int? consec,  bool today,  bool future)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakDay() when $default != null:
return $default(_that.name,_that.date,_that.ran,_that.consec,_that.today,_that.future);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String date,  bool ran,  int? consec,  bool today,  bool future)  $default,) {final _that = this;
switch (_that) {
case _StreakDay():
return $default(_that.name,_that.date,_that.ran,_that.consec,_that.today,_that.future);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String date,  bool ran,  int? consec,  bool today,  bool future)?  $default,) {final _that = this;
switch (_that) {
case _StreakDay() when $default != null:
return $default(_that.name,_that.date,_that.ran,_that.consec,_that.today,_that.future);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreakDay implements StreakDay {
  const _StreakDay({required this.name, required this.date, required this.ran, this.consec, this.today = false, this.future = false});
  factory _StreakDay.fromJson(Map<String, dynamic> json) => _$StreakDayFromJson(json);

@override final  String name;
@override final  String date;
@override final  bool ran;
@override final  int? consec;
@override@JsonKey() final  bool today;
@override@JsonKey() final  bool future;

/// Create a copy of StreakDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakDayCopyWith<_StreakDay> get copyWith => __$StreakDayCopyWithImpl<_StreakDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreakDayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakDay&&(identical(other.name, name) || other.name == name)&&(identical(other.date, date) || other.date == date)&&(identical(other.ran, ran) || other.ran == ran)&&(identical(other.consec, consec) || other.consec == consec)&&(identical(other.today, today) || other.today == today)&&(identical(other.future, future) || other.future == future));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,date,ran,consec,today,future);

@override
String toString() {
  return 'StreakDay(name: $name, date: $date, ran: $ran, consec: $consec, today: $today, future: $future)';
}


}

/// @nodoc
abstract mixin class _$StreakDayCopyWith<$Res> implements $StreakDayCopyWith<$Res> {
  factory _$StreakDayCopyWith(_StreakDay value, $Res Function(_StreakDay) _then) = __$StreakDayCopyWithImpl;
@override @useResult
$Res call({
 String name, String date, bool ran, int? consec, bool today, bool future
});




}
/// @nodoc
class __$StreakDayCopyWithImpl<$Res>
    implements _$StreakDayCopyWith<$Res> {
  __$StreakDayCopyWithImpl(this._self, this._then);

  final _StreakDay _self;
  final $Res Function(_StreakDay) _then;

/// Create a copy of StreakDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? date = null,Object? ran = null,Object? consec = freezed,Object? today = null,Object? future = null,}) {
  return _then(_StreakDay(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,ran: null == ran ? _self.ran : ran // ignore: cast_nullable_to_non_nullable
as bool,consec: freezed == consec ? _self.consec : consec // ignore: cast_nullable_to_non_nullable
as int?,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as bool,future: null == future ? _self.future : future // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
