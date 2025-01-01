# Automatic Logistic Chests
## Automatically Configures Provider, Storage, and Requester Chests

When a logistic chest is placed, the mod determines which inserters insert into or extract from valid crafting machines. Based on the ingredients and products, a logistic request, filter, or inserter condition is automatically set.

Simply place any machine with a valid recipe (e.g., assembling machine, furnace, etc.). Modded machines are supported as well!
- Connect a requester chest to the machine through an inserter. The requester chest will be configured to request all necessary ingredients.
- Connect a passive provider chest (or an active provider chest, etc.) to the machine with another inserter. 
  - The inserter will be connected to the logistic system, and its condition will be set to activate only when less than a stack of the product is available.
  - If the chest is a storage chest, its storage filter will also be configured, and the inserter will be set up with the appropriate condition.

This mod is inspired by the [AutomaticLogisticChest](https://mods.factorio.com/mod/AutomaticLogisticChest) mod by [Hideaki](https://mods.factorio.com/user/Hideaki).
