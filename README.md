A comprehensive Flutter application for browsing and booking flights, built with Clean Architecture and BLoC state management.

Features

Core Features
  Display list of available flights from JSON
  Advanced filtering system with real-time updates
  Multiple sorting options (price, duration, departure)
  Detailed flight information page
  Airline logo display with unique colors
  Fare breakdown by passenger type
  Clean Architecture (Domain, Data, Presentation)
  BLoC State Management for predictable state handling

Filter Functionality
  Price Range: Slider to filter by min/max price
  Airlines: Multi-select airline filter
  Cabin Class: Filter by cabin class (Basic, Basic Flex, Plus, Max)
  Stops: Toggle for non-stop flights only
  Refundable: Filter refundable flights only
  Real-time Updates: Instant feedback on filter changes

UI/UX Features
  Clean, modern Material Design
  Smooth animations and transitions
  Responsive layout
  Loading states and error handling
  Empty states with helpful messages
  Filter badge counter
  Pull-to-refresh functionality
  Flight cards with key information

Design Highlights
  Color-coded airline logos: Each airline has a unique brand color
  Visual flight timeline: Clear departure/arrival visualization
  Fare breakdown cards: Detailed passenger-type pricing
  Status indicators: Seats remaining, refundable status
  Professional typography: Clear hierarchy and readability

Getting Started

Prerequisites
  Flutter SDK (3.0.0 or higher)
  Dart SDK
  Android Studio / Xcode (for mobile development)
  VS Code or Android Studio

Installation
  Clone the repository
  Create assets folder and add JSON file
  Install dependencies
  Run the app

State Management: BLoC
This app uses BLoC (Business Logic Component) pattern for state management.

Why BLoC?
  Predictable State: Clear separation between events and states
  Testable: Easy to unit test with bloc_test package
  Scalable: Handles complex state logic efficiently
  Reusable: BLoCs can be shared across multiple screens
  Reactive: Uses streams for real-time updates

Common Issues & Solutions
  Issue: JSON not loading
  Solution: Ensure flights.json is in assets/ folder and listed in pubspec.yaml
  Issue: BLoC not found
  Solution: Ensure BlocProvider is wrapping the widget tree in main.dart
  Issue: Build errors
  Solution: Run flutter clean && flutter pub get
  Issue: Tests failing
  Solution: Ensure mock classes are properly set up with mocktail

License
This project was created for assessment purposes.

Developer Notes

Key Design Decisions
  BLoC over Provider: More scalable, testable and suitable for complex apps
  Clean Architecture: Proper separation of concerns
  Use Cases: Encapsulated business logic
  Repository Pattern: Abstraction over data sources
  Equatable: Efficient state comparisons

Performance Considerations

BLoC caching with repository layer
Efficient state comparisons with Equatable
Lazy loading ready (pagination can be added)
Image caching ready (airline logos)
Minimal dependencies


Built with ❤️ using Flutter, BLoC and Clean Architecture 🚀