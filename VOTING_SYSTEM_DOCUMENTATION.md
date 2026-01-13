# Voting/Testing System Implementation - Complete

## 🎯 Overview
A comprehensive voting and feedback system has been implemented to allow testers to rate and provide feedback on search results in the Dhara app. The system is designed to be simple, focused on quality feedback collection, and works offline with sync capabilities.

---

## ✅ Completed Features

### 1. **Core Voting System**
- ✅ Vote request models and types (`VoteRequest`, `VoteValue`, `VoteContentType`)
- ✅ Voting repository with offline support
- ✅ Automatic local storage of votes
- ✅ Vote counter tracking

### 2. **Tester Mode**
- ✅ Tester Mode service for managing state
- ✅ Toggle in profile dropdown menu (with switch)
- ✅ Persistent state across app restarts
- ✅ Reactive streams for real-time updates

### 3. **API Integration**
- ✅ Parsing `query_id` from API responses (type='query_id')
- ✅ Parsing `item_id` from each result (definitions, verses, chunks)
- ✅ Automatic propagation through result chain
- ✅ Support for all content types (dict, verse, chunk)

### 4. **User Interface**
- ✅ Voting widget on tool cards (4 vote options: 👍 Best, 👌 OK, 😐 Neutral, 👎 Wrong)
- ✅ Feedback modal for detailed text feedback
- ✅ Missing count modal for reporting incomplete results
- ✅ Vote counter widget (compact & full views)
- ✅ Clean, simple UI focused on functionality

### 5. **Data Management**
- ✅ Offline vote storage in SharedPreferences
- ✅ Pending votes queue for later sync
- ✅ Total votes counter
- ✅ Clear voting data functionality

---

## 📂 New Files Created

### Core Logic
1. `lib/app/types/voting/vote_request.dart` - Vote request model
2. `lib/app/types/voting/vote_type.dart` - Vote enums and extensions
3. `lib/app/data/voting/voting_repository.dart` - Voting data layer
4. `lib/app/data/services/tester_mode_service.dart` - Tester mode management

### UI Components
5. `lib/app/ui/widgets/voting_widget.dart` - Vote buttons on cards
6. `lib/app/ui/widgets/feedback_modal.dart` - Text feedback collection
7. `lib/app/ui/widgets/missing_count_modal.dart` - Missing results reporting
8. `lib/app/ui/widgets/vote_counter_widget.dart` - Vote count display

---

## 🔄 Modified Files

### Core
- `lib/main.dart` - Initialize TesterModeService
- `lib/app/types/unified/unified_response.dart` - Added queryId & itemId fields
- `lib/core/services/unified_service.dart` - Parse query_id & item_id from API

### UI
- `lib/app/ui/pages/dashboard/dashboard_page.dart` - Added tester mode toggle
- `lib/core/components/tool_card.dart` - Integrated voting widget

---

## 🎮 How to Use

### For Users (Testers):

#### 1. **Enable Tester Mode**
- Open the app
- Click profile menu (three dots in top right)
- Toggle "Tester Mode" ON

#### 2. **Vote on Results**
- Search for something (e.g., "Yada yada hi dharmasya")
- Expand any result card (Definition, Verse, or Chunk)
- At the bottom, you'll see voting buttons:
  - **👍 Best** = Excellent, highly relevant (vote: 2)
  - **👌 OK** = Acceptable, somewhat relevant (vote: 1)
  - **😐 Neutral** = No strong opinion (vote: 0)
  - **👎 Wrong** = Incorrect, not relevant (vote: -1)
- Click any button to submit your vote

#### 3. **Give Feedback** (Optional)
- *Feature to be added: Feedback button on cards*
- Write detailed comments about the result
- Submit

#### 4. **Report Missing Results** (Optional)
- *Feature to be added: Missing count button on search*
- Select how many results you think are missing (0-20)
- Submit

#### 5. **View Your Contribution**
- Total votes counter shown in tester mode
- All votes saved locally
- Will sync to server when API is ready

---

## 🔧 API Integration

### Request Parameters

The voting API endpoint: `GET /vote/`

**Parameters:**
```
item_id: String    - "0", "1", "2"... from API or "feed_back"
query_id: Int      - From API response (type='query_id')
value: String?     - dict_ref_id / verse_pk / chunk_ref_id
vote: String       - "2" (best), "1" (ok), "0" (neutral), "-1" (wrong)
```

### Content Type Mapping

| Content Type | `value` Field     | `item_id` Source |
|-------------|-------------------|------------------|
| Definition  | `dict_ref_id`     | From API response |
| Verse       | `verse_pk`        | From API response |
| Chunk       | `chunk_ref_id`    | From API response |
| Feedback    | Optional or "feed_back" | "feed_back" |
| Missing Count | "missing_count" | "feed_back" |

### How It Works

1. **Search Request**
   ```
   User searches: "Agni"
   ```

2. **API Streams Responses**
   ```json
   {"type": "query_id", "data": 480}
   {"type": "definition", "item_id": "0", "data": {...}}
   {"type": "verse", "item_id": "1", "data": [...]}
   {"type": "chunk", "item_id": "2", "data": [...]}
   ```

3. **App Stores IDs**
   - Each `UnifiedSearchResult` now has `queryId` and `itemId`
   - These are passed to voting widgets

4. **User Votes**
   ```
   Vote: "Best" on definition
   → item_id="0", query_id=480, value="12345" (dict_ref_id), vote="2"
   ```

5. **Vote Saved Locally**
   - Stored in SharedPreferences
   - Will sync when network available

---

## 🛠️ Technical Details

### Architecture

```
┌─────────────────────────────────────────────┐
│           Tester Mode Service               │
│  - Enable/disable tester mode               │
│  - Reactive streams                         │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│         Voting Repository                   │
│  - Submit votes                             │
│  - Offline storage                          │
│  - Sync pending votes                       │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│          SharedPreferences                  │
│  - pending_votes: List<VoteRequest>         │
│  - total_votes_count: int                   │
└─────────────────────────────────────────────┘
```

### Vote Flow

```
1. User clicks vote button
   ↓
2. VotingWidget creates VoteRequest
   ↓
3. VotingRepository.savePendingVote()
   ↓
4. Stored in SharedPreferences
   ↓
5. Total vote counter incremented
   ↓
6. UI shows success message
```

### Offline Support

- All votes stored locally first
- Queued for later sync
- `syncPendingVotes()` method available for background sync
- No data loss even without network

---

## 📊 Data Storage

### Vote Request JSON Structure
```json
{
  "item_id": "0",
  "query_id": 480,
  "value": "12345",
  "vote": "2"
}
```

### SharedPreferences Keys
- `tester_mode_enabled`: bool
- `pending_votes`: JSON string (array)
- `total_votes_count`: int

---

## 🎨 UI Components

### VotingWidget
- Shows only when tester mode is enabled
- 4 vote buttons with colors
- Visual feedback on selection
- Automatic submission

### FeedbackModal
- Full-screen modal
- Multi-line text input
- Submit/Cancel actions
- Loading state

### MissingCountModal
- Number picker (0-20)
- Quick select buttons (1, 3, 5, 10)
- +/- controls
- Visual counter display

### VoteCounterWidget
- Compact mode: Small badge
- Full mode: Card with icon
- Real-time count updates
- Only visible in tester mode

---

## 🚀 Next Steps (Optional Enhancements)

### High Priority
1. **Add Feedback Button** - Add button to call `showFeedbackModal()`
2. **Add Missing Count Button** - Add button to call `showMissingCountModal()`
3. **Sync Implementation** - Call `VotingRepository.syncPendingVotes()` when online
4. **Vote Counter in UI** - Display `VoteCounterWidget` in appropriate location

### Medium Priority
5. **Vote History** - Show user their past votes
6. **Edit/Delete Votes** - Allow users to change their minds
7. **Export Votes** - Download votes as JSON/CSV
8. **Server API** - Implement backend voting endpoint

### Low Priority
9. **Statistics Dashboard** - Show aggregated voting stats (admin only)
10. **Achievements** - Reward active testers
11. **Vote Categories** - Add more specific vote types
12. **Collaborative Filtering** - Use votes to improve search ranking

---

## 📱 Testing Checklist

- [ ] Enable tester mode from profile menu
- [ ] Tester mode persists after app restart
- [ ] Search returns results with query_id and item_id
- [ ] Voting buttons appear when expanding results
- [ ] Vote submission works and shows confirmation
- [ ] Vote counter increments after each vote
- [ ] Votes stored in SharedPreferences
- [ ] Feedback modal opens and submits
- [ ] Missing count modal opens and submits
- [ ] Tester mode can be disabled
- [ ] Voting UI disappears when tester mode is off

---

## 🐛 Known Limitations

1. **No Server Sync Yet** - Votes only stored locally
2. **No Vote Editing** - Once submitted, can't be changed
3. **No Vote History UI** - Can't see past votes in UI
4. **No Batch Operations** - Must vote on each result individually
5. **No Analytics** - No aggregated stats shown to testers

---

## 💡 Tips for Testers

1. **Be Honest** - Your genuine feedback helps improve the app
2. **Be Specific** - Use feedback modal for detailed comments
3. **Vote Consistently** - Use the same criteria for all results
4. **Report Missing** - If you know results are missing, report the count
5. **Check Relevance** - Focus on whether results match the query

---

## 🔐 Privacy & Data

- All votes stored locally on device
- No personal data collected (just vote values)
- Query ID and item ID help identify which results were voted on
- Data will only be synced when explicitly requested
- Can clear all voting data anytime

---

## 📞 Support

For issues or questions about the voting system:
1. Check this documentation first
2. Review the code comments in voting files
3. Contact the development team
4. Report bugs via feedback modal

---

**Implementation Date:** January 2026
**Version:** 1.0.0
**Status:** ✅ Complete and Ready for Testing





