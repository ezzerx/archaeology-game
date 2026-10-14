"""Keep the original GLB intact; fit and reduce a bounded real Tripo skull pilot."""
from pathlib import Path
import json
import numpy as np
import bpy,bmesh

root=Path(__file__).resolve().parents[2]
cfg=json.loads((root/'tools/p6a32/b17_skull_fit.json').read_text())
data=np.load(root/'work/p6a32/skull-fit.npz')
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.preferences.filepaths.save_version=0
bpy.ops.import_scene.gltf(filepath=str(root/'art/source/p6a32/b17-tripo-original.glb'))
obj=next(o for o in bpy.context.scene.objects if o.type=='MESH')
co=np.empty(len(obj.data.vertices)*3,dtype=np.float32);obj.data.vertices.foreach_get('co',co);co=co.reshape(-1,3)
source=np.column_stack((co[:,0],co[:,2],-co[:,1]))
assert source.shape==data['original'].shape and np.max(np.abs(source-data['original']))<1e-6,'Importer vertex ordering/convention changed; do not silently misfit anatomy.'
fit=data['fitted'];blender_co=np.column_stack((fit[:,0],-fit[:,2],fit[:,1]))
obj.data.vertices.foreach_set('co',blender_co.ravel())
bm=bmesh.new();bm.from_mesh(obj.data);bm.verts.ensure_lookup_table();bm.faces.ensure_lookup_table()
remove=[face for face in bm.faces if max(float(source[v.index,0]) for v in face.verts)>=cfg['source_x_cut']]
bmesh.ops.delete(bm,geom=remove,context='FACES')
bmesh.ops.delete(bm,geom=[v for v in bm.verts if not v.link_faces],context='VERTS')
bm.normal_update();bm.to_mesh(obj.data);bm.free();obj.data.update()
obj.name='B17_Tripo_Skull';bpy.context.view_layer.objects.active=obj
before=sum(len(p.vertices)-2 for p in obj.data.polygons)
mod=obj.modifiers.new('Skull source reduction','DECIMATE');mod.ratio=cfg['decimate_ratio']
bpy.ops.object.modifier_apply(modifier=mod.name)
for p in obj.data.polygons:p.use_smooth=True
for im in bpy.data.images:
    if im.type=='IMAGE' and max(im.size)>cfg['texture_size']:
        im.scale(cfg['texture_size'],cfg['texture_size']);im.pack()
obj.data.calc_loop_triangles()
co=np.empty(len(obj.data.vertices)*3,dtype=np.float32);obj.data.vertices.foreach_get('co',co);co=co.reshape(-1,3)
faces=np.array([t.vertices[:] for t in obj.data.loop_triangles],dtype=np.int32)
godot=np.column_stack((co[:,0],co[:,2],-co[:,1]))
np.savez(root/'work/p6a32/skull-runtime.npz',vertices=godot,faces=faces)
bpy.ops.wm.save_as_mainfile(filepath=str(root/'art/source/p6a32/b17-tripo-skull-fitted.blend'))
bpy.ops.export_scene.gltf(filepath=str(root/'assets/p6a32/b17_tripo_skull.glb'),export_format='GLB',export_yup=True)
report={'blender':bpy.app.version_string,'source_skull_triangles':before,'runtime_triangles':len(faces),'texture_size':cfg['texture_size'],'bounds':[godot.min(0).tolist(),godot.max(0).tolist()]}
(root/'work/p6a32/skull-budget.json').write_text(json.dumps(report,indent=2));print(json.dumps(report))
