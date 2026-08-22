// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marathon.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Marathon {

 String get id; String get courseId; String get name; String get distance; String get course; String get location; String get dday; String get prize; String get prizeEmoji; bool get joined; bool get ended; String get participants; String? get myRank; String? get myTime; String get img;
/// Create a copy of Marathon
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarathonCopyWith<Marathon> get copyWith => _$MarathonCopyWithImpl<Marathon>(this as Marathon, _$identity);

  /// Serializes this Marathon to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Marathon&&(identical(other.id, id) || other.id == id)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.course, course) || other.course == course)&&(identical(other.location, location) || other.location == location)&&(identical(other.dday, dday) || other.dday == dday)&&(identical(other.prize, prize) || other.prize == prize)&&(identical(other.prizeEmoji, prizeEmoji) || other.prizeEmoji == prizeEmoji)&&(identical(other.joined, joined) || other.joined == joined)&&(identical(other.ended, ended) || other.ended == ended)&&(identical(other.participants, participants) || other.participants == participants)&&(identical(other.myRank, myRank) || other.myRank == myRank)&&(identical(other.myTime, myTime) || other.myTime == myTime)&&(identical(other.img, img) || other.img == img));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,courseId,name,distance,course,location,dday,prize,prizeEmoji,joined,ended,participants,myRank,myTime,img);

@override
String toString() {
  return 'Marathon(id: $id, courseId: $courseId, name: $name, distance: $distance, course: $course, location: $location, dday: $dday, prize: $prize, prizeEmoji: $prizeEmoji, joined: $joined, ended: $ended, participants: $participants, myRank: $myRank, myTime: $myTime, img: $img)';
}


}

/// @nodoc
abstract mixin class $MarathonCopyWith<$Res>  {
  factory $MarathonCopyWith(Marathon value, $Res Function(Marathon) _then) = _$MarathonCopyWithImpl;
@useResult
$Res call({
 String id, String courseId, String name, String distance, String course, String location, String dday, String prize, String prizeEmoji, bool joined, bool ended, String participants, String? myRank, String? myTime, String img
});




}
/// @nodoc
class _$MarathonCopyWithImpl<$Res>
    implements $MarathonCopyWith<$Res> {
  _$MarathonCopyWithImpl(this._self, this._then);

  final Marathon _self;
  final $Res Function(Marathon) _then;

/// Create a copy of Marathon
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? courseId = null,Object? name = null,Object? distance = null,Object? course = null,Object? location = null,Object? dday = null,Object? prize = null,Object? prizeEmoji = null,Object? joined = null,Object? ended = null,Object? participants = null,Object? myRank = freezed,Object? myTime = freezed,Object? img = null,}) {
  return _then(Marathon(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as String,course: null == course ? _self.course : course // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,dday: null == dday ? _self.dday : dday // ignore: cast_nullable_to_non_nullable
as String,prize: null == prize ? _self.prize : prize // ignore: cast_nullable_to_non_nullable
as String,prizeEmoji: null == prizeEmoji ? _self.prizeEmoji : prizeEmoji // ignore: cast_nullable_to_non_nullable
as String,joined: null == joined ? _self.joined : joined // ignore: cast_nullable_to_non_nullable
as bool,ended: null == ended ? _self.ended : ended // ignore: cast_nullable_to_non_nullable
as bool,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as String,myRank: freezed == myRank ? _self.myRank : myRank // ignore: cast_nullable_to_non_nullable
as String?,myTime: freezed == myTime ? _self.myTime : myTime // ignore: cast_nullable_to_non_nullable
as String?,img: null == img ? _self.img : img // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Marathon].
extension MarathonPatterns on Marathon {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Marathon value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Marathon() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Marathon value)  $default,){
final _that = this;
switch (_that) {
case _Marathon():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Marathon value)?  $default,){
final _that = this;
switch (_that) {
case _Marathon() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String courseId,  String name,  String distance,  String course,  String location,  String dday,  String prize,  String prizeEmoji,  bool joined,  bool ended,  String participants,  String? myRank,  String? myTime,  String img)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Marathon() when $default != null:
return $default(_that.id,_that.courseId,_that.name,_that.distance,_that.course,_that.location,_that.dday,_that.prize,_that.prizeEmoji,_that.joined,_that.ended,_that.participants,_that.myRank,_that.myTime,_that.img);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String courseId,  String name,  String distance,  String course,  String location,  String dday,  String prize,  String prizeEmoji,  bool joined,  bool ended,  String participants,  String? myRank,  String? myTime,  String img)  $default,) {final _that = this;
switch (_that) {
case _Marathon():
return $default(_that.id,_that.courseId,_that.name,_that.distance,_that.course,_that.location,_that.dday,_that.prize,_that.prizeEmoji,_that.joined,_that.ended,_that.participants,_that.myRank,_that.myTime,_that.img);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String courseId,  String name,  String distance,  String course,  String location,  String dday,  String prize,  String prizeEmoji,  bool joined,  bool ended,  String participants,  String? myRank,  String? myTime,  String img)?  $default,) {final _that = this;
switch (_that) {
case _Marathon() when $default != null:
return $default(_that.id,_that.courseId,_that.name,_that.distance,_that.course,_that.location,_that.dday,_that.prize,_that.prizeEmoji,_that.joined,_that.ended,_that.participants,_that.myRank,_that.myTime,_that.img);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Marathon implements Marathon {
  const _Marathon({required this.id, required this.courseId, required this.name, required this.distance, required this.course, required this.location, required this.dday, required this.prize, required this.prizeEmoji, this.joined = false, this.ended = false, required this.participants, this.myRank, this.myTime, required this.img});
  factory _Marathon.fromJson(Map<String, dynamic> json) => _$MarathonFromJson(json);

@override final  String id;
@override final  String courseId;
@override final  String name;
@override final  String distance;
@override final  String course;
@override final  String location;
@override final  String dday;
@override final  String prize;
@override final  String prizeEmoji;
@override@JsonKey() final  bool joined;
@override@JsonKey() final  bool ended;
@override final  String participants;
@override final  String? myRank;
@override final  String? myTime;
@override final  String img;

/// Create a copy of Marathon
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarathonCopyWith<_Marathon> get copyWith => __$MarathonCopyWithImpl<_Marathon>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarathonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Marathon&&(identical(other.id, id) || other.id == id)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.course, course) || other.course == course)&&(identical(other.location, location) || other.location == location)&&(identical(other.dday, dday) || other.dday == dday)&&(identical(other.prize, prize) || other.prize == prize)&&(identical(other.prizeEmoji, prizeEmoji) || other.prizeEmoji == prizeEmoji)&&(identical(other.joined, joined) || other.joined == joined)&&(identical(other.ended, ended) || other.ended == ended)&&(identical(other.participants, participants) || other.participants == participants)&&(identical(other.myRank, myRank) || other.myRank == myRank)&&(identical(other.myTime, myTime) || other.myTime == myTime)&&(identical(other.img, img) || other.img == img));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,courseId,name,distance,course,location,dday,prize,prizeEmoji,joined,ended,participants,myRank,myTime,img);

@override
String toString() {
  return 'Marathon(id: $id, courseId: $courseId, name: $name, distance: $distance, course: $course, location: $location, dday: $dday, prize: $prize, prizeEmoji: $prizeEmoji, joined: $joined, ended: $ended, participants: $participants, myRank: $myRank, myTime: $myTime, img: $img)';
}


}

/// @nodoc
abstract mixin class _$MarathonCopyWith<$Res> implements $MarathonCopyWith<$Res> {
  factory _$MarathonCopyWith(_Marathon value, $Res Function(_Marathon) _then) = __$MarathonCopyWithImpl;
@override @useResult
$Res call({
 String id, String courseId, String name, String distance, String course, String location, String dday, String prize, String prizeEmoji, bool joined, bool ended, String participants, String? myRank, String? myTime, String img
});




}
/// @nodoc
class __$MarathonCopyWithImpl<$Res>
    implements _$MarathonCopyWith<$Res> {
  __$MarathonCopyWithImpl(this._self, this._then);

  final _Marathon _self;
  final $Res Function(_Marathon) _then;

/// Create a copy of Marathon
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? courseId = null,Object? name = null,Object? distance = null,Object? course = null,Object? location = null,Object? dday = null,Object? prize = null,Object? prizeEmoji = null,Object? joined = null,Object? ended = null,Object? participants = null,Object? myRank = freezed,Object? myTime = freezed,Object? img = null,}) {
  return _then(_Marathon(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as String,course: null == course ? _self.course : course // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,dday: null == dday ? _self.dday : dday // ignore: cast_nullable_to_non_nullable
as String,prize: null == prize ? _self.prize : prize // ignore: cast_nullable_to_non_nullable
as String,prizeEmoji: null == prizeEmoji ? _self.prizeEmoji : prizeEmoji // ignore: cast_nullable_to_non_nullable
as String,joined: null == joined ? _self.joined : joined // ignore: cast_nullable_to_non_nullable
as bool,ended: null == ended ? _self.ended : ended // ignore: cast_nullable_to_non_nullable
as bool,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as String,myRank: freezed == myRank ? _self.myRank : myRank // ignore: cast_nullable_to_non_nullable
as String?,myTime: freezed == myTime ? _self.myTime : myTime // ignore: cast_nullable_to_non_nullable
as String?,img: null == img ? _self.img : img // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
