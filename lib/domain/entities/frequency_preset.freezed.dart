// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'frequency_preset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FrequencyPreset {

/// Nama preset yang ditampilkan di UI.
 String get name;/// Frekuensi target dalam Hz (mis. 440, 432, 528).
 double get frequencyHz;
/// Create a copy of FrequencyPreset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FrequencyPresetCopyWith<FrequencyPreset> get copyWith => _$FrequencyPresetCopyWithImpl<FrequencyPreset>(this as FrequencyPreset, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FrequencyPreset;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FrequencyPreset&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.frequencyHz, _this.frequencyHz) || other.frequencyHz == _this.frequencyHz));
}


@override
int get hashCode {
  final _this = this as FrequencyPreset;
  return Object.hash(runtimeType,_this.name,_this.frequencyHz);
}

@override
String toString() {
  final _this = this as FrequencyPreset;
  return 'FrequencyPreset(name: ${_this.name}, frequencyHz: ${_this.frequencyHz})';
}


}

/// @nodoc
abstract mixin class $FrequencyPresetCopyWith<$Res>  {
  factory $FrequencyPresetCopyWith(FrequencyPreset value, $Res Function(FrequencyPreset) _then) = _$FrequencyPresetCopyWithImpl;
@useResult
$Res call({
 String name, double frequencyHz
});




}
/// @nodoc
class _$FrequencyPresetCopyWithImpl<$Res>
    implements $FrequencyPresetCopyWith<$Res> {
  _$FrequencyPresetCopyWithImpl(this._self, this._then);

  final FrequencyPreset _self;
  final $Res Function(FrequencyPreset) _then;

/// Create a copy of FrequencyPreset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? frequencyHz = null,}) {
  return _then(FrequencyPreset(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,frequencyHz: null == frequencyHz ? _self.frequencyHz : frequencyHz // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [FrequencyPreset].
extension FrequencyPresetPatterns on FrequencyPreset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FrequencyPreset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FrequencyPreset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FrequencyPreset value)  $default,){
final _that = this;
switch (_that) {
case _FrequencyPreset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FrequencyPreset value)?  $default,){
final _that = this;
switch (_that) {
case _FrequencyPreset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double frequencyHz)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FrequencyPreset() when $default != null:
return $default(_that.name,_that.frequencyHz);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double frequencyHz)  $default,) {final _that = this;
switch (_that) {
case _FrequencyPreset():
return $default(_that.name,_that.frequencyHz);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double frequencyHz)?  $default,) {final _that = this;
switch (_that) {
case _FrequencyPreset() when $default != null:
return $default(_that.name,_that.frequencyHz);case _:
  return null;

}
}

}

/// @nodoc


class _FrequencyPreset extends FrequencyPreset {
  const _FrequencyPreset({required this.name, required this.frequencyHz}): super._();
  

/// Nama preset yang ditampilkan di UI.
@override final  String name;
/// Frekuensi target dalam Hz (mis. 440, 432, 528).
@override final  double frequencyHz;

/// Create a copy of FrequencyPreset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FrequencyPresetCopyWith<_FrequencyPreset> get copyWith => __$FrequencyPresetCopyWithImpl<_FrequencyPreset>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FrequencyPreset&&(identical(other.name, name) || other.name == name)&&(identical(other.frequencyHz, frequencyHz) || other.frequencyHz == frequencyHz));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,frequencyHz);
}

@override
String toString() {
    return 'FrequencyPreset(name: $name, frequencyHz: $frequencyHz)';
}


}

/// @nodoc
abstract mixin class _$FrequencyPresetCopyWith<$Res> implements $FrequencyPresetCopyWith<$Res> {
  factory _$FrequencyPresetCopyWith(_FrequencyPreset value, $Res Function(_FrequencyPreset) _then) = __$FrequencyPresetCopyWithImpl;
@override @useResult
$Res call({
 String name, double frequencyHz
});




}
/// @nodoc
class __$FrequencyPresetCopyWithImpl<$Res>
    implements _$FrequencyPresetCopyWith<$Res> {
  __$FrequencyPresetCopyWithImpl(this._self, this._then);

  final _FrequencyPreset _self;
  final $Res Function(_FrequencyPreset) _then;

/// Create a copy of FrequencyPreset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? frequencyHz = null,}) {
  return _then(_FrequencyPreset(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,frequencyHz: null == frequencyHz ? _self.frequencyHz : frequencyHz // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
