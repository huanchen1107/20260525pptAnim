const fs = require('fs');
const path = require('path');
// Since standard node doesn't have a YAML parser built-in, we use a basic regex parser for our simple schema.
// Our schema:
// scenes:
//   - id: scene_01
//     time: 1.0
//     label: "Title: 全指南"
function parseSimpleYaml(content) {
  const lines = content.split('\n');
  const scenes = [];
  let currentScene = null;
  
  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed.startsWith('- id:')) {
      if (currentScene) scenes.push(currentScene);
      currentScene = { id: trimmed.replace('- id:', '').trim() };
    } else if (currentScene && trimmed.includes(':')) {
      const parts = trimmed.split(':');
      const key = parts[0].trim();
      const value = parts.slice(1).join(':').trim().replace(/^"/, '').replace(/"$/, '');
      if (key === 'time') {
        currentScene.timeSecs = parseFloat(value);
      } else {
        currentScene[key] = value;
      }
    }
  }
  if (currentScene) scenes.push(currentScene);
  return scenes;
}

try {
  const inputFile = process.argv[2];
  if (!fs.existsSync(inputFile)) {
    console.log("[]");
    process.exit(0);
  }
  const content = fs.readFileSync(inputFile, 'utf-8');
  const result = parseSimpleYaml(content);
  console.log(JSON.stringify(result));
} catch (e) {
  console.log("[]");
}
