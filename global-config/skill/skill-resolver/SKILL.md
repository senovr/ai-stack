---
name: skill-resolver
description: "Parametrized engine invoked by Meta-Agent. Analyzes technical requirements, resolves dependency trees, provisions skills idempotently, and generates the target agent file."
risk: low
source: awesome-skills-repo
date_updated: '2026-03-12'
tags: [skills, orchestration, bootstrap, auto-dependency]
tools: [bash]
---

# Skill Resolver (Smart Engine)

Automated orchestrator that matches project requirements against the skill catalog, resolves dependencies, and provisions the target workspace seamlessly.

## Execution Directives for the Agent
When invoked with `resolve "<stack>" --target <project-folder> --role <role-name>`, you MUST strictly execute the bash script below to accomplish the task. Do NOT ask the user for paths; use the arguments provided by the Meta-Agent.

### The Bash Pipeline
Run the following bash script to provision the environment. Replace `$TARGET_DIR` and `$ROLE_NAME` with the arguments you received. Pick up to 10 relevant skills based on the `<stack>` request and place them in the `SELECTED_SKILLS` array inside the script.

```bash
#!/bin/bash
set -e

# 1. Variables (LLM, replace these based on Meta-Agent input)
TARGET_DIR="<project-folder>"
ROLE_NAME="<role-name>"
# LLM: Fill this array with specific skills matching the <stack> from CATALOG.md
SELECTED_SKILLS=("skill-1" "skill-2") 

BARE_MINIMUM=("git-commit" "debugger" "plan-writing" "verification-before-completion")
TMP_REPO="/tmp/awesome-skills"

echo "Starting Skill Resolver pipeline..."

# 2. Idempotent Fetch of Skills Repository
if [ ! -d "$TMP_REPO/.git" ]; then
  echo "Cloning skills repository..."
  git clone https://github.com/sickn33/antigravity-awesome-skills.git "$TMP_REPO"
else
  echo "Updating existing skills repository..."
  cd "$TMP_REPO" && git fetch origin && git reset --hard origin/main
fi

mkdir -p "$TARGET_DIR/skills"

# Copy project templates from skill-resolver
if [ -d "$TMP_REPO/skill-resolver/templates" ]; then
  cp -n "$TMP_REPO/skill-resolver/templates/pyproject.toml" "$TARGET_DIR/" 2>/dev/null || true
  cp -n "$TMP_REPO/skill-resolver/templates/prek.toml" "$TARGET_DIR/" 2>/dev/null || true
fi

# 3. Resolve Dependencies and Copy (DAG Resolution)
ALL_SKILLS=("${SELECTED_SKILLS[@]}" "${BARE_MINIMUM[@]}")
PROCESSED_SKILLS=()

resolve_and_copy() {
  local skill=$1
  
  # Skip if already processed
  if [[ " ${PROCESSED_SKILLS[*]} " =~ " ${skill} " ]]; then
    return
  fi
  
  PROCESSED_SKILLS+=("$skill")
  local skill_path="$TMP_REPO/skills/$skill"
  
  if [ -d "$skill_path" ] || [ -f "$skill_path" ] || [ -f "$skill_path.md" ]; then
    echo "Provisioning: $skill"
    cp -rn "$skill_path"* "$TARGET_DIR/skills/" 2>/dev/null || true
    
    # Parse 'requires:' from YAML frontmatter if it's a markdown file
    if [ -f "$skill_path.md" ]; then
      local deps=$(awk '/^requires:/ {print $2}' "$skill_path.md" | tr -d '[],')
      for dep in $deps; do
        resolve_and_copy "$dep"
      done
    fi
  else
    echo "Warning: Skill '$skill' not found in catalog."
  fi
}

for skill in "${ALL_SKILLS[@]}"; do
  resolve_and_copy "$skill"
done

# 4. Generate Specialized Agent Markdown
AGENT_FILE="$TARGET_DIR/$ROLE_NAME.md"
cat << 'EOF' > "$AGENT_FILE"
***
description: "Specialized agent for this workspace. Strictly executes PLAN.md."
temperature: 0.2
mode: primary
***

# Specialized Agent

## Context & Stack
- **Workspace**: Current directory.
- **Local Skills**: `./skills/`

## Core Directives
1. Parse `PRD.md` and `TRD.md` before writing any code.
2. Execute tasks sequentially according to `PLAN.md`.
3. Mark checkboxes `[x]` in `PLAN.md` upon verifiable completion.
4. Run `verification-before-completion` before finalizing any milestone.
EOF

echo "Provisioning complete. Specialized agent created at $AGENT_FILE"
```
