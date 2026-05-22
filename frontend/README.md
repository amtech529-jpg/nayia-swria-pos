# Nayia Swaria - Flutter Project

## Architecture
This project follows **Clean Architecture** with **MVVM** pattern and uses **Riverpod** for state management.

### Directory Structure
- `lib/core/`: App-wide utilities, constants, themes, and network configurations.
- `lib/features/`: Feature-based modules. Each feature follows Clean Architecture layers:
  - `data/`: Data sources, models, and repository implementations.
  - `domain/`: Entities, repository contracts, and use cases.
  - `presentation/`: Riverpod providers, viewmodels, views, and widgets.
- `lib/shared/`: Reusable widgets and helper functions across multiple features.
- `lib/app/`: App-level configuration (routing, global providers).

### Key Technologies
- **State Management**: [Riverpod](https://riverpod.dev)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Responsiveness**: [Flutter ScreenUtil](https://pub.dev/packages/flutter_screenutil)
- **Environment Variables**: [Flutter Dotenv](https://pub.dev/packages/flutter_dotenv)

## Getting Started
1. Install dependencies: `flutter pub get`
2. Run code generation: `flutter pub run build_runner build`
3. Run the app: `flutter run`
