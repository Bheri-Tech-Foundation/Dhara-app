/// Vote request model for submitting votes to the API
class VoteRequest {
  /// The id of the response item to vote/record (e.g., "0", "1", "2", ..., "feed_back")
  final String itemId;
  
  /// The id of the query you want to vote for
  final int queryId;
  
  /// The value of response to vote/record
  /// - For results: dict_ref_id, verse_pk, or chunk_ref_id
  /// - For feedback: "missing_count" or "add_missing"
  final String? value;
  
  /// Value of the vote
  /// - For results: 2 (best), 1 (ok), 0 (neutral), -1 (wrong)
  /// - For missing_count: 0-20 (number as string)
  /// - For add_missing or feedback: text string
  final String vote;

  const VoteRequest({
    required this.itemId,
    required this.queryId,
    this.value,
    required this.vote,
  });

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'query_id': queryId,
        if (value != null) 'value': value,
        'vote': vote,
      };

  @override
  String toString() => 'VoteRequest(itemId: $itemId, queryId: $queryId, value: $value, vote: $vote)';
}






