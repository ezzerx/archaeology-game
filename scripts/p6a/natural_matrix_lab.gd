extends "res://scripts/p6a/soil_foundation_lab.gd"
## Reuse P6A1.5 reset, shader, controls and the untouched P4/P5 game scene.
const FIXTURES := ["Départ · Soil mince", "Matrice nue", "Trajet Chisel contrôlé", "Préparation Bone / Pick", "Interface Clay / Sandstone"]

func _create_profile() -> SoilFoundationProfile:
	return NaturalMatrixProfile.new(block.working_map)

func _ready() -> void:
	super._ready()
	get_window().title = "ArchaeologyGame — P6A1.6 Natural Matrix A/B"

func _controls() -> void:
	super._controls()
	var box := panel.get_child(0)
	box.get_child(0).text = "P6A1.6 / GÉOMÉTRIE A–B"
	buttons[0].text = "A · Matrice actuelle + Soil mince"
	buttons[1].text = "B · Relief naturel + Soil mince"
	fixture_select.clear()
	for title in FIXTURES: fixture_select.add_item(title)

func select_fixture(index: int) -> void:
	fixture = clampi(index, 0, FIXTURES.size() - 1)
	cleared = fixture != 0
	reload()

func show_substrate() -> void:
	select_fixture(1)

func reset_specimen() -> void:
	fixture = 0
	super.reset_specimen()

func reload() -> void:
	super.reload()
	if fixture >= 2: NaturalMatrixFixtures.apply(self, fixture)
	note.text = ["Soil mince identique, relief différent.\nBrush → Clay → Chisel / Pick.",
		"Comparer cuvettes, crête et palier.\nPatine ON/OFF pour lire la forme.",
		"Même trajet et nombre de coups natifs.\nLe creusement reste jouable.",
		"Même zone préparée au Pick natif.\nPlafonds Bone et film conservés.",
		"Coupe témoin à profondeur commune.\nInterfaces réelles, outils actifs."][fixture]
