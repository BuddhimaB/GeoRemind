# GeoRemind - Software Architecture Documentation

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Design Principles](#design-principles)
3. [Layer Details](#layer-details)
4. [Design Patterns](#design-patterns)
5. [Data Flow](#data-flow)
6. [State Management](#state-management)
7. [Error Handling](#error-handling)
8. [Testing Strategy](#testing-strategy)

## Architecture Overview

### Clean Architecture

GeoRemind follows **Clean Architecture** (also known as Onion Architecture or Hexagonal Architecture) proposed by Robert C. Martin. This architecture emphasizes:

- **Independence of Frameworks**: Business logic doesn't depend on Flutter
- **Testability**: Business rules can be tested without UI, database, or external services
- **Independence of UI**: UI can change without changing business rules
- **Independence of Database**: Can swap SQLite with any other database
- **Independence of External Services**: Business rules don't know about outside world

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│   ┌─────────────────────────────────────────────────┐      │
│   │            UI (Screens & Widgets)               │      │
│   └─────────────────────────────────────────────────┘      │
│   ┌─────────────────────────────────────────────────┐      │
│   │        State Management (Providers)             │      │
│   └─────────────────────────────────────────────────┘      │
├─────────────────────────────────────────────────────────────┤
│                      Domain Layer                            │
│   ┌─────────────────────────────────────────────────┐      │
│   │         Business Entities (Reminder)            │      │
│   └─────────────────────────────────────────────────┘      │
│   ┌─────────────────────────────────────────────────┐      │
│   │      Repository Interfaces (Contracts)          │      │
│   └─────────────────────────────────────────────────┘      │
├─────────────────────────────────────────────────────────────┤
│                       Data Layer                             │
│   ┌─────────────────────────────────────────────────┐      │
│   │    Data Models (Serialization/Deserialization)  │      │
│   └─────────────────────────────────────────────────┘      │
│   ┌─────────────────────────────────────────────────┐      │
│   │      Repository Implementations                 │      │
│   └─────────────────────────────────────────────────┘      │
│   ┌─────────────────────────────────────────────────┐      │
│   │    External Services (DB, Location, Notif)      │      │
│   └─────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Design Principles

### SOLID Principles

#### 1. Single Responsibility Principle (SRP)
Each class has one reason to change:
- `DatabaseService`: Only handles database operations
- `LocationService`: Only handles location tracking
- `NotificationService`: Only handles notifications
- `ReminderProvider`: Only manages reminder state

#### 2. Open/Closed Principle (OCP)
Open for extension, closed for modification:
- `ReminderRepository` interface allows new implementations without changing existing code
- Services can be extended through inheritance or composition

#### 3. Liskov Substitution Principle (LSP)
Derived classes must be substitutable:
- `ReminderRepositoryImpl` can replace `ReminderRepository` interface
- Any implementation of `ReminderRepository` works with `ReminderProvider`

#### 4. Interface Segregation Principle (ISP)
No client should depend on methods it doesn't use:
- `ReminderRepository` has only methods needed by consumers
- Services have focused, specific interfaces

#### 5. Dependency Inversion Principle (DIP)
Depend on abstractions, not concretions:
- `ReminderProvider` depends on `ReminderRepository` interface, not implementation
- High-level modules (presentation) don't depend on low-level modules (data)

### Additional Principles

- **DRY (Don't Repeat Yourself)**: Common logic in base classes and utilities
- **KISS (Keep It Simple, Stupid)**: Simple, readable code over clever solutions
- **YAGNI (You Aren't Gonna Need It)**: Don't add functionality until needed
- **Separation of Concerns**: Each layer has distinct responsibility
- **Dependency Injection**: Dependencies provided from outside

## Layer Details

### 1. Presentation Layer

**Responsibility**: User interface and user interaction

#### Providers (State Management)
```dart
class ReminderProvider extends ChangeNotifier {
  // State
  List<Reminder> _reminders = [];
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  
  // Business logic
  Future<void> createReminder(Reminder reminder) async { }
  Future<void> updateReminder(Reminder reminder) async { }
  Future<void> deleteReminder(String id) async { }
  
  // Notify listeners when state changes
  notifyListeners();
}
```

**Benefits:**
- Centralized state management
- Reactive UI updates
- Testable business logic
- Clear data flow

#### Screens
- **HomeScreen**: Main interface with reminder list and navigation
- **AddEditReminderScreen**: Form for creating/editing reminders
- **LocationPickerScreen**: Interface for selecting location
- **MapScreen**: Visualization of reminders on map

#### Widgets
- **ReminderCard**: Reusable component for displaying reminder
- **Characteristics**: Stateless where possible, composable, single purpose

### 2. Domain Layer

**Responsibility**: Business logic and rules

#### Entities
```dart
class Reminder extends Equatable {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isActive;
  // ... other fields
  
  // Pure business object - no database, UI, or service dependencies
}
```

**Benefits:**
- Framework-independent
- Easily testable
- Reusable across platforms
- Clear business rules

#### Repository Interfaces
```dart
abstract class ReminderRepository {
  Future<List<Reminder>> getAllReminders();
  Future<void> createReminder(Reminder reminder);
  Future<void> updateReminder(Reminder reminder);
  // ... other methods
}
```

**Benefits:**
- Abstraction from data source
- Easy to mock for testing
- Swappable implementations
- Clear contract

### 3. Data Layer

**Responsibility**: Data access and external service integration

#### Models
```dart
class ReminderModel extends Reminder {
  // Serialization
  Map<String, dynamic> toMap() { }
  factory ReminderModel.fromMap(Map<String, dynamic> map) { }
  
  // Conversion
  Reminder toEntity() { }
  factory ReminderModel.fromEntity(Reminder reminder) { }
}
```

**Benefits:**
- Separation of data representation from business logic
- Easy serialization/deserialization
- Database schema changes isolated

#### Repository Implementation
```dart
class ReminderRepositoryImpl implements ReminderRepository {
  final DatabaseService _databaseService;
  
  @override
  Future<List<Reminder>> getAllReminders() async {
    final models = await _databaseService.getAllReminders();
    return models.map((m) => m.toEntity()).toList();
  }
}
```

**Benefits:**
- Implements domain contract
- Handles data conversion
- Manages data source

#### Services

##### DatabaseService
```dart
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  
  Future<Database> get database async { }
  Future<List<ReminderModel>> getAllReminders() async { }
  Future<void> insertReminder(ReminderModel reminder) async { }
}
```

**Responsibilities:**
- Database initialization
- CRUD operations
- Query optimization
- Connection management

##### LocationService
```dart
class LocationService {
  Future<Position?> getCurrentLocation() async { }
  Stream<Position> getLocationStream() { }
  bool isWithinRadius(...) { }
  double calculateDistance(...) { }
}
```

**Responsibilities:**
- GPS access
- Location permissions
- Geofencing calculations
- Distance calculations

##### NotificationService
```dart
class NotificationService {
  Future<void> initialize() async { }
  Future<void> showReminderNotification(Reminder reminder) async { }
  Future<bool> requestPermission() async { }
}
```

**Responsibilities:**
- Notification initialization
- Permission handling
- Notification display
- Action handling

## Design Patterns

### 1. Repository Pattern
**Purpose**: Abstraction layer between business logic and data sources

```dart
// Interface (Domain)
abstract class ReminderRepository {
  Future<List<Reminder>> getAllReminders();
}

// Implementation (Data)
class ReminderRepositoryImpl implements ReminderRepository {
  final DatabaseService _db;
  
  @override
  Future<List<Reminder>> getAllReminders() => _db.getAllReminders();
}
```

**Benefits:**
- Testability: Easy to mock
- Flexibility: Swap implementations
- Maintainability: Centralized data access

### 2. Singleton Pattern
**Purpose**: Single instance of services

```dart
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  DatabaseService._init();
}
```

**Use Cases:**
- Database connections
- Service instances
- Configuration managers

### 3. Factory Pattern
**Purpose**: Object creation without specifying exact class

```dart
factory ReminderModel.fromMap(Map<String, dynamic> map) {
  return ReminderModel(
    id: map['id'],
    title: map['title'],
    // ...
  );
}
```

### 4. Observer Pattern (Provider)
**Purpose**: State change notification

```dart
class ReminderProvider extends ChangeNotifier {
  void _updateState() {
    notifyListeners(); // Notifies all listeners
  }
}

// UI listens
Consumer<ReminderProvider>(
  builder: (context, provider, child) {
    return ListView(children: provider.reminders);
  },
)
```

### 5. Dependency Injection
**Purpose**: Provide dependencies from outside

```dart
// Main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => ReminderProvider(
        ReminderRepositoryImpl(DatabaseService.instance),
        LocationService.instance,
        NotificationService.instance,
      ),
    ),
  ],
)
```

## Data Flow

### Create Reminder Flow
```
1. User fills form in AddEditReminderScreen
2. Taps "Create Reminder"
3. Screen calls provider.createReminder(reminder)
4. Provider calls repository.createReminder(reminder)
5. Repository converts entity to model
6. Repository calls databaseService.insertReminder(model)
7. DatabaseService executes SQL INSERT
8. Repository refreshes data
9. Provider updates state
10. Provider calls notifyListeners()
11. UI (Consumer) rebuilds with new data
```

### Location Tracking Flow
```
1. App starts
2. ReminderProvider initializes
3. Checks location permission
4. Starts location stream
5. LocationService emits position updates
6. Provider receives position
7. Provider checks if position within any reminder radius
8. If yes, triggers notification
9. Updates reminder state (triggered, inactive)
10. UI updates automatically
```

## State Management

### Provider Pattern

**Why Provider?**
- Simple and lightweight
- Built-in to Flutter ecosystem
- Good performance
- Easy to test
- Sufficient for app complexity

**State Structure:**
```dart
class ReminderProvider extends ChangeNotifier {
  // Private state
  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _error;
  
  // Public getters
  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // State mutations
  Future<void> loadReminders() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _reminders = await _repository.getAllReminders();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

## Error Handling

### Strategy
```dart
try {
  // Operation
  await _repository.createReminder(reminder);
} catch (e) {
  // Log error
  print('Error: $e');
  
  // Update UI state
  _error = 'Failed to create reminder';
  notifyListeners();
  
  // Optional: Show user message
  // Optional: Report to analytics
}
```

### Error Types
1. **Network Errors**: Handled at service level
2. **Database Errors**: Caught in repository
3. **Permission Errors**: Handled in services
4. **Validation Errors**: Prevented at UI level

## Testing Strategy

### Unit Tests
```dart
test('createReminder should add reminder to list', () async {
  // Arrange
  final mockRepo = MockReminderRepository();
  final provider = ReminderProvider(mockRepo, mockLocation, mockNotif);
  
  // Act
  await provider.createReminder(testReminder);
  
  // Assert
  expect(provider.reminders.length, 1);
});
```

### Widget Tests
```dart
testWidgets('ReminderCard displays title', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ReminderCard(reminder: testReminder),
    ),
  );
  
  expect(find.text('Test Reminder'), findsOneWidget);
});
```

### Integration Tests
```dart
testWidgets('Full create reminder flow', (tester) async {
  // 1. Open app
  // 2. Tap add button
  // 3. Fill form
  // 4. Submit
  // 5. Verify reminder appears in list
});
```

## Performance Considerations

### Database
- Indexes on frequently queried columns
- Batch operations for multiple inserts
- Connection pooling
- Lazy loading for large lists

### Location Services
- Appropriate distance filter (10m)
- Reasonable update interval (60s)
- Stop tracking when app backgrounded
- Battery-efficient location modes

### UI Rendering
- const widgets where possible
- ListView.builder for large lists
- RepaintBoundary for complex widgets
- Keys for list optimization

## Security Considerations

1. **Data Storage**: SQLite encrypted for sensitive data
2. **Permissions**: Runtime permission requests
3. **Location Privacy**: User control over tracking
4. **Input Validation**: All user input validated
5. **Error Messages**: No sensitive info in errors

## Scalability

### Current Architecture Supports:
- Adding new reminder types
- Different data sources (cloud DB)
- New notification types
- Additional location services
- Multiple language support
- New UI themes

### Future Enhancements:
- Multi-user support via cloud sync
- Reminder sharing between users
- Analytics and reporting
- ML-based suggestions
- Voice commands

---

**This architecture provides a solid foundation for a maintainable, testable, and scalable application.**
