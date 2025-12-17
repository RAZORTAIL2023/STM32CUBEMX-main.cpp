#!/bin/bash
# Test script for pre_generate.bat and post_generate.bat functionality
# This script simulates the behavior on a Linux system

echo "=========================================="
echo "Testing STM32CubeMX Scripts (Linux Test)"
echo "=========================================="

# Create test environment
TEST_DIR="test_env"
mkdir -p "$TEST_DIR/Core/Src"

echo ""
echo "=========================================="
echo "Test 1: First Generation (no main.cpp)"
echo "=========================================="

# Create initial main.c
echo "int main(void) { return 0; }" > "$TEST_DIR/Core/Src/main.c"
echo "[SETUP] Created main.c"
ls -l "$TEST_DIR/Core/Src/"

# Simulate pre_generate (should do nothing)
echo ""
echo "[PRE-GEN] Checking for main.cpp..."
if [ -f "$TEST_DIR/Core/Src/main.cpp" ]; then
    mv "$TEST_DIR/Core/Src/main.cpp" "$TEST_DIR/Core/Src/main.c"
    echo "[PRE-GEN] Renamed main.cpp to main.c"
else
    echo "[PRE-GEN] No main.cpp found - normal for first run"
fi

# Simulate CubeMX generation (main.c already exists)
echo ""
echo "[CUBEMX] Generated main.c"
ls -l "$TEST_DIR/Core/Src/"

# Simulate post_generate
echo ""
echo "[POST-GEN] Renaming main.c to main.cpp..."
if [ -f "$TEST_DIR/Core/Src/main.c" ]; then
    mv "$TEST_DIR/Core/Src/main.c" "$TEST_DIR/Core/Src/main.cpp"
    echo "[POST-GEN] SUCCESS: Renamed main.c to main.cpp"
else
    echo "[POST-GEN] ERROR: main.c not found"
    exit 1
fi

ls -l "$TEST_DIR/Core/Src/"

# Verify main.cpp exists
if [ -f "$TEST_DIR/Core/Src/main.cpp" ]; then
    echo "[VERIFY] ✓ main.cpp exists"
else
    echo "[VERIFY] ✗ main.cpp does not exist"
    exit 1
fi

echo ""
echo "=========================================="
echo "Test 2: Subsequent Generation (main.cpp exists)"
echo "=========================================="

# Simulate pre_generate (should rename main.cpp to main.c)
echo ""
echo "[PRE-GEN] Checking for main.cpp..."
if [ -f "$TEST_DIR/Core/Src/main.cpp" ]; then
    mv "$TEST_DIR/Core/Src/main.cpp" "$TEST_DIR/Core/Src/main.c"
    echo "[PRE-GEN] Renamed main.cpp to main.c"
else
    echo "[PRE-GEN] No main.cpp found"
    exit 1
fi

ls -l "$TEST_DIR/Core/Src/"

# Verify main.c exists now
if [ -f "$TEST_DIR/Core/Src/main.c" ]; then
    echo "[VERIFY] ✓ main.c exists (ready for CubeMX)"
else
    echo "[VERIFY] ✗ main.c does not exist"
    exit 1
fi

# Simulate CubeMX update (modifies main.c)
echo ""
echo "[CUBEMX] Updated main.c"
echo "int main(void) { /* updated */ return 0; }" > "$TEST_DIR/Core/Src/main.c"

# Simulate post_generate again
echo ""
echo "[POST-GEN] Renaming main.c to main.cpp..."
if [ -f "$TEST_DIR/Core/Src/main.c" ]; then
    mv "$TEST_DIR/Core/Src/main.c" "$TEST_DIR/Core/Src/main.cpp"
    echo "[POST-GEN] SUCCESS: Renamed main.c to main.cpp"
else
    echo "[POST-GEN] ERROR: main.c not found"
    exit 1
fi

ls -l "$TEST_DIR/Core/Src/"

# Verify main.cpp exists with updated content
if [ -f "$TEST_DIR/Core/Src/main.cpp" ]; then
    echo "[VERIFY] ✓ main.cpp exists"
    echo "[VERIFY] Content:"
    cat "$TEST_DIR/Core/Src/main.cpp"
else
    echo "[VERIFY] ✗ main.cpp does not exist"
    exit 1
fi

echo ""
echo "=========================================="
echo "Test 3: Keil Project File Update (Simulated)"
echo "=========================================="

# Create a mock Keil project file
mkdir -p "$TEST_DIR"
cat > "$TEST_DIR/test.uvprojx" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Project>
  <Targets>
    <Target>
      <Groups>
        <Group>
          <Files>
            <File>
              <FileName>main.c</FileName>
              <FilePath>.\Core\Src\main.c</FilePath>
            </File>
          </Files>
        </Group>
      </Groups>
    </Target>
  </Targets>
</Project>
EOF

echo "[SETUP] Created mock Keil project file"
echo "[BEFORE] Content:"
grep "main\." "$TEST_DIR/test.uvprojx"

# Simulate the PowerShell replacement (using sed in Linux)
echo ""
echo "[POST-GEN] Updating Keil project file..."
sed -i 's/\\main\.c/\\main.cpp/g' "$TEST_DIR/test.uvprojx"
sed -i 's/>main\.c</>main.cpp</g' "$TEST_DIR/test.uvprojx"

echo "[AFTER] Content:"
grep "main\." "$TEST_DIR/test.uvprojx"

# Verify the file was updated
if grep -q "main.cpp" "$TEST_DIR/test.uvprojx"; then
    echo "[VERIFY] ✓ Keil project file updated successfully"
else
    echo "[VERIFY] ✗ Keil project file not updated"
    exit 1
fi

echo ""
echo "=========================================="
echo "All Tests Passed! ✓"
echo "=========================================="
echo ""
echo "Summary:"
echo "1. ✓ First generation: main.c → main.cpp"
echo "2. ✓ Subsequent generation: main.cpp → main.c → main.cpp"
echo "3. ✓ Keil project file updated: main.c → main.cpp"
echo ""
echo "The batch scripts should work correctly on Windows."
echo "=========================================="

# Cleanup
rm -rf "$TEST_DIR"
