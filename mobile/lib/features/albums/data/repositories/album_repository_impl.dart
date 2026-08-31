import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:multai_mobile/core/storage/app_local_storage.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/album_entity.dart';
import '../../domain/repositories/album_repository.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final AppLocalStorage _localStorage;
  static const String _albumsKey = 'user_albums';

  AlbumRepositoryImpl({required AppLocalStorage localStorage})
      : _localStorage = localStorage;

  @override
  Future<Either<Failure, List<AlbumEntity>>> getAlbums() async {
    try {
      final data = _localStorage.getString(_albumsKey);
      if (data == null || data.isEmpty) return const Right([]);

      final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
      final albums = jsonList
          .map((e) => AlbumEntity.fromJson(e as Map<String, dynamic>))
          .toList();

      albums.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(albums);
    } catch (e) {
      debugPrint('Failed to load albums: $e');
      return Left(CacheFailure('Failed to load albums: $e'));
    }
  }

  @override
  Future<Either<Failure, AlbumEntity>> createAlbum(String name) async {
    try {
      if (name.trim().isEmpty) {
        return const Left(ValidationFailure('Album name cannot be empty'));
      }

      final existing = await getAlbums();
      return existing.fold(
        (failure) => Left(failure),
        (albums) async {
          final exists = albums.any(
            (a) => a.name.toLowerCase() == name.trim().toLowerCase(),
          );
          if (exists) {
            return const Left(
              ValidationFailure('An album with this name already exists'),
            );
          }

          final album = AlbumEntity(
            name: name.trim(),
            photoCount: 0,
            createdAt: DateTime.now(),
          );

          final updated = [album, ...albums];
          await _saveAlbums(updated);

          return Right(album);
        },
      );
    } catch (e) {
      debugPrint('Failed to create album: $e');
      return Left(CacheFailure('Failed to create album: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addPhotosToAlbum(
    String albumName,
    List<String> photoPaths,
  ) async {
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          return const Left(
            ValidationFailure('Gallery permission is required'),
          );
        }
      }

      for (final path in photoPaths) {
        final file = File(path);
        if (!await file.exists()) continue;

        final bytes = await file.readAsBytes();
        await Gal.putImageBytes(
          bytes,
          album: 'MultAI/$albumName',
        );
      }

      // Update album metadata
      final albumsResult = await getAlbums();
      await albumsResult.fold(
        (failure) {},
        (albums) async {
          final updated = albums.map((a) {
            if (a.name == albumName) {
              return a.copyWith(
                photoCount: a.photoCount + photoPaths.length,
                coverPhotoPath: a.coverPhotoPath ?? photoPaths.first,
              );
            }
            return a;
          }).toList();
          await _saveAlbums(updated);
        },
      );

      return const Right(null);
    } catch (e) {
      debugPrint('Failed to add photos to album: $e');
      return Left(CacheFailure('Failed to add photos: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAlbumPhotos(
    String albumName,
  ) async {
    try {
      final dir = await _getAlbumDir(albumName);
      if (!await dir.exists()) return const Right([]);

      final files = await dir
          .list()
          .where((e) => e is File)
          .cast<File>()
          .toList();

      return Right(files.map((f) => f.path).toList());
    } catch (e) {
      debugPrint('Failed to get album photos: $e');
      return Left(CacheFailure('Failed to get album photos: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAlbum(String name) async {
    try {
      final albumsResult = await getAlbums();
      return await albumsResult.fold(
        (failure) async => Left(failure),
        (albums) async {
          final updated = albums.where((a) => a.name != name).toList();
          await _saveAlbums(updated);

          // Try to delete local album directory if it exists
          try {
            final dir = await _getAlbumDir(name);
            if (await dir.exists()) {
              await dir.delete(recursive: true);
            }
          } catch (_) {}

          return const Right(null);
        },
      );
    } catch (e) {
      debugPrint('Failed to delete album: $e');
      return Left(CacheFailure('Failed to delete album: $e'));
    }
  }

  Future<void> _saveAlbums(List<AlbumEntity> albums) async {
    final jsonList = albums.map((a) => a.toJson()).toList();
    await _localStorage.setString(_albumsKey, jsonEncode(jsonList));
  }

  Future<Directory> _getAlbumDir(String albumName) async {
    final base = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getApplicationCacheDirectory();
    return Directory('${base.path}/album_${albumName.replaceAll(' ', '_')}');
  }
}
