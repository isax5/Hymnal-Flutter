import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hymnal_app/layers/domain/model/hymnal.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class SheetsScreen extends StatefulWidget {
  final Hymnal hymnal;
  final int hymnNumber;

  const SheetsScreen({
    super.key,
    required this.hymnal,
    required this.hymnNumber,
  });

  @override
  State<SheetsScreen> createState() => _SheetsScreenState();
}

class _SheetsScreenState extends State<SheetsScreen> {
  List<String> _sheetUrls = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSheets();
  }

  void _loadSheets() {
    if (widget.hymnal.hymnsSheetsFileName == null) return;

    final baseName = widget.hymnal.hymnsSheetsFileName!.replaceAll(
      '###',
      widget.hymnNumber.toString().padLeft(3, '0'),
    );

    final urls = <String>[];

    // Check for base sheet
    urls.add('assets/musicSheets/$baseName');

    // Check for additional pages
    for (int i = 1; i <= 6; i++) {
      final extraName = baseName.replaceAll(
        '.png',
        '_$i.png',
      );
      urls.add('assets/musicSheets/$extraName');
    }

    setState(() {
      _sheetUrls = urls;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sheet Music - Hymn ${widget.hymnNumber}'),
        actions: [
          if (_sheetUrls.length > 1)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('${_currentIndex + 1}/${_sheetUrls.length}'),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PhotoViewGallery.builder(
              itemCount: _sheetUrls.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: AssetImage(_sheetUrls[index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              pageController: PageController(initialPage: 0),
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
    );
  }
}
