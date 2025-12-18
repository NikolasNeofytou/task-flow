# Project Page Enhancements

## Overview

The Projects page has been enhanced with advanced filtering, sorting, progress visualization, team collaboration features, and deadline warnings to provide better project management and visibility.

## Features Implemented

### 1. Project Progress Visualization

#### Description
Each project card now displays a visual progress bar showing task completion status with percentage and completed/total task counts.

#### UI Components
- **Progress Bar**: Linear progress indicator with color-coding matching project status
- **Task Counter**: Shows "X/Y tasks" format (e.g., "8/12 tasks")
- **Percentage Display**: Shows completion percentage (e.g., "67%")

#### Technical Implementation

**Model Changes** (`lib/core/models/project.dart`):
```dart
class Project {
  final int completedTasks;  // Number of completed tasks
  
  double get progress => tasks > 0 ? completedTasks / tasks : 0.0;
}
```

**UI Rendering**:
```dart
// Progress display
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('${project.completedTasks}/${project.tasks} tasks'),
    Text('${(project.progress * 100).toInt()}%'),
  ],
),
LinearProgressIndicator(
  value: project.progress,
  minHeight: 6,
  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
),
```

#### User Benefits
- Quick visual assessment of project completion status
- Easy identification of projects needing attention
- Clear understanding of workload distribution

---

### 2. Team Member Avatars

#### Description
Project cards display circular avatars of assigned team members, making it easy to see who's working on each project.

#### UI Components
- **Avatar Circles**: Color-coded circles with team member initials
- **Overflow Indicator**: "+N" badge for projects with >3 members
- **Tooltips**: Hover to see full team member names

#### Technical Implementation

**Model Changes** (`lib/core/models/project.dart`):
```dart
class Project {
  final List<String> teamMembers; // User IDs of assigned team members
}
```

**Mock Data** (`lib/core/data/mock_data.dart`):
```dart
Project(
  id: 'proj-1',
  name: 'Mobile App V2',
  teamMembers: ['user-1', 'user-2', 'user-3'],
),
```

**UI Rendering**:
```dart
asyncUsers.when(
  data: (users) {
    final teamMembers = users
        .where((u) => project.teamMembers.contains(u.id))
        .toList();
    
    return Row(
      children: [
        for (var i = 0; i < teamMembers.length && i < 3; i++)
          Tooltip(
            message: teamMembers[i].name,
            child: CircleAvatar(
              radius: 14,
              child: Text(teamMembers[i].name[0]),
            ),
          ),
        if (teamMembers.length > 3)
          CircleAvatar(
            child: Text('+${teamMembers.length - 3}'),
          ),
      ],
    );
  },
)
```

#### User Benefits
- Instant visibility of team assignments
- Easy identification of team member workload
- Visual confirmation of project staffing

---

### 3. Advanced Filtering System

#### Description
Comprehensive filtering system allowing users to filter projects by status, team member, and deadline status.

#### Filter Options

**Status Filters**:
- On Track
- Due Soon
- Blocked

**Team Member Filters**:
- Filter by any team member (shows their avatar and first name)

**Deadline Filters**:
- Show overdue only (checkbox)

#### UI Components
- **Filter Toggle Button**: Shows active filter count with expand/collapse icon
- **Filter Panel**: Expandable panel with all filter options
- **FilterChips**: Interactive chips for each filter option
- **Clear All Button**: Quickly reset all filters

#### Technical Implementation

**State Management**:
```dart
class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  ProjectStatus? _selectedStatus;
  String? _selectedTeamMember;
  bool _showOverdueOnly = false;
  bool _showFilters = false;
  
  bool get _hasActiveFilters =>
      _selectedStatus != null || 
      _selectedTeamMember != null || 
      _showOverdueOnly;
}
```

**Filter Application** (`_BoardView._applyFilters()`):
```dart
// Status filter
if (selectedStatus != null) {
  filtered = filtered.where((p) => p.status == selectedStatus).toList();
}

// Team member filter
if (selectedTeamMember != null) {
  filtered = filtered.where((p) => 
    p.teamMembers.contains(selectedTeamMember)
  ).toList();
}

// Overdue filter
if (showOverdueOnly) {
  final now = DateTime.now();
  filtered = filtered.where((p) {
    if (p.deadline == null) return false;
    return p.deadline!.isBefore(now);
  }).toList();
}
```

#### User Workflows

**Applying Filters**:
1. Click "Filters" button to expand filter panel
2. Select desired status, team member, or toggle overdue
3. Projects list updates in real-time
4. Filter button shows active filter indicator

**Clearing Filters**:
1. Click "Clear all" in filter panel
2. All filters reset to default state
3. Full project list displayed

#### User Benefits
- Focus on specific project types or team members
- Quickly identify overdue projects
- Combine multiple filters for precise views
- Easy filter management

---

### 4. Sort Options

#### Description
Flexible sorting system allowing users to organize projects by different criteria.

#### Sort Options

- **By Status** (default): Groups by On Track → Due Soon → Blocked
- **By Deadline**: Soonest deadlines first
- **By Progress**: Highest completion percentage first
- **By Name**: Alphabetical order

#### UI Components
- **Sort Menu**: Dropdown menu with sort options
- **Sort Icon**: Standard sort icon button in toolbar

#### Technical Implementation

**State Management**:
```dart
String _sortBy = 'status'; // status, deadline, progress, name
```

**Sort Logic**:
```dart
List<Project> _sortProjects(List<Project> projects, String sortBy) {
  final sorted = [...projects];
  switch (sortBy) {
    case 'deadline':
      sorted.sort((a, b) {
        if (a.deadline == null && b.deadline == null) return 0;
        if (a.deadline == null) return 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      });
      break;
    case 'progress':
      sorted.sort((a, b) => b.progress.compareTo(a.progress));
      break;
    case 'name':
      sorted.sort((a, b) => a.name.compareTo(b.name));
      break;
    case 'status':
    default:
      sorted.sort((a, b) => a.status.index.compareTo(b.status.index));
      break;
  }
  return sorted;
}
```

#### User Benefits
- Flexible project organization
- Quick prioritization by deadline or progress
- Easy project lookup by name
- Status-based grouping for workflow management

---

### 5. Deadline Visual Indicators

#### Description
Prominent visual warnings for projects approaching or past their deadlines.

#### Indicator Types

**OVERDUE Badge** (Red):
- Shown when deadline has passed
- Red background with border
- Warning icon
- "OVERDUE" text in bold

**Days Remaining Badge** (Yellow):
- Shown when deadline is within 7 days
- Yellow/warning color scheme
- Clock icon
- Shows exact days remaining (e.g., "5 days")

#### Technical Implementation

**Deadline Calculation**:
```dart
final now = DateTime.now();
final isOverdue = project.deadline != null && 
                  project.deadline!.isBefore(now);
final daysUntilDeadline = project.deadline?.difference(now).inDays;
```

**UI Rendering**:
```dart
if (isOverdue)
  Container(
    decoration: BoxDecoration(
      color: AppColors.error.withOpacity(0.1),
      border: Border.all(color: AppColors.error),
    ),
    child: Row(
      children: [
        Icon(Icons.warning, color: AppColors.error),
        Text('OVERDUE', style: TextStyle(color: AppColors.error)),
      ],
    ),
  )
else if (daysUntilDeadline != null && daysUntilDeadline <= 7)
  Container(
    decoration: BoxDecoration(
      color: AppColors.warning.withOpacity(0.1),
      border: Border.all(color: AppColors.warning),
    ),
    child: Row(
      children: [
        Icon(Icons.schedule, color: AppColors.warning),
        Text('$daysUntilDeadline days', style: TextStyle(color: AppColors.warning)),
      ],
    ),
  )
```

#### User Benefits
- Immediate visual alert for deadline issues
- Proactive warning for approaching deadlines
- Clear distinction between urgency levels
- Prevents missed deadlines

---

## Data Model Changes

### Project Model Enhancement

**File**: `lib/core/models/project.dart`

**New Fields**:
```dart
class Project {
  final int completedTasks;      // Number of completed tasks
  final List<String> teamMembers; // User IDs of assigned team members
  
  double get progress => tasks > 0 ? completedTasks / tasks : 0.0;
}
```

### Mock Data Updates

**File**: `lib/core/data/mock_data.dart`

**Enhanced Project Data**:
```dart
Project(
  id: 'proj-1',
  name: 'Mobile App V2',
  status: ProjectStatus.onTrack,
  tasks: 12,
  completedTasks: 8,                           // NEW
  deadline: DateTime(now.year, now.month, now.day + 5),
  teamMembers: ['user-1', 'user-2', 'user-3'], // NEW
),
```

---

## User Workflows

### Viewing Project Progress

1. Navigate to Projects page
2. Each project card displays:
   - Progress bar with percentage
   - Completed vs total tasks
   - Color-coded status indicator
3. Quickly identify projects needing attention

### Filtering Projects

1. Click "Filters" button in toolbar
2. Filter panel expands showing options
3. Select status filter (On Track/Due Soon/Blocked)
4. Select team member to see their projects
5. Toggle "Show overdue only" for urgent items
6. View filtered results in real-time
7. Click "Clear all" to reset filters

### Sorting Projects

1. Click sort icon (three horizontal lines with arrows)
2. Select sort option from menu:
   - Sort by Status (default grouping)
   - Sort by Deadline (urgent first)
   - Sort by Progress (most complete first)
   - Sort by Name (alphabetical)
3. Project list reorganizes immediately

### Monitoring Deadlines

1. Projects with deadlines within 7 days show yellow badge
2. Overdue projects show red "OVERDUE" badge
3. Both badges appear at top-right of project card
4. Use "Show overdue only" filter to focus on urgent projects

### Viewing Team Assignments

1. Team member avatars appear at bottom-right of each project card
2. Up to 3 avatars shown directly
3. "+N" badge indicates additional members
4. Hover over avatar to see full name
5. Use team member filter to see specific person's projects

---

## Testing Checklist

### Progress Visualization
- [ ] Progress bar displays correctly for different completion levels (0%, 50%, 100%)
- [ ] Task count shows accurate numbers
- [ ] Percentage calculation is correct
- [ ] Progress bar color matches project status color

### Team Member Avatars
- [ ] Avatars display for projects with team members
- [ ] Initials are correct for each user
- [ ] "+N" badge shows for >3 members with correct count
- [ ] Tooltips display full names on hover
- [ ] Avatar colors are consistent and distinct

### Filtering
- [ ] Status filter works for each status type
- [ ] Team member filter shows only relevant projects
- [ ] Overdue filter correctly identifies past-deadline projects
- [ ] Multiple filters can be combined
- [ ] "Clear all" resets all filters
- [ ] Filter count indicator updates correctly
- [ ] Filter panel expands/collapses smoothly

### Sorting
- [ ] Each sort option correctly reorganizes projects
- [ ] Sort by deadline handles null deadlines properly
- [ ] Sort by progress orders by percentage
- [ ] Sort by name is alphabetical
- [ ] Sort persists when filters change

### Deadline Indicators
- [ ] Overdue badge appears for past deadlines
- [ ] Days remaining badge appears within 7 days
- [ ] Badge calculations are accurate
- [ ] Colors and icons are appropriate
- [ ] Badges don't appear for projects with no deadline

### Data Integration
- [ ] Mock data includes all new fields
- [ ] User data loads correctly
- [ ] Project data displays without errors
- [ ] All relationships (user IDs) are valid

---

## Future Enhancements

### Phase 1: Drag & Drop Reordering
- Drag projects between status columns
- Manual priority ordering within columns
- Persist custom order preferences

### Phase 2: Quick Actions
- Inline edit project name
- Quick status change dropdown
- Pin/favorite projects
- Archive completed projects

### Phase 3: Project Templates
- Predefined project templates
- Template categories (development, design, marketing)
- Custom template creation
- Quick start with templates

### Phase 4: Bulk Operations
- Multi-select projects
- Batch status updates
- Bulk team member assignment
- Mass archive/delete

### Phase 5: View Modes
- Toggle between board/list/grid layouts
- Kanban-style board view
- Compact list view for many projects
- Grid view for visual overview

### Phase 6: Advanced Features
- Activity timeline per project
- Search result highlighting
- Export projects to CSV/PDF
- Project dependencies visualization
- Gantt chart view
- Custom fields per project

---

## Accessibility Considerations

### Screen Reader Support
- Semantic HTML structure with proper ARIA labels
- Progress bars include aria-valuenow and aria-valuemax
- FilterChips announce selected state
- Tooltips provide additional context

### Keyboard Navigation
- All filters accessible via keyboard
- Sort menu navigable with arrow keys
- FilterChips toggle with Space/Enter
- Tab order follows logical flow

### Visual Accessibility
- High contrast for deadline badges
- Color-blind friendly status colors
- Sufficient text size for readability
- Clear visual hierarchy

### Motion Considerations
- Respects prefers-reduced-motion
- Filter panel expansion can be instant if needed
- Progress animations are subtle

---

## Performance Considerations

### Optimization Strategies
- Memoized color calculations (StatusColorCache)
- Efficient filtering with List.where
- Debounced search input (300ms)
- Lazy loading for large project lists
- Optimized avatar rendering

### State Management
- Riverpod providers for data fetching
- ConsumerWidget for reactive updates
- Local state for UI interactions
- Minimal rebuilds on filter changes

---

## Related Documentation

- [Task Assignment System](./task_assignment_system.md) - Team collaboration features
- [Fluent UI System](./fluent_ui_system.md) - Design system components
- [Design Tokens](./design-tokens.md) - Colors and spacing used
- [Project Plan](./project_plan.md) - Overall project roadmap

---

## Summary

The enhanced Projects page provides comprehensive project management capabilities with:

✅ **Visual Progress Tracking** - Instant understanding of completion status  
✅ **Team Visibility** - Clear view of project assignments  
✅ **Powerful Filtering** - Focus on what matters most  
✅ **Flexible Sorting** - Organize projects your way  
✅ **Deadline Awareness** - Never miss important dates  

These features significantly improve project visibility, team coordination, and deadline management, making TaskFlow a more powerful project management tool.
