import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multai_mobile/core/constants/storage_keys.dart';
import 'package:multai_mobile/core/storage/app_local_storage.dart';
import 'package:multai_mobile/features/albums/data/repositories/album_repository_impl.dart';
import 'package:multai_mobile/features/albums/domain/entities/album_entity.dart';

class MockAppLocalStorage extends Mock implements AppLocalStorage {}

void main() {
  late MockAppLocalStorage storage;
  late AlbumRepositoryImpl repository;

  setUp(() {
    storage = MockAppLocalStorage();
    repository = AlbumRepositoryImpl(localStorage: storage);
  });

  AlbumEntity album(String name) => AlbumEntity(
    name: name,
    photoCount: 0,
    createdAt: DateTime(2026, 1, 1),
  );

  String encode(List<AlbumEntity> albums) =>
      jsonEncode(albums.map((a) => a.toJson()).toList());

  group('album isolation between accounts', () {
    test('reads only the signed-in account index', () async {
      when(
        () => storage.getString(StorageKeys.currentUserId),
      ).thenReturn('user-b');
      when(
        () => storage.getString('user_albums_user-b'),
      ).thenReturn(encode([album('B album')]));

      final names = (await repository.getAlbums()).fold(
        (_) => <String>[],
        (albums) => albums.map((a) => a.name).toList(),
      );

      expect(names, ['B album']);
      verifyNever(() => storage.getString('user_albums_user-a'));
      verifyNever(() => storage.getString('user_albums'));
    });

    test('switching accounts hides the previous account albums', () async {
      when(
        () => storage.getString(StorageKeys.currentUserId),
      ).thenReturn('user-a');
      when(
        () => storage.getString('user_albums_user-a'),
      ).thenReturn(encode([album('A album')]));

      final first = await repository.getAlbums();
      expect(first.fold((_) => <AlbumEntity>[], (a) => a), hasLength(1));

      when(
        () => storage.getString(StorageKeys.currentUserId),
      ).thenReturn('user-b');
      when(() => storage.getString('user_albums_user-b')).thenReturn(null);

      final second = await repository.getAlbums();
      expect(second.fold((_) => <AlbumEntity>[], (a) => a), isEmpty);
    });

    test('writes new albums under the signed-in account key', () async {
      when(
        () => storage.getString(StorageKeys.currentUserId),
      ).thenReturn('user-a');
      when(() => storage.getString('user_albums_user-a')).thenReturn(null);
      when(() => storage.setString(any(), any())).thenAnswer((_) async {});

      final created = await repository.createAlbum('Trip');
      expect(created.isRight(), isTrue);

      final written = verify(
        () => storage.setString('user_albums_user-a', captureAny()),
      ).captured.single as String;
      expect(jsonDecode(written).single['name'], 'Trip');
    });

    test('falls back to the legacy key when no account is stored', () async {
      when(
        () => storage.getString(StorageKeys.currentUserId),
      ).thenReturn(null);
      when(
        () => storage.getString('user_albums'),
      ).thenReturn(encode([album('Legacy')]));

      final names = (await repository.getAlbums()).fold(
        (_) => <String>[],
        (albums) => albums.map((a) => a.name).toList(),
      );

      expect(names, ['Legacy']);
    });
  });
}
