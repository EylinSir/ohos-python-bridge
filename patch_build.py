#!/usr/bin/env python3
"""Patch build.sh for cross compiling on GitHub Actions (x86_64 Linux -> aarch64 OHOS)"""

import sys

with open('build.sh', 'r') as f:
    lines = f.readlines()

skip_patterns = [
    'Harmonybrew/ohos-',
    'ln -sf',
    'ln -s ',
    'curl.*ohos-sdk',
    'tar.*ohos-sdk',
    'cd ohos-sdk',
    'unzip -q',
    'xargs',
    'rm -rf *.tar.gz',
]

in_while_loop = False
in_for_loop = False
in_multiline_skip = False
in_gettext = False
new_lines = []
current_dir = ""

for i, line in enumerate(lines):
    should_skip = False
    for pat in skip_patterns:
        if pat in line:
            should_skip = True
            break
    if in_multiline_skip:
        should_skip = True
        if not line.rstrip().endswith('\\'):
            in_multiline_skip = False
    elif should_skip and line.rstrip().endswith('\\'):
        in_multiline_skip = True
    if 'while read' in line:
        in_while_loop = True
        should_skip = True
    if in_while_loop:
        if line.strip().startswith('done'):
            in_while_loop = False
            should_skip = True
        else:
            should_skip = True
    if line.strip().startswith('for executable in'):
        in_for_loop = True
        should_skip = True
    if in_for_loop:
        if line.strip() == 'done':
            in_for_loop = False
            should_skip = True
        else:
            should_skip = True
    
    # Fix SDK path
    line = line.replace('/opt/ohos-sdk/ohos/', '/opt/ohos-sdk/linux/')
    
    # Track current directory
    if line.strip().startswith('cd ') and 'ohos-sdk' not in line:
        current_dir = line.strip().split()[1]
    
    # Skip gettext entirely
    if 'cd gettext' in line:
        in_gettext = True
    if in_gettext:
        should_skip = True
        if line.strip() == 'cd $WORKDIR' or line.strip().startswith('cd /'):
            in_gettext = False
    
    # Add --host to non-Python, non-zlib configure commands
    if './configure' in line and 'Python' not in current_dir and 'zlib' not in current_dir and not in_gettext and '--host' not in line:
        line = line.replace('./configure', './configure --host=aarch64-linux-gnu --build=x86_64-linux-gnu')
    
    # Add --enable-shared and --with-build-python to Python's LDFLAGS line
    if 'Python' in current_dir and 'LDFLAGS=' in line and '--enable-shared' not in line:
        line = line.rstrip().rstrip('\\').rstrip() + ' --enable-shared --with-build-python=$BUILD_PYTHON\n'
    
    # Fix OpenSSL private keyword after Configure
    if './Configure' in line and 'linux-aarch64' in line:
        new_lines.append(line)
        new_lines.append('sed -i "s/\\bprivate\\b/priv/g" apps/include/apps.h\n')
        should_skip = True
    
    if should_skip:
        new_lines.append('#SKIP: ' + line)
    else:
        new_lines.append(line)

with open('build.sh', 'w') as f:
    f.writelines(new_lines)

print(f"Patched {len(new_lines)} lines")
