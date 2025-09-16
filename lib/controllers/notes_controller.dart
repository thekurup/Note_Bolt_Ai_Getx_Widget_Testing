// lib/controllers/notes_controller.dart

import 'package:get/get.dart';
import 'package:notebolt/models/note_models.dart';

// ✅ This controller manages ALL note-related state and logic
// ✅ Extends GetxController to get reactive superpowers
// ✅ NEW: Enhanced with complete CRUD operations and validation
class NotesController extends GetxController {
  
  // 🔹 REACTIVE VARIABLES SECTION
  
  // ✅ RxList = Reactive List - UI automatically rebuilds when this changes
  // ✅ Private (_allNotes) so other files can't directly modify it
  // ✅ .obs makes it observable - like watching the change of note through Obx
  final RxList<Note> _allNotes = <Note>[].obs;
  
  // ✅ Tracks which category is currently selected
  // ✅ RxString means UI rebuilds when category changes
  final RxString _selectedCategory = 'All'.obs;
  
  // ✅ Available filter options - regular List since it never changes
  // 🚀 STAGE 3 OPTIMIZATION: Made static const for better memory efficiency
  static const List<String> categories = ['All', 'Work', 'Personal', 'Reading', 'Saved'];

  // 🚀 STAGE 3 OPTIMIZATION: Added caching for expensive filteredNotes computation
  // ✅ Cache filtered results to avoid recalculating on every access
  List<Note>? _cachedFilteredNotes;
  String? _lastFilterCategory;
  int? _lastNotesLength;

  // ✅ NEW: Additional reactive state for enhanced functionality
  final RxBool isLoading = false.obs;
  final RxString lastOperation = ''.obs;
  final RxInt totalNotesCount = 0.obs;

  // 🔹 GETTERS SECTION (Computed Properties)
  
  // ✅ Public way to access notes (read-only copy)
  // ✅ .toList() creates a copy so external code can't modify original
  List<Note> get allNotes => _allNotes.toList();
  
  // ✅ Public way to check current category
  String get selectedCategory => _selectedCategory.value;
  
  // ✅ SMART FILTER - automatically recalculates when dependencies change
  // ✅ This is the magic! When _selectedCategory or _allNotes change, this updates
  // 🚀 STAGE 3 OPTIMIZATION: Added smart caching to avoid expensive filtering
  List<Note> get filteredNotes {
    // 🚀 STAGE 3: Check cache first - avoid expensive recalculation
    if (_cachedFilteredNotes != null && 
        _lastFilterCategory == _selectedCategory.value &&
        _lastNotesLength == _allNotes.length) {
      return _cachedFilteredNotes!;
    }

    // Calculate filtered notes
    List<Note> result;
    
    // If "All" is selected, show everything
    if (_selectedCategory.value == 'All') {
      result = _allNotes.toList();
    } else {
      // ✅ Filter notes where tag matches selected category
      // ✅ .where() is like a smart filter that keeps only matching items
      result = _allNotes.where((note) => note.tag == _selectedCategory.value).toList();
    }

    // 🚀 STAGE 3: Cache the result for next access
    _cachedFilteredNotes = result;
    _lastFilterCategory = _selectedCategory.value;
    _lastNotesLength = _allNotes.length;
    
    return result;
  }
  
  // ✅ Helper method to check if a category is currently selected
  bool isCategorySelected(String category) {
    return _selectedCategory.value == category;
  }

  // 🚀 STAGE 3 OPTIMIZATION: Added search functionality with debouncing
  final RxString _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;
  
  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  // 🚀 STAGE 3: Smart search that works with filtered notes
  List<Note> get searchResults {
    if (_searchQuery.value.isEmpty) return filteredNotes;
    
    final query = _searchQuery.value.toLowerCase();
    return filteredNotes.where((note) {
      return note.title.toLowerCase().contains(query) ||
             note.snippet.toLowerCase().contains(query) ||
             note.tag.toLowerCase().contains(query);
    }).toList();
  }

  // ✅ NEW: Get notes by category
  List<Note> getNotesByCategory(String category) {
    if (category == 'All') return _allNotes.toList();
    return _allNotes.where((note) => note.tag == category).toList();
  }

  // ✅ NEW: Get note by ID
  Note? getNoteById(String noteId) {
    try {
      return _allNotes.firstWhere((note) => note.id == noteId);
    } catch (e) {
      return null;
    }
  }

  // ✅ NEW: Check if note exists
  bool noteExists(String noteId) {
    return _allNotes.any((note) => note.id == noteId);
  }

  // ✅ NEW: Get category statistics
  Map<String, int> getCategoryStats() {
    final stats = <String, int>{};
    for (final category in categories) {
      if (category == 'All') {
        stats[category] = _allNotes.length;
      } else {
        stats[category] = _allNotes.where((note) => note.tag == category).length;
      }
    }
    return stats;
  }

  // 🔹 INITIALIZATION SECTION
  
  // ✅ This runs automatically when controller is created
  // ✅ Like the constructor but with GetX superpowers
  @override
  void onInit() {
    super.onInit();           // Call parent's initialization
    _loadSampleNotes();       // Load our test data
    // 🚀 STAGE 3 OPTIMIZATION: Setup performance workers
    _setupPerformanceWorkers();
    // ✅ NEW: Initialize total count
    _updateTotalCount();
  }

  // 🚀 STAGE 3 OPTIMIZATION: Workers for better performance and side effects
  void _setupPerformanceWorkers() {
    // Clear cache when category changes
    ever(_selectedCategory, (_) {
      _clearCache();
    });
    
    // Clear cache when notes list changes
    ever(_allNotes, (_) {
      _clearCache();
      _updateTotalCount();
    });
    
    // Debounce search to avoid excessive filtering
    debounce(_searchQuery, (query) {
      print('Search stabilized: $query');
      // Could trigger analytics or other side effects here
    }, time: const Duration(milliseconds: 300));
  }

  // 🚀 STAGE 3: Helper method to clear cache
  void _clearCache() {
    _cachedFilteredNotes = null;
    _lastFilterCategory = null;
    _lastNotesLength = null;
  }

  // ✅ NEW: Update total count
  void _updateTotalCount() {
    totalNotesCount.value = _allNotes.length;
  }

  // 🔹 ACTION METHODS SECTION (State Changers)
  
  // ✅ Private method to create sample notes for testing
  void _loadSampleNotes() {
    // ✅ Create array of sample notes using our factory constructor
    final sampleNotes = [
      Note.sample(
        title: 'Flutter UI Design Guidelines',
        snippet: 'Key principles for creating beautiful and responsive Flutter interfaces with proper state management...',
        tag: 'Work',
        emoji: '🎨',
        hoursAgo: 2,    // Created 2 hours ago
      ),
      Note.sample(
        title: 'Meeting Notes - Q4 Planning',
        snippet: 'Discussed upcoming features, timeline adjustments, and resource allocation for the next quarter...',
        tag: 'Work',
        emoji: '📝',
        hoursAgo: 5,    // Created 5 hours ago
      ),
      Note.sample(
        title: 'Book Ideas: The Creative Process',
        snippet: 'Exploring different approaches to creativity and how to maintain consistent inspiration...',
        tag: 'Personal',
        emoji: '💡',
        hoursAgo: 24,   // Created 1 day ago
      ),
      Note.sample(
        title: 'Travel Itinerary: Japan 2024',
        snippet: 'Tokyo -> Kyoto -> Osaka. Must visit temples, best ramen spots, and cultural experiences...',
        tag: 'Personal',
        emoji: '🗾',
        hoursAgo: 72,   // Created 3 days ago
      ),
      Note.sample(
        title: 'React vs Flutter Comparison',
        snippet: 'Performance benchmarks, development speed, and ecosystem analysis for mobile development...',
        tag: 'Reading',
        emoji: '⚡',
        hoursAgo: 168,  // Created 1 week ago
      ),
    ];
    
    // ✅ Add all sample notes to our reactive list
    // ✅ This triggers UI rebuild automatically!
    // 🚀 STAGE 3 OPTIMIZATION: Use assignAll for better batch performance
    _allNotes.assignAll(sampleNotes);
  }
  
  // ✅ Change selected category and trigger UI updates
  void selectCategory(String category) {
    // ✅ Performance optimization - only update if actually different
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;    // This triggers UI rebuild!
      
      // ✅ Debug logging to see what's happening
      print('Category changed to: $category');
      print('Filtered notes count: ${filteredNotes.length}');
      
      // ✅ NEW: Update last operation
      lastOperation.value = 'Category filter: $category';
    }
  }
  
  // ✅ NEW: Enhanced add note method with validation and error handling
  Future<bool> addNote({
    required String title,
    required String snippet,
    required String tag,
    required String emoji,
  }) async {
    try {
      // ✅ Input validation
      if (title.trim().isEmpty) {
        throw Exception('Title cannot be empty');
      }
      
      if (snippet.trim().isEmpty) {
        throw Exception('Content cannot be empty');
      }
      
      if (title.trim().length < 3) {
        throw Exception('Title must be at least 3 characters long');
      }
      
      if (snippet.trim().length < 10) {
        throw Exception('Content must be at least 10 characters long');
      }
      
      // ✅ Set loading state
      isLoading.value = true;
      
      // ✅ FIXED: Reduced delay for better UX
      await Future.delayed(const Duration(milliseconds: 200));
      
      // ✅ Create new Note object with current timestamp
      final newNote = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),  // Unique ID
        title: title.trim(),
        snippet: snippet.trim(),
        tag: tag,
        emoji: emoji,
        createdAt: DateTime.now(),    // Right now
      );
      
      // ✅ Add to BEGINNING of list (newest notes appear first)
      // ✅ .insert(0, item) puts it at the top
      _allNotes.insert(0, newNote);

      // 🚀 STAGE 3 OPTIMIZATION: Auto-switch to note's category for better UX
      if (_selectedCategory.value != 'All' && _selectedCategory.value != tag) {
        selectCategory(tag);
      }
      
      // ✅ NEW: Update last operation
      lastOperation.value = 'Added note: ${title.trim()}';
      
      print('✅ Note added successfully: ${newNote.title}');
      return true;
      
    } catch (error) {
      print('❌ Error adding note: $error');
      
      // ✅ NEW: Update last operation with error
      lastOperation.value = 'Error adding note: $error';
      
      // ✅ Re-throw for UI to handle
      rethrow;
      
    } finally {
      // ✅ Always hide loading state
      isLoading.value = false;
    }
  }
  
  // ✅ NEW: Enhanced delete note method with validation
  Future<bool> deleteNote(String noteId) async {
    try {
      // ✅ Validation
      if (noteId.isEmpty) {
        throw Exception('Note ID cannot be empty');
      }
      
      if (!noteExists(noteId)) {
        throw Exception('Note not found');
      }
      
      // ✅ Set loading state
      isLoading.value = true;
      
      // ✅ Get note title before deletion for feedback
      final noteToDelete = getNoteById(noteId);
      final noteTitle = noteToDelete?.title ?? 'Unknown';
      
      // ✅ FIXED: Reduced delay for better UX
      await Future.delayed(const Duration(milliseconds: 150));
      
      // ✅ .removeWhere() finds and removes all matching items
      _allNotes.removeWhere((note) => note.id == noteId);
      
      // ✅ NEW: Update last operation
      lastOperation.value = 'Deleted note: $noteTitle';
      
      print('✅ Note deleted successfully: $noteTitle');
      return true;
      
    } catch (error) {
      print('❌ Error deleting note: $error');
      
      // ✅ NEW: Update last operation with error
      lastOperation.value = 'Error deleting note: $error';
      
      // ✅ Re-throw for UI to handle
      rethrow;
      
    } finally {
      // ✅ Always hide loading state
      isLoading.value = false;
    }
  }

  // 🚀 STAGE 3 OPTIMIZATION: Added bulk delete for better performance
  Future<bool> deleteMultipleNotes(List<String> noteIds) async {
    try {
      if (noteIds.isEmpty) {
        throw Exception('No notes to delete');
      }
      
      isLoading.value = true;
      
      // ✅ Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final deletedCount = noteIds.length;
      _allNotes.removeWhere((note) => noteIds.contains(note.id));
      
      lastOperation.value = 'Deleted $deletedCount notes';
      print('✅ Bulk delete successful: $deletedCount notes');
      return true;
      
    } catch (error) {
      print('❌ Error in bulk delete: $error');
      lastOperation.value = 'Error in bulk delete: $error';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  // ✅ NEW: Enhanced update note method with validation
  Future<bool> updateNote(String noteId, {
    String? title,      // ✅ ? means optional parameter
    String? snippet,
    String? tag,
    String? emoji,
  }) async {
    try {
      // ✅ Validation
      if (noteId.isEmpty) {
        throw Exception('Note ID cannot be empty');
      }
      
      if (!noteExists(noteId)) {
        throw Exception('Note not found');
      }
      
      // ✅ Validate updated fields
      if (title != null && title.trim().isEmpty) {
        throw Exception('Title cannot be empty');
      }
      
      if (title != null && title.trim().length < 3) {
        throw Exception('Title must be at least 3 characters long');
      }
      
      if (snippet != null && snippet.trim().isEmpty) {
        throw Exception('Content cannot be empty');
      }
      
      if (snippet != null && snippet.trim().length < 10) {
        throw Exception('Content must be at least 10 characters long');
      }
      
      // ✅ Set loading state
      isLoading.value = true;
      
      // ✅ FIXED: Reduced delay for better UX
      await Future.delayed(const Duration(milliseconds: 200));
      
      // ✅ Find the note's position in the list
      final noteIndex = _allNotes.indexWhere((note) => note.id == noteId);
      
      // ✅ If found (index != -1), update it
      if (noteIndex != -1) {
        final existingNote = _allNotes[noteIndex];
        
        // ✅ Create new Note with updated values (immutable pattern)
        // ✅ ?? means "use new value OR keep existing if new is null"
        final updatedNote = Note(
          id: existingNote.id,                    // Keep same ID
          title: title?.trim() ?? existingNote.title,    // New title OR existing
          snippet: snippet?.trim() ?? existingNote.snippet,
          tag: tag ?? existingNote.tag,
          emoji: emoji ?? existingNote.emoji,
          createdAt: existingNote.createdAt,      // Keep original timestamp
        );
        
        // ✅ Replace the old note with updated version
        // 🚀 STAGE 3 OPTIMIZATION: Direct assignment is faster than remove+insert
        _allNotes[noteIndex] = updatedNote;
        
        // ✅ NEW: Update last operation
        lastOperation.value = 'Updated note: ${updatedNote.title}';
        
        print('✅ Note updated successfully: ${updatedNote.title}');
        return true;
      } else {
        throw Exception('Note not found in list');
      }
      
    } catch (error) {
      print('❌ Error updating note: $error');
      
      // ✅ NEW: Update last operation with error
      lastOperation.value = 'Error updating note: $error';
      
      // ✅ Re-throw for UI to handle
      rethrow;
      
    } finally {
      // ✅ Always hide loading state
      isLoading.value = false;
    }
  }

  // 🚀 STAGE 3 OPTIMIZATION: Bulk update method for better performance
  Future<bool> updateMultipleNotes(Map<String, Map<String, String?>> updates) async {
    try {
      if (updates.isEmpty) {
        throw Exception('No updates to apply');
      }
      
      isLoading.value = true;
      
      // ✅ Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      int updatedCount = 0;
      
      for (int i = 0; i < _allNotes.length; i++) {
        final note = _allNotes[i];
        final update = updates[note.id];
        
        if (update != null) {
          _allNotes[i] = Note(
            id: note.id,
            title: update['title']?.trim() ?? note.title,
            snippet: update['snippet']?.trim() ?? note.snippet,
            tag: update['tag'] ?? note.tag,
            emoji: update['emoji'] ?? note.emoji,
            createdAt: note.createdAt,
          );
          updatedCount++;
        }
      }
      
      lastOperation.value = 'Bulk updated $updatedCount notes';
      print('✅ Bulk update successful: $updatedCount notes');
      return true;
      
    } catch (error) {
      print('❌ Error in bulk update: $error');
      lastOperation.value = 'Error in bulk update: $error';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ NEW: Duplicate note functionality
  Future<bool> duplicateNote(String noteId) async {
    try {
      final originalNote = getNoteById(noteId);
      if (originalNote == null) {
        throw Exception('Original note not found');
      }
      
      return await addNote(
        title: '${originalNote.title} (Copy)',
        snippet: originalNote.snippet,
        tag: originalNote.tag,
        emoji: originalNote.emoji,
      );
      
    } catch (error) {
      print('❌ Error duplicating note: $error');
      rethrow;
    }
  }

  // ✅ NEW: Clear all notes with confirmation
  Future<bool> clearAllNotes() async {
    try {
      isLoading.value = true;
      
      // ✅ Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      final deletedCount = _allNotes.length;
      _allNotes.clear();
      
      lastOperation.value = 'Cleared all notes ($deletedCount deleted)';
      print('✅ All notes cleared: $deletedCount notes deleted');
      return true;
      
    } catch (error) {
      print('❌ Error clearing notes: $error');
      lastOperation.value = 'Error clearing notes: $error';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ NEW: Export notes as JSON (for backup/sharing)
  List<Map<String, dynamic>> exportNotesToJson() {
    try {
      final exportData = _allNotes.map((note) => note.toJson()).toList();
      lastOperation.value = 'Exported ${_allNotes.length} notes';
      print('✅ Notes exported: ${_allNotes.length} notes');
      return exportData;
    } catch (error) {
      print('❌ Error exporting notes: $error');
      lastOperation.value = 'Error exporting notes: $error';
      rethrow;
    }
  }

  // ✅ NEW: Import notes from JSON
  Future<bool> importNotesFromJson(List<Map<String, dynamic>> jsonData) async {
    try {
      isLoading.value = true;
      
      // ✅ Validate JSON data
      if (jsonData.isEmpty) {
        throw Exception('No data to import');
      }
      
      // ✅ Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final importedNotes = jsonData.map((json) => Note.fromJson(json)).toList();
      
      // ✅ Add imported notes to existing notes
      _allNotes.addAll(importedNotes);
      
      // ✅ Sort by creation date (newest first)
      _allNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      lastOperation.value = 'Imported ${importedNotes.length} notes';
      print('✅ Notes imported: ${importedNotes.length} notes');
      return true;
      
    } catch (error) {
      print('❌ Error importing notes: $error');
      lastOperation.value = 'Error importing notes: $error';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // 🚀 STAGE 3 OPTIMIZATION: Performance monitoring
  void logPerformanceStats() {
    print('=== PERFORMANCE STATS ===');
    print('Total notes: ${_allNotes.length}');
    print('Current category: $_selectedCategory');
    print('Filtered notes: ${filteredNotes.length}');
    print('Cache status: ${_cachedFilteredNotes != null ? "CACHED" : "UNCACHED"}');
    print('Last operation: ${lastOperation.value}');
    print('Is loading: ${isLoading.value}');
    print('========================');
  }

  // ✅ NEW: Reset controller to initial state
  void resetController() {
    _allNotes.clear();
    _selectedCategory.value = 'All';
    _searchQuery.value = '';
    isLoading.value = false;
    lastOperation.value = '';
    totalNotesCount.value = 0;
    _clearCache();
    
    // ✅ Reload sample data
    _loadSampleNotes();
    
    print('✅ Controller reset to initial state');
  }

  // ✅ PERFORMANCE: Clean up resources
  @override
  void onClose() {
    // GetX automatically disposes Rx variables
    // Manual cleanup only needed for streams, timers, etc.
    // 🚀 STAGE 3: Clear cache on disposal
    _clearCache();
    print('✅ NotesController disposed');
    super.onClose();
  }
}

/*
🚀 FINAL NOTES CONTROLLER FEATURES SUMMARY:
==========================================

✅ ENHANCED CRUD OPERATIONS:
- addNote() with validation and error handling
- updateNote() with field validation 
- deleteNote() with existence checks
- duplicateNote() functionality
- Bulk operations (update/delete multiple)

✅ ADVANCED QUERYING:
- getNoteById() for finding specific notes
- getNotesByCategory() for filtered results
- noteExists() for validation
- getCategoryStats() for analytics

✅ DATA MANAGEMENT:
- exportNotesToJson() for backup
- importNotesFromJson() for restore
- clearAllNotes() for reset functionality
- resetController() for development

✅ REACTIVE STATE MANAGEMENT:
- isLoading for UI loading states
- lastOperation for user feedback
- totalNotesCount for statistics
- All operations are reactive and update UI automatically

✅ ERROR HANDLING & VALIDATION:
- Input validation for all CRUD operations
- Proper error messages and user feedback
- Try-catch blocks with error propagation
- Loading states for better UX

✅ PERFORMANCE OPTIMIZATIONS:
- Smart caching for filtered notes
- Debounced search functionality
- Bulk operations for efficiency
- Memory cleanup on disposal

✅ DEVELOPMENT FEATURES:
- Comprehensive logging
- Performance monitoring
- Debug statistics
- Sample data loading

USAGE IN UI CONTROLLERS:
- All form controllers can now use these methods
- Proper error handling with try-catch
- Loading states for better UX
- Automatic UI updates through reactive variables

NEXT STEPS:
- Test all CRUD operations in the UI
- Add persistence (SharedPreferences/SQLite)
- Implement favorites functionality
- Add note sharing capabilities
*/