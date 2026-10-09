// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Track {

/// Identifier unik aplikasi (UUID v4).
 String get id;/// Judul trek.
 String get title;/// Nama artis; `'<unknown>'` bila tak diketahui.
 String get artist;/// Sumber berkas audio.
 TrackSource get source;/// Nama album, `null` bila tak diketahui.
 String? get album;/// Nomor trek dalam album (tag `TRK`), `null` bila tak diketahui.
/// Dipakai mengurutkan lagu dalam tampilan album (task 3.1).
 int? get trackNumber;/// Ekstensi berkas audio tanpa titik — mis. `mp3`, `flac`, `opus`.
/// Dipakai menampilkan codec pada info lagu (task 3.1). Nilai ini
/// diambil dari MediaStore, bukan nama berkas.
 String? get fileExtension;/// URI sampul album (content:// dari MediaStore). `null` bila tak ada.
 String? get artUri;/// Durasi dalam milidetik.
 int? get durationMs;/// Terakhir diputar — dipakai tab "Putar terakhir" (task 2.6).
 DateTime? get lastPlayedAt;
/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackCopyWith<Track> get copyWith => _$TrackCopyWithImpl<Track>(this as Track, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Track;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Track&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.artist, _this.artist) || other.artist == _this.artist)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.album, _this.album) || other.album == _this.album)&&(identical(other.trackNumber, _this.trackNumber) || other.trackNumber == _this.trackNumber)&&(identical(other.fileExtension, _this.fileExtension) || other.fileExtension == _this.fileExtension)&&(identical(other.artUri, _this.artUri) || other.artUri == _this.artUri)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.lastPlayedAt, _this.lastPlayedAt) || other.lastPlayedAt == _this.lastPlayedAt));
}


@override
int get hashCode {
  final _this = this as Track;
  return Object.hash(runtimeType,_this.id,_this.title,_this.artist,_this.source,_this.album,_this.trackNumber,_this.fileExtension,_this.artUri,_this.durationMs,_this.lastPlayedAt);
}

@override
String toString() {
  final _this = this as Track;
  return 'Track(id: ${_this.id}, title: ${_this.title}, artist: ${_this.artist}, source: ${_this.source}, album: ${_this.album}, trackNumber: ${_this.trackNumber}, fileExtension: ${_this.fileExtension}, artUri: ${_this.artUri}, durationMs: ${_this.durationMs}, lastPlayedAt: ${_this.lastPlayedAt})';
}


}

/// @nodoc
abstract mixin class $TrackCopyWith<$Res>  {
  factory $TrackCopyWith(Track value, $Res Function(Track) _then) = _$TrackCopyWithImpl;
@useResult
$Res call({
 String id, String title, String artist, TrackSource source, String? album, int? trackNumber, String? fileExtension, String? artUri, int? durationMs, DateTime? lastPlayedAt
});


$TrackSourceCopyWith<$Res> get source;

}
/// @nodoc
class _$TrackCopyWithImpl<$Res>
    implements $TrackCopyWith<$Res> {
  _$TrackCopyWithImpl(this._self, this._then);

  final Track _self;
  final $Res Function(Track) _then;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? source = null,Object? album = freezed,Object? trackNumber = freezed,Object? fileExtension = freezed,Object? artUri = freezed,Object? durationMs = freezed,Object? lastPlayedAt = freezed,}) {
  return _then(Track(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TrackSource,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String?,trackNumber: freezed == trackNumber ? _self.trackNumber : trackNumber // ignore: cast_nullable_to_non_nullable
as int?,fileExtension: freezed == fileExtension ? _self.fileExtension : fileExtension // ignore: cast_nullable_to_non_nullable
as String?,artUri: freezed == artUri ? _self.artUri : artUri // ignore: cast_nullable_to_non_nullable
as String?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,lastPlayedAt: freezed == lastPlayedAt ? _self.lastPlayedAt : lastPlayedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackSourceCopyWith<$Res> get source {
  
  return $TrackSourceCopyWith<$Res>(_self.source, (value) {
    return _then(_self.copyWith(source: value));
  });
}
}


/// Adds pattern-matching-related methods to [Track].
extension TrackPatterns on Track {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Track value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Track() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Track value)  $default,){
final _that = this;
switch (_that) {
case _Track():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Track value)?  $default,){
final _that = this;
switch (_that) {
case _Track() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String artist,  TrackSource source,  String? album,  int? trackNumber,  String? fileExtension,  String? artUri,  int? durationMs,  DateTime? lastPlayedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.source,_that.album,_that.trackNumber,_that.fileExtension,_that.artUri,_that.durationMs,_that.lastPlayedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String artist,  TrackSource source,  String? album,  int? trackNumber,  String? fileExtension,  String? artUri,  int? durationMs,  DateTime? lastPlayedAt)  $default,) {final _that = this;
switch (_that) {
case _Track():
return $default(_that.id,_that.title,_that.artist,_that.source,_that.album,_that.trackNumber,_that.fileExtension,_that.artUri,_that.durationMs,_that.lastPlayedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String artist,  TrackSource source,  String? album,  int? trackNumber,  String? fileExtension,  String? artUri,  int? durationMs,  DateTime? lastPlayedAt)?  $default,) {final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.source,_that.album,_that.trackNumber,_that.fileExtension,_that.artUri,_that.durationMs,_that.lastPlayedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Track extends Track {
  const _Track({required this.id, required this.title, required this.artist, required this.source, this.album, this.trackNumber, this.fileExtension, this.artUri, this.durationMs, this.lastPlayedAt}): super._();
  

/// Identifier unik aplikasi (UUID v4).
@override final  String id;
/// Judul trek.
@override final  String title;
/// Nama artis; `'<unknown>'` bila tak diketahui.
@override final  String artist;
/// Sumber berkas audio.
@override final  TrackSource source;
/// Nama album, `null` bila tak diketahui.
@override final  String? album;
/// Nomor trek dalam album (tag `TRK`), `null` bila tak diketahui.
/// Dipakai mengurutkan lagu dalam tampilan album (task 3.1).
@override final  int? trackNumber;
/// Ekstensi berkas audio tanpa titik — mis. `mp3`, `flac`, `opus`.
/// Dipakai menampilkan codec pada info lagu (task 3.1). Nilai ini
/// diambil dari MediaStore, bukan nama berkas.
@override final  String? fileExtension;
/// URI sampul album (content:// dari MediaStore). `null` bila tak ada.
@override final  String? artUri;
/// Durasi dalam milidetik.
@override final  int? durationMs;
/// Terakhir diputar — dipakai tab "Putar terakhir" (task 2.6).
@override final  DateTime? lastPlayedAt;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackCopyWith<_Track> get copyWith => __$TrackCopyWithImpl<_Track>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Track&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.source, source) || other.source == source)&&(identical(other.album, album) || other.album == album)&&(identical(other.trackNumber, trackNumber) || other.trackNumber == trackNumber)&&(identical(other.fileExtension, fileExtension) || other.fileExtension == fileExtension)&&(identical(other.artUri, artUri) || other.artUri == artUri)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.lastPlayedAt, lastPlayedAt) || other.lastPlayedAt == lastPlayedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,artist,source,album,trackNumber,fileExtension,artUri,durationMs,lastPlayedAt);
}

@override
String toString() {
    return 'Track(id: $id, title: $title, artist: $artist, source: $source, album: $album, trackNumber: $trackNumber, fileExtension: $fileExtension, artUri: $artUri, durationMs: $durationMs, lastPlayedAt: $lastPlayedAt)';
}


}

/// @nodoc
abstract mixin class _$TrackCopyWith<$Res> implements $TrackCopyWith<$Res> {
  factory _$TrackCopyWith(_Track value, $Res Function(_Track) _then) = __$TrackCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String artist, TrackSource source, String? album, int? trackNumber, String? fileExtension, String? artUri, int? durationMs, DateTime? lastPlayedAt
});


@override $TrackSourceCopyWith<$Res> get source;

}
/// @nodoc
class __$TrackCopyWithImpl<$Res>
    implements _$TrackCopyWith<$Res> {
  __$TrackCopyWithImpl(this._self, this._then);

  final _Track _self;
  final $Res Function(_Track) _then;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? source = null,Object? album = freezed,Object? trackNumber = freezed,Object? fileExtension = freezed,Object? artUri = freezed,Object? durationMs = freezed,Object? lastPlayedAt = freezed,}) {
  return _then(_Track(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TrackSource,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String?,trackNumber: freezed == trackNumber ? _self.trackNumber : trackNumber // ignore: cast_nullable_to_non_nullable
as int?,fileExtension: freezed == fileExtension ? _self.fileExtension : fileExtension // ignore: cast_nullable_to_non_nullable
as String?,artUri: freezed == artUri ? _self.artUri : artUri // ignore: cast_nullable_to_non_nullable
as String?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,lastPlayedAt: freezed == lastPlayedAt ? _self.lastPlayedAt : lastPlayedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackSourceCopyWith<$Res> get source {
  
  return $TrackSourceCopyWith<$Res>(_self.source, (value) {
    return _then(_self.copyWith(source: value));
  });
}
}

// dart format on
