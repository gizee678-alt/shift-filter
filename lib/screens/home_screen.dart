import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/app_provider.dart';
import '../models/employee.dart';
import '../widgets/shift_chip.dart';
import '../widgets/employee_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/upload_zone.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();
  final _searchController = TextEditingController();
  late AppProvider _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = AppProviderScope.of(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    // Request permissions
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          _showSnack('Camera permission required');
        }
        return;
      }
    } else {
      final status = await Permission.photos.request();
      if (!status.isGranted && !status.isLimited) {
        // Try storage permission for older Android
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          if (mounted) {
            _showSnack('Gallery permission required');
          }
          return;
        }
      }
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (image != null && mounted) {
        await _provider.processImage(image.path);
      }
    } catch (e) {
      if (mounted) _showSnack('Could not open image: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImageSourceSheet(
        onCamera: () {
          Navigator.pop(context);
          _pickImage(ImageSource.camera);
        },
        onGallery: () {
          Navigator.pop(context);
          _pickImage(ImageSource.gallery);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(),
          floatingActionButton: _provider.state == AppState.success
              ? FloatingActionButton.extended(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('New Scan'),
                )
              : null,
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.table_chart_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Shift Filter'),
        ],
      ),
      actions: [
        if (_provider.state == AppState.success)
          IconButton(
            onPressed: _provider.clearFilters,
            icon: const Icon(Icons.filter_alt_off_rounded),
            tooltip: 'Clear Filters',
          ),
        IconButton(
          onPressed: _provider.toggleTheme,
          icon: Icon(
            _provider.themeMode == ThemeMode.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
          ),
          tooltip: 'Toggle Theme',
        ),
        if (_provider.state == AppState.success)
          IconButton(
            onPressed: () {
              _provider.reset();
              _searchController.clear();
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset',
          ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_provider.state) {
      case AppState.idle:
        return _buildIdleView();
      case AppState.loading:
        return _buildLoadingView();
      case AppState.error:
        return _buildErrorView();
      case AppState.success:
        return _buildResultView();
    }
  }

  Widget _buildIdleView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UploadZone(onTap: _showImageSourceDialog)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2),
            const SizedBox(height: 32),
            _buildShiftLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftLegend() {
    return Column(
      children: [
        Text(
          'Supported Shifts',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: kSupportedShifts
              .map((s) => ShiftChip(shift: s, selected: false, onTap: null))
              .toList(),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Scanning roster...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'OCR processing in progress',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Scan Failed',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _provider.errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Try Again'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _provider.reset,
              child: const Text('Go Back'),
            ),
          ],
        ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }

  Widget _buildResultView() {
    final roster = _provider.rosterData!;
    final filtered = _provider.filteredEmployees;

    return Column(
      children: [
        // Stats bar
        _buildStatsBar(roster, filtered.length),

        // Image preview strip
        if (roster.imagePath != null) _buildImagePreview(roster.imagePath!),

        // Filters
        _buildFilters(),

        // Search
        _buildSearch(),

        // Results
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyFilter()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => EmployeeCard(
                    employee: filtered[i],
                    selectedDay: _provider.selectedDay,
                    index: i,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatsBar(RosterData roster, int filteredCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          StatCard(
            label: 'Total',
            value: '${roster.totalEmployees}',
            icon: Icons.people_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          StatCard(
            label: 'Filtered',
            value: '$filteredCount',
            icon: Icons.filter_list_rounded,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          StatCard(
            label: 'Days',
            value: '${roster.days.length}',
            icon: Icons.calendar_today_rounded,
            color: Colors.orange,
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildImagePreview(String imagePath) {
    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image_rounded),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Roster scanned',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '${_provider.rosterData!.totalEmployees} employees found',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final days = _provider.availableDays;
    final shifts = _provider.availableShiftsForDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day selector
        if (days.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
            child: Text(
              'Day',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChipItem(
                  label: 'All',
                  selected: _provider.selectedDay == null,
                  onTap: () => _provider.selectDay(null),
                ),
                ...days.map((d) => _FilterChipItem(
                      label: d,
                      selected: _provider.selectedDay == d,
                      onTap: () => _provider.selectDay(d),
                    )),
              ],
            ),
          ),
        ],

        // Shift selector
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: Text(
            'Shift',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _FilterChipItem(
                label: 'All',
                selected: _provider.selectedShift == null,
                onTap: () => _provider.selectShift(null),
              ),
              ...shifts.map((s) => ShiftChip(
                    shift: s,
                    selected: _provider.selectedShift == s,
                    onTap: () => _provider.selectShift(
                      _provider.selectedShift == s ? null : s,
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: _provider.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search employee name...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    _provider.setSearchQuery('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildEmptyFilter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No employees match',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _provider.clearFilters();
              _searchController.clear();
            },
            child: const Text('Clear filters'),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ImageSourceSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _ImageSourceSheet({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Scan Roster',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _SheetOption(
            icon: Icons.camera_alt_rounded,
            title: 'Take Photo',
            subtitle: 'Use camera to capture roster',
            color: Colors.blue,
            onTap: onCamera,
          ),
          const Divider(indent: 72),
          _SheetOption(
            icon: Icons.photo_library_rounded,
            title: 'Choose from Gallery',
            subtitle: 'Select a screenshot or photo',
            color: Colors.purple,
            onTap: onGallery,
          ),
          const SizedBox(height: 24),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 250.ms, curve: Curves.easeOut);
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
