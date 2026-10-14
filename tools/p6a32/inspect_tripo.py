"""Preserve and inspect Antoine's Tripo source in Blender; render real geometry."""
from pathlib import Path
import json, math, sys
import bpy
from mathutils import Vector

root=Path(__file__).resolve().parents[2]
out=root/'work/p6a32/tripo-inspect';out.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
source=Path(sys.argv[sys.argv.index('--')+1]) if '--' in sys.argv else root/'art/source/p6a32/b17-tripo-original.glb'
bpy.ops.import_scene.gltf(filepath=str(source))
models=[obj for obj in bpy.context.scene.objects if obj.type=='MESH']
points=[obj.matrix_world @ v.co for obj in models for v in obj.data.vertices]
lo=Vector(tuple(min(p[i] for p in points) for i in range(3)))
hi=Vector(tuple(max(p[i] for p in points) for i in range(3)))
center=(lo+hi)/2;size=hi-lo
report={'blender':bpy.app.version_string,'bounds':[list(lo),list(hi)],'meshes':[],'images':[]}
for obj in models:
    report['meshes'].append({'name':obj.name,'vertices':len(obj.data.vertices),'triangles':sum(len(p.vertices)-2 for p in obj.data.polygons),'uv_layers':len(obj.data.uv_layers),'materials':[m.name for m in obj.data.materials]})
for im in bpy.data.images:
    if im.type=='IMAGE':report['images'].append({'name':im.name,'size':list(im.size)})
(out/'blender-inspect.json').write_text(json.dumps(report,indent=2))
bpy.ops.wm.save_as_mainfile(filepath=str(out/'b17-tripo-inspection.blend'))
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=8;scene.cycles.use_denoising=False
scene.render.resolution_x=640;scene.render.resolution_y=400;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG'
scene.world=bpy.data.worlds.new('Neutral inspection world')
scene.view_settings.view_transform='Standard'
world=scene.world;world.use_nodes=True
world.node_tree.nodes['Background'].inputs['Color'].default_value=(.35,.35,.35,1)
world.node_tree.nodes['Background'].inputs['Strength'].default_value=.7
for offset,energy,scale in [((-.3,-.5,1.5),450,1.0),((.5,.3,1.0),220,1.2)]:
    bpy.ops.object.light_add(type='AREA',location=center+Vector(offset)*max(size))
    lamp=bpy.context.object;lamp.data.energy=energy;lamp.data.shape='DISK';lamp.data.size=max(size)*scale
    lamp.rotation_euler=(center-lamp.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=center+Vector((0,0,2))*max(size))
camera=bpy.context.object;camera.data.type='ORTHO';camera.data.ortho_scale=max(size.x,size.z*1.6)*1.16;scene.camera=camera
for name,offset in [('front',(0,-2,0)),('angled',(0,-1.8,.7)),('side',(1.8,-.5,.4))]:
    camera.location=center+Vector(offset)*max(size)
    camera.rotation_euler=(center-camera.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath=str(out/(name+'.png'))
    bpy.ops.render.render(write_still=True)
print(json.dumps(report))
