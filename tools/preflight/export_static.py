"""Export the .blend loaded by Blender's CLI. No geometry generation or retuning."""
import argparse
from pathlib import Path
import sys
import bpy

assert bpy.app.version == (5, 2, 2), bpy.app.version_string
assert bpy.data.filepath, 'Load a saved .blend before invoking this exporter'
parser = argparse.ArgumentParser()
parser.add_argument('--output', required=True)
args = parser.parse_args(sys.argv[sys.argv.index('--') + 1:])
output = Path(args.output).resolve()
assert output.suffix.lower() == '.glb'
output.parent.mkdir(parents=True, exist_ok=True)
bpy.ops.export_scene.gltf(filepath=str(output),
    export_format='GLB', export_yup=True, export_apply=True,
    export_normals=True, export_texcoords=True, export_materials='EXPORT',
    export_animations=False, export_cameras=False, export_lights=False)
print('STATIC_GLB_EXPORTED:', output)
