# EM-Distributed Installation Guide

**Flexible, portable installation for EM-Distributed on ANY system**

Works on macOS, Linux, and any Unix-like system.

---

## 🚀 Quick Install (Recommended)

### Method 1: Automated Installation

From EM-Skill directory:

```bash
cd /path/to/EM-Skill
bash install-em-distributed.sh
```

This will:
- ✅ Auto-detect EM-Skill location
- ✅ Install wrapper to ~/.local/bin/
- ✅ Setup shell aliases in ~/.zshrc or ~/.bashrc
- ✅ Create config file at ~/.em-skill/config
- ✅ Verify PATH configuration

---

## 📦 Manual Installation

### Step 1: Copy Wrapper Script

```bash
# Create bin directory
mkdir -p ~/.local/bin

# Copy wrapper script
cp /path/to/EM-Skill/em-distributed-wrapper ~/.local/bin/em-distributed
chmod +x ~/.local/bin/em-distributed
```

### Step 2: Configure EM-Skill Location

**Option A: Environment Variable**
```bash
# Add to ~/.zshrc or ~/.bashrc
export EM_SKILL_DIR=/path/to/EM-Skill
```

**Option B: Config File**
```bash
# Create config directory
mkdir -p ~/.em-skill

# Create config file
echo "EM_SKILL_DIR=/path/to/EM-Skill" > ~/.em-skill/config
```

### Step 3: Setup PATH
```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"
```

### Step 4: Setup Aliases
```bash
# Add to ~/.zshrc or ~/.bashrc
alias em-distributed='~/.local/bin/em-distributed'
alias em-dist='~/.local/bin/em-distributed'
alias em-start='~/.local/bin/em-distributed start'
alias em-be='~/.local/bin/em-distributed be'
alias em-fe='~/.local/bin/em-distributed fe'
```

### Step 5: Reload Shell
```bash
source ~/.zshrc   # or source ~/.bashrc
# or
exec zsh          # or restart terminal
```

---

## ✅ Verify Installation
```bash
# Check wrapper is in PATH
which em-distributed

# Show help
em-distributed help

# Check config
cat ~/.em-skill/config
```

