# Custom Element Timing: Why Load Order Doesn't Fix the KaTeX Problem

## The Question

Would it help to define the `math-text` custom element before KaTeX loads, so it exists when Elm renders?

## Why Not

The `_render()` method calls `katex.renderToString()`. If you define the custom element before KaTeX loads, `_render()` fires immediately when Elm inserts `<math-text>` elements — but `katex` would be undefined and it would crash.

You *could* make it work by adding a deferred rendering queue:

- Define the class early
- Have `_render()` check `if (typeof katex === 'undefined') return;`
- After KaTeX loads, find all `<math-text>` elements and trigger re-render

But that's more complex and fragile than the current approach.

## The Right Fix: `_upgradeProperty`

The `_upgradeProperty` pattern (used in `Demo/index.html`) is the standard solution, recommended by Google for custom elements that receive properties from virtual DOM frameworks like Elm.

### The Problem It Solves

When a custom element is defined asynchronously (after a CDN script loads), the framework may have already:

1. Created the element (as `HTMLUnknownElement`)
2. Set properties on the instance (`element.content = "x^2"`)

When `customElements.define()` runs, the element gets "upgraded":

- The constructor runs, resetting internal state (`this._content = ''`)
- The original properties become hidden behind prototype getters/setters
- `connectedCallback` sees empty content

### The Pattern

```javascript
connectedCallback() {
    this._upgradeProperty('content');
    this._upgradeProperty('display');
    this._render();
}

_upgradeProperty(prop) {
    if (this.hasOwnProperty(prop)) {
        let value = this[prop];
        delete this[prop];   // Remove own-property
        this[prop] = value;  // Re-set via prototype setter
    }
}
```

This rescues pre-set values regardless of load order and handles both initial render and subsequent updates correctly.

## Applying This Pattern Elsewhere

Any custom element that:

1. Receives properties from Elm via `Html.Attributes.property`
2. Is defined asynchronously (e.g., after a CDN script loads)

**must** use `_upgradeProperty()` in `connectedCallback` for each property Elm sets. Without this, the element will silently fail to render on initial load.
