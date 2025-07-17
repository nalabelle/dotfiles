#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const scriptPath = path.join(__dirname, '..', 'merge-vscode-settings.js');
const fixturesDir = path.join(__dirname, 'fixtures');

// Test runner
function runTest(testName, testFn) {
  try {
    testFn();
    console.log(`✓ ${testName}`);
  } catch (error) {
    console.error(`✗ ${testName}: ${error.message}`);
    process.exit(1);
  }
}

// Test functions
function testBasicMerge() {
  const tmpDir = fs.mkdtempSync('/tmp/merge-test-');
  const existingFile = path.join(fixturesDir, 'existing-settings.jsonc');
  const managedFile = path.join(fixturesDir, 'managed-settings.json');
  const outputFile = path.join(tmpDir, 'output.jsonc');

  try {
    // Run the merge script
    execSync(`node "${scriptPath}" "${existingFile}" "${managedFile}" "${outputFile}"`, {
      stdio: 'pipe'
    });

    // Verify output exists
    if (!fs.existsSync(outputFile)) {
      throw new Error('Output file was not created');
    }

    // Read and parse the result
    const resultText = fs.readFileSync(outputFile, 'utf8');

    // Verify comments are preserved
    if (!resultText.includes('// User preferences')) {
      throw new Error('Line comments were not preserved');
    }
    if (!resultText.includes('/* Block comment example */')) {
      throw new Error('Block comments were not preserved');
    }
    if (!resultText.includes('// My favorite theme')) {
      throw new Error('Inline comments were not preserved');
    }

    // Parse the JSONC to verify the merge logic
    const CJSON = require('comment-json');
    const result = CJSON.parse(resultText);

    // Verify managed settings take precedence
    if (result["editor.fontSize"] !== 16) {
      throw new Error(`Expected fontSize 16, got ${result["editor.fontSize"]}`);
    }

    // Verify existing settings are preserved when not overridden
    if (result["editor.theme"] !== "dark") {
      throw new Error(`Expected theme "dark", got ${result["editor.theme"]}`);
    }

    // Verify new managed settings are added
    if (result["telemetry.telemetryLevel"] !== "off") {
      throw new Error('New managed setting was not added');
    }

    // Verify all expected keys are present
    const expectedKeys = ["editor.fontSize", "editor.theme", "workbench.colorTheme",
                         "git.autofetch", "git.confirmSync", "telemetry.telemetryLevel",
                         "projectManager.sortList"];
    for (const key of expectedKeys) {
      if (!(key in result)) {
        throw new Error(`Expected key "${key}" not found in result`);
      }
    }

  } finally {
    // Cleanup
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
}

function testInvalidJSON() {
  const tmpDir = fs.mkdtempSync('/tmp/merge-test-');
  const existingFile = path.join(fixturesDir, 'invalid-settings.jsonc');
  const managedFile = path.join(fixturesDir, 'managed-settings.json');
  const outputFile = path.join(tmpDir, 'output.jsonc');

  try {
    // This should fail
    try {
      execSync(`node "${scriptPath}" "${existingFile}" "${managedFile}" "${outputFile}"`, {
        stdio: 'pipe'
      });
      throw new Error('Expected script to fail with invalid JSON');
    } catch (error) {
      // Expected to fail - this is correct behavior
      if (error.status !== 1) {
        throw new Error('Script should exit with status 1 for invalid JSON');
      }
    }

  } finally {
    // Cleanup
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
}

function testMissingFiles() {
  try {
    execSync(`node "${scriptPath}"`, { stdio: 'pipe' });
    throw new Error('Expected script to fail with missing arguments');
  } catch (error) {
    if (error.status !== 1) {
      throw new Error('Script should exit with status 1 for missing arguments');
    }
  }
}

function testNonExistentFiles() {
  const tmpDir = fs.mkdtempSync('/tmp/merge-test-');

  try {
    const nonExistentFile = path.join(tmpDir, 'does-not-exist.json');
    const managedFile = path.join(fixturesDir, 'managed-settings.json');
    const outputFile = path.join(tmpDir, 'output.jsonc');

    try {
      execSync(`node "${scriptPath}" "${nonExistentFile}" "${managedFile}" "${outputFile}"`, {
        stdio: 'pipe'
      });
      throw new Error('Expected script to fail with non-existent input file');
    } catch (error) {
      if (error.status !== 1) {
        throw new Error('Script should exit with status 1 for non-existent file');
      }
    }

  } finally {
    // Cleanup
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
}

// Run all tests
console.log('Running merge-vscode-settings tests...\n');

runTest('Basic merge with comment preservation', testBasicMerge);
runTest('Invalid JSON handling', testInvalidJSON);
runTest('Missing arguments handling', testMissingFiles);
runTest('Non-existent file handling', testNonExistentFiles);

console.log('\n✓ All tests passed!');
