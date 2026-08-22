// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ThemeRun {

 String get id; String get emoji; String get name; String get desc; double get km; String get img; List<LatLngPoint> get courseRoute;
/// Create a copy of ThemeRun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemeRunCopyWith<ThemeRun> get copyWith => _$ThemeRunCopyWithImpl<ThemeRun>(this as ThemeRun, _$identity);

  /// Serializes this ThemeRun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeRun&&(identical(other.id, id) || other.id == id)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.name, name) || other.name == name)&&(identical(other.desc, desc) || other.desc == desc)&&(identical(other.km, km) || other.km == km)&&(identical(other.img, img) || other.img == img)&&const DeepCollectionEquality().equals(other.courseRoute, courseRoute));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,emoji,name,desc,km,img,const DeepCollectionEquality().hash(courseRoute));

@override
String toString() {
  return 'ThemeRun(id: $id, emoji: $emoji, name: $name, desc: $desc, km: $km, img: $img, courseRoute: $courseRoute)';
}


}

/// @nodoc
abstract mixin class $ThemeRunCopyWith<$Res>  {
  factory $ThemeRunCopyWith(ThemeRun value, $Res Function(ThemeRun) _then) = _$ThemeRunCopyWithImpl;
@useResult
$Res call({
 String id, String emoji, String name, String desc, double km, String img, List<LatLngPoint> courseRoute
});




}
/// @nodoc
class _$ThemeRunCopyWithImpl<$Res>
    implements $ThemeRunCopyWith<$Res> {
  _$ThemeRunCopyWithImpl(this._self, this._then);

  final ThemeRun _self;
  final $Res Function(ThemeRun) _then;

/// Create a copy of ThemeRun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? emoji = null,Object? name = null,Object? desc = null,Object? km = null,Object? img = null,Object? courseRoute = null,}) {
  return _then(ThemeRun(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,desc: null == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as String,km: null == km ? _self.km : km // ignore: cast_nullable_to_non_nullable
as double,img: null == img ? _self.img : img // ignore: cast_nullable_to_non_nullable
as String,courseRoute: null == courseRoute ? _self.courseRoute : courseRoute // ignore: cast_nullable_to_non_nullable
as List<LatLngPoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [ThemeRun].
extension ThemeRunPatterns on ThemeRun {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeRun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeRun() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeRun value)  $default,){
final _that = this;
switch (_that) {
case _ThemeRun():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeRun value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeRun() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String emoji,  String name,  String desc,  double km,  String img,  List<LatLngPoint> courseRoute)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeRun() when $default != null:
return $default(_that.id,_that.emoji,_that.name,_that.desc,_that.km,_that.img,_that.courseRoute);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String emoji,  String name,  String desc,  double km,  String img,  List<LatLngPoint> courseRoute)  $default,) {final _that = this;
switch (_that) {
case _ThemeRun():
return $default(_that.id,_that.emoji,_that.name,_that.desc,_that.km,_that.img,_that.courseRoute);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String emoji,  String name,  String desc,  double km,  String img,  List<LatLngPoint> courseRoute)?  $default,) {final _that = this;
switch (_that) {
case _ThemeRun() when $default != null:
return $default(_that.id,_that.emoji,_that.name,_that.desc,_that.km,_that.img,_that.courseRoute);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThemeRun implements ThemeRun {
  const _ThemeRun({required this.id, required this.emoji, required this.name, required this.desc, required this.km, required this.img,  List<LatLngPoint> courseRoute = const <LatLngPoint>[]}): _courseRoute = courseRoute;
  factory _ThemeRun.fromJson(Map<String, dynamic> json) => _$ThemeRunFromJson(json);

@override final  String id;
@override final  String emoji;
@override final  String name;
@override final  String desc;
@override final  double km;
@override final  String img;
 final  List<LatLngPoint> _courseRoute;
@override@JsonKey() List<LatLngPoint> get courseRoute {
  if (_courseRoute is EqualUnmodifiableListView) return _courseRoute;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_courseRoute);
}


/// Create a copy of ThemeRun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemeRunCopyWith<_ThemeRun> get copyWith => __$ThemeRunCopyWithImpl<_ThemeRun>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThemeRunToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeRun&&(identical(other.id, id) || other.id == id)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.name, name) || other.name == name)&&(identical(other.desc, desc) || other.desc == desc)&&(identical(other.km, km) || other.km == km)&&(identical(other.img, img) || other.img == img)&&const DeepCollectionEquality().equals(other._courseRoute, _courseRoute));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,emoji,name,desc,km,img,const DeepCollectionEquality().hash(_courseRoute));

@override
String toString() {
  return 'ThemeRun(id: $id, emoji: $emoji, name: $name, desc: $desc, km: $km, img: $img, courseRoute: $courseRoute)';
}


}

/// @nodoc
abstract mixin class _$ThemeRunCopyWith<$Res> implements $ThemeRunCopyWith<$Res> {
  factory _$ThemeRunCopyWith(_ThemeRun value, $Res Function(_ThemeRun) _then) = __$ThemeRunCopyWithImpl;
@override @useResult
$Res call({
 String id, String emoji, String name, String desc, double km, String img, List<LatLngPoint> courseRoute
});




}
/// @nodoc
class __$ThemeRunCopyWithImpl<$Res>
    implements _$ThemeRunCopyWith<$Res> {
  __$ThemeRunCopyWithImpl(this._self, this._then);

  final _ThemeRun _self;
  final $Res Function(_ThemeRun) _then;

/// Create a copy of ThemeRun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? emoji = null,Object? name = null,Object? desc = null,Object? km = null,Object? img = null,Object? courseRoute = null,}) {
  return _then(_ThemeRun(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,desc: null == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as String,km: null == km ? _self.km : km // ignore: cast_nullable_to_non_nullable
as double,img: null == img ? _self.img : img // ignore: cast_nullable_to_non_nullable
as String,courseRoute: null == courseRoute ? _self._courseRoute : courseRoute // ignore: cast_nullable_to_non_nullable
as List<LatLngPoint>,
  ));
}


}

// dart format on
