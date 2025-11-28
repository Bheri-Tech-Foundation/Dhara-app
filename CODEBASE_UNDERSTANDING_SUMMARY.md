# 📚 Dhara App - Complete Codebase Understanding

> **Last Updated**: November 24, 2025  
> **App Version**: 2.0.0+25  
> **Purpose**: Complete understanding document before bug fixing

---

## 🎯 **App Overview**

**Dhara (धारा)** is a multi-platform AI-powered search application for Indic knowledge, supporting:
- **Android** (primary platform)
- **iOS**
- **Web** (Flutter Web)
- **Desktop** (Windows, macOS, Linux)

### Core Features
1. **Shodh (शोध)** - AI-powered unified search across dictionaries, verses, and books
2. **Prashna (प्रश्न)** - AI chatbot for Q&A with citations
3. **Verse Search** - Search and browse religious verses (Bhagavad Gita, etc.)
4. **Dictionary** - Word definitions in multiple Indian languages
5. **Books** - Browse and search through Indic books

### Tech Stack
- **Framework**: Flutter 3.7.0+ (Dart)
- **State Management**: BLoC (flutter_bloc), Provider, RxDart
- **Routing**: Flutter Modular
- **API**: Retrofit + Dio (REST API)
- **Auth**: Google Sign-In, Firebase
- **Storage**: flutter_secure_storage
- **Backend**: Django REST API at `https://project.iith.ac.in/bheri`

---

## 📁 **Project Structure**

```
dhara-app/
├── lib/
│   ├── app/                          # Main application layer
│   │   ├── app_module.dart           # Route & dependency configuration
│   │   ├── app_widget.dart           # Root widget with theming
│   │   ├── core_module.dart          # Core dependency injection
│   │   ├── bloc/                     # Global BLoC state management
│   │   ├── data/                     # Data layer
│   │   │   ├── local/                # Local storage (secure_local_data)
│   │   │   ├── remote/               # API layer
│   │   │   │   └── api/
│   │   │   │       ├── base/         # DioCreator, interceptors
│   │   │   │       └── parts/        # API endpoints by feature
│   │   │   │           ├── auth/
│   │   │   │           ├── dictionary/
│   │   │   │           ├── verse/
│   │   │   │           ├── prashna/
│   │   │   │           ├── citation/
│   │   │   │           ├── share/
│   │   │   │           └── unified/
│   │   │   └── services/             # Business logic services
│   │   ├── domain/                   # Domain layer (repositories)
│   │   │   ├── auth/
│   │   │   ├── dictionary/
│   │   │   ├── verse/
│   │   │   ├── prashna/
│   │   │   ├── books/
│   │   │   ├── citation/
│   │   │   └── share/
│   │   ├── types/                    # Data models (DTOs, entities)
│   │   │   ├── auth/
│   │   │   ├── verse/
│   │   │   ├── dictionary/
│   │   │   ├── prashna/
│   │   │   ├── books/
│   │   │   └── user/
│   │   ├── ui/                       # UI layer
│   │   │   ├── pages/                # Feature pages
│   │   │   │   ├── splash/
│   │   │   │   ├── onboarding/
│   │   │   │   ├── auth/             # Login page
│   │   │   │   ├── dashboard/        # Main container with tabs
│   │   │   │   ├── prashna/          # AI chat
│   │   │   │   ├── verses/           # Verse search
│   │   │   │   ├── words/            # Dictionary
│   │   │   │   └── books/            # Book reader
│   │   │   ├── sections/             # Reusable UI sections
│   │   │   ├── widgets/              # Reusable widgets
│   │   │   └── shared/               # Shared UI components
│   │   └── providers/                # Google Auth integration
│   ├── core/                         # Core functionality
│   │   ├── cache/                    # Smart search cache
│   │   ├── components/               # Tool cards, verse cards
│   │   ├── controllers/              # QuickSearch, Unified controllers
│   │   ├── pages/                    # Enhanced QuickSearch, Unified
│   │   └── services/                 # Core services
│   ├── config/                       # Environment configuration
│   │   └── environments/
│   │       ├── development.dart
│   │       └── final_release.dart
│   ├── res/                          # Resources (theme, styles, colors)
│   │   ├── theme/                    # AppTheme, colors
│   │   ├── styles/                   # Text styles
│   │   ├── values/                   # Dimensions, gaps, colors
│   │   └── layouts/                  # Breakpoints, containers
│   ├── main.dart                     # App entry point
│   ├── flavors.dart                  # Flavor configuration
│   └── firebase_options.dart         # Firebase config
├── android/                          # Android-specific code
├── ios/                              # iOS-specific code
├── web/                              # Web-specific code
├── assets/                           # Images, fonts, data files
│   ├── img/                          # App logo, images
│   ├── svg/                          # SVG icons
│   ├── fonts/                        # Multi-language fonts (NotoSans)
│   ├── prashna.json                  # Prashna data
│   └── unified.json                  # Unified search data
├── pubspec.yaml                      # Dependencies
└── [Various .md files]               # Documentation

```

---

## 🔄 **Application Flow**

### 1. **App Initialization**
```
main.dart
  ├─> Initialize DeveloperModeService
  ├─> Set flavor (FINALE_RELEASE)
  ├─> ModularApp with AppModule
  └─> AppWidget (MaterialApp with routing)
```

### 2. **Authentication Flow**
```
SplashPage
  ├─> Check onboarding completion
  │   └─> If not completed → OnboardingPage → LoginPage
  ├─> Check authentication (access token + user data)
  │   ├─> Authenticated → Dashboard (QuickSearch)
  │   └─> Not authenticated → LoginPage
  
LoginPage
  ├─> Google Sign-In (Web: access token, Mobile: ID token)
  ├─> Backend authentication → JWT tokens
  └─> Navigate to Dashboard
```

### 3. **Main Navigation**
```
DashboardPage (Container with bottom nav / side nav)
  ├─> Tab 1: Shodh (शोध) - QuickSearch/Unified
  │   └─> EnhancedQuickSearchPage / UnifiedPage
  ├─> Tab 2: Prashna (प्रश्न) - AI Chat
  │   └─> PrashnaPage
  └─> Legacy (in dropdown):
      ├─> WordDefine - Dictionary
      └─> QuickVerse - Verse search
```

### 4. **Tab Color System**
The app has dynamic colors for each tab:
- **Unified Search**: Orange (`#FF6B35`)
- **Prashna**: Indigo (`#7986CB`)
- **Verse**: Green
- **Dictionary**: Blue

---

## 🏗️ **Architecture Patterns**

### Clean Architecture Layers

```
┌─────────────────────────────────────┐
│         UI Layer (Widgets)          │
│   - Pages, Sections, Widgets        │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│      Presentation (BLoC/Cubit)      │
│   - Controllers, State Management   │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│       Domain (Use Cases)            │
│   - Repositories, Domain Logic      │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│         Data Layer                  │
│   - API, Local Storage, Services    │
└─────────────────────────────────────┘
```

### Dependency Injection
- **Flutter Modular** manages DI
- **CoreModule** exports shared dependencies:
  - SecureLocalData
  - Dio (HTTP client)
  - ApiRepos (Auth, Dictionary, Verse, Prashna, etc.)
  - Repositories
  - Services (singleton instances)
  - Controllers

---

## 🔑 **Key Components**

### 1. **Authentication System**

**Files**:
- `lib/app/domain/auth/auth_account_repo.dart`
- `lib/app/providers/google/google_auth.dart`
- `lib/app/ui/pages/auth/login_page.dart`

**Flow**:
1. User clicks "Sign in with Google"
2. Google OAuth popup/native sign-in
3. Get token (access token for web, ID token for mobile)
4. Send to backend: `POST /bheri/api/google_login/`
5. Backend validates with Google API
6. Returns JWT (access_token + refresh_token)
7. Store in SecureLocalData
8. Navigate to app

**Storage**:
- Access token
- Refresh token
- User data (name, email, picture)

---

### 2. **Shodh (Unified Search)**

**Files**:
- `lib/core/pages/enhanced_quicksearch_page.dart`
- `lib/core/pages/unified_page.dart`
- `lib/core/controllers/unified_controller.dart`
- `lib/core/services/unified_service.dart`

**Features**:
- Search across Dictionary, Verses, and Books simultaneously
- Results displayed in expandable tool cards
- Session-based search history
- Smart caching with `SmartSearchCache`

**API Endpoints**:
- Dictionary: `/bheri/api/dictionary/search`
- Verses: `/bheri/api/verses/search`
- Books: `/bheri/api/books/search`

---

### 3. **Prashna (AI Chat)**

**Files**:
- `lib/app/ui/pages/prashna/page.dart`
- `lib/app/ui/pages/prashna/controller.dart`
- `lib/app/data/remote/api/parts/prashna/api_point_simple.dart`

**Features**:
- AI-powered Q&A chatbot
- Multiple AI models (GPT-4, Claude, Gemini)
- Tool calls with citations
- Chat history with session management
- Streaming responses (SSE - Server-Sent Events)
- Execution logs and debugging

**API Endpoint**:
- Chat: `/bheri/api/chat/` (POST with streaming)

**Data Models**:
- `ChatMessage` - User and AI messages
- `ToolCall` - Function calls made by AI
- `ExecutionLog` - Debugging information
- `AIModel` - Model configuration

---

### 4. **Dictionary (WordDefine)**

**Files**:
- `lib/app/ui/pages/words/page.dart`
- `lib/app/domain/dictionary/repo.dart`
- `lib/core/services/dictionary_service.dart`

**Features**:
- Word definitions in multiple Indian languages
- Similar words suggestions
- Word hyperlinks
- Language-specific fonts (NotoSans)
- Copy and share functionality

**API Endpoint**:
- Search: `/bheri/api/dictionary/search?query={word}`

---

### 5. **Verses (QuickVerse)**

**Files**:
- `lib/app/ui/pages/verses/page.dart`
- `lib/app/domain/verse/repo.dart`
- `lib/core/services/verse_service.dart`

**Features**:
- Search verses from Bhagavad Gita, Upanishads, etc.
- Multi-language support (Hindi, English, Sanskrit, etc.)
- Bookmarks
- Previous/Next navigation
- Search history
- Citations and sharing

**API Endpoints**:
- Search: `/bheri/api/verses/search`
- Bookmarks: `/bheri/api/verses/bookmarks`
- Details: `/bheri/api/verses/{id}`

**Supported Languages**:
- Hindi, English, Sanskrit, Bengali, Gujarati, Kannada, Malayalam, Tamil, Telugu, Oriya, Punjabi

---

### 6. **Books**

**Files**:
- `lib/app/ui/pages/books/page.dart`
- `lib/app/domain/books/repo.dart`
- `lib/core/services/books_service.dart`

**Features**:
- Browse Indic books (Mahabharata, Ramayana, etc.)
- Chapter navigation
- Chunk-based content loading
- Bookmarks
- Citations

**API Endpoints**:
- List: `/bheri/api/books/`
- Chunks: `/bheri/api/books/{id}/chunks`

---

## 🎨 **Theming System**

### Theme Provider
- `AppThemeProvider` manages theme mode (light/dark)
- Dynamic color based on active tab
- Custom `AppThemeColors` extension

### Font System
Multi-language support with NotoSans fonts:
- **Bengali** - NotoSansBengali
- **Gujarati** - NotoSansGujarati
- **Punjabi** - NotoSansGurmukhi
- **Kannada** - NotoSansKannada
- **Malayalam** - NotoSansMalayalam
- **Tamil** - NotoSansTamil
- **Telugu** - NotoSansTelugu
- **Devanagari** - NotoSansDevanagari
- **Oriya** - NotoSansOriya

### Responsive Design
- Breakpoints system (`BreakpointType.sm`, `md`, `lg`, `xl`, etc.)
- Mobile: Bottom navigation
- Desktop/Tablet: Side navigation

---

## 🔧 **Configuration**

### Environment Setup

**Files**:
- `lib/flavors.dart`
- `lib/config/env.dart`
- `lib/config/environments/final_release.dart`

**Flavors**:
1. **DEVELOPMENT** - Dev environment
2. **DEVELOPMENT_N** - New dev environment
3. **FINALE_RELEASE** - Production (active)

**Configuration**:
```dart
// Production Config
API URL: https://project.iith.ac.in/bheri
Google Client ID (Android): 316847997090-rq6reduc42g6qu8lta3l0r8kcj2mfvdt.apps.googleusercontent.com
Dashboard Route: /Dhara
```

### Build Configuration

**Android**:
- Package: `in.bheri.dhara`
- Version: 2.0.0 (build 25)
- Min SDK: 21
- Target SDK: 34
- Signing: Release keystore (`dhara.jks`)

**Version Info** (from `pubspec.yaml`):
- Version: `2.0.0+25`
- Build number incremented for each release

---

## 📡 **API Integration**

### Base Configuration
```dart
Base URL: https://project.iith.ac.in/bheri
Client: web_client (web) / bheri_web (mobile)
```

### API Structure

**Authentication**:
- `POST /bheri/api/google_login/`
  - Body: `{ accessToken, idToken, client }`
  - Response: `{ accessToken, refreshToken, user }`

**Dictionary**:
- `GET /bheri/api/dictionary/search?query={word}`

**Verses**:
- `GET /bheri/api/verses/search?query={text}&language={lang}`
- `GET /bheri/api/verses/{id}`
- `GET /bheri/api/verses/bookmarks`
- `POST /bheri/api/verses/bookmarks`

**Prashna (Chat)**:
- `POST /bheri/api/chat/`
  - Body: `{ messages, model, tools }`
  - Response: Streaming (SSE)

**Books**:
- `GET /bheri/api/books/`
- `GET /bheri/api/books/{id}/chunks`

**Citation & Share**:
- `POST /bheri/api/citations/generate`
- `POST /bheri/api/share/create`

### HTTP Client
- **Dio** for HTTP requests
- **Retrofit** for type-safe API calls
- **Interceptors**: Auth token, logging
- **Error handling**: `DomainResult<T>` wrapper

---

## 💾 **Data Models**

### User
```dart
class UserRM {
  String? name;
  String? email;
  String? picture;
}
```

### Verse
```dart
class Verse {
  int id;
  String verseHead;
  String verseText;
  String translation;
  String language;
  VerseOtherField? otherFields; // Commentary, word meanings
}
```

### Dictionary Word
```dart
class DictWordDetail {
  String word;
  List<WordDefinition> definitions;
  List<String> similarWords;
}
```

### Chat Message
```dart
class ChatMessage {
  String id;
  String content;
  bool isUser;
  List<ToolCall>? toolCalls;
  DateTime timestamp;
}
```

### Book
```dart
class BookChunk {
  int id;
  String title;
  String content;
  String book;
  String chapter;
}
```

---

## 🧪 **Testing & Development**

### Development Commands
```bash
# Run on web
flutter run -d chrome --web-port=5000

# Run on Android
flutter run

# Build for production (web)
flutter build web --release --base-href /dhara/

# Build APK
flutter build apk --release

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Scripts
- `run_web_dev.bat/.sh` - Start web development server
- `build_for_deployment.bat/.sh` - Build for production

---

## 🐛 **Known Issues & Fixes**

### Fixed Issues (from documentation)
1. ✅ **Google Sign-In on Web** - Access token flow implemented
2. ✅ **Tab switching colors** - Dynamic color system
3. ✅ **Search bar centering** - Layout fixes
4. ✅ **Prashna copy/share** - Functionality implemented
5. ✅ **Error message UX** - Better error handling
6. ✅ **Session management** - Proper state handling
7. ✅ **Similar words display** - Fixed layout

### Areas to Monitor
- **Performance**: Large data loading (verses, books)
- **Caching**: Smart cache invalidation
- **Streaming**: SSE connection stability in Prashna
- **Auth**: Token refresh mechanism
- **Multi-language**: Font rendering edge cases

---

## 📱 **Features Summary**

| Feature | Status | Platform | Notes |
|---------|--------|----------|-------|
| Google Sign-In | ✅ Working | All | Access token (web), ID token (mobile) |
| Splash Screen | ✅ Working | All | Animated with auth check |
| Onboarding | ✅ Working | All | 5 screens with features intro |
| Dashboard | ✅ Working | All | Responsive with tabs |
| Shodh (Unified) | ✅ Working | All | Multi-source search |
| Prashna (Chat) | ✅ Working | All | AI chat with streaming |
| Dictionary | ✅ Working | All | Multi-language support |
| Verses | ✅ Working | All | Search, bookmarks, history |
| Books | ✅ Working | All | Chapter navigation |
| Dark Mode | ✅ Working | All | Toggle in menu |
| Theme Customization | ✅ Working | All | Per-tab colors |
| Bug Reporting | ✅ Working | Mobile | Floating button (email/WhatsApp) |
| Beta Badge | ✅ Working | All | Visual indicator |

---

## 🚀 **Deployment**

### Android
1. Build: `flutter build apk --release`
2. Output: `build/app/outputs/flutter-apk/app-release.apk`
3. Signed with: `dhara.jks` keystore

### Web
1. Build: `flutter build web --release --base-href /dhara/`
2. Output: `build/web/`
3. Deploy: Vercel, Firebase Hosting, or static server
4. Route: `/dhara` subdirectory

### Backend Requirements
- CORS enabled for app domains
- Google OAuth token validation (both access and ID tokens)
- JWT token generation
- API endpoints documented above

---

## 🎯 **Development Workflow**

### For Bug Fixing
1. **Identify the bug** - Location (page/feature)
2. **Find relevant files**:
   - UI bug → `lib/app/ui/pages/{feature}/`
   - Logic bug → `lib/app/domain/{feature}/` or `lib/core/services/`
   - API bug → `lib/app/data/remote/api/parts/{feature}/`
   - State bug → Controller/BLoC in feature directory
3. **Check related files**:
   - State: `cubit_states.dart`
   - Controller: `controller.dart`
   - Repository: `lib/app/domain/{feature}/repo.dart`
4. **Test locally**:
   - Run: `flutter run -d chrome` (web) or `flutter run` (Android)
   - Hot reload: `r` in terminal
5. **Build and verify**:
   - Clean: `flutter clean`
   - Get dependencies: `flutter pub get`
   - Build: `flutter build apk --release`

### Code Organization
- **UI Components**: Stateless/Stateful widgets in `lib/app/ui/`
- **Business Logic**: Repositories in `lib/app/domain/`
- **State Management**: BLoC/Cubit controllers
- **Services**: Singleton services in `lib/core/services/`
- **Data Models**: TypeScript-like models with JSON serialization

---

## 📚 **Important Files Reference**

### Core Files
- `lib/main.dart` - Entry point
- `lib/app/app_module.dart` - Routing configuration
- `lib/app/core_module.dart` - Dependency injection
- `lib/flavors.dart` - Environment configuration

### Authentication
- `lib/app/domain/auth/auth_account_repo.dart`
- `lib/app/providers/google/google_auth.dart`
- `lib/app/ui/pages/auth/login_page.dart`

### Main Pages
- `lib/app/ui/pages/dashboard/dashboard_page.dart` - Main container
- `lib/core/pages/enhanced_quicksearch_page.dart` - Shodh
- `lib/core/pages/unified_page.dart` - Unified search
- `lib/app/ui/pages/prashna/page.dart` - AI chat
- `lib/app/ui/pages/verses/page.dart` - Verses
- `lib/app/ui/pages/words/page.dart` - Dictionary

### Services
- `lib/core/services/unified_service.dart`
- `lib/core/services/dictionary_service.dart`
- `lib/core/services/verse_service.dart`
- `lib/core/services/books_service.dart`

### Theme
- `lib/res/theme/app_theme.dart`
- `lib/res/theme/app_theme_colors.dart`
- `lib/res/theme/app_theme_provider.dart`

---

## 💡 **Key Learnings**

### Architecture Strengths
✅ Clean separation of concerns (UI, Domain, Data)  
✅ Modular design with feature-based organization  
✅ Type-safe API calls with Retrofit  
✅ Reactive state management with BLoC  
✅ Comprehensive multi-language support  
✅ Well-structured theming system  

### Areas for Potential Improvement
⚠️ Large file sizes (some controllers > 1000 lines)  
⚠️ Consider splitting large pages into smaller components  
⚠️ Add more inline documentation for complex logic  
⚠️ Consider adding unit tests for critical business logic  
⚠️ Optimize image/asset loading for performance  

---

## 📞 **Contact & Support**

### Documentation
- `BACKEND_INTEGRATION_GUIDE.md` - Backend API integration
- `WEB_DEPLOYMENT_README.md` - Web deployment guide
- `QUICK_START.md` - Quick start guide
- `DEPLOYMENT_GUIDE.md` - Full deployment instructions
- Various fix documentation: `*_FIX.md` files

### Beta Support
- Bug reporting via floating email button (mobile)
- WhatsApp/Email integration for user feedback

---

## ✅ **Checklist: Understanding Complete**

- [x] Project structure understood
- [x] Main features identified (Shodh, Prashna, Verses, Dictionary, Books)
- [x] Authentication flow clear
- [x] API integration understood
- [x] State management pattern clear
- [x] Theming and multi-language support understood
- [x] Build and deployment process clear
- [x] Key files and their purposes identified
- [x] Data models and types understood
- [x] Services and repositories mapped

---

## 🎊 **Ready for Bug Fixing!**

You now have a complete understanding of:
1. **What** the app does (features)
2. **How** it's structured (architecture)
3. **Where** to find code (file organization)
4. **What** technologies are used (tech stack)
5. **How** to build and run it (development workflow)

**Next Step**: Identify and fix bugs! 🐛🔧

For bug fixes:
1. Reproduce the bug
2. Find the relevant page/feature
3. Check controller → service → repository
4. Fix the issue
5. Test thoroughly
6. Document the fix

Good luck! 🚀





