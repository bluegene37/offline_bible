# Contributing to Offline Bible

Thank you for your interest in contributing to **Offline Bible**! We welcome bug reports, feature proposals, and code contributions from the community.

---

## 🧭 Code of Conduct

We are committed to providing a welcoming, inclusive, and harassment-free experience for everyone. Please be respectful, constructive, and kind in all discussions and code reviews.

---

## 🛠️ Development Setup

### Prerequisites
- **Flutter SDK**: `^3.24.0` (or latest stable Dart `^3.5.0` / Flutter SDK)
- **Java Development Kit (JDK)**: OpenJDK 21 (for Android builds)
- **Xcode**: 15+ (for macOS & iOS builds)
- **Git**: 2.30+

### Setup Instructions
1. **Fork and Clone the Repository**:
   ```bash
   git clone https://github.com/bluegene37/offline_bible.git
   cd offline_bible
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify Environment**:
   ```bash
   flutter doctor
   ```

4. **Run Static Analysis & Tests**:
   ```bash
   flutter analyze --fatal-infos
   flutter test
   ```

5. **Run the App in Debug Mode**:
   ```bash
   # Android / iOS device or emulator
   flutter run

   # macOS desktop
   flutter run -d macos

   # Chrome Web
   flutter run -d chrome
   ```

---

## 🌿 Git Branching Strategy

- `master` / `main`: Production-ready branch. All merged code must pass CI.
- `feature/<feature-name>`: New capabilities or major UI additions.
- `fix/<issue-name>`: Bug fixes and performance patches.
- `chore/<task-name>`: Dependency updates, CI workflows, or documentation improvements.

---

## 📝 Commit Standards

We follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification:

```
<type>(<scope>): <short summary>

[optional body]

[optional footer(s)]
```

### Supported Types:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Formatting, missing semi-colons, white-space changes (no functional code changes)
- `refactor`: Code changes that neither fix a bug nor add a feature
- `perf`: Performance improvements
- `test`: Adding or correcting tests
- `chore`: Maintenance, CI configuration, build scripts, dependencies

---

## 📐 Coding Guidelines

1. **Dart Code Formatting**: Always format code using `dart format .` before committing.
2. **Analyzer & Lints**: Adhere to `analysis_options.yaml`. No warnings or infos should be ignored without strong documented justification.
3. **State Management**: The app uses GetX for reactive state and controllers. Keep business logic inside controllers and services under `lib/core/` and `lib/features/*/controllers/`.
4. **Data Persistence**: Offline Bible utilizes Hive CE for local storage. Always ensure backward compatibility for stored key-value structures.
5. **No Telemetry / Privacy First**: Never introduce network calls or telemetry SDKs. The app is 100% offline-first; the only optional network connection is fetching public-domain translations from `api.getbible.net`.

---

## 🧪 Testing Guidelines

- Every new feature or bug fix must be accompanied by unit or widget tests under `test/`.
- Verify all tests pass locally prior to opening a pull request:
  ```bash
  dart format --output=none --set-exit-if-changed .
  flutter analyze --fatal-infos
  flutter test
  ```

---

## 🚀 Submitting a Pull Request

1. Push your branch to your fork.
2. Open a Pull Request against `master`.
3. Fill out the [Pull Request Template](.github/pull_request_template.md).
4. Ensure all automated GitHub Actions checks pass.
5. Address any code review feedback promptly and thoughtfully.
