# Installation Guide

Complete installation guide for Logseq Task Viewer.

## System Requirements

### Operating System
- **macOS 13.0 (Ventura) or later**
- Apple Silicon (M1/M2/M3) or Intel processor

### Prerequisites
- **Homebrew** package manager (install from [brew.sh](https://brew.sh))
- **Logseq** with a DB graph (database-based, not file/markdown)

## Installation Methods

### Method 1: Download Pre-Built App (Recommended)

This is the easiest way to install Logseq Task Viewer.

#### Step 1: Download the App

1. Visit the [Releases page](https://github.com/kerim/logseq-task-viewer/releases/latest)
2. Download `LogseqTaskViewer.app.zip`
3. Unzip the downloaded file (double-click in Finder)

#### Step 2: Move to Applications

1. Drag `LogseqTaskViewer.app` to your `/Applications` folder
2. Or place it anywhere you prefer (Desktop, custom folder, etc.)

#### Step 3: First Launch (Bypass Gatekeeper)

Because the app is not signed with an Apple Developer certificate, macOS will block it on first launch.

**To bypass Gatekeeper:**
1. **Right-click** (or Control+click) on `LogseqTaskViewer.app`
2. Select **"Open"** from the menu
3. Click **"Open"** in the security dialog
4. The app will launch

**Alternative method** (if right-click doesn't work):
1. Try to open the app normally (double-click)
2. macOS will show an error: "LogseqTaskViewer cannot be opened"
3. Go to **System Settings** → **Privacy & Security**
4. Scroll down to find: "LogseqTaskViewer was blocked"
5. Click **"Open Anyway"**
6. Click **"Open"** in the confirmation dialog

**Note:** You only need to do this once. Future launches will work normally.

#### Step 4: Install Dependencies

Open Terminal and run:

```bash
brew install logseq
brew install jet
```

**What these do:**
- `logseq` - Logseq CLI for querying your database
- `jet` - Converts EDN (Clojure data) to JSON

**Verify installation:**
```bash
logseq --version
jet --version
```

Both should show version numbers without errors.

### Method 2: Build from Source

For developers or those who want to build from source.

#### Step 1: Install Xcode

1. Install **Xcode 15+** from the Mac App Store
2. Open Xcode and accept the license agreement
3. Install Command Line Tools:
   ```bash
   xcode-select --install
   ```

#### Step 2: Clone Repository

```bash
cd ~/Documents/Code  # Or your preferred directory
git clone https://github.com/kerim/logseq-task-viewer.git
cd logseq-task-viewer
```

#### Step 3: Build with Xcode

```bash
xcodebuild -scheme LogseqTaskViewer -configuration Release build
```

The built app will be at: `build/Release/LogseqTaskViewer.app`

#### Step 4: Move to Applications

```bash
cp -R build/Release/LogseqTaskViewer.app /Applications/
```

#### Step 5: Install Dependencies

```bash
brew install logseq
brew install jet
```

## Logseq Setup

### Using DB Graphs (Required)

Logseq Task Viewer **only works with DB graphs**, not file-based (markdown) graphs.

**Check your graph type:**
1. Open Logseq
2. Click graph name in top-left
3. Look at the graph type indicator

**If you have a file-based graph:**
- You'll need to create a new DB graph or convert your existing graph
- See [Logseq documentation](https://docs.logseq.com) for migration instructions

### Task Format

Tasks must be properly formatted in Logseq:

**Required:**
- Block must have `#Task` tag
- Block must have a status property

**Example task:**
```
- Buy groceries #Task
  status:: Todo
  priority:: High
```

**Supported statuses:**
- `Todo` - Not started
- `Doing` - In progress
- `Done` - Completed
- `Cancelled` - No longer needed

**Supported priorities:**
- `Urgent` (🔴 Red icon)
- `High` (🟠 Orange icon)
- `Medium` (🟡 Yellow icon)
- `Low` (🔵 Blue icon)

## First Run Configuration

### Step 1: Launch the App

1. Open `LogseqTaskViewer.app`
2. Look for the checkmark icon (✓) in your menu bar
3. Click the icon - you'll see a dropdown panel

### Step 2: Select Your Graph

1. Open Query Manager (from menu or click gear icon)
2. At the top, you'll see **Graph:** dropdown
3. Select your Logseq database from the list
4. The selection is saved automatically

### Step 3: View Your Tasks

1. Close Query Manager
2. Click the menu bar icon
3. You'll see your DOING tasks (default query)

### Step 4: Explore Queries

1. Open Query Manager again
2. You'll see three default queries:
   - **DOING Tasks** - Currently in-progress tasks
   - **TODO Tasks** - Not-started tasks
   - **High Priority** - Urgent and High priority tasks
3. Double-click any query to execute it
4. Results appear in the main dropdown panel

## Troubleshooting

### App won't open / "Unidentified Developer" error

**Solution:** Use the right-click → Open method (see Step 3 above)

### "No graph selected" alert

**Problem:** You haven't selected a Logseq graph yet

**Solution:**
1. Open Query Manager
2. Select your graph from the dropdown
3. If dropdown is empty, make sure Logseq CLI is installed: `brew install logseq`

### No tasks showing

**Possible causes:**

1. **No tasks in selected status**
   - Default query shows DOING tasks
   - If you have no tasks with "Doing" status, nothing appears
   - Try "TODO Tasks" query instead

2. **Tasks not properly formatted**
   - Tasks must have `#Task` tag
   - Tasks must have `status::` property
   - Check your Logseq graph

3. **Wrong graph selected**
   - Verify correct graph in Query Manager
   - Try switching graphs

### "Command failed" errors

**Problem:** Logseq CLI or Jet not found

**Solution:**
```bash
# Install dependencies
brew install logseq jet

# Verify installation
which logseq  # Should show: /opt/homebrew/bin/logseq
which jet     # Should show: /opt/homebrew/bin/jet
```

### Query Manager window hidden

**Problem:** Query Manager opened off-screen

**Solution:**
1. Quit the app (right-click menu bar icon → Quit)
2. Relaunch the app
3. Open Query Manager again

### Custom queries not working

**Problem:** Syntax error in Datalog query

**Solution:**
1. Test query in Logseq first
2. Use the "Preview" button in Query Manager
3. Check error message for syntax issues
4. Reference default queries as examples

## Uninstallation

### Remove the App

```bash
rm -rf /Applications/LogseqTaskViewer.app
```

### Remove User Data (Optional)

```bash
# Remove saved queries and preferences
defaults delete com.kerim.LogseqTaskViewer
```

### Remove Dependencies (Optional)

**Only if you don't use Logseq CLI elsewhere:**
```bash
brew uninstall logseq
brew uninstall jet
```

## Getting Help

### Documentation
- [README.md](../README.md) - Overview and features
- [CHANGELOG.md](CHANGELOG.md) - Version history
- [DEVELOPMENT_REPORT.md](DEVELOPMENT_REPORT.md) - Technical details

### Support
- [Open an issue](https://github.com/kerim/logseq-task-viewer/issues) on GitHub
- Check [existing issues](https://github.com/kerim/logseq-task-viewer/issues) for solutions

## Next Steps

Once installed:

1. **Explore default queries** - Try DOING, TODO, High Priority
2. **Create custom queries** - Build your own Datalog queries
3. **Organize your workflow** - Use different queries for different contexts
4. **Keyboard workflow** - Keep the app in your menu bar for quick access

Enjoy using Logseq Task Viewer! 🎉
