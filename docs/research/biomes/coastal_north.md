# Biome research: `coastal_north`

Status: **draft — owner should skim before art or spawn tables**

Slice 0 trees, forage, and animals must come from this list.

## Ecoregion

- Real-world analogue: Vinland landfall at the tip of Newfoundland’s Great Northern Peninsula — **L’Anse aux Meadows** and the surrounding forest-tundra / boreal coast, facing the Strait of Belle Isle.
- Approximate region: northern Newfoundland / southern Labrador coast, ~51°N.
- Period notes: Norse presence around the early 11th century. Prefer species present then. Post-Columbian and 19th/20th-century introductions are listed under **Do not include**.

The sagas’ grapes and butternuts did **not** grow at this landfall. Archaeology found butternut (`Juglans cinerea`) and more southern woods at the site as **imports from farther south** (Gulf of St. Lawrence / New Brunswick). Those belong to later inland biomes, not this shore.

## Climate

Cold maritime boreal / forest-tundra. Wind, fog, granite, peat and raised bog, long winters. Shore is exposed; spruce and fir behind the strand were historically taller until later European firewood cutting pushed the treeline inland. Game language: cold wind, moss, peat, granite outcroppings.

## Flora (must have sources)

| Role in game | Species (common / scientific) | Notes | Source |
|---|---|---|---|
| Canopy | Balsam fir (`Abies balsamea`) | Grew on and around the site when the Norse arrived. Slice 0 default choppable tree. | Canadian Encyclopedia, L’Anse aux Meadows |
| Canopy | Spruce (`Picea` spp.) | Forests of fir and spruce stood just behind the strand before later cutting. | Great Unsolved Mysteries in Canadian History, “Where is Vinland?” |
| Canopy | Tamarack / larch (`Larix laricina`) | Local “tamarack”; still in bushy clusters on the exposed site. | Same; Canadian Encyclopedia |
| Canopy / edge | White birch (`Betula` spp.) and poplar | Listed among stands on and around the site. | Canadian Encyclopedia |
| Wind-stunted | Tuckamore (wind-crippled fir/spruce) | Visual language for the shore edge, not a separate species. | Newfoundland boreal coast (see also Parks Canada site descriptions) |
| Shrub | Juniper, dwarf birch, willow, alder | Open-plain and stream-edge cover. | “Where is Vinland?”; Robertson peat study (Myrica–Betula along streams) |
| Bog / peat | Sphagnum, sedges (`Carex`, `Eriophorum`), sweet gale (`Myrica`) | Raised bog and slope fen. Ground texture, not choppable. | Robertson 1970s peat analysis, LAM NHS |
| Forage | Bakeapple / cloudberry (`Rubus chamaemorus`) | Local name “bake apple”; abundant in raised bog. Slice 0 forage. | “Where is Vinland?” |
| Forage | Blueberry (`Vaccinium` spp.) | Low bushes on the ground cover. Slice 0 forage. | “Where is Vinland?” |
| Forage | Cranberry (`Vaccinium` / related bog cranberry) | Named with blueberry on the site cover. | “Where is Vinland?” |
| Do not spawn here | Butternut, wild grape, linden, elm, beech, hemlock | Found as **carried** southern material, not local canopy. Save for river-valley / further south. | Canadian Encyclopedia; Wallace / LAM interpretation |

## Fauna (must have sources)

Newfoundland’s native land-mammal list is short. **Caribou**, not white-tailed deer, make the trails on this coast.

| Role in game | Species | Notes | Source |
|---|---|---|---|
| Trail-makers | Woodland caribou (`Rangifer tarandus`) | Native; dung fungi at LAM associated with caribou. Slice 0 “deer trails” are **caribou trails**. | NL Wildlife mammal list; PNAS 2019 LAM paper (`Sporormiella`) |
| Prey / atmosphere | Arctic hare (`Lepus arcticus`) | Native hare. | NL Wildlife; Wikipedia list of Newfoundland mammals (native) |
| Prey / atmosphere | Beaver, muskrat | Native rodents. | NL Wildlife |
| Threat (later slices) | Black bear (`Ursus americanus`) | Native. | NL Wildlife |
| Threat (later slices) | Newfoundland wolf (`Canis lupus beothucus`) | Present in the 11th century; later extirpated. Use wolf, not coyote. | NL Wildlife (extirpated wolf); mammal lists |
| Other carnivores | Red fox, Canada lynx, marten, otter | Native; low-frequency atmosphere. | NL Wildlife |
| Shore / sea | Seals, whales, walrus; Atlantic fish | LAM was a resource station facing marine hunting routes. | Canadian Encyclopedia (marine / Strait of Belle Isle context) |

## Do not include

These are wrong for 11th-century insular Newfoundland:

- **Moose** — introduced 1878 and 1904 (NL Wildlife; Heritage NL moose paper)
- **Coyote** — arrived 1985
- **Snowshoe hare** — introduced ~1860 (arctic hare is the native one)
- **Red squirrel, chipmunk, mink (as wild), deer mouse** — introductions
- White-tailed deer (not native here)
- Palms, apples as orchard trees, generic fantasy berries
- Grapes and butternut *as local plants* (they are why Vinland was named, but they grew farther south — later biomes)

## Slice 0 spawn table (so art and code have one list)

Use these and nothing else until this file is revised:

- Trees to chop: balsam fir, spruce (standing or fallen)
- Ground: moss/peat, bog, low blueberry/cranberry bushes
- Rocks: granite as objects on the moss, not painted into the floor
- Clutter: sphagnum cushions, fir/spruce needles, short fallen branches (not deciduous leaves)
- Forage pickups: bakeapple, blueberry
- Path: caribou trail inland, away from water
- Atmosphere: three arctic hares on the moss (look-don’t-touch; off the trail)
- No wolves or bears in slice 0 (named here so slice 1 does not invent them)

## Sources

1. Parks Canada / Canadian Encyclopedia, “L’Anse aux Meadows” — https://thecanadianencyclopedia.ca/en/article/lanse-aux-meadows
2. Great Unsolved Mysteries in Canadian History, “Where is Vinland?” (site vegetation, bakeapples, blueberries, cranberries, fir/spruce) — https://canadianmysteries.ca/sites/vinland/lanseauxmeadows/site/indexen.html
3. Alexander Robertson, botanical-chemical peat analysis, L’Anse aux Meadows NHS (bog, sphagnum, Myrica, fossil trees)
4. “New horizons at L’Anse aux Meadows,” *PNAS* 2019 — https://doi.org/10.1073/pnas.1907986116 (caribou dung fungi)
5. Newfoundland & Labrador Wildlife, mammals table — https://www.gov.nl.ca/fal/wildlife/all-species/mammals/ (native vs exotic; moose exotic; wolf extirpated)
6. Heritage NL, introduction of moose to Newfoundland (1878 / 1904) — https://heritagenl.ca/wp-content/uploads/2020/05/19-Introduction-of-Moose-to-the-Island-of-Newfoundland.pdf
