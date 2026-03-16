# Gemini CLI - Project Instructions

## Project Overview
This project (`hybrid_digital_docs_assignment_frontend`) is a Flutter application for an HR Document Management System.

## Tech Stack
The project utilizes a modern, industry-standard Flutter tech stack for high performance and maintainability:
- **State Management:** `flutter_riverpod` (v3+) - Used for both global state and the ViewModel layer.
- **Networking:** `dio` (v5+) with `retrofit` for type-safe API client generation.
- **Routing:** `go_router` (v17+) for declarative navigation and deep linking.
- **Local Storage:** `hive` / `hive_flutter` for fast local NoSQL storage and `flutter_secure_storage` for sensitive credentials.
- **Serialization:** `json_serializable` / `json_annotation` combined with `build_runner` for automated data mapping.
- **Localization:** `easy_localization` for multi-language support (e.g., English and Khmer).
- **Icons & Assets:** `heroicons`, `font_awesome_flutter`, `flutter_svg` for scalable vector graphics.
- **Animation & UX:** `shimmer` for loading states and `lottie` for interactive animations.
- **Utilities:** `permission_handler`, `url_launcher`, `image_picker`, `file_picker`, and `path_provider`.

## Architecture (Feature-First MVVM)
The project strictly follows a **Feature-First MVVM** architecture. Code is modularized by feature rather than by layer.

### Directory Structure
Code must be organized by feature under `lib/features/`. Each feature should encapsulate its own MVVM layers:
- `models/`: Data classes and entities (with `@JsonSerializable`).
- `repositories/`: Data fetching, API clients (using Retrofit), and local storage interactions.
- `services/`: Business logic and external resource integrations.
- `providers/` (ViewModel): Riverpod providers holding business logic, interacting with repositories/services, and exposing state to the UI.
- `screens/`: Main UI pages for the feature (using `ConsumerWidget` or `ConsumerStatefulWidget`).
- `widgets/`: Reusable UI components specific to the feature.

Global configurations, themes, constants, and global state (e.g., core authentication) should reside in `lib/core/`.
Shared widgets and utilities that span multiple features should reside in `lib/shared/`.

## Features
The application includes the following core HR Document Management features:
- **Dashboard:** Overview of HR metrics, quick actions, and document statuses.
- **Documents:** Management of HR documents, file grid/table views, branches, categories, JD/SOP tasks, expiration badges, and search filters.
- **Employees:** Employee directory, detailed profiles, achievements, attendance records, leave history, and status cards.
- **Departments:** Organization and department management.
- **Reports:** HR and document reporting, analytics, and bar charts.
- **Settings:** App configuration, user management, roles & permissions, appearance, privacy, and security.
- **Notifications:** System alerts and updates.

## UI Style & Guidelines
The UI must be designed with a modern, clean, and highly interactive aesthetic, emulating a web-based admin dashboard (similar to Shadcn UI / Tailwind CSS aesthetics, but built natively in Flutter).

### Layout Structure
- **Dashboard Layout:** Utilize a persistent, collapsible **Sidebar** on the left for primary navigation and a **Header** on the top for context, user profiles, and quick actions. The main content area should sit below the header and handle its own scrolling.
- **Responsiveness:** The layout must adapt seamlessly across desktop, tablet, and mobile dimensions utilizing Flutter's `LayoutBuilder`, `Flex`, `Expanded`, and responsive grid techniques.

### Styling & Components
- **Theming:** Implement robust system-wide Light and Dark mode support. Establish a central `ThemeData` to handle background, surface, and foreground colors.
- **Accent Colors:** Support dynamic accent colors for primary actions, active states, and focus rings.
- **Components (Shadcn aesthetic):**
  - **Cards:** Use `Card` widgets with minimal border radius, subtle borders, and soft multi-layered drop shadows.
  - **Buttons:** Clean, flat buttons with distinct primary, secondary, outline, and ghost variants.
  - **Inputs:** Simple, bordered input fields, dropdowns, and text areas that highlight on focus.
  - **Data Display:** Utilize DataTables for lists of documents/employees with clear pagination, filtering, and row actions.
  - **Feedback:** Use Toast notifications (using `shimmer` or `snackbars`) for success/error feedback.
- **Typography:** Use clean sans-serif fonts (like `Poppins` for English and `Kantumruy Pro` for Khmer) with a strong hierarchy.
- **Icons:** Use modern, outline-style icons from `heroicons` or `lucide_icons`.

## State Management Rules
- Always use **Riverpod** (`flutter_riverpod`) for state management.
- **Separation of Concerns:** Views (`screens/`, `widgets/`) should only listen to state and trigger user actions. Business logic and state mutation must strictly reside within the `providers/` (ViewModel) layer.
- Use `AsyncValue` to handle loading and error states gracefully in the UI.