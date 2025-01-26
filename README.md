# Automatic Logistic Chests

Automatically configures item requests and inserter conditions for logistic chests, including passive provider, active provider, storage, requester, and buffer chests.

## How It Works

1. **Place a Crafting Machine**: Start by placing a crafting machine, such as an assembling machine or furnace, and select a valid recipe.
2. **Set Up Inserters**: Connect the machine with inserters for both input and output as required.
3. **Add Logistic Chests**: Place the appropriate logistic chests (e.g., requester, provider, storage, or buffer). The mod automatically configures chests only at their initial placement if the machine and inserters are already set up.
4. **Refresh Chests Manually as Needed**: Use the manual refresh shortcuts to update chest requests or clear unused filters when necessary.

## Logistic Chest Behavior

- **Passive and Active Provider Chests**: Configures inserter logistic network conditions to supply items when required.
- **Storage Chests**: Sets inserter logistic network conditions and applies a storage filter on the chest.
- **Requester Chests**: Automatically adds item requests based on the crafting machine's requirements.
- **Buffer Chests**: Configures both item requests and inserter logistic network conditions based on the setup's needs.

## Settings

### Map Settings

- **Send Message When All Refreshed**: Display a chat message after refreshing all logistic chests (default: true).
- **Only Admins Can Refresh All**: Limit the ability to refresh all logistic chests to admins (default: true).
- **Maximum Inserter Range**: Set the maximum range of modded inserters (default: 2, min: 1, max: 100).
- **Disable Inserters**: Disable inserters when the provide threshold is reached (default: true).
- **Provide Stack Size Modifier**: Adjust the multiplier for the provided stack size (default: 1, min: 0.1, max: 100).
- **Request Stack Size Modifier**: Adjust the multiplier for the requested stack size (default: 1, min: 0.1, max: 100).
- **Trash Unrequested Items**: Enable the 'Trash unrequested' option when requesting items (default: true).
- **Request From Buffer Chests**: Enable the 'Request from buffer chests' option for requester chests (default: false).
- **Ingredient Integrations**: Configure custom ingredient integrations for specific entity types. Refer to the mod description for details on the exact format (default: artillery-turret=artillery-shell;rocket-silo=satellite).
- **Product Integrations**: Configure custom product integrations for specific entity types. Refer to the Integration Format section below for details (default: `rocket-silo=space-science-pack`).

### Per-Player Settings

- **Receive a message when refreshing a logistic chest**: Receive a chat message when a selected logistic chest is refreshed (default: true).

## Controls

- **Refresh Selected Logistic Chest**: Shortcut to refresh a single logistic chest and its inserters (default: SHIFT + R).
- **Refresh All Logistic Chests**: Shortcut to refresh all logistic chests and their inserters (default: CONTROL + R).

## Integration Format

The mod allows you to customize the automatic configuration of logistic chests by specifying **Ingredient Integrations** and **Product Integrations**.
If an entity is **not** specified in the custom integrations, the mod defaults to the standard recipe-based configuration.

- **Format**: `entity-type=item[:quality],another-item[:quality];other-entity=item2`.
  - Use **semicolons** (`;`) to separate multiple entity definitions.  
    Example: `entity1=item1;entity2=item2`.
  - Use **commas** (`,`) to list multiple items for the same entity.  
    Example: `entity=item1,item2`.
  - The optional `:quality` part specifies item quality (e.g., `uncommon`, `rare`, `epic`, `legendary`, ...) and defaults to `normal` if omitted.

**Note**: Some of the examples below do not make sense gameplay-wise but are included to demonstrate the format.

### Ingredient Integrations

This setting determines which items requester chests will request for specific entities.

**Examples:**

- **Single Ingredient:**
  To have requester chests supply **coal** to furnaces:
  ```
  furnace=coal
  ```

- **Multiple Ingredients:**
  If you want requester chests to supply **iron-plate** and **copper-plate** to assembling machines:
  ```
  assembling-machine=iron-plate,copper-plate
  ```

- **With Quality Specification:**
  To request **iron-plate** of `epic` quality and **copper-plate** of `rare` quality for assembling machines:
  ```
  assembling-machine=iron-plate:epic,copper-plate:rare
  ```

### Product Integrations

This setting determines which items provider chests will offer from specific entities.

**Examples:**

- **Single Product:**
  To have provider chests offer **space-science-pack** from rocket silos:
  ```
  rocket-silo=space-science-pack
  ```

- **With Quality Specification:**
  To provide **space-science-pack** of `legendary` quality from rocket silos:
  ```
  rocket-silo=space-science-pack:legendary
  ```

### Combined Example

For a comprehensive setup where:
- Furnaces request **coal**,
- Assembling machines request **iron-plate:epic** and **copper-plate:rare**,
- Rocket silos provide **space-science-pack:legendary**,

You can configure:
```
**Ingredient Integrations:**
furnace=coal;assembling-machine=iron-plate:epic,copper-plate:rare

**Product Integrations:**
rocket-silo=space-science-pack:legendary
```

## FAQ

### Why don’t requests update automatically when recipes change or are removed?

The mod prioritizes simplicity and performance. It does not continuously monitor recipe changes or dynamically update chest requests to avoid unnecessary complexity. This design keeps the mod efficient and lightweight.

To clear or refresh requests, use the **Refresh Selected Logistic Chest** or **Refresh All Logistic Chests** shortcuts.

### How do I update or clear requests when recipes change or are removed?

When you change or remove a recipe from a crafting machine, existing requests for its components will remain until manually refreshed. To update or clear these requests:

- Use **Refresh Selected Logistic Chest** to update a specific chest.
- Use **Refresh All Logistic Chests** to refresh your entire setup.

### Why do Ingredient or Product Integrations not work?

If your Ingredient or Product Integrations don’t behave as expected, ensure that:

1. You’ve used the correct format described in the **Integration Format** section of the mod description.  
   - Remember to separate entities with semicolons (`;`) and items with commas (`,`), and use the optional `:quality` specifier if needed.
2. The entity names and item names match the in-game definitions exactly, including case sensitivity.
3. If specifying quality, you’ve used a valid quality level (e.g., `epic`, `legendary`) or verified that it defaults to `normal` if omitted.

Refer to the **Integration Format** section in the mod description for full details and examples.

### Can this mod handle dynamic setups?

This mod works best for static setups like malls or predefined blueprints. It is designed to provide initial configuration and manual adjustments rather than continuously adapting to changes in dynamic environments.

If you use the mod in dynamic setups, you will need to manually refresh chests when changes occur. Full automation for such setups is outside the mod's scope, as it focuses on maintaining simplicity and performance.

### What’s the difference between static and dynamic setups?

- **Static Setups**: These are stable configurations, such as preplanned blueprints or mall designs, where recipes and layouts don’t frequently change. The mod is optimized for these cases, requiring minimal interaction after the initial setup.
- **Dynamic Setups**: These are setups where machines, recipes, or logistics are frequently altered. While the mod can be used in such scenarios, manual refreshes are required for updates.

## Inspiration

This mod is inspired by the [AutomaticLogisticChest](https://mods.factorio.com/mod/AutomaticLogisticChest) mod by [Hideaki](https://mods.factorio.com/user/Hideaki).
