# Add Memory Bank Instructions Workflow

You are helping add the memory-bank-instructions.md file to the current project and set up the memory bank system. Follow these steps:

1. Create the `.kilocode/rules/memory-bank` directory if it doesn't exist using `execute_command` with `mkdir -p .kilocode/rules/memory-bank`

2. Download the latest memory-bank-instructions.md file directly using `execute_command` with:

   ```bash
   curl -o .kilocode/rules/memory-bank-instructions.md https://github.com/nalabelle/dotfiles/raw/refs/heads/main/.kilocode/rules/memory-bank-instructions.md
   ```

   This will overwrite the file if it already exists, ensuring you get the most up-to-date version.

3. Check if `.kilocode/rules/memory-bank/brief.md` already exists using `read_file`:
   - If brief.md already exists, skip this step (do not overwrite existing brief)
   - If brief.md doesn't exist, check if the project has a README.md file using `read_file`
   - If README.md exists, create `.kilocode/rules/memory-bank/brief.md` using the README content as a starting point
   - Use `write_to_file` to create the brief with a header like "# Project Brief" followed by the README content
   - If README.md doesn't exist, use `ask_followup_question` to ask the user to describe their project briefly

4. Verify the files were created successfully using `read_file` to check:
   - `.kilocode/rules/memory-bank-instructions.md`
   - `.kilocode/rules/memory-bank/brief.md`

5. Inform the user that:
   - The memory bank instructions have been added to their project
   - The project brief has been created (either from README or user input)
   - They can now use the memory bank system for improved AI assistance
   - They should run "initialize memory bank" to complete the memory bank setup

This workflow makes the memory bank system available in any project where it's run, always using the latest version from the dotfiles repository and creating the foundational brief.md file.
