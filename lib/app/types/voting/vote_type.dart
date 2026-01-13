/// Enum representing different types of content that can be voted on
enum VoteContentType {
  /// Dictionary definition
  definition,
  
  /// Verse
  verse,
  
  /// Book chunk
  chunk,
}

extension VoteContentTypeExtension on VoteContentType {
  String get name {
    switch (this) {
      case VoteContentType.definition:
        return 'Definition';
      case VoteContentType.verse:
        return 'Verse';
      case VoteContentType.chunk:
        return 'Book Chunk';
    }
  }
}

/// Enum for vote values (academic/scholarly evaluation)
enum VoteValue {
  /// -1: Not Relevant
  notRelevant,
  
  /// 0: Not Sure (user explicitly reviewed but cannot decide)
  neutral,
  
  /// 1: Relevant
  relevant,
  
  /// 2: Highly Relevant
  highlyRelevant,
}

extension VoteValueExtension on VoteValue {
  int get numericValue {
    switch (this) {
      case VoteValue.notRelevant:
        return -1;
      case VoteValue.neutral:
        return 0;
      case VoteValue.relevant:
        return 1;
      case VoteValue.highlyRelevant:
        return 2;
    }
  }

  String get label {
    switch (this) {
      case VoteValue.notRelevant:
        return 'Not Relevant';
      case VoteValue.neutral:
        return 'Not Sure';
      case VoteValue.relevant:
        return 'Relevant';
      case VoteValue.highlyRelevant:
        return 'Highly Relevant';
    }
  }

  // Shorter label for compact UI
  String get shortLabel {
    switch (this) {
      case VoteValue.notRelevant:
        return 'Not\nRelevant';
      case VoteValue.neutral:
        return 'Not\nSure';
      case VoteValue.relevant:
        return 'Relevant';
      case VoteValue.highlyRelevant:
        return 'Highly\nRelevant';
    }
  }

  String get icon {
    switch (this) {
      case VoteValue.notRelevant:
        return '✗';
      case VoteValue.neutral:
        return '?';
      case VoteValue.relevant:
        return '✓';
      case VoteValue.highlyRelevant:
        return '✓✓';
    }
  }

  static VoteValue? fromNumeric(int value) {
    switch (value) {
      case -1:
        return VoteValue.notRelevant;
      case 0:
        return VoteValue.neutral;
      case 1:
        return VoteValue.relevant;
      case 2:
        return VoteValue.highlyRelevant;
      default:
        return null;
    }
  }
}

