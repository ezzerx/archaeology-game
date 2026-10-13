"""Blender-only technical probe reduction; this is not the Tripo source asset."""
from pathlib import Path
import json
import bpy

root=Path(__file__).resolve().parents[2]
source=root/'assets/p6a32/b17_binding_probe.glb'
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=str(source))
report=[]
for obj in list(bpy.context.scene.objects):
    if obj.type!='MESH': continue
    bpy.context.view_layer.objects.active=obj
    before=sum(len(p.vertices)-2 for p in obj.data.polygons)
    mod=obj.modifiers.new('Bounded technical probe reduction','DECIMATE')
    mod.ratio=.20
    bpy.ops.object.modifier_apply(modifier=mod.name)
    for poly in obj.data.polygons: poly.use_smooth=True
    report.append({'part':obj.name,'source_triangles':before,'runtime_triangles':sum(len(p.vertices)-2 for p in obj.data.polygons)})
bpy.ops.wm.save_as_mainfile(filepath=str(root/'work/p6a32/b17-binding-probe.blend'))
bpy.ops.export_scene.gltf(filepath=str(source),export_format='GLB',export_yup=True)
(root/'work/p6a32/probe-budget.json').write_text(json.dumps({'blender':bpy.app.version_string,'parts':report},indent=2))
print(json.dumps(report))
