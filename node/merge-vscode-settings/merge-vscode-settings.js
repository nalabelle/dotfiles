#!/usr/bin/env node

const fs = require('fs');
const CJSON = require('comment-json');

function mergeIntoTarget(target, source) {
  for (const key in source) {
    if (source[key] !== null && typeof source[key] === 'object' && !Array.isArray(source[key]) &&
        target[key] !== null && typeof target[key] === 'object' && !Array.isArray(target[key])) {
      mergeIntoTarget(target[key], source[key]);
    } else {
      target[key] = source[key];
    }
  }
}

// Read command line arguments
const [,, existingSettingsPath, managedSettingsPath, outputPath] = process.argv;

if (!existingSettingsPath || !managedSettingsPath || !outputPath) {
  console.error('Usage: merge-vscode-settings <existing-settings> <managed-settings> <output>');
  process.exit(1);
}

try {
  // Parse JSONC with comments preserved
  const existingText = fs.readFileSync(existingSettingsPath, 'utf8');
  const existingSettings = CJSON.parse(existingText);

  // Parse regular JSON for managed settings
  const managedSettings = JSON.parse(fs.readFileSync(managedSettingsPath, 'utf8'));

  // Merge settings (managed settings take precedence) - modify existing in place to preserve comments
  mergeIntoTarget(existingSettings, managedSettings);

  // Stringify back to JSONC format with comments preserved
  const mergedText = CJSON.stringify(existingSettings, null, 2);

  fs.writeFileSync(outputPath, mergedText);
  console.log('Successfully merged VS Code settings while preserving comments');
} catch (error) {
  console.error('Warning: Failed to merge VS Code settings:', error.message);
  process.exit(1);
}
