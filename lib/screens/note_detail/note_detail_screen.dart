// lib/screens/note_detail/note_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notes_controller.dart';
import '../edit_note/edit_note_screen.dart';

// 🔍 What is this controller?
// A dedicated GetX controller that manages all business logic for the note detail screen
// 💡 Why create a separate controller for detail screen?
// Separates UI concerns from business logic, provides reactive state management for favorites, loading, and actions
// 🔁 What happens when this controller is created?
// Initializes reactive variables for favorite status, loading states, and stores note data for operations
// ⚠️ What would break without this controller?
// All logic would be mixed in UI, no reactive state management, poor separation of concerns
class NoteDetailController extends GetxController {
 
 // 🔍 What are these reactive variables?
 // Observable boolean values that automatically trigger UI rebuilds when changed
 // 💡 Why use .obs for these specific variables?
 // UI needs to show different states (favorited vs unfavorited, loading vs ready) in real-time
 // 🔁 What happens when these values change?
 // Any Obx() widget watching these variables automatically rebuilds with new visual state
 // ⚠️ What would break without .obs?
 // UI would show stale state, buttons wouldn't update visually, poor user experience
 final RxBool isFavorite = false.obs;
 final RxBool isLoading = false.obs;
 
 // 🔍 What is this Map storing?
 // The complete note data passed from the previous screen (home screen note card tap)
 // 💡 Why use Map<String, dynamic> instead of Note object?
 // Provides flexibility for different data formats and easy JSON-like access to properties
 // 🔁 What happens when we store note data here?
 // Controller has access to all note information for displaying and performing operations
 // ⚠️ What would break without storing currentNote?
 // No access to note data, couldn't display content, perform operations, or navigate properly
 Map<String, dynamic> currentNote = {};
 
 // 🔍 What does this initialization method do?
 // Receives note data from previous screen and sets up the controller's state
 // 💡 Why create a separate initialization method?
 // Clean separation between controller creation and data setup, allows proper error handling
 // 🔁 What happens during initialization?
 // Note data is copied and stored, favorite status is set (placeholder for now)
 // ⚠️ What would break without proper initialization?
 // Controller would have empty data, UI would show blank content or crash
 void initializeWithNote(Map<String, dynamic> note) {
   currentNote = Map.from(note);
   // TODO: Check if note is favorited (from preferences or controller)
   isFavorite.value = false; // Default for now
 }
 
 // 🔍 What does this toggle method do?
 // Changes the favorite status and provides user feedback through snackbar
 // 💡 Why combine state change with user feedback?
 // Provides immediate visual confirmation of the action, better UX than silent state changes
 // 🔁 What happens when user taps favorite button?
 // 1. isFavorite.value flips to opposite state
 // 2. Obx() widgets watching isFavorite automatically rebuild 
 // 3. Snackbar appears with confirmation message
 // ⚠️ What would break without reactive favorite toggle?
 // Button wouldn't update visually, users wouldn't know if action succeeded
 void toggleFavorite() {
   isFavorite.value = !isFavorite.value;
   
   // 🔍 What is Get.snackbar() doing here?
   // GetX's built-in snackbar system for showing temporary messages to users
   // 💡 Why show snackbar feedback?
   // Confirms the action succeeded, provides clear user feedback, professional app feel
   // 🔁 What happens when snackbar shows?
   // Temporary message appears at bottom of screen, auto-disappears after 2 seconds
   // ⚠️ What would break without user feedback?
   // Silent actions confuse users, they can't tell if their tap worked
   Get.snackbar(
     isFavorite.value ? 'Added to Favorites' : 'Removed from Favorites',
     isFavorite.value 
         ? 'Note saved to your favorites'
         : 'Note removed from favorites',
     snackPosition: SnackPosition.BOTTOM,
     backgroundColor: isFavorite.value ? Colors.green : Colors.orange,
     colorText: Colors.white,
     duration: const Duration(seconds: 2),
   );
   
   // TODO: Persist favorite status to storage
 }
 
 // 🔍 What does this navigation method do?
 // Handles the transition to edit mode with loading animation and data passing
 // 💡 Why manage loading state during navigation?
 // Provides visual feedback during transition, prevents multiple rapid taps
 // 🔁 What happens when user taps edit button?
 // 1. Loading state activates (button shows spinner)
 // 2. Navigation to EditNoteScreen with note data
 // 3. When returning, loading state clears
 // ⚠️ What would break without proper navigation handling?
 // No way to edit notes, or crashes due to improper data passing
 void navigateToEdit() {
   isLoading.value = true;
   
   // 🔍 What is Get.to() doing?
   // GetX navigation method that pushes EditNoteScreen onto the navigation stack
   // 💡 Why Get.to() instead of Navigator.push()?
   // Cleaner syntax, automatic route management, less boilerplate code
   // 🔁 What happens during navigation?
   // New screen slides in from right, note data passed to edit screen
   // ⚠️ What would break without Get.to()?
   // Would need complex Navigator.push setup, more error-prone
   Get.to(
     () => EditNoteScreen(note: currentNote),
     transition: Transition.rightToLeft,
     duration: const Duration(milliseconds: 300),
   )?.then((_) {
     // 🔍 What happens in this callback?
     // Executes when user returns from edit screen to detail screen
     // 💡 Why clear loading state on return?
     // Edit navigation is complete, button should return to normal state
     // 🔁 What happens when user returns?
     // Loading state clears, edit button becomes interactive again
     // ⚠️ What would break without this callback?
     // Stuck loading state, disabled edit button permanently
     isLoading.value = false;
   });
 }
 
 // 🔍 What does this sharing method do?
 // Formats note content and prepares it for sharing (placeholder implementation)
 // 💡 Why format the content before sharing?
 // Creates a professional, readable format when shared to other apps
 // 🔁 What happens when user taps share?
 // Note content formatted with title, content, metadata, and app branding
 // ⚠️ What would break without proper formatting?
 // Messy shared content, poor representation of the app
 void shareNote() {
   final noteContent = '''
${currentNote['title']}

${currentNote['snippet']}

Category: ${currentNote['tag']}
Created: ${currentNote['createdAt']}

Shared from NoteBolt AI
   ''';
   
   // TODO: Implement actual sharing (using share_plus package)
   print('Sharing note: $noteContent');
   
   // 🔍 Why show a placeholder snackbar?
   // Informs users that feature is planned but not yet implemented
   // 💡 Why not hide incomplete features?
   // Transparent development, shows planned functionality, gets user expectations set
   // 🔁 What happens until real sharing is implemented?
   // Users see professional message about upcoming feature
   // ⚠️ What would break without placeholder feedback?
   // Broken functionality with no explanation, confused users
   Get.snackbar(
     'Share Feature',
     'Sharing functionality will be implemented with share_plus package',
     snackPosition: SnackPosition.BOTTOM,
     backgroundColor: Colors.blue,
     colorText: Colors.white,
     duration: const Duration(seconds: 3),
   );
 }
 
 // 🔍 What does this duplication method do?
 // Creates a copy of the current note with modified title and shows feedback
 // 💡 Why duplicate instead of just manual copying?
 // Saves user time, maintains all formatting and categorization, convenient feature
 // 🔁 What happens when user chooses duplicate?
 // 1. Loading state activates
 // 2. New note created with "(Copy)" suffix
 // 3. Success message shown
 // ⚠️ What would break without error handling?
 // Silent failures or crashes when duplication fails
 void duplicateNote() async {
   isLoading.value = true;
   
   try {
     // 🔍 What is Get.find<NotesController>() doing?
     // Retrieves the shared NotesController instance that manages all notes data
     // 💡 Why use Get.find() instead of creating new controller?
     // Accesses the same data that other screens use, maintains consistency
     // 🔁 What happens when we get the controller?
     // Access to all note management methods (add, delete, update, etc.)
     // ⚠️ What would break without access to NotesController?
     // No way to create the duplicate note, feature would be non-functional
     final notesController = Get.find<NotesController>();
     
     // 🔍 What is notesController.addNote() doing?
     // Calls the shared controller's method to create a new note with duplicate data
     // 💡 Why modify the title with "(Copy)"?
     // Prevents confusion between original and duplicate, clear visual distinction
     // 🔁 What happens when note is added?
     // New note appears in the main list, all reactive UI automatically updates
     // ⚠️ What would break without title modification?
     // Identical titles create confusion about which note is which
     notesController.addNote(
       title: '${currentNote['title']} (Copy)',
       snippet: currentNote['snippet'] ?? '',
       tag: currentNote['tag'] ?? 'Personal',
       emoji: currentNote['emoji'] ?? '📝',
     );
     
     // 🔍 What does this success snackbar do?
     // Provides immediate confirmation that the duplication succeeded
     // 💡 Why show success feedback?
     // Users need confirmation that their action worked, professional app behavior
     // 🔁 What happens after successful duplication?
     // Green success message appears, users know they can find the copy in main list
     // ⚠️ What would break without success confirmation?
     // Users unsure if duplication worked, might try again unnecessarily
     Get.snackbar(
       'Note Duplicated',
       'A copy of this note has been created',
       snackPosition: SnackPosition.BOTTOM,
       backgroundColor: Colors.green,
       colorText: Colors.white,
       duration: const Duration(seconds: 2),
     );
     
   } catch (error) {
     // 🔍 What does this error handling do?
     // Catches any failures during duplication and shows user-friendly error message
     // 💡 Why wrap in try-catch?
     // Prevents crashes, provides graceful failure handling, better user experience
     // 🔁 What happens when duplication fails?
     // Red error message appears, users know to try again or report issue
     // ⚠️ What would break without error handling?
     // App crashes or silent failures, users don't know what went wrong
     Get.snackbar(
       'Error',
       'Failed to duplicate note. Please try again.',
       snackPosition: SnackPosition.BOTTOM,
       backgroundColor: Colors.red,
       colorText: Colors.white,
       duration: const Duration(seconds: 3),
     );
   } finally {
     // 🔍 What does the finally block do?
     // Ensures loading state is cleared regardless of success or failure
     // 💡 Why use finally?
     // Guarantees cleanup happens, prevents stuck loading indicators
     // 🔁 What happens in the finally block?
     // Loading spinner disappears, button returns to normal state
     // ⚠️ What would break without finally?
     // Stuck loading states on errors, buttons remain disabled
     isLoading.value = false;
   }
 }
 
 // 🔍 What does this enhanced delete method do?
 // Provides safe deletion with confirmation dialog and consistent user feedback
 // 💡 Why make delete flow consistent with edit page?
 // Uniform user experience, predictable behavior across screens
 // 🔁 What happens when user chooses delete?
 // 1. Confirmation dialog appears
 // 2. If confirmed, note is deleted
 // 3. Success message and navigation back to home
 // ⚠️ What would break without confirmation?
 // Accidental deletions, lost user data, poor user experience
 void deleteNote() async {
   // 🔍 What is Get.dialog<bool>() doing?
   // Shows a modal dialog and returns true/false based on user choice
   // 💡 Why use GetX dialog instead of showDialog?
   // Cleaner syntax, automatic handling, consistent with app architecture
   // 🔁 What happens when dialog shows?
   // User must explicitly confirm or cancel, prevents accidental deletions
   // ⚠️ What would break without confirmation dialog?
   // Accidental deletions when user taps delete by mistake
   final confirmed = await Get.dialog<bool>(
     AlertDialog(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       title: const Row(
         children: [
           Icon(Icons.delete_forever, color: Colors.red, size: 24),
           SizedBox(width: 8),
           Text(
             'Delete Note',
             style: TextStyle(
               fontFamily: 'Poppins',
               fontWeight: FontWeight.w600,
             ),
           ),
         ],
       ),
       content: const Text(
         'Are you sure you want to delete this note? This action cannot be undone.',
         style: TextStyle(fontFamily: 'Poppins'),
       ),
       actions: [
         TextButton(
           onPressed: () => Get.back(result: false),
           child: const Text(
             'Cancel',
             style: TextStyle(
               fontFamily: 'Poppins',
               color: Color(0xFF6B7280),
             ),
           ),
         ),
         ElevatedButton(
           onPressed: () => Get.back(result: true),
           style: ElevatedButton.styleFrom(
             backgroundColor: Colors.red,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
           ),
           child: const Text(
             'Delete',
             style: TextStyle(
               fontFamily: 'Poppins',
               fontWeight: FontWeight.w500,
               color: Colors.white,
             ),
           ),
         ),
       ],
     ),
   );

   // 🔍 What does this confirmation check do?
   // Ensures deletion only happens when user explicitly confirms
   // 💡 Why check for confirmed == true instead of just confirmed?
   // Explicit boolean comparison, handles null case when dialog is dismissed
   // 🔁 What happens when user confirms?
   // Deletion process begins with loading state and actual note removal
   // ⚠️ What would break without confirmation check?
   // Deletion might happen even when user cancels or dismisses dialog
   if (confirmed == true) {
     isLoading.value = true;

     try {
       // 🔍 What is the deletion process doing?
       // Accesses shared controller and removes the note from the main data store
       // 💡 Why access the shared controller for deletion?
       // Ensures the note is removed from the main list that other screens use
       // 🔁 What happens when note is deleted?
       // Note disappears from all lists, UI automatically updates across the app
       // ⚠️ What would break without controller access?
       // Note would remain in main list, inconsistent app state
       final notesController = Get.find<NotesController>();
       await notesController.deleteNote(currentNote['id']);

       // 🔍 What does this success message do?
       // Provides immediate confirmation that deletion succeeded
       // 💡 Why use orange background for delete success?
       // Orange indicates caution/warning action completed, different from normal green
       // 🔁 What happens after successful deletion?
       // Orange success message appears briefly before navigation
       // ⚠️ What would break without success feedback?
       // Users unsure if deletion worked, might try again
       Get.snackbar(
         '🗑️ Note Deleted Successfully!',
         'Note has been removed',
         snackPosition: SnackPosition.TOP,
         backgroundColor: const Color(0xFFF59E0B), // Orange background
         colorText: Colors.white,
         duration: const Duration(seconds: 2),
         margin: const EdgeInsets.all(16),
         borderRadius: 12,
         icon: const Icon(Icons.check_circle, color: Colors.white, size: 28),
         animationDuration: const Duration(milliseconds: 400),
       );

       // 🔍 What does this delay do?
       // Allows user to see the success message before navigation happens
       // 💡 Why delay navigation?
       // Better UX flow, users see confirmation before screen changes
       // 🔁 What happens during the delay?
       // Success snackbar displays, user has time to read the feedback
       // ⚠️ What would break without the delay?
       // Immediate navigation, users miss the success confirmation
       await Future.delayed(const Duration(milliseconds: 800));
       
       // 🔍 What does Get.until() do?
       // Pops navigation stack until reaching the first route (home screen)
       // 💡 Why use Get.until() instead of Get.back()?
       // Ensures we reach home screen regardless of navigation stack depth
       // 🔁 What happens during navigation?
       // All intermediate screens are removed, user lands on home screen
       // ⚠️ What would break without proper navigation?
       // User stuck on detail screen of deleted note, broken app state
       try {
         Get.until((route) => route.isFirst);
       } catch (e) {
         Get.offAllNamed('/');
       }
       
     } catch (error) {
       // 🔍 What does this error handling do?
       // Catches deletion failures and shows user-friendly error message
       // 💡 Why specific error styling?
       // Light red background with dark red text is less alarming than pure red
       // 🔁 What happens when deletion fails?
       // Professional error message appears, users know to try again
       // ⚠️ What would break without error handling?
       // App crashes or silent failures, users don't know what happened
       Get.snackbar(
         '❌ Delete Failed',
         'Unable to delete note. Please try again.',
         snackPosition: SnackPosition.TOP,
         backgroundColor: Colors.red.shade100,
         colorText: Colors.red.shade800,
         duration: const Duration(seconds: 3),
         margin: const EdgeInsets.all(16),
         borderRadius: 8,
         icon: const Icon(Icons.error, color: Colors.red),
       );
     } finally {
       // 🔍 What does the finally block ensure?
       // Loading state is always cleared, even if deletion fails
       // 💡 Why is finally block critical here?
       // Prevents stuck loading states that would disable the UI permanently
       // 🔁 What happens in finally?
       // Loading spinner disappears, UI returns to normal interactive state
       // ⚠️ What would break without finally?
       // Stuck loading indicators on errors, broken user interface
       isLoading.value = false;
     }
   }
 }
 
 // 🔍 What does this category navigation do?
 // Sets category filter and returns to home screen to show filtered results
 // 💡 Why combine filter setting with navigation?
 // Provides quick way to see all notes in the same category as current note
 // 🔁 What happens when user taps "View All" for category?
 // 1. Home screen's category filter is set to current note's category
 // 2. Navigation back to home screen
 // 3. Home screen shows only notes matching the category
 // ⚠️ What would break without category filter integration?
 // No connection between detail screen and home screen filtering
 void viewCategoryNotes(String category) {
   // 🔍 What is selectCategory() doing?
   // Updates the shared controller's category filter to the specified category
   // 💡 Why use the shared controller's filter method?
   // Maintains consistency with home screen's filtering system
   // 🔁 What happens when category is selected?
   // Home screen's reactive UI automatically shows only matching notes
   // ⚠️ What would break without shared controller access?
   // No way to influence home screen's filter state
   final notesController = Get.find<NotesController>();
   notesController.selectCategory(category);
   
   // 🔍 What does Get.back() do here?
   // Returns to the previous screen (home screen) which will show filtered results
   // 💡 Why navigate back instead of using Get.to()?
   // Maintains proper navigation stack, user can use back button normally
   // 🔁 What happens after navigation?
   // Home screen displays with category filter applied, showing related notes
   // ⚠️ What would break without navigation?
   // Filter would be set but user wouldn't see the results
   Get.back();
   
   // 🔍 What does this confirmation snackbar do?
   // Provides feedback that the category filter has been applied successfully
   // 💡 Why show filter confirmation?
   // Users understand why they're seeing different notes, clear cause and effect
   // 🔁 What happens when snackbar shows?
   // Purple message appears confirming the filter is active
   // ⚠️ What would break without filter confirmation?
   // Users might be confused why note list suddenly changed
   Get.snackbar(
     'Category Filter Applied',
     'Showing all $category notes',
     snackPosition: SnackPosition.BOTTOM,
     backgroundColor: const Color(0xFF8B5CF6),
     colorText: Colors.white,
     duration: const Duration(seconds: 2),
   );
 }
}

// 🔍 What is this main screen widget?
// The primary UI widget that displays note content and manages user interactions
// 💡 Why StatelessWidget instead of StatefulWidget?
// All state is managed by GetX controller, no local widget state needed
// 🔁 What happens when this widget builds?
// Creates the complete note detail interface with reactive components
// ⚠️ What would break without this widget?
// No UI to display note details, app would have no detail screen
class NoteDetailScreen extends StatelessWidget {
 // 🔍 What is this note parameter?
 // The complete note data passed from the previous screen (home screen note card)
 // 💡 Why require note data in constructor?
 // Screen needs data to display, enforces proper data passing
 // 🔁 What happens when note data is provided?
 // Screen has all information needed to show title, content, category, timestamp
 // ⚠️ What would break without required note data?
 // Screen would have nothing to display, would crash or show empty content
 final Map<String, dynamic> note;
 
 const NoteDetailScreen({
   super.key,
   required this.note,
 });

 @override
 Widget build(BuildContext context) {
   
   // 🔍 What is this controller tag system?
   // Creates unique controller instance for each note detail screen
   // 💡 Why use unique tags instead of single controller?
   // Prevents controller conflicts when multiple detail screens exist
   // 🔁 What happens with unique tagging?
   // Each note detail screen has its own isolated controller state
   // ⚠️ What would break without unique tags?
   // Controller state conflicts, wrong data shown, crashes
   final String controllerTag = 'detail_${note['id']}';
   final NoteDetailController detailController = Get.put(
     NoteDetailController(),
     tag: controllerTag,
   );
   
   // 🔍 What does immediate initialization do?
   // Sets up controller with note data right away for immediate use
   // 💡 Why initialize immediately instead of delayed?
   // Ensures data is available when UI starts building, prevents empty states
   // 🔁 What happens during initialization?
   // Controller receives note data and sets up reactive state
   // ⚠️ What would break without immediate initialization?
   // UI would briefly show empty or default data before real data loads
   detailController.initializeWithNote(note);
   
   // 🔍 What is this responsive design setup?
   // Calculates screen size to adapt layout for phones vs tablets
   // 💡 Why implement responsive design?
   // Better user experience on different device sizes, professional app quality
   // 🔁 What happens on different screen sizes?
   // Larger padding and text sizes on tablets, compact layout on phones
   // ⚠️ What would break without responsive design?
   // Poor layout on tablets, cramped design, unprofessional appearance
   final screenSize = MediaQuery.of(context).size;
   final screenWidth = screenSize.width;
   final isTablet = screenWidth > 600;
   
   return Scaffold(
     // 🔍 What does this background color do?
     // Provides consistent purple-themed branding throughout the app
     // 💡 Why use branded background color?
     // Creates cohesive visual experience, reinforces app identity
     // 🔁 What happens with branded background?
     // Screen feels like part of unified app experience
     // ⚠️ What would break without branded background?
     // Generic white background, less professional, broken design consistency
     backgroundColor: const Color(0xFFF8F6FF),
     
     // 🔍 What is this custom app bar?
     // Specialized navigation bar with back button, note info, and action menu
     // 💡 Why create custom app bar instead of default?
     // Provides note-specific information and actions in the header
     // 🔁 What happens with custom app bar?
     // Users see note category, timestamp, and can access sharing/actions
     // ⚠️ What would break without custom app bar?
     // Generic navigation with no context about current note
     appBar: _DetailAppBar(
       note: note,
       controller: detailController,
     ),
     
     // 🔍 What does this body structure provide?
     // Scrollable container with responsive padding for main content
     // 💡 Why use SafeArea and SingleChildScrollView?
     // SafeArea prevents content overlap with system UI, scrolling handles overflow
     // 🔁 What happens with this structure?
     // Content displays properly on all devices with smooth scrolling
     // ⚠️ What would break without proper body structure?
     // Content hidden behind notch/status bar, or overflow errors
     body: SafeArea(
       child: SingleChildScrollView(
         padding: EdgeInsets.symmetric(
           horizontal: isTablet ? screenWidth * 0.1 : screenWidth * 0.04,
           vertical: 20,
         ),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             
             // 🔍 What does the note header display?
             // Beautiful gradient card with note title, category, reading time
             // 💡 Why create dedicated header section?
             // Draws attention to note title, provides key metadata at glance
             // 🔁 What happens in header section?
             // Purple gradient background showcases note title prominently
             // ⚠️ What would break without header section?
             // No visual hierarchy, title gets lost among content
             _NoteHeader(
               note: note,
               isTablet: isTablet,
             ),
             
             const SizedBox(height: 24),
             
             // 🔍 What does the content section show?
             // Main note content in readable format with word count
             // 💡 Why separate content from header?
             // Creates clear reading flow, focuses attention on content
             // 🔁 What happens in content section?
             // Note text displayed with comfortable reading typography
             // ⚠️ What would break without content section?
             // No way to view the actual note content, main purpose lost
             _NoteContent(
               content: note['snippet'] ?? 'No content available',
               isTablet: isTablet,
             ),
             
             const SizedBox(height: 32),
             
             // 🔍 What do these action buttons do?
             // Primary actions user can take on the note (edit, share, favorite)
             // 💡 Why group actions in a row?
             // Efficient use of space, all actions visible at once
             // 🔁 What happens with action buttons?
             // Users can quickly edit, share, or favorite without menu navigation
             // ⚠️ What would break without action buttons?
             // No way to interact with the note, static read-only interface
             _DetailActionsRow(
               note: note,
               controller: detailController,
               isTablet: isTablet,
             ),
             
             const SizedBox(height: 24),
             
             // 🔍 What does the related notes section do?
             // Shows other notes in the same category for easy discovery
             // 💡 Why show related notes?
             // Improves content discovery, keeps users engaged with related content
             // 🔁 What happens with related notes?
             // Users can quickly jump to similar notes without going back to home
             // ⚠️ What would break without related notes?
             // Isolated note viewing, poor content discoverability
             _RelatedNotesSection(
               currentCategory: note['tag'] ?? 'Personal',
               controller: detailController,
               isTablet: isTablet,
             ),
             
             const SizedBox(height: 60),
           ],
         ),
       ),
     ),
     
     // 🔍 What does the floating action button do?
     // Provides quick access to edit mode with loading state indication
     // 💡 Why add a FAB when there's an edit button?
     // Follows material design patterns, always accessible regardless of scroll position
     // 🔁 What happens with edit FAB?
     // Quick edit access from anywhere on screen, shows loading during navigation
     // ⚠️ What would break without edit FAB?
     // Less convenient editing access, users might miss edit functionality
     floatingActionButton: _EditNoteFAB(controller: detailController),
   );
 }
}

// 🔍 What is this custom app bar widget?
// Specialized app bar that shows note-specific information and actions
// 💡 Why implement PreferredSizeWidget?
// Required interface for Scaffold.appBar, defines height requirements
// 🔁 What happens with custom app bar?
// Shows note category, emoji, timestamp, and action menu
// ⚠️ What would break without implementing PreferredSizeWidget?
// Scaffold wouldn't know how to size the app bar properly, layout errors
class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
 final Map<String, dynamic> note;
 final NoteDetailController controller;
 
 const _DetailAppBar({
   required this.note,
   required this.controller,
 });

 @override
 Widget build(BuildContext context) {
   return AppBar(
     backgroundColor: const Color(0xFFF8F6FF),
     elevation: 0,
     
     // 🔍 What does the leading back button do?
     // Provides navigation back to previous screen with GetX navigation
     // 💡 Why use custom back button instead of default?
     // Consistent styling with app design, proper GetX navigation
     // 🔁 What happens when user taps back?
     // Returns to previous screen using GetX navigation system
     // ⚠️ What would break without back button?
     // Users trapped on detail screen, no way to navigate back
     leading: IconButton(
       onPressed: () => Get.back(),
       icon: const Icon(
         Icons.arrow_back_ios,
         color: Color(0xFF6B7280),
         size: 20,
       ),
     ),
     
     // 🔍 What does this title section display?
     // Note category information with emoji and timestamp
     // 💡 Why show category info in app bar?
     // Provides context about current note without taking body space
     // 🔁 What happens in title area?
     // Emoji in colored container, category name, and timestamp shown
     // ⚠️ What would break without title info?
     // No context about current note, generic app bar
     title: Row(
       children: [
         // 🔍 What does this emoji container do?
         // Displays note's category emoji in purple-tinted background
         // 💡 Why put emoji in colored container?
         // Creates visual consistency, draws attention, matches app theme
         // 🔁 What happens with emoji display?
         // Category emoji shown prominently in purple container
         // ⚠️ What would break without emoji container?
         // Less visual interest, no category indication at glance
         Container(
           padding: const EdgeInsets.all(6),
           decoration: BoxDecoration(
             color: const Color(0xFF8B5CF6).withOpacity(0.1),
             borderRadius: BorderRadius.circular(8),
           ),
           child: Text(
             note['emoji'] ?? '📝',
             style: const TextStyle(fontSize: 16),
           ),
         ),
         const SizedBox(width: 12),
         // 🔍 What does this column show?
         // Category name and timestamp in vertical layout
         // 💡 Why stack category and timestamp vertically?
         // Efficient use of horizontal space, clear hierarchy
         // 🔁 What happens in this column?
         // Category name displayed prominently, timestamp shown below
         // ⚠️ What would break without this information?
         // No context about note category or when it was created
         Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(
               note['tag'] ?? 'Note',
               style: const TextStyle(
                 fontFamily: 'Poppins',
                 fontSize: 16,
                 fontWeight: FontWeight.w500,
                 color: Color(0xFF374151),
               ),
             ),
             Text(
               note['formattedTimestamp'] ?? 'Recently',
               style: const TextStyle(
                 fontFamily: 'Poppins',
                 fontSize: 12,
                 color: Color(0xFF9CA3AF),
               ),
             ),
           ],
         ),
       ],
     ),
     
     // 🔍 What do these action buttons provide?
     // Quick access to sharing and more options menu
     // 💡 Why have both share button and menu?
     // Share is common action (deserves dedicated button), menu holds other actions
     // 🔁 What happens with action buttons?
     // Share button triggers sharing, menu shows additional options
     // ⚠️ What would break without action buttons?
     // No way to access note actions from app bar
     actions: [
       // 🔍 What does the share button do?
       // Provides quick access to note sharing functionality
       // 💡 Why dedicated share button instead of in menu?
       // Sharing is common action, deserves prominent placement
       // 🔁 What happens when share is tapped?
       // Controller's shareNote() method is called, placeholder message shown
       // ⚠️ What would break without share button?
       // Less convenient sharing access, buried in menu
       IconButton(
         onPressed: () => controller.shareNote(),
         icon: const Icon(
           Icons.share,
           color: Color(0xFF6B7280),
           size: 20,
         ),
       ),
       
       // 🔍 What does this popup menu provide?
       // Additional note actions in dropdown menu format
       // 💡 Why use PopupMenuButton for additional actions?
       // Saves app bar space, groups less common actions together
       // 🔁 What happens when menu is opened?
       // Dropdown shows favorite, duplicate, export, delete options
       // ⚠️ What would break without popup menu?
       // No access to important note actions like delete, duplicate
       PopupMenuButton<String>(
         icon: const Icon(
           Icons.more_vert,
           color: Color(0xFF6B7280),
         ),
         // 🔍 What does the onSelected callback do?
         // Handles menu item selection and triggers appropriate actions
         // 💡 Why use switch statement for menu handling?
         // Clean way to handle multiple menu options, easy to extend
         // 🔁 What happens when menu item is selected?
         // Corresponding controller method is called based on selection
         // ⚠️ What would break without onSelected handling?
         // Menu items would be non-functional, no actions triggered
         onSelected: (value) {
           switch (value) {
             case 'favorite':
               controller.toggleFavorite();
               break;
             case 'duplicate':
               controller.duplicateNote();
               break;
             case 'export':
               // TODO: Implement export functionality
               Get.snackbar(
                 'Export Feature',
                 'Export functionality coming soon!',
                 snackPosition: SnackPosition.BOTTOM,
                 backgroundColor: Colors.blue,
                 colorText: Colors.white,
                 duration: const Duration(seconds: 2),
               );
               break;
             case 'delete':
               controller.deleteNote();
               break;
           }
         },
         // 🔍 What does itemBuilder create?
         // The list of menu items shown in the popup
         // 💡 Why dynamic favorite option with Obx?
         // Shows current favorite state, updates text/icon reactively
         // 🔁 What happens in itemBuilder?
         // Creates menu items with icons and text, favorite item is reactive
         // ⚠️ What would break without itemBuilder?
         // No menu items to display, empty popup menu
         itemBuilder: (context) => [
           // 🔍 What makes this favorite option special?
           // Uses Obx to show current favorite state dynamically
           // 💡 Why wrap favorite option in Obx?
           // Heart icon and text change based on current favorite status
           // 🔁 What happens when favorite state changes?
           // Menu item automatically updates to show filled/empty heart
           // ⚠️ What would break without Obx wrapper?
           // Static menu item, wouldn't reflect current favorite state
           PopupMenuItem(
             value: 'favorite',
             child: Obx(() => Row(
               children: [
                 Icon(
                   controller.isFavorite.value 
                       ? Icons.favorite 
                       : Icons.favorite_border,
                   size: 18,
                   color: controller.isFavorite.value 
                       ? Colors.red 
                       : Colors.grey,
                 ),
                 const SizedBox(width: 8),
                 Text(controller.isFavorite.value 
                     ? 'Remove from Favorites' 
                     : 'Add to Favorites'),
               ],
             )),
           ),
           const PopupMenuItem(
             value: 'duplicate',
             child: Row(
               children: [
                 Icon(Icons.copy, size: 18),
                 SizedBox(width: 8),
                 Text('Duplicate'),
               ],
             ),
           ),
           const PopupMenuItem(
             value: 'export',
             child: Row(
               children: [
                 Icon(Icons.download, size: 18),
                 SizedBox(width: 8),
                 Text('Export'),
               ],
             ),
           ),
           const PopupMenuDivider(),
           const PopupMenuItem(
             value: 'delete',
             child: Row(
               children: [
                 Icon(Icons.delete, size: 18, color: Colors.red),
                 SizedBox(width: 8),
                 Text('Delete', style: TextStyle(color: Colors.red)),
               ],
             ),
           ),
         ],
       ),
     ],
   );
 }

 // 🔍 What does preferredSize define?
 // Required by PreferredSizeWidget to tell Scaffold the app bar height
 // 💡 Why use kToolbarHeight constant?
 // Flutter's standard app bar height, ensures consistency across app
 // 🔁 What happens with preferredSize?
 // Scaffold reserves correct amount of space for app bar
 // ⚠️ What would break without preferredSize?
 // Compilation error, PreferredSizeWidget interface not satisfied
 @override
 Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// 🔍 What does this header widget display?
// Beautiful gradient card containing note title and metadata
// 💡 Why separate header from content?
// Creates visual hierarchy, title gets prominent display with branded styling
// 🔁 What happens in note header?
// Purple gradient background showcases title, category tag, reading time
// ⚠️ What would break without dedicated header?
// Title mixed with content, no visual emphasis on note title
class _NoteHeader extends StatelessWidget {
 final Map<String, dynamic> note;
 final bool isTablet;
 
 const _NoteHeader({
   required this.note,
   required this.isTablet,
 });

 @override
 Widget build(BuildContext context) {
   return Container(
     width: double.infinity,
     padding: EdgeInsets.all(isTablet ? 24 : 20),
     // 🔍 What does this gradient decoration do?
     // Creates beautiful purple gradient background with glow effect
     // 💡 Why use gradient instead of solid color?
     // More visually appealing, matches app branding, creates depth
     // 🔁 What happens with gradient decoration?
     // Header stands out with purple gradient and subtle shadow
     // ⚠️ What would break without gradient decoration?
     // Plain white header, no visual impact, boring design
     decoration: BoxDecoration(
       gradient: const LinearGradient(
         colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
         begin: Alignment.topLeft,
         end: Alignment.bottomRight,
       ),
       borderRadius: BorderRadius.circular(16),
       boxShadow: [
         BoxShadow(
           color: const Color(0xFF8B5CF6).withOpacity(0.3),
           blurRadius: 15,
           offset: const Offset(0, 8),
         ),
       ],
     ),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         
         // 🔍 What does this title display?
         // Main note title with large, bold white typography
         // 💡 Why use large, bold text for title?
         // Creates clear hierarchy, title is most important element
         // 🔁 What happens with title display?
         // Note title shown prominently in white against purple gradient
         // ⚠️ What would break without prominent title?
         // No clear way to identify the note, poor visual hierarchy
         Text(
           note['title'] ?? 'Untitled Note',
           style: TextStyle(
             fontFamily: 'Poppins',
             fontSize: isTablet ? 28 : 24,
             fontWeight: FontWeight.w700,
             color: Colors.white,
             height: 1.2,
           ),
         ),
         
         const SizedBox(height: 16),
         
         // 🔍 What does this metadata row show?
         // Category tag on left, reading time estimate on right
         // 💡 Why show category and reading time?
         // Category helps organize, reading time helps users plan
         // 🔁 What happens in metadata row?
         // Category shown in pill, reading time calculated and displayed
         // ⚠️ What would break without metadata?
         // No context about note category or length
         Row(
           children: [
             // 🔍 What does the category tag display?
             // Note category in white pill with semi-transparent background
             // 💡 Why use pill-shaped tag?
             // Modern design pattern, clearly separates category from other text
             // 🔁 What happens with category tag?
             // Category name shown in white pill against gradient
             // ⚠️ What would break without category tag?
             // No visual indication of note category
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
               decoration: BoxDecoration(
                 color: Colors.white.withOpacity(0.2),
                 borderRadius: BorderRadius.circular(20),
               ),
               child: Text(
                 note['tag'] ?? 'Personal',
                 style: const TextStyle(
                   fontFamily: 'Poppins',
                   fontSize: 12,
                   fontWeight: FontWeight.w500,
                   color: Colors.white,
                 ),
               ),
             ),
             
             const Spacer(),
             
             // 🔍 What does the reading time show?
             // Estimated reading time based on content length
             // 💡 Why show reading time estimate?
             // Helps users understand time commitment before reading
             // 🔁 What happens with reading time?
             // Word count calculated, reading time estimated at 200 words/minute
             // ⚠️ What would break without reading time?
             // No indication of note length or time needed to read
             Row(
               children: [
                 const Icon(
                   Icons.schedule,
                   size: 16,
                   color: Colors.white,
                 ),
                 const SizedBox(width: 4),
                 Text(
                   '${_calculateReadingTime(note['snippet'] ?? '')} min read',
                   style: const TextStyle(
                     fontFamily: 'Poppins',
                     fontSize: 12,
                     color: Colors.white,
                   ),
                 ),
               ],
             ),
           ],
         ),
       ],
     ),
   );
 }

 // 🔍 What does this calculation method do?
 // Estimates reading time based on word count at 200 words per minute
 // 💡 Why calculate reading time?
 // Industry standard for content, helps users plan their time
 // 🔁 What happens in calculation?
 // Words counted, divided by 200, rounded up to nearest minute
 // ⚠️ What would break without reading time calculation?
 // No way to estimate time needed, less useful metadata
 int _calculateReadingTime(String content) {
   final wordCount = content.split(' ').length;
   final readingTime = (wordCount / 200).ceil(); // 200 words per minute
   return readingTime < 1 ? 1 : readingTime;
 }
}

// 🔍 What does this content widget display?
// Main note content in readable format with word count header
// 💡 Why separate content from header?
// Clean reading experience, content gets proper focus without distractions
// 🔁 What happens in content display?
// White card with note text, comfortable typography for reading
// ⚠️ What would break without content section?
// No way to read the actual note content, defeats main purpose
class _NoteContent extends StatelessWidget {
 final String content;
 final bool isTablet;
 
 const _NoteContent({
   required this.content,
   required this.isTablet,
 });

 @override
 Widget build(BuildContext context) {
   return Container(
     width: double.infinity,
     padding: EdgeInsets.all(isTablet ? 28 : 24),
     // 🔍 What does this white card decoration do?
     // Creates clean reading surface with subtle shadow for depth
     // 💡 Why white background for content?
     // Optimal reading contrast, reduces eye strain, focuses on text
     // 🔁 What happens with white card?
     // Content displayed in clean, readable white container
     // ⚠️ What would break without white card?
     // Content mixed with background, poor readability
     decoration: BoxDecoration(
       color: Colors.white,
       borderRadius: BorderRadius.circular(16),
       boxShadow: [
         BoxShadow(
           color: Colors.black.withOpacity(0.05),
           blurRadius: 10,
           offset: const Offset(0, 4),
         ),
       ],
     ),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         
         // 🔍 What does this content header show?
         // "Content" label with article icon and word count
         // 💡 Why add content section header?
         // Creates clear section separation, provides metadata
         // 🔁 What happens with content header?
         // Purple icon, "Content" label, word count displayed
         // ⚠️ What would break without section header?
         // Content section unclear, no metadata about length
         Row(
           children: [
             const Icon(
               Icons.article_outlined,
               size: 20,
               color: Color(0xFF8B5CF6),
             ),
             const SizedBox(width: 8),
             Text(
               'Content',
               style: TextStyle(
                 fontFamily: 'Poppins',
                 fontSize: isTablet ? 18 : 16,
                 fontWeight: FontWeight.w600,
                 color: const Color(0xFF374151),
               ),
             ),
             const Spacer(),
             // 🔍 What does this word count do?
             // Shows accurate word count by filtering empty strings
             // 💡 Why show word count?
             // Helps users understand content length at a glance
             // 🔁 What happens with word count?
             // Content split by spaces, empty strings filtered, count displayed
             // ⚠️ What would break without word count?
             // No indication of content length or detail level
             Text(
               '${content.split(' ').where((word) => word.isNotEmpty).length} words',
               style: TextStyle(
                 fontFamily: 'Poppins',
                 fontSize: isTablet ? 14 : 12,
                 color: const Color(0xFF9CA3AF),
               ),
             ),
           ],
         ),
         
         const SizedBox(height: 16),
         
         // 🔍 What does this content text display?
         // Main note content with optimal reading typography
         // 💡 Why specific font size and line height?
         // Optimized for comfortable reading on different screen sizes
         // 🔁 What happens with content text?
         // Note content displayed with professional typography
         // ⚠️ What would break without proper typography?
         // Poor reading experience, eye strain, unprofessional appearance
         Text(
           content,
           style: TextStyle(
             fontFamily: 'Poppins',
             fontSize: isTablet ? 18 : 16,
             fontWeight: FontWeight.w400,
             color: const Color(0xFF1F1937),
             height: 1.6, // Comfortable line spacing for reading
           ),
         ),
       ],
     ),
   );
 }
}

// 🔍 What do these action buttons provide?
// Primary note actions in horizontal layout (edit, share, favorite)
// 💡 Why group actions in a row?
// Efficient space usage, all important actions visible at once
// 🔁 What happens with action buttons?
// Edit and share buttons expanded, favorite button compact on right
// ⚠️ What would break without action buttons?
// No way to interact with note, static viewing only
class _DetailActionsRow extends StatelessWidget {
 final Map<String, dynamic> note;
 final NoteDetailController controller;
 final bool isTablet;
 
 const _DetailActionsRow({
   required this.note,
   required this.controller,
   required this.isTablet,
 });

 @override
 Widget build(BuildContext context) {
   return Row(
     children: [
       
       // 🔍 What does the edit button do?
       // Primary action to navigate to edit screen
       // 💡 Why make edit button prominent?
       // Editing is the most common action after viewing
       // 🔁 What happens when edit is tapped?
       // Controller navigates to edit screen with note data
       // ⚠️ What would break without edit button?
       // No way to modify note content, read-only interface
       Expanded(
         child: ElevatedButton.icon(
           onPressed: () => controller.navigateToEdit(),
           icon: const Icon(Icons.edit, size: 20),
           label: Text(
             'Edit Note',
             style: TextStyle(
               fontFamily: 'Poppins',
               fontSize: isTablet ? 16 : 14,
               fontWeight: FontWeight.w500,
             ),
           ),
           style: ElevatedButton.styleFrom(
             backgroundColor: const Color(0xFF8B5CF6),
             foregroundColor: Colors.white,
             elevation: 2,
             padding: EdgeInsets.symmetric(
               vertical: isTablet ? 16 : 12,
             ),
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(12),
             ),
           ),
         ),
       ),
       
       const SizedBox(width: 12),
       
       // 🔍 What does the share button do?
       // Secondary action to share note content
       // 💡 Why make share button outlined?
       // Secondary action styling, less prominent than edit
       // 🔁 What happens when share is tapped?
       // Controller formats and shares note content
       // ⚠️ What would break without share button?
       // No convenient way to share notes with others
       Expanded(
         child: OutlinedButton.icon(
           onPressed: () => controller.shareNote(),
           icon: const Icon(Icons.share, size: 20),
           label: Text(
             'Share',
             style: TextStyle(
               fontFamily: 'Poppins',
               fontSize: isTablet ? 16 : 14,
               fontWeight: FontWeight.w500,
             ),
           ),
           style: OutlinedButton.styleFrom(
             foregroundColor: const Color(0xFF8B5CF6),
             side: const BorderSide(color: Color(0xFF8B5CF6)),
             padding: EdgeInsets.symmetric(
               vertical: isTablet ? 16 : 12,
             ),
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(12),
             ),
           ),
         ),
       ),
       
       const SizedBox(width: 12),
       
       // 🔍 What does the favorite button do?
       // Quick toggle for favorite status with reactive visual feedback
       // 💡 Why wrap favorite button in Obx?
       // Icon and color change reactively based on favorite state
       // 🔁 What happens when favorite is tapped?
       // Favorite state toggles, icon updates, snackbar shows feedback
       // ⚠️ What would break without reactive favorite button?
       // Static icon, no visual feedback for favorite status
       Container(
         decoration: BoxDecoration(
           border: Border.all(color: const Color(0xFFE5E7EB)),
           borderRadius: BorderRadius.circular(12),
         ),
         child: Obx(() => IconButton(
           onPressed: () => controller.toggleFavorite(),
           icon: Icon(
             controller.isFavorite.value 
                 ? Icons.favorite 
                 : Icons.favorite_border,
             color: controller.isFavorite.value 
                 ? Colors.red 
                 : const Color(0xFF6B7280),
             size: 24,
           ),
           padding: EdgeInsets.all(isTablet ? 16 : 12),
         )),
       ),
     ],
   );
 }
}

// 🔍 What does this related notes section show?
// Other notes in the same category for content discovery
// 💡 Why show related notes?
// Improves content discovery, keeps users engaged longer
// 🔁 What happens in related notes?
// Finds notes with same category, shows up to 3 as list items
// ⚠️ What would break without related notes?
// Isolated note viewing, poor content discoverability
class _RelatedNotesSection extends StatelessWidget {
 final String currentCategory;
 final NoteDetailController controller;
 final bool isTablet;
 
 const _RelatedNotesSection({
   required this.currentCategory,
   required this.controller,
   required this.isTablet,
 });

 @override
 Widget build(BuildContext context) {
   // 🔍 What does this related notes query do?
   // Finds notes in same category, excluding current note, limited to 3
   // 💡 Why limit to 3 related notes?
   // Keeps section manageable, prevents overwhelming the user
   // 🔁 What happens in the query?
   // Filters by category, excludes current note, takes first 3, maps to display format
   // ⚠️ What would break without this query?
   // No related notes to show, empty section
   final notesController = Get.find<NotesController>();
   final relatedNotes = notesController.allNotes
       .where((note) => 
           note.tag == currentCategory && 
           note.id != controller.currentNote['id'])
       .take(3) // Show only 3 related notes
       .map((note) => {
         'id': note.id,
         'title': note.title,
         'tag': note.tag,
         'emoji': note.emoji,
         'snippet': note.snippet,
         'createdAt': note.formattedTimestamp,
       })
       .toList();
   
   // 🔍 What does this empty check do?
   // Hides entire section when no related notes exist
   // 💡 Why hide section instead of showing empty state?
   // Cleaner interface, no unnecessary empty sections
   // 🔁 What happens when no related notes?
   // Section completely hidden using SizedBox.shrink()
   // ⚠️ What would break without empty check?
   // Empty section taking up space, showing "Related Notes" with nothing
   if (relatedNotes.isEmpty) {
     return const SizedBox.shrink();
   }
   
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       
       // 🔍 What does this section header show?
       // "Related Notes" title with "View All" button
       // 💡 Why include "View All" button?
       // Provides easy access to see all notes in category
       // 🔁 What happens with section header?
       // Title on left, "View All" button on right that triggers category filter
       // ⚠️ What would break without section header?
       // No context about what the note items represent
       Row(
         children: [
           Text(
             'Related Notes',
             style: TextStyle(
               fontFamily: 'Poppins',
               fontSize: isTablet ? 18 : 16,
               fontWeight: FontWeight.w600,
               color: const Color(0xFF374151),
             ),
           ),
           const Spacer(),
           // 🔍 What does the "View All" button do?
           // Navigates back to home with category filter applied
           // 💡 Why provide "View All" option?
           // Users might want to see all notes in category, not just 3
           // 🔁 What happens when "View All" is tapped?
           // Controller sets category filter and navigates to home
           // ⚠️ What would break without "View All"?
           // No way to see complete list of related notes
           TextButton(
             onPressed: () => controller.viewCategoryNotes(currentCategory),
             child: Text(
               'View All',
               style: TextStyle(
                 fontFamily: 'Poppins',
                 fontSize: isTablet ? 14 : 12,
                 color: const Color(0xFF8B5CF6),
                 fontWeight: FontWeight.w500,
               ),
             ),
           ),
         ],
       ),
       
       const SizedBox(height: 12),
       
       // 🔍 What does this list generation do?
       // Creates individual note items from related notes data
       // 💡 Why use map().toList() pattern?
       // Transforms data into widgets, creates list of note item widgets
       // 🔁 What happens in list generation?
       // Each related note converted to _RelatedNoteItem widget
       // ⚠️ What would break without list generation?
       // No actual note items displayed, just empty section
       ...relatedNotes.map((note) => _RelatedNoteItem(
         note: note,
         isTablet: isTablet,
       )).toList(),
     ],
   );
 }
}

// 🔍 What does this individual note item show?
// Single related note with emoji, title, category, and navigation
// 💡 Why create separate widget for each note item?
// Reusable component, clean code organization, consistent styling
// 🔁 What happens with note item?
// ListTile shows note info, taps navigate to that note's detail screen
// ⚠️ What would break without individual note items?
// No way to display or interact with related notes
class _RelatedNoteItem extends StatelessWidget {
 final Map<String, dynamic> note;
 final bool isTablet;
 
 const _RelatedNoteItem({
   required this.note,
   required this.isTablet,
 });

 @override
 Widget build(BuildContext context) {
   return Container(
     margin: const EdgeInsets.only(bottom: 8),
     child: ListTile(
       // 🔍 What does the onTap handler do?
       // Navigates to the tapped related note's detail screen
       // 💡 Why allow navigation to related notes?
       // Enables content discovery, users can explore related content
       // 🔁 What happens when related note is tapped?
       // New detail screen opens for the selected related note
       // ⚠️ What would break without onTap navigation?
       // Related notes would be displayed but not interactive
       onTap: () {
         Get.to(() => NoteDetailScreen(note: note));
       },
       // 🔍 What does the leading emoji container show?
       // Note's category emoji in purple-tinted container
       // 💡 Why show emoji in leading position?
       // Quick visual category identification, consistent with app design
       // 🔁 What happens with leading emoji?
       // Emoji displayed in purple container matching app theme
       // ⚠️ What would break without leading emoji?
       // Less visual interest, no quick category identification
       leading: Container(
         width: 40,
         height: 40,
         decoration: BoxDecoration(
           color: const Color(0xFF8B5CF6).withOpacity(0.1),
           borderRadius: BorderRadius.circular(8),
         ),
         child: Center(
           child: Text(
             note['emoji'] ?? '📝',
             style: const TextStyle(fontSize: 16),
           ),
         ),
       ),
       // 🔍 What does the title text display?
       // Note's title with ellipsis truncation if too long
       // 💡 Why truncate title with ellipsis?
       // Maintains consistent list item height, prevents layout breaking
       // 🔁 What happens with title display?
       // Title shown in semi-bold text, truncated with "..." if needed
       // ⚠️ What would break without title truncation?
       // Long titles could break list layout, overflow issues
       title: Text(
         note['title'] ?? 'Untitled',
         style: TextStyle(
           fontFamily: 'Poppins',
           fontSize: isTablet ? 16 : 14,
           fontWeight: FontWeight.w500,
           color: const Color(0xFF374151),
         ),
         maxLines: 1,
         overflow: TextOverflow.ellipsis,
       ),
       // 🔍 What does the subtitle show?
       // Note's category tag in lighter color
       // 💡 Why show category as subtitle?
       // Provides context about note type without taking main space
       // 🔁 What happens with subtitle display?
       // Category name shown in light gray below title
       // ⚠️ What would break without category subtitle?
       // No indication of note category in related items
       subtitle: Text(
         note['tag'] ?? 'Personal',
         style: TextStyle(
           fontFamily: 'Poppins',
           fontSize: isTablet ? 12 : 11,
           color: const Color(0xFF9CA3AF),
         ),
       ),
       // 🔍 What does the trailing arrow do?
       // Visual indicator that item is tappable for navigation
       // 💡 Why include trailing arrow?
       // Standard UI pattern indicating navigatable list items
       // 🔁 What happens with trailing arrow?
       // Small right arrow shown on right side of list item
       // ⚠️ What would break without trailing arrow?
       // Users might not realize items are tappable
       trailing: const Icon(
         Icons.arrow_forward_ios,
         size: 16,
         color: Color(0xFF9CA3AF),
       ),
       // 🔍 What do these styling properties do?
       // White background with rounded corners for list item
       // 💡 Why style list items with background and shape?
       // Creates card-like appearance, separates items visually
       // 🔁 What happens with tile styling?
       // Each related note appears as white rounded rectangle
       // ⚠️ What would break without tile styling?
       // Items blend together, no visual separation
       tileColor: Colors.white,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(8),
       ),
     ),
   );
 }
}

// 🔍 What does this floating action button provide?
// Quick edit access with loading state indication
// 💡 Why add FAB when there's already an edit button?
// Follows material design, always accessible regardless of scroll position
// 🔁 What happens with edit FAB?
// Purple button with edit icon, shows spinner during navigation loading
// ⚠️ What would break without edit FAB?
// Less convenient edit access, might miss edit functionality when scrolled
class _EditNoteFAB extends StatelessWidget {
 final NoteDetailController controller;
 
 const _EditNoteFAB({required this.controller});

 @override
 Widget build(BuildContext context) {
   // 🔍 What does this Obx wrapper do?
   // Makes FAB reactive to loading state changes
   // 💡 Why wrap entire FAB in Obx?
   // Button appearance and functionality change based on loading state
   // 🔁 What happens when loading state changes?
   // Button color, icon, and functionality update automatically
   // ⚠️ What would break without Obx wrapper?
   // Static FAB, no loading feedback, possible double-taps
   return Obx(() => FloatingActionButton(
     // 🔍 What does this conditional onPressed do?
     // Disables button during loading, prevents multiple rapid taps
     // 💡 Why disable button during loading?
     // Prevents navigation conflicts, provides clear loading feedback
     // 🔁 What happens when button is disabled vs enabled?
     // Disabled: null onPressed, grayed out. Enabled: navigates to edit
     // ⚠️ What would break without conditional onPressed?
     // Multiple navigation attempts, app state conflicts
     onPressed: controller.isLoading.value 
         ? null 
         : () => controller.navigateToEdit(),
     // 🔍 What does this conditional background color do?
     // Shows gray when loading, purple when ready
     // 💡 Why change background color based on loading?
     // Visual feedback that button is disabled/enabled
     // 🔁 What happens with color changes?
     // Gray indicates loading/disabled, purple indicates ready/enabled
     // ⚠️ What would break without color feedback?
     // No visual indication of button state
     backgroundColor: controller.isLoading.value 
         ? Colors.grey 
         : const Color(0xFF8B5CF6),
     foregroundColor: Colors.white,
     elevation: 6,
     // 🔍 What does this conditional child do?
     // Shows spinner during loading, edit icon when ready
     // 💡 Why switch between spinner and icon?
     // Clear visual feedback about current state and action
     // 🔁 What happens with child switching?
     // Loading: spinning circle. Ready: edit icon
     // ⚠️ What would break without conditional child?
     // No loading feedback, users unsure if tap registered
     child: controller.isLoading.value 
         ? const SizedBox(
             width: 24,
             height: 24,
             child: CircularProgressIndicator(
               strokeWidth: 2,
               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
             ),
           )
         : const Icon(Icons.edit, size: 28),
   ));
 }
}