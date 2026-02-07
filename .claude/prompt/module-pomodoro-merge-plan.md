# Module-Pomodoro Timer Merge Plan

## Executive Summary

The current WorldSkills competition timer app contains two distinct but overlapping timer implementations: `PomodoroPage` and `ModuleTimerPage`. This duplication creates user confusion, code redundancy, and an inconsistent experience. Both pages serve similar purposes - tracking skill training time - but with different approaches:

- **PomodoroPage**: Focuses on timeboxing with customizable durations (45-180 minutes) and task management
- **ModuleTimerPage**: Organizes work into 3-hour competition modules with structured sub-tasks

Merging these implementations will create a unified timer experience that leverages the strengths of both approaches while eliminating redundancy. The resulting system will maintain the WorldSkills competition theme through module-based structure while incorporating Pomodoro's flexible timeboxing benefits for individual tasks.

### Benefits of Merging

1. **Reduced User Confusion**: Single, clear interface for all timer functionality
2. **Code Consolidation**: Eliminate duplicate timer logic and UI components
3. **Enhanced Feature Set**: Combine module structure with flexible timeboxing
4. **Consistent UX**: Unified design language and interaction patterns
5. **Maintainability**: Single codebase to update and maintain

## Proposed Architecture

### Core Data Models

#### Enhanced ModuleModel
```dart
class ModuleModel {
  final String id;
  final String name;
  final String description;
  final Duration defaultDuration; // Default 3 hours for competition modules
  final ModuleStatus status;
  final List<TaskItem> tasks;
  final ModuleType type; // COMPETITION or PRACTICE
  
  // New fields from Pomodoro
  final bool allowCustomDuration;
  final List<Duration> presetDurations; // [45, 60, 90, 120, 180] minutes
}

class TaskItem {
  final String id;
  final String title;
  final TaskStatus status; // current, done, upcoming
  final Duration estimatedDuration;
  final Duration actualSpent; // Track time spent on this task
  final DateTime? completedAt;
}

enum ModuleType { COMPETITION, PRACTICE }
enum TaskStatus { CURRENT, DONE, UPCOMING }
```

#### Unified Timer Controller
```dart
class UnifiedTimerController {
  ModuleModel? currentModule;
  TaskItem? currentTask;
  Duration totalDuration;
  Duration remaining;
  bool isRunning = false;
  Timer? _timer;
  
  // Enhanced functionality
  void startModule(ModuleModel module);
  void startTask(TaskItem task, Duration duration);
  void pause();
  void reset();
  void nextTask();
  void completeTask();
  void switchToPomodoroMode();
  void switchToModuleMode();
}
```

### UI Component Structure

```
UnifiedTimerPage
├── LeftPanel (300px width)
│   ├── ModuleSelector
│   │   ├── CompetitionModules (A-D)
│   │   └── PracticeModules
│   └── TimerModeSelector
│       ├── ModuleMode (3-hour timer)
│       └── PomodoroMode (flexible timer)
├── CenterPanel (flexible)
│   ├── TimerDisplay
│   │   ├── CircularProgress
│   │   └── TimeDisplay
│   ├── ModeIndicator
│   └── ControlButtons (play/pause/reset)
└── RightPanel (320px width)
    ├── CurrentTaskDetails
    │   ├── TaskDescription
    │   └── DurationSelector (Pomodoro mode)
    ├── TaskList
    │   ├── CompetitionTasks
    │   └── CustomTasks
    └── ProgressSummary
        ├── TasksCompleted
        └── TimeSpent
```

## Implementation Strategy

### Phase 1: Foundation and Data Models (Week 1)

1. **Create Enhanced Data Models**
   - File: `lib/features/unified_timer/models/unified_timer_model.dart`
   - Extend ModuleModel with new fields
   - Create TaskItem model with enhanced properties

2. **Develop Unified Timer Controller**
   - File: `lib/features/unified_timer/controllers/unified_timer_controller.dart`
   - Merge functionality from PomodoroController and ModuleTimerPage timer logic
   - Implement module and task switching capabilities

3. **Update Navigation Structure**
   - Modify `lib/layout/landscape_scaffold.dart`
   - Replace PomodoroPage and ModuleTimerPage with UnifiedTimerPage
   - Update bottom navigation to have single timer option

### Phase 2: Core UI Implementation (Week 2)

1. **Create Base UI Components**
   - File: `lib/features/unified_timer/widgets/unified_timer_page.dart`
   - Implement basic layout structure with left, center, and right panels
   - Create responsive layout handling for different screen sizes

2. **Implement Module Selector**
   - File: `lib/features/unified_timer/widgets/module_selector.dart`
   - Adapt from ModuleListPanel with support for practice modules
   - Add competition and practice module categories

3. **Build Timer Display Component**
   - File: `lib/features/unified_timer/widgets/timer_display.dart`
   - Merge timer display logic from both implementations
   - Support both countdown (Pomodoro) and count-up (Module) modes

### Phase 3: Task Management Integration (Week 3)

1. **Implement Enhanced Task List**
   - File: `lib/features/unified_timer/widgets/task_list.dart`
   - Combine task management features from both implementations
   - Support both competition tasks and custom practice tasks

2. **Create Duration Selector**
   - File: `lib/features/unified_timer/widgets/duration_selector.dart`
   - Pomodoro-style duration presets for practice mode
   - Module duration override options for competition modules

3. **Add Progress Tracking**
   - File: `lib/features/unified_timer/widgets/progress_summary.dart`
   - Visual progress indicators for module completion
   - Time tracking per task and per module

### Phase 4: Advanced Features (Week 4)

1. **Implement Mode Switching**
   - Toggle between competition and practice modes
   - Adaptive UI based on selected mode
   - Persistence of mode selection

2. **Add Celebration Effects**
   - File: `lib/features/unified_timer/widgets/celebration_overlay.dart`
   - Port confetti effects from PomodoroPage
   - Add module completion celebrations

3. **Implement State Persistence**
   - File: `lib/features/unified_timer/services/timer_persistence.dart`
   - Save and restore timer state
   - Track historical completion data

### Phase 5: Testing and Refinement (Week 5)

1. **Unit Testing**
   - File: `test/features/unified_timer/`
   - Test timer controller logic
   - Test state transitions

2. **Widget Testing**
   - File: `test/features/unified_timer/widget_test.dart`
   - Test UI component interactions
   - Test mode switching functionality

3. **Integration Testing**
   - Test full user workflows
   - Test state persistence
   - Test edge cases

## UI/UX Design Details

### Visual Design Principles

1. **Consistent WorldSkills Branding**
   - Maintain existing color scheme (WsColors)
   - Preserve the competition theme in visual elements
   - Use consistent typography and spacing

2. **Clear Mode Differentiation**
   - Visual indicators for competition vs. practice mode
   - Color-coded elements (competition: cyan, practice: green)
   - Consistent iconography for mode switching

3. **Progressive Disclosure**
   - Show essential controls prominently
   - Advanced options in collapsible sections
   - Contextual help for complex features

### Layout Specifications

1. **Left Panel (Module Selector)**
   - Fixed width: 300px on desktop, adaptive on tablet
   - Collapsible on smaller screens
   - Module cards with status indicators
   - Mode toggle at top

2. **Center Panel (Timer Display)**
   - Flexible width, responsive to screen size
   - Circular progress indicator with time display
   - Control buttons with clear affordances
   - Current mode indicator

3. **Right Panel (Task Details)**
   - Fixed width: 320px on desktop, adaptive on tablet
   - Current task details with description
   - Task list with completion status
   - Progress summary with statistics

### Interaction Patterns

1. **Timer Controls**
   - Primary play/pause button prominently displayed
   - Reset button secondary
   - Mode switcher tertiary

2. **Task Selection**
   - Click to select current task
   - Drag to reorder tasks
   - Swipe to complete task

3. **Module Navigation**
   - Module selection from left panel
   - Visual feedback for current module
   - Keyboard shortcuts for power users

## Code Changes by File

### Files to Modify

1. **lib/layout/landscape_scaffold.dart**
   - Update _pages array to include UnifiedTimerPage
   - Remove PomodoroPage and ModuleTimerPage references
   - Update navigation subtitles and labels

2. **lib/features/pomodoro/pomodoro_page.dart**
   - Extract reusable components to new unified widgets
   - Port celebration effects to unified implementation

3. **lib/features/module_timer/module_timer_page.dart**
   - Extract module management logic to unified controller
   - Port module list component to unified implementation

### Files to Create

1. **lib/features/unified_timer/models/unified_timer_model.dart**
   - Enhanced ModuleModel and new TaskItem classes
   - Enum definitions for module types and task status

2. **lib/features/unified_timer/controllers/unified_timer_controller.dart**
   - Unified timer logic combining both implementations
   - State management for module and task switching

3. **lib/features/unified_timer/widgets/unified_timer_page.dart**
   - Main page implementation with three-panel layout
   - Mode switching and responsive design

4. **lib/features/unified_timer/widgets/module_selector.dart**
   - Module selection component with competition/practice tabs
   - Module cards with status indicators

5. **lib/features/unified_timer/widgets/timer_display.dart**
   - Circular progress indicator with time display
   - Mode-specific timer formatting

6. **lib/features/unified_timer/widgets/task_list.dart**
   - Task management component with drag-and-drop
   - Task status tracking and completion indicators

7. **lib/features/unified_timer/services/timer_persistence.dart**
   - State persistence for timer and task data
   - Historical completion tracking

### Files to Delete (after migration)

1. **lib/features/pomodoro/pomodoro_page.dart**
2. **lib/features/module_timer/module_timer_page.dart**
3. **lib/features/pomodoro/pomodoro_controller.dart** (logic migrated)
4. **lib/features/module_timer/module_list_panel.dart** (component migrated)

## Migration Path

### Data Migration Strategy

1. **Current Module Data**
   - Migrate existing ModuleModel definitions to enhanced model
   - Add default practice modules for common skills
   - Map existing status to new enum values

2. **Task Data Migration**
   - Convert Pomodoro task items to new TaskItem model
   - Associate existing tasks with appropriate modules
   - Preserve completion status and time estimates

3. **Settings Migration**
   - Preserve user preferences where applicable
   - Add new settings for mode preferences
   - Default to competition mode for existing users

### User Experience Migration

1. **Feature Communication**
   - In-app notification of unified timer implementation
   - Tutorial walkthrough of new interface
   - Highlight key improvements and benefits

2. **Graceful Transition**
   - Maintain familiar UI elements where possible
   - Clear visual indicators for moved features
   - Tooltips and help text for new functionality

3. **Fallback Plan**
   - Ability to temporarily revert to original implementations
   - User feedback mechanism during transition period
   - Quick iteration based on user feedback

## Testing Strategy

### Unit Tests

1. **Timer Controller Tests**
   - Test timer state transitions
   - Verify duration calculations
   - Test module and task switching

2. **Model Tests**
   - Test data validation
   - Test state transitions
   - Test time calculations

### Integration Tests

1. **End-to-End Workflows**
   - Complete competition module workflow
   - Practice mode with custom tasks
   - Mode switching scenarios

2. **State Persistence Tests**
   - Save and restore timer state
   - Test data migration
   - Verify historical data integrity

### User Acceptance Testing

1. **Competition Mode Testing**
   - Verify 3-hour module timing
   - Test task completion tracking
   - Validate module progression

2. **Practice Mode Testing**
   - Test flexible duration selection
   - Verify custom task creation
   - Test Pomodoro-style timeboxing

## Success Metrics

### Technical Metrics

1. **Code Reduction**
   - Target: 30% reduction in timer-related code
   - Fewer duplicate components
   - Simplified state management

2. **Performance Improvements**
   - Faster app initialization
   - Reduced memory usage
   - Smoother timer transitions

### User Experience Metrics

1. **Usability Improvements**
   - Reduced user confusion (measured by support tickets)
   - Increased feature utilization
   - Improved task completion rates

2. **Feature Adoption**
   - Usage of combined features
   - Session duration improvements
   - User retention rates

## Risks and Mitigations

### Technical Risks

1. **Complexity of Implementation**
   - Risk: Overly complex unified implementation
   - Mitigation: Incremental development with regular refactoring

2. **State Management Issues**
   - Risk: Timer state inconsistencies
   - Mitigation: Comprehensive state management design and testing

### User Experience Risks

1. **Feature Loss During Migration**
   - Risk: Loss of specific features users value
   - Mitigation: Feature audit and prioritization before implementation

2. **User Resistance to Change**
   - Risk: Users uncomfortable with new interface
   - Mitigation: Gradual rollout with clear communication

## Timeline Summary

| Phase | Duration | Key Deliverables |
|------|----------|------------------|
| Phase 1: Foundation | Week 1 | Enhanced data models, unified timer controller |
| Phase 2: Core UI | Week 2 | Base page structure, module selector, timer display |
| Phase 3: Task Integration | Week 3 | Task management, duration selector, progress tracking |
| Phase 4: Advanced Features | Week 4 | Mode switching, celebrations, state persistence |
| Phase 5: Testing & Refinement | Week 5 | Testing suite, bug fixes, performance optimization |

## Conclusion

This merge plan provides a comprehensive approach to unifying the Pomodoro and Module timer functionality while preserving the strengths of both implementations. The phased approach ensures a manageable development process with regular deliverables and testing checkpoints.

The resulting unified timer will provide a more intuitive experience for WorldSkills competition preparation while maintaining the flexibility needed for practice sessions. The modular architecture ensures future extensibility while reducing code duplication and maintenance burden.

By following this plan, the team can deliver a cohesive, feature-rich timer experience that enhances the WorldSkills competition preparation app while eliminating user confusion and technical debt.
