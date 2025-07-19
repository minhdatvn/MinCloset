// scripts/merge_arb.dart

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

// Cấu hình: Thay đổi các đường dẫn này nếu cần
const inputDir = 'lib/l10n/unit';      
const outputDir = 'lib/l10n';         
const outputPrefix = 'app';           

void main() async {
  final directory = Directory(inputDir);
  if (!await directory.exists()) {
    print('Error: Input directory not found at $inputDir');
    return;
  }

  await Directory(outputDir).create(recursive: true);

  final files = await directory.list().where((item) => item.path.endsWith('.arb')).toList();

  final Map<String, List<File>> filesByLocale = {};
  for (var fileEntity in files) {
    final file = File(fileEntity.path);
    
    try {
      final content = json.decode(await file.readAsString());
      final locale = content['@@locale'];
      if (locale != null) {
        filesByLocale.putIfAbsent(locale, () => []).add(file);
      }
    } catch (e) {
      print('Warning: Could not parse ${file.path}. Skipping. Error: $e');
    }
  }

  if (filesByLocale.isEmpty) {
    print('No valid .arb files found in $inputDir to merge.');
    return;
  }

  for (var entry in filesByLocale.entries) {
    final locale = entry.key;
    final filesToMerge = entry.value;
    final Map<String, dynamic> mergedContent = {
      '@@locale': locale,
    };

    print('Merging files for locale: "$locale"...');

    for (var file in filesToMerge) {
      try {
        final content = json.decode(await file.readAsString()) as Map<String, dynamic>;
        content.remove('@@locale'); 
        mergedContent.addAll(content);
        print('  - Merged ${p.basename(file.path)}');
      } catch (e) {
        print('Warning: Could not merge ${file.path}. Skipping. Error: $e');
      }
    }

    // <<< SỬA LỖI Ở ĐÂY >>>
    // Thêm mã ngôn ngữ (locale) vào tên file đầu ra
    final outputFile = File(p.join(outputDir, '${outputPrefix}_$locale.arb'));
    
    final encoder = JsonEncoder.withIndent('  ');
    await outputFile.writeAsString(encoder.convert(mergedContent));
    print('Successfully created ${outputFile.path}');
  }

  print('\nMerge complete!');
}