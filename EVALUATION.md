# Evaluation & Contracts

This document contains objective grading criteria and specific verification contracts for tasks defined in `PLANS.md`.

## Grading Criteria
- **Functionality**: Must seamlessly maintain context, update documents accurately, and support agent continuity over multiple sessions.
- **Code Quality**: APM paths, sync protocols, and standard conventions must stay intact. No generic or hallucinated paths.
- **Testing**: Can be verified by running `deploy.sh` and ensuring IDEs successfully recognize the installed skills without errors.

## Active Sprint Contracts
### [Extract Context-Harness to GitHub]
- **Verification Method**: `apm install` succeeds and correctly resolves `fantasy-cc/context-harness` from GitHub.
- **Acceptance Threshold**: The APM lockfile and `.github/skills/` reflect the new remote repository path.

## Evaluation Log
- [2026-03-26] - [Extract Context-Harness to GitHub] - [Grade: Pass] - [Skill successfully extracted to separate Git repo, published, and linked via APM.]
