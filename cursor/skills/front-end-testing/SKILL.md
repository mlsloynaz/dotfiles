---
name: Angular 14+ Frontend Testing Expert (Jest & Vitest)
description: Provides expert guidance and code examples for implementing unit and integration tests in modern Angular 14+ applications using both Jest and Vitest test runners, focusing on best practices with Angular Testing Library.
author: Claude Code
---

# Angular 14+ Frontend Testing Skills

This skill equips the agent with specialized knowledge for testing modern Angular (v14+) applications. It covers unit and integration testing of components, services, pipes, and directives using both **Jest** (a widely adopted runner) and **Vitest** (a faster, modern alternative built on Vite with native ESM support).

## Core Testing Principles
*   **Adhere to the Arrange-Act-Assert (AAA) pattern** for structuring tests.
*   **Focus on testing user behavior** rather than implementation details, often using the [Angular Testing Library](https://testing-library.com).
*   **Utilize Standalone components** and modern Angular features (`inject()`, signal inputs) in examples.
*   **Ensure tests are isolated** and don't depend on each other.

## Key Skill Areas and Code Generation

### 1. Component Testing (Unit & Integration)

*   **Setup:** Use `TestBed` or `render` from `[@testing-library/angular](https://testing-library.com)` to create and interact with components in a simulated DOM environment ([JSDOM](https://github.com) with Vitest/Jest or full browser with Vitest browser mode).
*   **Interactions:** Simulate user events like clicks, input changes, and form submissions using the `[@testing-library/user-event](https://testing-library.com)` library.
*   **Assertions:** Employ custom matchers from `[@testing-library/jest-dom](https://testing-library.com)` to write readable assertions (e.g., `expect(element).toHaveTextContent(...)`, `expect(element).toBeInTheDocument()`).

### 2. Service & Logic Testing

*   **Mocking Dependencies:** Use Jest's (`jest.fn()`, `jest.spyOn()`, `jest.mock()`) or Vitest's (`vi.fn()`, `vi.spyOn()`, `vi.mock()`) powerful mocking utilities to isolate services and their dependencies (like the `HttpClient`).
*   **Asynchronous Operations:** Handle `Observables`, `Promises`, `async/await`, and Angular's `fakeAsync` / `tick()` utilities.

### 3. Setup and Configuration Guidance

*   **Jest Configuration:** Guide on setting up `jest.config.js(ts)` with `ts-jest` for Angular projects.
*   **Vitest Configuration:** Provide `vite.config.ts` or `vite.config.mts` setup, leveraging the `@analogjs/platform` builder for seamless integration in Angular CLI projects.
*   **Runner Comparison:** Advise on the benefits of each runner:
    *   **Vitest** for speed, native ESM support, and a better developer experience with instant watch mode.
    *   **Jest** for its mature ecosystem and broader editor support.

## Output Format
When asked to write a test, use the following structure:
1.  **Explanation:** Briefly describe the testing strategy and key concepts used.
2.  **Code Snippet:** Provide a clean, modern TypeScript code block for the test.
3.  **Command:** Suggest the relevant command to run the test (e.g., `npm test`, `npx vitest`, or `ng test` if configured correctly).

## Examples
Reference `examples/component-testing.md` and `examples/service-mocking.md` for specific implementation patterns.
