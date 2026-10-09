"""PREFLIGHT ONLY. Regenerate a metric axis/normal/material probe, never game art."""
from pathlib import Path
import bpy

assert bpy.app.version == (5, 2, 2), bpy.app.version_string
root = Path(__file__).resolve().parents[2]
source = root / 'art/source/preflight'
source.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.context.scene.unit_settings.system = 'METRIC'
bpy.context.scene.unit_settings.scale_length = 1.0
bpy.context.preferences.filepaths.save_version = 0

def material(name, color, roughness):
    mat = bpy.data.materials.new(name)
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1)
    bsdf.inputs['Roughness'].default_value = roughness
    bsdf.inputs['Metallic'].default_value = 0
    mat.diffuse_color = (*color, 1)
    return mat

neutral = material('probe_neutral', (.32, .32, .32), .8)
top = material('probe_top', (.8, .55, .1), .25)
red = material('probe_x_red', (.8, .03, .03), .6)
green = material('probe_y_green', (.03, .8, .03), .6)
blue = material('probe_z_blue', (.03, .03, .8), .6)
origin = bpy.data.objects.new('PREFLIGHT_ONLY', None)
bpy.context.collection.objects.link(origin)
origin.location = (.3, .2, 0)

def box(name, size, location, mat):
    bpy.ops.mesh.primitive_cube_add(size=1)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    obj.parent = origin
    obj.location = location
    obj.data.materials.append(mat)
    return obj

body = box('probe_body', (.2, .1, .05), (0, 0, .025), neutral)
body.data.materials.append(top)
for face in body.data.polygons:
    face.material_index = int(face.normal.z > .9)
box('axis_x', (.02, .02, .02), (.16, 0, .01), red)
box('axis_y', (.03, .03, .03), (0, .14, .015), green)
box('axis_z', (.04, .04, .04), (0, 0, .12), blue)
bpy.ops.wm.save_as_mainfile(filepath=str(source / 'pipeline_probe.blend'))
print('PREFLIGHT_PROBE_SAVED: 4 boxes, 48 triangles, metric Z-up')
