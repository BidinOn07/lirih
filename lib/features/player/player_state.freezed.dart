// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerState {

/// Antrean trek yang sedang dimainkan.
 List<Track> get queue;/// Indeks trek aktif; `-1` bila belum ada trek.
 int get currentIndex;/// Sedang memutar?
 bool get isPlaying;/// Posisi playback (milidetik).
 int get positionMs;/// Durasi trek aktif (milidetik).
 int get durationMs;/// Frekuensi penalaan aktif (default A4 internasional).
 double get frequencyHz;/// Mode pengulangan antrean (task 1.11).
 LoopMode get repeatMode;
/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerStateCopyWith<PlayerState> get copyWith => _$PlayerStateCopyWithImpl<PlayerState>(this as PlayerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlayerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerState&&const DeepCollectionEquality().equals(other.queue, _this.queue)&&(identical(other.currentIndex, _this.currentIndex) || other.currentIndex == _this.currentIndex)&&(identical(other.isPlaying, _this.isPlaying) || other.isPlaying == _this.isPlaying)&&(identical(other.positionMs, _this.positionMs) || other.positionMs == _this.positionMs)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.frequencyHz, _this.frequencyHz) || other.frequencyHz == _this.frequencyHz)&&(identical(other.repeatMode, _this.repeatMode) || other.repeatMode == _this.repeatMode));
}


@override
int get hashCode {
  final _this = this as PlayerState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.queue),_this.currentIndex,_this.isPlaying,_this.positionMs,_this.durationMs,_this.frequencyHz,_this.repeatMode);
}

@override
String toString() {
  final _this = this as PlayerState;
  return 'PlayerState(queue: ${_this.queue}, currentIndex: ${_this.currentIndex}, isPlaying: ${_this.isPlaying}, positionMs: ${_this.positionMs}, durationMs: ${_this.durationMs}, frequencyHz: ${_this.frequencyHz}, repeatMode: ${_this.repeatMode})';
}


}

/// @nodoc
abstract mixin class $PlayerStateCopyWith<$Res>  {
  factory $PlayerStateCopyWith(PlayerState value, $Res Function(PlayerState) _then) = _$PlayerStateCopyWithImpl;
@useResult
$Res call({
 List<Track> queue, int currentIndex, bool isPlaying, int positionMs, int durationMs, double frequencyHz, LoopMode repeatMode
});




}
/// @nodoc
class _$PlayerStateCopyWithImpl<$Res>
    implements $PlayerStateCopyWith<$Res> {
  _$PlayerStateCopyWithImpl(this._self, this._then);

  final PlayerState _self;
  final $Res Function(PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? queue = null,Object? currentIndex = null,Object? isPlaying = null,Object? positionMs = null,Object? durationMs = null,Object? frequencyHz = null,Object? repeatMode = null,}) {
  return _then(PlayerState(
queue: null == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as List<Track>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,positionMs: null == positionMs ? _self.positionMs : positionMs // ignore: cast_nullable_to_non_nullable
as int,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,frequencyHz: null == frequencyHz ? _self.frequencyHz : frequencyHz // ignore: cast_nullable_to_non_nullable
as double,repeatMode: null == repeatMode ? _self.repeatMode : repeatMode // ignore: cast_nullable_to_non_nullable
as LoopMode,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerState].
extension PlayerStatePatterns on PlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerState value)  $default,){
final _that = this;
switch (_that) {
case _PlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Track> queue,  int currentIndex,  bool isPlaying,  int positionMs,  int durationMs,  double frequencyHz,  LoopMode repeatMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.queue,_that.currentIndex,_that.isPlaying,_that.positionMs,_that.durationMs,_that.frequencyHz,_that.repeatMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Track> queue,  int currentIndex,  bool isPlaying,  int positionMs,  int durationMs,  double frequencyHz,  LoopMode repeatMode)  $default,) {final _that = this;
switch (_that) {
case _PlayerState():
return $default(_that.queue,_that.currentIndex,_that.isPlaying,_that.positionMs,_that.durationMs,_that.frequencyHz,_that.repeatMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Track> queue,  int currentIndex,  bool isPlaying,  int positionMs,  int durationMs,  double frequencyHz,  LoopMode repeatMode)?  $default,) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.queue,_that.currentIndex,_that.isPlaying,_that.positionMs,_that.durationMs,_that.frequencyHz,_that.repeatMode);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerState extends PlayerState {
  const _PlayerState({required  List<Track> queue, this.currentIndex = -1, this.isPlaying = false, this.positionMs = 0, this.durationMs = 0, this.frequencyHz = kReferenceFrequencyHz, this.repeatMode = LoopMode.off}): _queue = queue,super._();
  

/// Antrean trek yang sedang dimainkan.
 final  List<Track> _queue;
/// Antrean trek yang sedang dimainkan.
@override List<Track> get queue {
  if (_queue is EqualUnmodifiableListView) return _queue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queue);
}

/// Indeks trek aktif; `-1` bila belum ada trek.
@override@JsonKey() final  int currentIndex;
/// Sedang memutar?
@override@JsonKey() final  bool isPlaying;
/// Posisi playback (milidetik).
@override@JsonKey() final  int positionMs;
/// Durasi trek aktif (milidetik).
@override@JsonKey() final  int durationMs;
/// Frekuensi penalaan aktif (default A4 internasional).
@override@JsonKey() final  double frequencyHz;
/// Mode pengulangan antrean (task 1.11).
@override@JsonKey() final  LoopMode repeatMode;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerStateCopyWith<_PlayerState> get copyWith => __$PlayerStateCopyWithImpl<_PlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerState&&const DeepCollectionEquality().equals(other.queue, _queue)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.positionMs, positionMs) || other.positionMs == positionMs)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.frequencyHz, frequencyHz) || other.frequencyHz == frequencyHz)&&(identical(other.repeatMode, repeatMode) || other.repeatMode == repeatMode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_queue),currentIndex,isPlaying,positionMs,durationMs,frequencyHz,repeatMode);
}

@override
String toString() {
    return 'PlayerState(queue: $queue, currentIndex: $currentIndex, isPlaying: $isPlaying, positionMs: $positionMs, durationMs: $durationMs, frequencyHz: $frequencyHz, repeatMode: $repeatMode)';
}


}

/// @nodoc
abstract mixin class _$PlayerStateCopyWith<$Res> implements $PlayerStateCopyWith<$Res> {
  factory _$PlayerStateCopyWith(_PlayerState value, $Res Function(_PlayerState) _then) = __$PlayerStateCopyWithImpl;
@override @useResult
$Res call({
 List<Track> queue, int currentIndex, bool isPlaying, int positionMs, int durationMs, double frequencyHz, LoopMode repeatMode
});




}
/// @nodoc
class __$PlayerStateCopyWithImpl<$Res>
    implements _$PlayerStateCopyWith<$Res> {
  __$PlayerStateCopyWithImpl(this._self, this._then);

  final _PlayerState _self;
  final $Res Function(_PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? queue = null,Object? currentIndex = null,Object? isPlaying = null,Object? positionMs = null,Object? durationMs = null,Object? frequencyHz = null,Object? repeatMode = null,}) {
  return _then(_PlayerState(
queue: null == queue ? _self._queue : queue // ignore: cast_nullable_to_non_nullable
as List<Track>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,positionMs: null == positionMs ? _self.positionMs : positionMs // ignore: cast_nullable_to_non_nullable
as int,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,frequencyHz: null == frequencyHz ? _self.frequencyHz : frequencyHz // ignore: cast_nullable_to_non_nullable
as double,repeatMode: null == repeatMode ? _self.repeatMode : repeatMode // ignore: cast_nullable_to_non_nullable
as LoopMode,
  ));
}


}

// dart format on
