# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project: リーンなSaaSサービス開発を支える技術 (Lean SaaS Technology)

### Build/Test Commands
- Not yet established - update when build system is implemented
- Expected to follow standard npm/yarn conventions:
  - `npm run dev` - Run development server
  - `npm run build` - Build production assets
  - `npm run test` - Run all tests
  - `npm test -- -t "test name"` - Run single test
  - `npm run lint` - Run linting

### Code Style Guidelines
- **Formatting**: Follow Prettier conventions with 2-space indentation
- **Imports**: Group imports by type (React, libs, components, utils)
- **Naming**: Use camelCase for variables/functions, PascalCase for components/classes
- **Types**: Use TypeScript with strict mode; prefer interfaces for object types
- **Error Handling**: Use try/catch with descriptive error messages
- **Components**: Prefer functional components with hooks over class components
- **State Management**: Use React Query for server state, Context API for global state
- **Documentation**: Document complex functions with JSDoc comments

### Repository Structure
Follow standard Next.js/React conventions when implementing