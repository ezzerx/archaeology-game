class_name PreparationRules
extends RefCounted
## Provisional P5 progression thresholds. Excavation tuning belongs to P4/P7.

const DETECTED := 10.0
const EXPOSED := 50.0
const PREPARED_EXPOSURE := 80.0
const PREPARED_CLEANLINESS := 80.0
const VERTEBRATE_EXPOSURE := 5.0
const THEROPOD_SPINE := 15.0
const THEROPOD_LIMB := 10.0
const THEROPOD_SKULL := 35.0
const SKULL_OBJECTIVE_EXPOSURE := 60.0
const SKULL_OBJECTIVE_CLEANLINESS := 50.0
const SKELETON_OBJECTIVE := 60.0
const FRAGMENT_EXPOSURE := 90.0
const FRAGMENT_DETECTED := 10.0
const QUALITY_EXPOSURE := 95.0
const QUALITY_CLEANLINESS := 95.0
const CLASSIFICATIONS := ["Unknown", "Vertebrate remains", "Possible Theropod", "Likely small theropod"]
const OBJECTIVES := ["Prepare the skull", "Reveal 60 % of the skeleton", "Recover both fragments"]

static func component_state(exposure: float, cleanliness: float) -> String:
	if exposure >= PREPARED_EXPOSURE and cleanliness >= PREPARED_CLEANLINESS: return "Prepared"
	if exposure >= EXPOSED: return "Exposed"
	if exposure >= DETECTED: return "Detected"
	return "Hidden"

static func fine_preparation(exposure: float, cleanliness: float) -> bool:
	return exposure >= QUALITY_EXPOSURE and cleanliness >= QUALITY_CLEANLINESS

static func classification(previous: int, overall: float, components: Array[float]) -> int:
	var stage := previous
	if overall >= VERTEBRATE_EXPOSURE or components.max() >= DETECTED: stage = maxi(stage, 1)
	if components[1] >= THEROPOD_SPINE and components[3] >= THEROPOD_LIMB: stage = maxi(stage, 2)
	if stage >= 2 and components[0] >= THEROPOD_SKULL: stage = 3
	return stage

static func objectives(skull_exposure: float, skull_cleanliness: float, overall: float, recovered: int) -> Array[bool]:
	return [skull_exposure >= SKULL_OBJECTIVE_EXPOSURE and skull_cleanliness >= SKULL_OBJECTIVE_CLEANLINESS,
		overall >= SKELETON_OBJECTIVE, recovered == RecoverableFragmentField.COUNT]
