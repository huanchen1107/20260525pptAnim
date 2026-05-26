## Overview

Extend the FastAPI UI with a storyboard editing workflow that is safe, reviewable, and fast:

1. Load current YAML
2. Edit YAML directly
3. Validate YAML shape (basic)
4. Save YAML
5. Optionally regenerate from idea/defaults and show a diff
6. Render the slide and review output

## API Additions

- `PUT /api/storyboard/{project}/{slide}`: Save YAML
- `POST /api/storyboard/{project}/{slide}/validate`: Validate YAML (lightweight)
- `POST /api/storyboard/{project}/{slide}/regenerate?dry_run=1`: Produce regenerated YAML without overwriting
- `POST /api/storyboard/{project}/{slide}/apply`: Apply regenerated YAML to file
- `POST /api/render/{project}/{slide}`: Render only one slide (final by default)

## Diff Strategy

- Use unified diff (`difflib.unified_diff`) on server.
- UI shows diff with simple coloring and an "Apply" button.

## Safety

- All writes are allowlisted to `user/<project>/slides/slide-N-storyboard.yml`.
- Validate slide id patterns.
- Persist backups on overwrite: `slide-N-storyboard.yml.bak.<timestamp>`.

