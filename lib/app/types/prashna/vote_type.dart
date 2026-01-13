/// Vote type for Prashna evaluations
enum PrashnaVoteType {
  faithfulness,
  relevance,
  correctness,
  feedback;

  String get apiValue {
    switch (this) {
      case PrashnaVoteType.feedback:
        return 'feed_back'; // API expects feed_back with underscore
      default:
        return name;
    }
  }

  String get displayName {
    switch (this) {
      case PrashnaVoteType.faithfulness:
        return 'Faithfulness';
      case PrashnaVoteType.relevance:
        return 'Relevance';
      case PrashnaVoteType.correctness:
        return 'Correctness';
      case PrashnaVoteType.feedback:
        return 'Feedback';
    }
  }

  String get description {
    switch (this) {
      case PrashnaVoteType.faithfulness:
        return 'How accurately does the answer reflect the source texts?';
      case PrashnaVoteType.relevance:
        return 'How relevant is this answer to your question?';
      case PrashnaVoteType.correctness:
        return 'How correct is this answer based on your knowledge?';
      case PrashnaVoteType.feedback:
        return 'Share your detailed thoughts on this response';
    }
  }
}

/// Vote value for Prashna (rating scale)
/// Order: excellent (2), good (1), neutral (0), poor (-1)
enum PrashnaVoteValue {
  excellent,   // 2
  good,        // 1
  neutral,     // 0: Not Sure (user reviewed but cannot decide)
  poor;        // -1

  int get numericValue {
    switch (this) {
      case PrashnaVoteValue.excellent:
        return 2;
      case PrashnaVoteValue.good:
        return 1;
      case PrashnaVoteValue.neutral:
        return 0;
      case PrashnaVoteValue.poor:
        return -1;
    }
  }

  /// Get context-specific label based on vote type
  /// Consistent pattern: Highly X → X → Not Sure → Not X
  String labelForType(PrashnaVoteType voteType) {
    switch (voteType) {
      case PrashnaVoteType.faithfulness:
        switch (this) {
          case PrashnaVoteValue.excellent:
            return 'Highly Faithful';
          case PrashnaVoteValue.good:
            return 'Faithful';
          case PrashnaVoteValue.neutral:
            return 'Not Sure';
          case PrashnaVoteValue.poor:
            return 'Not Faithful';
        }
      case PrashnaVoteType.correctness:
        switch (this) {
          case PrashnaVoteValue.excellent:
            return 'Highly Correct';
          case PrashnaVoteValue.good:
            return 'Correct';
          case PrashnaVoteValue.neutral:
            return 'Not Sure';
          case PrashnaVoteValue.poor:
            return 'Incorrect';
        }
      case PrashnaVoteType.relevance:
        switch (this) {
          case PrashnaVoteValue.excellent:
            return 'Highly Relevant';
          case PrashnaVoteValue.good:
            return 'Relevant';
          case PrashnaVoteValue.neutral:
            return 'Not Sure';
          case PrashnaVoteValue.poor:
            return 'Not Relevant';
        }
      case PrashnaVoteType.feedback:
        return ''; // Not used for feedback
    }
  }

  String get icon {
    switch (this) {
      case PrashnaVoteValue.excellent:
        return '✓✓';
      case PrashnaVoteValue.good:
        return '✓';
      case PrashnaVoteValue.neutral:
        return '?';
      case PrashnaVoteValue.poor:
        return '✗';
    }
  }

  static PrashnaVoteValue? fromNumeric(int value) {
    switch (value) {
      case 2:
        return PrashnaVoteValue.excellent;
      case 1:
        return PrashnaVoteValue.good;
      case 0:
        return PrashnaVoteValue.neutral;
      case -1:
        return PrashnaVoteValue.poor;
      default:
        return null;
    }
  }
}

/// Prashna vote request model
class PrashnaVoteRequest {
  final int queryId;
  final PrashnaVoteType voteType;
  final String vote; // Either numeric string ("2", "1", "0", "-1") or text for feedback

  const PrashnaVoteRequest({
    required this.queryId,
    required this.voteType,
    required this.vote,
  });

  /// Create a vote request for a rating (faithfulness, relevance, correctness)
  factory PrashnaVoteRequest.rating({
    required int queryId,
    required PrashnaVoteType voteType,
    required PrashnaVoteValue voteValue,
  }) {
    return PrashnaVoteRequest(
      queryId: queryId,
      voteType: voteType,
      vote: voteValue.numericValue.toString(),
    );
  }

  /// Create a vote request for text feedback
  factory PrashnaVoteRequest.feedback({
    required int queryId,
    required String feedbackText,
  }) {
    return PrashnaVoteRequest(
      queryId: queryId,
      voteType: PrashnaVoteType.feedback,
      vote: feedbackText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query_id': queryId,
      'v_type': voteType.apiValue,
      'vote': vote,
    };
  }
}


