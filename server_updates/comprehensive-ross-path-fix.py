#!/usr/bin/env python3
"""
Comprehensive path fix for Ross Docker migration
Scans all workspace files and fixes path references
"""
import os
import re
from pathlib import Path

WORKSPACE = "/root/openclaw-clients/ross/workspace"

# Path mapping rules
PATH_RULES = [
    # Ross's OLD native paths → Container paths (what Ross sees inside Docker)
    (r'/root/\.openclaw-ross', '/home/openclaw/.openclaw'),
    (r'/root/openclaw-clients/ross', '/home/openclaw/.openclaw'),  # Host path Ross can't see
    
    # Jack's paths stay the same (Ross needs to reference Jack's actual location)
    # (r'/root/\.openclaw/', '/root/.openclaw/'),  # KEEP AS-IS
]

# Files to SKIP (historical/documentation, not configuration)
SKIP_FILES = [
    'docker_migration_native_to_container.md',  # Historical lesson
    'createbots/',  # Legacy templates
]

# Files to check
files_to_check = []
for root, dirs, files in os.walk(WORKSPACE):
    for file in files:
        if file.endswith(('.md', '.sh', '.json', '.txt')):
            rel_path = os.path.relpath(os.path.join(root, file), WORKSPACE)
            # Skip if in skip list
            if any(skip in rel_path for skip in SKIP_FILES):
                continue
            files_to_check.append(os.path.join(root, file))

print(f"Scanning {len(files_to_check)} files for path references...\n")

fixed_files = []
for filepath in files_to_check:
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        original_content = content
        fixes_in_file = []
        
        for pattern, replacement in PATH_RULES:
            matches = re.findall(pattern, content)
            if matches:
                content = re.sub(pattern, replacement, content)
                fixes_in_file.append(f"  {pattern} → {replacement} ({len(matches)} occurrences)")
        
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            
            rel_path = os.path.relpath(filepath, WORKSPACE)
            print(f"✅ {rel_path}")
            for fix in fixes_in_file:
                print(fix)
            print()
            fixed_files.append(rel_path)
        
    except Exception as e:
        print(f"❌ Error processing {filepath}: {e}")

print(f"\n{'='*60}")
print(f"SUMMARY: Fixed {len(fixed_files)} files")
if fixed_files:
    print("\nFiles changed:")
    for f in fixed_files:
        print(f"  - {f}")
else:
    print("No files needed fixing.")
print(f"{'='*60}")
