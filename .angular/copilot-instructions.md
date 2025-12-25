# Angular 21 – Signal-first Coding Instructions

You are an expert Angular 21 developer.
Always generate code following modern Angular best practices.
Avoid legacy patterns.

---

## 1. Angular Version & Architecture

- Target Angular **21+**
- Use **Standalone APIs only**
- Must NOT set `standalone: true` inside Angular decorators. It's the default in Angular v20+.
- DO NOT use NgModule
- DO NOT use class-based state with setters
- DO NOT use RxJS unless explicitly required (e.g., complex async operations, existing Observable APIs)

---

## 2. TypeScript Best Practices

- Use strict type checking
- Prefer type inference when the type is obvious
- Avoid the `any` type; use `unknown` when type is uncertain
- Write functional, maintainable, performant, and accessible code

---

## 3. Dependency Injection

- Always use `inject()` instead of constructor injection

```ts
const http = inject(HttpClient);
const router = inject(Router);
```

- Never write constructors just for DI

---

## 4. State Management – SIGNAL FIRST

### Use Signals for all state

- `signal()`
- `computed()`
- `effect()`
- `input()` / `output()` / `model()`

### Do NOT use:

- `BehaviorSubject`
- `Subject`
- Manual `subscribe()`
- `async` pipe unless wrapping Observable → Signal (use `toSignal()` if needed)

### Rules

- Use signals for local component state
- Use `computed()` for derived state
- Keep state transformations pure and predictable
- Do NOT use `mutate` on signals, use `update` or `set` instead

### Example

```ts
@Component({
  selector: 'app-counter',
  template: `
    <button (click)="increment()">+</button>
    <span>{{ count() }}</span>
  `,
})
export class CounterComponent {
  count = signal(0);
  doubleCount = computed(() => this.count() * 2);

  increment() {
    this.count.update((v) => v + 1);
  }
}
```

---

## 5. Component Design Rules

- Components must be **pure & reactive**
- Keep components small and focused on a single responsibility
- State must be expressed as **signals**
- Logic lives in:
  - component signals
  - signal-based stores
  - services exposing signals
- Set `changeDetection: ChangeDetectionStrategy.OnPush` in `@Component` decorator
- Prefer inline templates for small components
- When using external templates/styles, use paths relative to the component TS file

---

## 6. Inputs & Outputs (NO @Input / @Output)

Use signal-based APIs:

```ts
count = input<number>(0); // Input signal
required = input.required<string>(); // Required input
valueChange = output<number>(); // Output event
modelValue = model<string>(); // Two-way binding
```

Never use:

- `@Input()`
- `@Output()`
- `EventEmitter`

---

## 7. Template Control Flow

Always use **new control flow syntax**:

```html
@if (isLoading()) {
<app-spinner />
} @else { @for (item of items(); track item.id) {
<app-item [item]="item" />
} } @switch (status()) { @case ('loading') { <app-spinner /> } @case ('success') { <app-content /> } @default {
<app-error /> } }
```

Do NOT use:

- `*ngIf`
- `*ngFor`
- `*ngSwitch`

---

## 8. Template Best Practices

- Keep templates simple and avoid complex logic
- Do NOT use `ngClass`, use `class` bindings instead
- Do NOT use `ngStyle`, use `style` bindings instead
- Do not assume globals like (`new Date()`) are available
- Do not write arrow functions in templates (they are not supported)

---

## 9. HTTP & Side Effects

### Fetch data with signals

```ts
const users = signal<User[]>([]);
const loading = signal(false);
const http = inject(HttpClient);

effect(() => {
  loading.set(true);
  firstValueFrom(http.get<User[]>('/api/users'))
    .then((data) => users.set(data))
    .finally(() => loading.set(false));
});
```

- Side effects belong in `effect()`
- Never subscribe manually unless necessary
- Use `toSignal()` to convert Observables to signals when needed

---

## 10. Services Pattern

- Services should expose **signals**, not Observables
- Design services around a single responsibility
- Use the `providedIn: 'root'` option for singleton services
- Use the `inject()` function instead of constructor injection

```ts
@Injectable({ providedIn: 'root' })
export class UserStore {
  private http = inject(HttpClient);
  private usersSig = signal<User[]>([]);

  users = this.usersSig.asReadonly();
  activeUsers = computed(() => this.users().filter((u) => u.active));

  async load() {
    const data = await firstValueFrom(this.http.get<User[]>('/api/users'));
    this.usersSig.set(data);
  }
}
```

---

## 11. Computed State

Always derive data using `computed()`:

```ts
filteredUsers = computed(() => this.users().filter((u) => u.active));

hasActiveUsers = computed(() => this.filteredUsers().length > 0);
```

Never calculate derived state inside templates

---

## 12. Effects Rules

`effect()` is for:

- Logging
- HTTP calls
- Syncing localStorage
- Reacting to signal changes
- Side effects that don't return values

```ts
effect(() => {
  console.log('Count changed:', this.count());
  localStorage.setItem('count', this.count().toString());
});
```

Do NOT mutate state inside `computed()`

---

## 13. Forms

- Prefer **signal-based forms** or Reactive forms
- Avoid Template-driven forms

```ts
name = signal('');
email = signal('');
isValid = computed(() => this.name().length > 2 && this.email().includes('@'));
```

---

## 14. Host Bindings

- Do NOT use the `@HostBinding` and `@HostListener` decorators
- Put host bindings inside the `host` object of the `@Component` or `@Directive` decorator instead

```ts
@Component({
  selector: 'app-button',
  host: {
    '[class.active]': 'isActive()',
    '(click)': 'handleClick()'
  }
})
```

---

## 15. Images & Assets

- Use `NgOptimizedImage` for all static images
- `NgOptimizedImage` does not work for inline base64 images

---

## 16. Accessibility Requirements

- It MUST pass all AXE checks
- It MUST follow all WCAG AA minimums, including focus management, color contrast, and ARIA attributes

---

## 17. Performance Rules

- Use `computed()` for memoization
- Keep signals granular
- Avoid giant global signals
- Implement lazy loading for feature routes

---

## 18. Code Style

- Prefer functional & declarative style
- Small focused components
- Clear naming conventions
- No magic side effects
- Keep code readable and maintainable

---

## 19. Default Assumptions

Unless user explicitly asks:

- Always assume Signal-based solution
- Always assume Standalone components
- Always assume Angular 21+ syntax
- Always use `inject()` for DI
- Always use `input()` / `output()` / `model()`
- Always use new control flow (`@if`, `@for`, `@switch`)
- Avoid RxJS unless necessary

