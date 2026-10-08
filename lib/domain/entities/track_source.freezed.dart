// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrackSource {

/// Absolute path atau `content://` URI berkas audio.
 String get filePath;/// Durasi dalam milidetik jika diketahui saat pemindaian.
 int? get durationMs;/// ID MediaStore lagu — dipakai mengambil sampul album via
/// `on_audio_query.queryArtwork` (task 3.4). `null` bila trek tidak
/// berasal dari MediaStore (mis. dipilih via SAF).
 int? get mediaStoreId;
/// Create a copy of TrackSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackSourceCopyWith<TrackSource> get copyWith => _$TrackSourceCopyWithImpl<TrackSource>(this as TrackSource, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TrackSource;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackSource&&(identical(other.filePath, _this.filePath) || other.filePath == _this.filePath)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.mediaStoreId, _this.mediaStoreId) || other.mediaStoreId == _this.mediaStoreId));
}


@override
int get hashCode {
  final _this = this as TrackSource;
  return Object.hash(runtimeType,_this.filePath,_this.durationMs,_this.mediaStoreId);
}

@override
String toString() {
  final _this = this as TrackSource;
  return 'TrackSource(filePath: ${_this.filePath}, durationMs: ${_this.durationMs}, mediaStoreId: ${_this.mediaStoreId})';
}


}

/// @nodoc
abstract mixin class $TrackSourceCopyWith<$Res>  {
  factory $TrackSourceCopyWith(TrackSource value, $Res Function(TrackSource) _then) = _$TrackSourceCopyWithImpl;
@useResult
$Res call({
 String filePath, int? durationMs, int? mediaStoreId
});




}
/// @nodoc
class _$TrackSourceCopyWithImpl<$Res>
    implements $TrackSourceCopyWith<$Res> {
  _$TrackSourceCopyWithImpl(this._self, this._then);

  final TrackSource _self;
  final $Res Function(TrackSource) _then;

/// Create a copy of TrackSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filePath = null,Object? durationMs = freezed,Object? mediaStoreId = freezed,}) {
  return _then(TrackSource.local(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,mediaStoreId: freezed == mediaStoreId ? _self.mediaStoreId : mediaStoreId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackSource].
extension TrackSourcePatterns on TrackSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LocalSource value)?  local,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LocalSource() when local != null:
return local(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LocalSource value)  local,}){
final _that = this;
switch (_that) {
case LocalSource():
return local(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LocalSource value)?  local,}){
final _that = this;
switch (_that) {
case LocalSource() when local != null:
return local(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String filePath,  int? durationMs,  int? mediaStoreId)?  local,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LocalSource() when local != null:
return local(_that.filePath,_that.durationMs,_that.mediaStoreId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String filePath,  int? durationMs,  int? mediaStoreId)  local,}) {final _that = this;
switch (_that) {
case LocalSource():
return local(_that.filePath,_that.durationMs,_that.mediaStoreId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String filePath,  int? durationMs,  int? mediaStoreId)?  local,}) {final _that = this;
switch (_that) {
case LocalSource() when local != null:
return local(_that.filePath,_that.durationMs,_that.mediaStoreId);case _:
  return null;

}
}

}

/// @nodoc


class LocalSource implements TrackSource {
  const LocalSource({required this.filePath, this.durationMs, this.mediaStoreId});
  

/// Absolute path atau `content://` URI berkas audio.
@override final  String filePath;
/// Durasi dalam milidetik jika diketahui saat pemindaian.
@override final  int? durationMs;
/// ID MediaStore lagu — dipakai mengambil sampul album via
/// `on_audio_query.queryArtwork` (task 3.4). `null` bila trek tidak
/// berasal dari MediaStore (mis. dipilih via SAF).
@override final  int? mediaStoreId;

/// Create a copy of TrackSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalSourceCopyWith<LocalSource> get copyWith => _$LocalSourceCopyWithImpl<LocalSource>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalSource&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.mediaStoreId, mediaStoreId) || other.mediaStoreId == mediaStoreId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,filePath,durationMs,mediaStoreId);
}

@override
String toString() {
    return 'TrackSource.local(filePath: $filePath, durationMs: $durationMs, mediaStoreId: $mediaStoreId)';
}


}

/// @nodoc
abstract mixin class $LocalSourceCopyWith<$Res> implements $TrackSourceCopyWith<$Res> {
  factory $LocalSourceCopyWith(LocalSource value, $Res Function(LocalSource) _then) = _$LocalSourceCopyWithImpl;
@override @useResult
$Res call({
 String filePath, int? durationMs, int? mediaStoreId
});




}
/// @nodoc
class _$LocalSourceCopyWithImpl<$Res>
    implements $LocalSourceCopyWith<$Res> {
  _$LocalSourceCopyWithImpl(this._self, this._then);

  final LocalSource _self;
  final $Res Function(LocalSource) _then;

/// Create a copy of TrackSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filePath = null,Object? durationMs = freezed,Object? mediaStoreId = freezed,}) {
  return _then(LocalSource(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,mediaStoreId: freezed == mediaStoreId ? _self.mediaStoreId : mediaStoreId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
