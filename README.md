# Automatic Logistic Chests

Automatically configures item requests and inserter conditions. Supports all logistic chests: passive provider, active provider, storage, requester, and buffer.

### How It Works

1. **Place a Crafting Machine**: Start by placing a crafting machine, such as an assembling machine or furnace, and select a valid recipe.
2. **Place Inserters**: Connect the machine with inserters for both input and output as needed.
3. **Place Logistic Chests**: Add the appropriate logistic chests (e.g., requester, provider, storage, or buffer). The mod automatically configures the chests only when they are placed and the machine and inserters are already set up.
   - Alternatively, you can manually refresh chests using the provided controls (see Controls section).

### Logistic Chest Behavior

- **Passive and Active Provider Chests**: Configures inserter logistic network conditions to supply items when required.
- **Storage Chests**: Configures inserter logistic network conditions and additionally sets a storage filter on the chest.
- **Requester Chests**: Automatically adds item requests based on the crafting machine's requirements.
- **Buffer Chests**: Both set item requests and inserter logistic network conditions, adapting to the setup's needs.

### Settings

#### Map Settings

- **Enable Artillery Turret Integration**: Enable requesting and providing artillery shells (default: true).
- **Enable Rocket Silo Integration**: Enable requesting satellites and providing space science packs (default: true).
- **Maximum Inserter Range**: Set the maximum range of modded inserters (default: 2, min: 1, max: 100).
- **Send Message When All Refreshed**: Send a chat message when all logistic chests are refreshed (default: true).
- **Only Admins Can Refresh All**: Require admin rights to refresh all logistic chests (default: true).
- **Provide Stack Size Modifier**: Multiplier for the provided stack size (default: 1, min: 0.1, max: 100).
- **Request Stack Size Modifier**: Multiplier for the requested stack size (default: 1, min: 0.1, max: 100).
- **Disable Inserters**: Disable inserters when the provide threshold is reached (default: true).
- **Trash Unrequested Items**: Enable the 'Trash unrequested' option when requesting items (default: true).

#### Per-Player Settings

- **Receive Message When Selected Refreshed**: Receive a chat message when a selected logistic chest is refreshed (default: true).

### Controls

- **Refresh Selected Logistic Chest**: Shortcut to refresh a single logistic chest and its inserters (default: SHIFT + R).
- **Refresh All Logistic Chests**: Shortcut to refresh all logistic chests and their inserters (default: CONTROL + R).

### Inspiration

Inspired by the [AutomaticLogisticChest](https://mods.factorio.com/mod/AutomaticLogisticChest) mod by [Hideaki](https://mods.factorio.com/user/Hideaki).
