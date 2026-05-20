import 'package:flutter_test/flutter_test.dart';
import 'package:langgeng_clip/features/library/export_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('readAll returns empty list by default', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = ExportHistoryRepository(
      await SharedPreferences.getInstance(),
    );

    expect(repository.readAll(), isEmpty);
  });

  test('add persists export history newest first', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = ExportHistoryRepository(
      await SharedPreferences.getInstance(),
    );

    await repository.add(
      const ExportHistoryItem(
        id: '1',
        title: 'Clip 1',
        cachePath: '/cache/1.mp4',
        galleryUri: 'content://1',
        createdAtMillis: 1000,
        durationMillis: 5000,
        resolution: '1080p',
        frameRate: '30',
        codec: 'H.264',
        targetWidth: 1080,
        targetHeight: 1920,
        cropToPortrait: true,
        requiresReencode: true,
      ),
    );
    await repository.add(
      const ExportHistoryItem(
        id: '2',
        title: 'Clip 2',
        cachePath: '/cache/2.mp4',
        createdAtMillis: 2000,
        durationMillis: 6000,
      ),
    );

    final items = repository.readAll();

    expect(items, hasLength(2));
    expect(items.first.id, '2');
    expect(items.last.id, '1');
    expect(items.last.galleryUri, 'content://1');
    expect(items.last.resolution, '1080p');
    expect(items.last.frameRate, '30');
    expect(items.last.codec, 'H.264');
    expect(items.last.targetWidth, 1080);
    expect(items.last.targetHeight, 1920);
    expect(items.last.cropToPortrait, isTrue);
    expect(items.last.requiresReencode, isTrue);
  });

  test('rename updates title', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = ExportHistoryRepository(
      await SharedPreferences.getInstance(),
    );

    await repository.add(
      const ExportHistoryItem(
        id: '1',
        title: 'Clip 1',
        cachePath: '/cache/1.mp4',
        createdAtMillis: 1000,
        durationMillis: 5000,
      ),
    );
    await repository.rename(id: '1', title: 'Renamed Clip');

    expect(repository.readAll().single.title, 'Renamed Clip');
  });

  test('delete removes item', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = ExportHistoryRepository(
      await SharedPreferences.getInstance(),
    );

    await repository.add(
      const ExportHistoryItem(
        id: '1',
        title: 'Clip 1',
        cachePath: '/cache/1.mp4',
        createdAtMillis: 1000,
        durationMillis: 5000,
      ),
    );
    await repository.delete('1');

    expect(repository.readAll(), isEmpty);
  });

  test('duplicate creates copy newest first', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = ExportHistoryRepository(
      await SharedPreferences.getInstance(),
    );

    await repository.add(
      const ExportHistoryItem(
        id: '1',
        title: 'Clip 1',
        cachePath: '/cache/1.mp4',
        createdAtMillis: 1000,
        durationMillis: 5000,
      ),
    );
    await repository.duplicate('1');

    final items = repository.readAll();
    expect(items, hasLength(2));
    expect(items.first.title, 'Clip 1 (copy)');
    expect(items.last.id, '1');
  });
}
