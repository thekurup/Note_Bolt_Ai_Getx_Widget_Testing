// lib/models/note_model.dart

// ✅ This creates a blueprint/template for every note in our app
class Note {
  // ✅ `final` means once set, these values can't change (immutable)
  // ✅ This prevents bugs where data accidentally gets modified
  final String id;        // Unique identifier (like a passport number)
  final String title;     // Main heading of the note
  final String snippet;   // Preview text (first few lines)
  final String tag;       // Category: Work, Personal, Reading, etc.
  final String emoji;     // Visual icon to represent the note
  final DateTime createdAt; // When this note was created

  // ✅ Constructor - this runs every time we create a new Note
  // ✅ `required` means we MUST provide these values - no forgetting!
  Note({
    required this.id,
    required this.title,
    required this.snippet,
    required this.tag,
    required this.emoji,
    required this.createdAt,
  });

  // ✅ GETTER METHOD - calculates formatted time dynamically
  // ✅ Why getter? Because time changes! "2 hours ago" becomes "3 hours ago"
  String get formattedTimestamp {
    final now = DateTime.now();                    // Get current time
    final difference = now.difference(createdAt);  // Calculate how long ago
    
    // ✅ Convert duration into human-readable format
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }

  // ✅ FACTORY CONSTRUCTOR - special way to create sample notes easily
  // ✅ `factory` means this returns a Note object but with custom logic
  factory Note.sample({
    required String title,
    required String snippet,
    required String tag,
    required String emoji,
    required int hoursAgo,  // How many hours ago this note was "created"
  }) {
    return Note(
      // ✅ Generate unique ID using current timestamp
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      snippet: snippet,
      tag: tag,
      emoji: emoji,
      // ✅ Subtract hours to simulate notes created in the past
      createdAt: DateTime.now().subtract(Duration(hours: hoursAgo)),
    );
  }

  // ✅ Convert Note object to JSON Map for database storage
  // ✅ Preparing for future database integration
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'snippet': snippet,
      'tag': tag,
      'emoji': emoji,
      // ✅ Convert DateTime to string format for JSON compatibility
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ✅ Create Note object from JSON Map (reverse of toJson)
  // ✅ Used when loading notes from database
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      snippet: json['snippet'],
      tag: json['tag'],
      emoji: json['emoji'],
      // ✅ Convert string back to DateTime object
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}